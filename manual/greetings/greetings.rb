# Intro hooray!

require_relative "../../lib/prawn_doc"

PrawnDoc::Example.generate("greetings.pdf", :page_size => "FOLIO") do
  package "greetings" do |p|
    p.example "hello"

    p.intro do
      prose "Welcoem to PrawnDoc"
    end
  end
end
