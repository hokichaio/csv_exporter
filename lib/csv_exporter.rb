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
          if options[:include_column_names]
            human_name = []
            if options[:structure].present?
              options[:structure].each do |s|
                human_name << I18n.t(s, :scope => [:activerecord, :attributes, data.model.table_name.singularize], :default => s)                
              end
            else
              human_name.concat I18n.t(row.attributes.keys, :scope => [:activerecord, :attributes, data.model.table_name.singularize])
            end
            options[:include_column_names] = false
            y << NKF::nkf(options[:nkf], CSV.generate_line(human_name))
          end
          
          if options[:structure].present?
            output_row = []
            options[:structure].each do |s|
              begin
                output_row << s.split(".").inject(row){|obj, met| obj.send(met)}
              rescue
                output_row << ""
              end
            end
            y << NKF::nkf(options[:nkf], CSV.generate_line(output_row))
          else
            y << NKF::nkf(options[:nkf], CSV.generate_line(row.attributes.values))
          end
        end
      rescue => e
        y << NKF::nkf(options[:nkf], I18n.t("csv_exporter.file_corrupted") + "\n")
        y << "#{e}: #{e.message}\n"
      end
    end)
  end
end
  
