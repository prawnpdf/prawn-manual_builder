# frozen_string_literal: true

require "prawn/manual_builder"

Prawn::ManualBuilder::Chapter.new do
  title "Standalone Example"

  text do
    prose "This is a standalone example."
  end

  example standalone: true do
    puts "A standalone example"
  end
end
