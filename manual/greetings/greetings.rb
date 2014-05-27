# Intro hooray!

require_relative "../../lib/prawn/manual_builder"

Prawn::ManualBuilder::Example.generate("greetings.pdf", :page_size => "FOLIO") do
  package "greetings" do |p|
    p.example "hello"

    p.intro do
      prose "Welcome to Prawn::ManualBuilder"
    end
  end
end
