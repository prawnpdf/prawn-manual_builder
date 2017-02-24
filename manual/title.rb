# frozen_string_literal: true

require "prawn/manual_builder"

Prawn::ManualBuilder::Peritext.new do
  text do
    doc.text "This is a test"
  end
end
