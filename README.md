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
#args =>
  #data => data array of model
  #headers => response headers
  #options => optional
```

CvsExporter will output all columns in the model for default.
If you want to include nested models, or construct your own csv structure.
use the following option

```ruby
self.response_body = CsvExporter.export_by_line(@posts, headers, :structure => ["id", "author.id", "author.name"])
```

or you can append extra nested columns by using the :append option

```ruby
self.response_body = CsvExporter.export_by_line(@posts, headers, :append => ["author.id", "author.name"])
```

CsvExporter will look up your i18n file for column names.

## Other options

```ruby
:nkf #string, CsvExporter use NKF for csv file encoding, the default value is "-s"
:charset #string, default is "Shift_JIS"
:include_column_names #boolean, output column name in first row, default is true
```

## Copyright

Copyright &copy; 2011-2015 [Kevin Tsai](http://www.facebook.com/hokichaio)
