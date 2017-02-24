# frozen_string_literal: true

require 'uri'

module Prawn
  module ManualBuilder
    class TextRenderer
      def initialize(doc, &text)
        @doc = doc
        @text = text
      end

      def render
        return unless text

        instance_eval(&text)
      end

      private

      attr_reader :doc, :text

      def header(str)
        doc.font(HEADER_FONT, size: HEADER_FONT_SIZE) do
          str.split(/\n\n+/).each do |paragraph|
            doc.text(
              paragraph.gsub(/\s+/," "),
              align: :justify,
              inline_format: true,
              leading: LEADING,
              color: DARK_GRAY)

            doc.move_down(RHYTHM)
          end
        end

        doc.move_down(RHYTHM)
      end

      def header_with_bg(header_text = [], header_options = { final_gap: false })
        if header_text.is_a?(String)
          header_text = [{ text: header_text }]
        end
        header_text = header_text.map { |fragment| { font: HEADER_FONT, size: HEADER_FONT_SIZE }.merge(fragment) }
        text_height = doc.height_of_formatted(header_text, header_options)

        doc.bounding_box(
          [-doc.bounds.absolute_left, doc.cursor + PAGE_MARGIN],
          width: doc.bounds.absolute_left + doc.bounds.absolute_right,
          height: PAGE_MARGIN * 2 + text_height
        ) do
          doc.fill_color(LIGHT_GRAY)
          doc.fill_rectangle(
            [doc.bounds.left, doc.bounds.top],
            doc.bounds.right,
            doc.bounds.top - doc.bounds.bottom
          )
          doc.fill_color(BLACK)

          doc.bounding_box(
            [PAGE_MARGIN + INNER_MARGIN, doc.bounds.top - PAGE_MARGIN],
            width: doc.bounds.width - PAGE_MARGIN * 2 - INNER_MARGIN * 2,
            height: text_height
          ) do
            doc.formatted_text(header_text, header_options)
          end
        end

        doc.stroke_color(GRAY)
        doc.stroke_horizontal_line(-doc.bounds.absolute_left, doc.bounds.width + doc.bounds.absolute_right, at: doc.cursor)
        doc.stroke_color(BLACK)

        doc.move_down(RHYTHM * 3)
      end

      def prose(str)
        doc.font(TEXT_FONT, size: TEXT_FONT_SIZE) do
          extra_markup(str).split(/\n\n+/).each do |paragraph|
            doc.text(
              paragraph.gsub(/\s+/," "),
              align: :justify,
              inline_format: true,
              leading: LEADING,
              color: DARK_GRAY)

            doc.move_down(RHYTHM)
          end
        end

        doc.move_down(RHYTHM)
      end

      def list(*items)
        doc.move_up(RHYTHM)

        doc.font("DejaVu", size: 11) do
          items.each do |li|
            doc.float { doc.text("\u2022", size: doc.font_size * 1.25) }
            doc.indent(RHYTHM) do
              doc.text(
                extra_markup(li).gsub(/\s+/, ' '),
                inline_format: true,
                color: DARK_GRAY,
                leading: LEADING
              )
            end

            doc.move_down(RHYTHM / 2)
          end

          doc.move_down(RHYTHM / 2)
        end
      end

      def ordered_list(*items)
        doc.move_up(RHYTHM)

        doc.font("DejaVu", size: 11) do
          counter_width = (1..items.size).to_a.map { |i| doc.width_of("#{i}.") }.max
          space_width = doc.width_of(' ')
          items.each_with_index do |li, i|
            doc.float do
              doc.bounding_box([0, doc.cursor], width: counter_width) do
                doc.text("#{i + 1}.", color: DARK_GRAY, align: :right)
              end
            end
            doc.indent(counter_width + space_width) do
              doc.text(
                extra_markup(li).gsub(/\s+/, ' '),
                inline_format: true,
                color: DARK_GRAY,
                leading: LEADING
              )
            end

            doc.move_down(RHYTHM / 2)
          end

          doc.move_down(RHYTHM / 2)
        end
      end

      def extra_markup(str)
        str
          .gsub(/<code>([^<]+?)<\/code>/, '<font name="Iosevka"><b>\1</b></font>') # Process the <code> tags
          .gsub(URI::Parser.new.make_regexp(%w[http https])) do |match|
            %(<color rgb="#{BLUE}"><link href="#{match}">#{match.gsub('/', "/#{Prawn::Text::ZWSP}")}</link></color>) # Process the links
          end
      end
    end
  end
end
