require "enumerator"
require "prawn"

require_relative "manual_builder/example"
require_relative "manual_builder/example_file"
require_relative "manual_builder/example_section"
require_relative "manual_builder/example_package"
require_relative "manual_builder/syntax_highlight"
require_relative "manual_builder/example"

module Prawn
  module ManualBuilder
    def self.manual_dir=(dir)
      @manual_dir = dir
    end

    def self.manual_dir
      @manual_dir || Dir.pwd
    end

    DATADIR = File.dirname(__FILE__) + "/../../data"
  end
end
