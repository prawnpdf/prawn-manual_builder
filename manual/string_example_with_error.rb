# frozen_string_literal: true

require "prawn/manual_builder"

Prawn::ManualBuilder::Chapter.new do
  title "String Example with Error"

  text do
    prose "This demonstrates both a string example and what happens if example raises an exception"
  end

  example <<~CODE
    raise "Unscheduled Rapid Disassembly"
  CODE
end
