# CsvExporter

## Install

```ruby
gem 'csv_exporter', :git => "https://github.com/hokichaio/csv_exporter.git"
```

## Getting started

Example:

Use the following script in your controller

```ruby
self.response_body = CsvExporter.export_by_line(@posts, headers)
```

CvsExporter will output all columns in the model for default.
If you want to include nested models, or construct yoru own csv structure.
use the following option

```ruby
self.response_body = CsvExporter.export_by_line(@posts, headers, :structure => ["id", "author.id", "author.name"])
```

CsvExporter will look up your I18n file for column names.

## Copyright

Copyright &copy; 2011-2015 [Kevin Tsai](http://www.facebook.com/hokichaio)
