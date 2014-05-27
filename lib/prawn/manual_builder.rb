require "enumerator"

module Prawn
  module ManualBuilder
    def self.manual_dir=(dir)
      @manual_dir = dir
    end

    def self.manual_dir
      @manual_dir || Dir.pwd
    end

    def self.document_class
      @document_class || Prawn::Document
    rescue NameError
      raise "Prawn::ManualBuilder.document_class was not set. "+
            "Either assign a custom document class, or make sure to install "+
            "and require the Prawn gem."

    end

    DATADIR = File.dirname(__FILE__) + "/../../data"
  end
end

require_relative "manual_builder/example"
require_relative "manual_builder/example_file"
require_relative "manual_builder/example_section"
require_relative "manual_builder/example_package"
require_relative "manual_builder/syntax_highlight"
require_relative "manual_builder/example"
