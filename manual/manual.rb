# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "prawn/manual_builder"

Prawn::ManualBuilder::Manual.new(__dir__, page_size: "A4") do
  part "title"

  section 'Section' do
    chapter 'greetings/greetings'
    chapter 'greetings/hello'
  end

  section 'Empty Section' do
  end

  part 'blank_peritext'

  chapter 'code_syntax_highlight'
  chapter 'long_example'
  chapter 'page_overflow'
  chapter 'no_example'
  chapter 'string_example_with_error'
  chapter 'standalone'
end.generate("manual.pdf")
