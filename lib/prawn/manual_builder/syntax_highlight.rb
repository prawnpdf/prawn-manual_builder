# frozen_string_literal: true

module Prawn
  module ManualBuilder
    class SyntaxHighlight
      DEFAULT_STYLE = { color: 'FFFFFF' }.freeze
      STRING_STYLE = { color: '56D65E' }.freeze
      COMMENT_STYPE = { color: 'AEAEAE' }.freeze
      CONSTANT_STYLE = { color: '88A5D2' }.freeze
      IVAR_STYLE = { color: 'E8ED97' }.freeze
      NUMBER_STYLE = { color: 'C8FF0E' }.freeze
      EMBEXPR_STYLE = { color: 'EF804F' }.freeze
      KEYWORD_STYLE = { color: 'FEE100' }.freeze
      SYMBOL_STYLE = { color: 'C8FF0E' }.freeze
      METHOD_STYLE = { color: 'FF5C00' }.freeze

      def initialize(code)
        @code = code
      end

      def to_prawn
        tokens.each_with_index.map do |token, index|
          style =
            case token.type
            when :STRING_BEGIN, :STRING_CONTENT, :STRING_END, :HEREDOC_START, :HEREDOC_END
              STRING_STYLE
            when :COMMENT
              COMMENT_STYPE
            when :CONSTANT
              CONSTANT_STYLE
            when :INSTANCE_VARIABLE
              IVAR_STYLE
            when :INTEGER, :FLOAT, :INTEGER_RATIONAL, :INTEGER_IMAGINARY
              NUMBER_STYLE
            when :EMBEXPR_BEGIN, :EMBEXPR_END
              EMBEXPR_STYLE
            when /\AKEYWORD_/
              KEYWORD_STYLE
            when :SYMBOL_BEGIN, :LABEL
              SYMBOL_STYLE
            when :IDENTIFIER
              case tokens[index - 1].type
              when :SYMBOL_BEGIN
                SYMBOL_STYLE
              when :DOT
                METHOD_STYLE
              else
                DEFAULT_STYLE
              end
            else
              DEFAULT_STYLE
            end
          { text: token.value.gsub(' ', Prawn::Text::NBSP) }.merge(style)
        end
        .compact
        .each_with_object([]) do |fragment, fragments|
          if fragments.empty?
            fragments << fragment
          elsif fragments.last.reject { |k, _| k == :text} == fragment.reject { |k, _| k == :text } || fragment[:text].match?(/\A[#{Prawn::Text::NBSP}\s\t\r\n]*\z/)
            fragments.last[:text] << fragment[:text]
          else
            fragments << fragment
          end
        end
      end

      private

      attr_reader :code

      def tokens
        @tokens ||=
          begin
            result = Prism.lex(code)
            tokens =
              result.value
                .map(&:first) # Only tokens

            # Add a BOF token to be able to not miss the whitespace at the beginning
            tokens.prepend(Prism::Token.new(:PRAWN_BOF, '', Prism::Location.new(result.source, 0, 0)))

            cursor = 0
            # Add whitespace tokens
            tokens
              # Tokens are not sequential. Specifically, heredoc body is out of order.
              # We don't want to add "backwards" whitespace tokens in that case.
              .sort_by { |token| token.location.start_offset }
              .each_cons(2)
              .flat_map do |token, next_token|
                if next_token.location.start_offset != token.location.end_offset
                  ws_location = Prism::Location.new(
                    result.source,
                    token.location.end_offset,
                    next_token.location.start_offset - token.location.end_offset
                  )
                  [
                    token,
                    Prism::Token.new(:PRAWN_WHITESPACE, ws_location.slice, ws_location)
                  ]
              else
                  [token]
                end
              end
          end
      end
    end
  end
end
