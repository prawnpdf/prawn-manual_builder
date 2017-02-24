# frozen_string_literal: true

require "prawn/manual_builder"

Prawn::ManualBuilder::Chapter.new do
  title "No Example"

  text do
    prose "No example here"
  end
end
