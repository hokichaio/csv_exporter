require 'csv'
require 'nkf'
  
class CsvExporter
  
  def self.export_by_line(data, headers, options = {})
    headers["Cache-Control"] ||= "no-cache"
    headers["Transfer-Encoding"] = "chunked"
    headers.merge!('Content-Type' => "text/csv; charset=Shift_JIS",'Content-Disposition' => "attachment; filename=\"#{data.model}_#{Time.now}.csv\"")
    return Rack::Chunked::Body.new(Enumerator.new do |y|
      begin
        human_name = []
        if options[:structure].present?
          human_name.concat I18n.t(options[:structure], :scope => [:activerecord, :attributes, data.model.table_name.singularize])
        else
          data.model.column_names.each do |column_name|
            human_name << data.model.human_attribute_name(column_name)
          end
        end
        
        y << NKF::nkf("-s", CSV.generate_line(human_name))
        data.find_each do |row|
          if options[:structure].present?
            output_row = []
            options[:structure].each do |s|
              begin
                output_row << s.split(".").inject(row){|obj, met| obj.send(met)}
              rescue
              end
            end
            y << NKF::nkf("-s", CSV.generate_line(output_row))
          else
            y << NKF::nkf("-s", CSV.generate_line(row.attributes.values))
          end
        end
      rescue => e
        y << NKF::nkf("-s", "データの破損を検知しました、このデータを破棄してください。\n")
        y << "#{e}: #{e.message}\n"
      end
    end)
  end
end
  
