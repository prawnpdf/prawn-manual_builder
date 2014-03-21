require "enumerator"
require "prawn"

require_relative "prawn_doc/example_file"
require_relative "prawn_doc/example_section"
require_relative "prawn_doc/example_package"
require_relative "prawn_doc/syntax_highlight"
require_relative "prawn_doc/example"

module PrawnDoc
  def self.manual_dir=(dir)
    @manual_dir = dir
  end

  def self.manual_dir
    @manual_dir || Dir.pwd
  end

  DATADIR = File.dirname(__FILE__) + "/../data"
end
