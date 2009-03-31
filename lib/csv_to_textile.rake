require 'fileutils'
require 'fastercsv'

class Array
  # 2 dimensional array methods
  def strip_rows
    self.map{|x| x.compact.empty? ? nil : x}.compact
  end
  
  def fill_rows(padding=nil)
    max_cols = self.map{|x| x.length}.max
    self.map{|x| x.fill(padding,x.length,max_cols-x.length)}
  end
  
  def strip_cols
    self.fill_rows.transpose.strip_rows.transpose
  end

  def pad_columns(blank_filler="&nbsp;")
    col_widths = self.fill_rows.transpose.map{|x| x.map{|y| y.to_s.strip.gsub(/ +/, " ").length}.max }
    self.map{|x| x.enum_for(:each_with_index).map{|y,i| ((y.nil? or y.empty?) ? blank_filler : y.to_s.strip.gsub(/ +/, " ")).ljust(col_widths[i]) }}
  end
end

class CsvToTextileParser
  def self.parse(file_name)
    puts "--- Parsing '#{file_name}' ---"
    export = FasterCSV.read(file_name).strip_rows.strip_cols.pad_columns.map{|x| "| #{x.join(" | ")} |"}.join("\n")
    textile_file = file_name.gsub('.csv', '.textile.txt')
    File.truncate(textile_file, 0) if File.exist?(textile_file)
    File.open(textile_file, File::CREAT|File::APPEND|File::WRONLY) {|f| f << export}
    puts "--- End of parsing ---"
  end
end

desc "Parse csv to textile tables"
task :csv_to_textile do
  unless (ENV["DIR"].nil? or ENV["DIR"].empty?)
    Dir.glob(File.join(ENV["DIR"], '*.csv')).each do |file_name|
      CsvToTextileParser.parse(file_name)
    end
  else
    raise "directory name needed 'DIR=/Users/xyz/Desktop/csvs'"
  end
end


