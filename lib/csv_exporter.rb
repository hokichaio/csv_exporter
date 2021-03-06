require 'csv'
require 'nkf'
require 'i18n'

I18n.load_path += Dir[
  File.join(File.dirname(__FILE__), 'locale', '*.yml')
]

class CsvExporter

  def self.export_by_line(data, headers, options = {})
    options[:nkf] ||= "-s"
    options[:charset] ||= "Shift_JIS"
    headers["Cache-Control"] ||= "no-cache"
    headers["Transfer-Encoding"] = "chunked"
    headers.merge!('Content-Type' => "text/csv; charset=#{options[:charset]}",'Content-Disposition' => "attachment; filename=\"#{data.model}_#{Time.now}.csv\"")
    return Rack::Chunked::Body.new(Enumerator.new do |y|
      begin
        options[:include_column_names] ||= true
        data.find_each do |row|
          #create column name
          if options[:include_column_names]
            human_name = []
            if options[:structure].present?
              options[:structure].each do |s|
                human_name << I18n.t(s, :scope => [:activerecord, :attributes, data.model.table_name.singularize], :default => s)
              end
            else
              row.attributes.keys.each do |k|
                human_name << I18n.t(k, :scope => [:activerecord, :attributes, data.model.table_name.singularize], :default => k)
              end
              if options[:append].present?
                options[:append].each do |a|
                  human_name << I18n.t(a, :scope => [:activerecord, :attributes, data.model.table_name.singularize], :default => a)
                end
              end
            end
            options[:include_column_names] = false
            y << NKF::nkf(options[:nkf], CSV.generate_line(human_name))
          end
          #create data
          output_row = []
          if options[:structure].present?
            options[:structure].each do |s|
              begin
                output_row << s.split(".").inject(row){|obj, met| obj.send(met)}
              rescue
                output_row << ""
              end
            end
          else
            output_row = row.attributes.values
            if options[:append].present?
              options[:append].each do |a|
                output_row << a.split(".").inject(row){|obj, met| obj.send(met)}
              end
            end
          end
          y << NKF::nkf(options[:nkf], CSV.generate_line(output_row))
        end
      rescue => e
        y << NKF::nkf(options[:nkf], I18n.t("csv_exporter.file_corrupted") + "\n")
        y << "#{e}: #{e.message}\n"
      end
    end)
  end
end
