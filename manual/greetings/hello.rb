# frozen_string_literal: true

require "prawn/manual_builder"

Prawn::ManualBuilder::Chapter.new do
  title "Hello"

  text do
    prose "HOWDY THERE Prawn::ManualBuilder!!!!!"#, :size => 36, :color => "0000ff"
  end

  example <<~CODE, eval: false, standalone: false
      text "HOWDY THERE from #{self.class.name}!!!!!", :size => 36, :color => "0000ff"

    bounding_box([100, 100], :width => 100, height: 100) do
      stroke_bounds
    end

    # do some more stuff here
  CODE
end
