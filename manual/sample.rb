require_relative "../lib/prawn_doc"

PrawnDoc.manual_dir = File.dirname(__FILE__)

options = { :skip_page_creation => true, :page_size => "FOLIO" }

PrawnDoc::Example.generate("manual.pdf", options) do
  load_package "greetings"
end
