# frozen_string_literal: true

module Prawn
  module ManualBuilder
    class Section
      def initialize(title)
        @title = title
        @content = []
      end

      attr_reader :title, :content

      def render(doc)
        # Do nothing
      end

      def page_number
        content.find { _1.respond_to?(:page_number) }&.page_number
      end
    end
  end
end
