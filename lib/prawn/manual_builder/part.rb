# frozen_string_literal: true

module Prawn
  module ManualBuilder
    class Part
      attr_accessor :auto_render
      attr_accessor :manual
      attr_accessor :path
      attr_reader :page_number

      def render(doc)
        raise NotImplementedError
      end

      private

      def colored_box(doc, box_text, options={})
        options = {
          fill_color: DARK_GRAY,
          stroke_color: nil,
          text_color: LIGHT_GRAY,
          leading: LEADING
        }.merge(options)

        text_options = {
          leading: options[:leading],
          fallback_fonts: ["DejaVu", "Jigmo", "Jigmo2", "Jigmo3"]
        }

        box_height = 0

        doc.bounding_box(
          [INNER_MARGIN + RHYTHM, doc.cursor],
          width: doc.bounds.width - (INNER_MARGIN + RHYTHM) * 2
        ) do
          box_height = doc.height_of_formatted(box_text, text_options)
        end

        if box_height > doc.cursor - doc.bounds.bottom
          doc.start_new_page
          doc.move_down(INNER_MARGIN)
        end

        doc.bounding_box(
          [INNER_MARGIN + RHYTHM, doc.cursor],
          width: doc.bounds.width - (INNER_MARGIN + RHYTHM) * 2
        ) do
          box_height = doc.height_of_formatted(box_text, text_options)

          doc.fill_color(options[:fill_color])
          doc.stroke_color(options[:stroke_color] || options[:fill_color])
          doc.fill_and_stroke_rounded_rectangle(
              [doc.bounds.left - RHYTHM, doc.cursor],
              doc.bounds.left + doc.bounds.right + RHYTHM * 2,
              box_height + RHYTHM * 2,
              5
          )
          doc.fill_color(BLACK)
          doc.stroke_color(BLACK)

          doc.pad(RHYTHM) do
            doc.formatted_text(box_text, text_options)
          end
        end

        doc.move_down(RHYTHM * 2)
      end

      def inner_box(doc, &block)
        doc.bounding_box(
          [INNER_MARGIN, doc.cursor],
          width: doc.bounds.width - INNER_MARGIN * 2,
          &block
        )
      end
    end
  end
end
