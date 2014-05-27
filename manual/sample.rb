require "prawn"
require_relative "../lib/prawn/manual_builder"

Prawn::ManualBuilder.manual_dir = File.dirname(__FILE__)

options = { :skip_page_creation => true, :page_size => "FOLIO" }

Prawn::ManualBuilder::Example.generate("manual.pdf", options) do
  load_package "greetings"
end
