# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Code Syntax Highlighting'

  text do
    prose 'Some pretty code.'
  end

  # rubocop: disable Lint/UselessAssignment, Lint/ConstantDefinitionInBlock
  example eval: false do
    local_var = true

    # Comment

    Kernel.puts(<<~HEREDOC)
      A bunch of text.
      #{[1 + 2, 4].max}
    HEREDOC

    CONST = 42 + @ivar.method.call.chain {
      {
        string: 'string',
        regexp: /regexp/,
        symbol: :symbol,
      }
    }
  end
  # rubocop: enable Lint/UselessAssignment, Lint/ConstantDefinitionInBlock
end
