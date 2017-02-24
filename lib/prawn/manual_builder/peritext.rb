# frozen_string_literal: true

require 'prism'
require_relative 'part'
require_relative 'text_renderer'

module Prawn
  module ManualBuilder
    class Peritext < Part

      def initialize(&block)
        super

        if block
          instance_eval(&block)
        else
          warn "Peritext defined in #{__FILE__} has no content"
        end
      end

      # DSL
      def text(&block)
        if !block_given?
          @text
        else
          @text = block
        end
      end

      def render(doc)
        doc.start_new_page(margin: PAGE_MARGIN)
        @page_number = doc.page_number

        inner_box(doc) do
          TextRenderer.new(doc, &text).render
        end
      end
    end
  end
end
