require 'csv'

module XmlToCsv
  module Documents
    class CSV < Nokogiri::XML::SAX::Document

      def self.parse(file, record_name: nil, headers: nil, output: nil)
        new(record_name: record_name, headers: headers, output: output).tap do |csv|
          Nokogiri::XML::SAX::Parser.new(csv).parse(file)
        end
      end

      def initialize(record_name: nil, headers: nil, output: $stdout)
        @record_name = record_name
        @headers = headers
        @output = output
      end

      def start_element(name, attrs = [])
        if name == record_name
          @row = new_row
        end
      end

      def characters(str)
        content << str
      end

      def end_element(name)
        if name == record_name
          csv << row.values
        else
          row[name] = content.strip
        end

        content.clear
      end

      def end_document
        csv.close
      end

      protected

      def new_row
        headers.inject({}) do |hash, key|
          hash.update(key => nil)
        end
      end

      def csv
        @csv ||= ::CSV.new(output, headers: headers, write_headers: true)
      end

      def scope(arg=nil)
        @scope = arg || @scope || :out_of_record
      end

      def record_name
        @record_name
      end

      def output
        @output
      end

      def csv_filename
        @csv_filename
      end

      def headers
        @headers
      end

      def content
        @content ||= ""
      end

      def row
        @row
      end
    end
  end
end

