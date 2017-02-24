# frozen_string_literal: true

require "prawn/manual_builder"

Prawn::ManualBuilder::Chapter.new do
  title "Long example"

  text do
    prose "Long example:"
  end

  example do
    # Let's have some space







    # A bit more




    text "Hi!"
    start_new_page


    # And some more space




    text "Hello!"
    start_new_page
  end
end
