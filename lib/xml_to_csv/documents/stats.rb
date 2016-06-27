require 'nokogiri'
require 'csv'

module XmlToCsv
  module Documents
    class Stats < Nokogiri::XML::SAX::Document
      attr_accessor :headers, :row_count

      def self.parse(file, record_name: nil)
        new(record_name).tap do |stats|
          Nokogiri::XML::SAX::Parser.new(stats).parse(file)
        end
      end

      def initialize(record_name)
        @record_name = record_name
        @row_count = 0
        @headers = Set.new
      end

      def start_element(name, attrs = [])
        if name == record_name
          @row_count += 1
          scope :inside_record
        elsif scope == :inside_record
          headers << name
        end
      end

      def end_element(name)
        if name == record_name
          scope :outside_of_record
        end
      end

      def end_document
        # Convert headers to an array
        @headers = headers.to_a
      end

      protected

      def scope(arg=nil)
        @scope = arg || @scope || :outside_of_record
      end

      def record_name
        @record_name
      end
    end
  end
end
