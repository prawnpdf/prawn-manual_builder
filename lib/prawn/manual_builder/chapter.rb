# frozen_string_literal: true

require 'prism'
require_relative 'part'
require_relative 'text_renderer'
require_relative "syntax_highlight"

module Prawn
  module ManualBuilder
    class Chapter < Part
      def initialize(&block)
        super

        if block
          instance_eval(&block)
        else
          warn "Chapter defined in #{__FILE__} has no content"
        end

        self.auto_render = true
        at_exit do
          if self.auto_render
            execute_example
          end
        end
      end

      # Chapter DSL
      def title(title = NOT_SET)
        if title == NOT_SET
          @title
        else
          @title = title
        end
      end

      def text(&block)
        if !block_given?
          @text
        else
          @text = block
        end
      end

      def example(source = NOT_SET, axes: false, new_page: false, eval: true, standalone: false, &block)
        if source == NOT_SET && !block_given?
          @example
        elsif source != NOT_SET && block_given?
          raise ArgumentError, "Example can't be specified both as a block and as a string"
        else
          if source != NOT_SET
            @example = source
          else
            @example = block
          end
          @example_axes = axes
          @eval_example = eval
          @standalone_example = standalone
          @new_page_example = new_page
        end
      end

      def eval_example?
        @eval_example
      end

      def standalone_example?
        @standalone_example
      end

      def new_page_example?
        @new_page_example
      end

      def example_axes?
        @example_axes
      end

      def render(doc)
        doc.start_new_page(margin: PAGE_MARGIN)
        @page_number = doc.page_number

        chapter_header(doc)

        inner_box(doc) do
          TextRenderer.new(doc, &text).render
        end

        example_source(doc)

        if eval_example? && !standalone_example?
          eval_example(doc)
        end

        unless eval_example?
          standalone_example(doc)
        end
      end

      def to_s
        super[-2, 0] = " path: #{path}"
      end

      private

      def example_source_code
        case example
        when Proc
          block_source_line = example.source_location.last
          source = File.read(path)
          parse_result = Prism.parse(source)

          block =
            Prism::Pattern.new("CallNode[name: :example, block: BlockNode]")
              .scan(parse_result.value)
              .find { |node| node.block.location.start_line == block_source_line }
              &.block

          return '' unless block

          source.byteslice(block.opening_loc.end_offset, block.closing_loc.start_offset - block.opening_loc.end_offset)
            .then { _1.gsub(/^#{_1.scan(/^[ \t]*(?=\S)/).min}/, '') } # Remove indentation
        when String
          example
        else
          ''
        end
          .sub(/(?<=\A)([ \t]*\r?\n)*/, '') # Remove empty lines at the beginning
          .rstrip # Remove trailing whitespace
      end

      def chapter_header(doc)
        raise "Title is not set" unless title

        header_options = {
          leading: 6,
          final_gap: false,
        }
        header_text = [
          { text: title, font: HEADER_FONT, size: HEADER_FONT_SIZE, color: DARK_GRAY },
        ]

        if manual.root_path && example
          rel_path = Pathname.new(path).relative_path_from(manual.root_path)

          header_text.concat(
            [
              { text: "\n" },
              { text: "#{rel_path.dirname}/", color: BROWN, font: 'Iosevka', size: HEADER_FONT_SIZE * 0.75 },
              { text: "#{rel_path.basename}", color: ORANGE, font: 'Iosevka', size: HEADER_FONT_SIZE * 0.75 },
            ]
          )
        end

        TextRenderer.new(doc) do
          header_with_bg(header_text, header_options)
        end.render
      end

      def example_source(doc)
        return if example_source_code.empty?

        doc.font(CODE_FONT, size: CODE_FONT_SIZE) do
          colored_box(doc, SyntaxHighlight.new(example_source_code).to_prawn, fill_color: DARK_GRAY)
        end
      end

      def eval_example(doc)
        old_new_page_callback = doc.new_page_callback
        crossed_page = false
        doc.new_page_callback = lambda do |doc|
          # Reset bounding box on new page
          doc.bounds = Prawn::Document::BoundingBox.new(
            doc,
            nil,
            [0, doc.page.dimensions[3]],
            width: doc.page.dimensions[2],
            height: doc.page.dimensions[3]
          )
          setup_example_area(doc)
          crossed_page = true
        end

        preserving_doc_settings(doc) do
          doc.save_graphics_state do
            doc.bounding_box(
              [-doc.bounds.absolute_left, doc.cursor],
              width: doc.page.dimensions[2],
              height: doc.y
            ) do
              doc.start_new_page if new_page_example?
              setup_example_area(doc) unless crossed_page

              begin
                if example.is_a?(Proc)
                  doc.instance_eval(&example)
                else
                  doc.instance_eval(example, path)
                end
              rescue => e
                puts "Error evaluating example: #{e.message}"
                puts
                puts "---- Source: ----"
                puts
                puts example
                puts
                puts "---- Backtrace: ----"
                puts e.backtrace
              end
            end
          end
        end
      ensure
        doc.new_page_callback = old_new_page_callback
      end

      def setup_example_area(doc)
        doc.save_graphics_state do
          line_width = PAGE_MARGIN
          text_size = PAGE_MARGIN * 0.6
          doc.stroke_color(GRAY)
          doc.line_width(line_width)

          doc.stroke_rectangle([line_width / 2, doc.bounds.top - line_width / 2], doc.bounds.width - line_width, doc.bounds.height - line_width)

          # We're reseting fonts for the example so we have to add it again
          example_title_font = '_ManualExampleTitle'
          doc.font_families.update(
            example_title_font => {
              normal: "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans-Bold.ttf",
              bold: "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans-Bold.ttf",
            })
          example_title = 'Example Output'
          text = [{text: example_title, font: example_title_font, size: text_size, styles: [:bold], color: 'ffffff'}]
          h = doc.height_of_formatted(text, { final_gap: false })

          doc.bounding_box(
            [line_width, doc.bounds.top - (line_width - h) / 2 * 1.25],
            width: doc.bounds.width - line_width * 2
          ) do
            doc.formatted_text(text, align: :right)
          end
        end

        doc.bounds = Prawn::Document::BoundingBox.new(
          doc,
          doc.bounds,
          [PAGE_MARGIN, doc.bounds.top - PAGE_MARGIN],
          width: doc.bounds.width - PAGE_MARGIN * 2,
          height: doc.bounds.height - PAGE_MARGIN * 2
          )
        doc.move_cursor_to(doc.bounds.height)

        doc.stroke_axis if example_axes?
      end

      # Used to generate the url for the example files
      MANUAL_URL = "https://github.com/prawnpdf/prawn/tree/master/manual"


      # Renders a box with the link for the example file
      def standalone_example(doc)
        url = "#{MANUAL_URL}/#{Pathname(path).relative_path_from(manual.root_path)}"

        reason = [
          { text: "This code snippet was not evaluated inline. "\
                  "You may see its output by running the "\
                  "example file located here:\n",
            color: DARK_GRAY, font: 'DejaVu', size: 11 },
          { text: url.gsub('/', "/#{Prawn::Text::ZWSP}"), color: BLUE, link: url, font: 'DejaVu', size: 11 }
        ]

        colored_box(
          doc, reason,
          fill_color: LIGHT_GOLD,
          stroke_color: DARK_GOLD,
          leading: LEADING * 3
        )
      end

      def execute_example
        if standalone_example?
          if self.example.is_a?(String)
            eval(example, TOPLEVEL_BINDING)
          else
            Object.new.instance_eval(&example)
          end
        else
          Prawn::Document.generate("example.pdf") do |doc|
            if self.example.is_a?(String)
              doc.instance_eval(example, path)
            else
              doc.instance_eval(&example)
            end
          end
        end
      end

      def preserving_doc_settings(doc)
        old_settings = {
          font: doc.instance_variable_get(:@font),
          font_size: doc.instance_variable_get(:@font_size),
          leading: doc.default_leading,
          text_direction: doc.text_direction,
          line_width: doc.line_width,
          cap_style: doc.cap_style,
          join_style: doc.join_style,
          fill_color: doc.fill_color,
          stroke_color: doc.stroke_color,
          font_families: doc.font_families.dup,
        }
        doc.instance_variable_set(:@font_families, nil)
        doc.font('Helvetica', size: 12)

        yield
      ensure
        doc.font_families.replace(old_settings[:font_families])
        doc.set_font(old_settings[:font], size: old_settings[:font_size])
        doc.default_leading = old_settings[:leading]
        doc.text_direction = old_settings[:text_direction]
        doc.line_width = old_settings[:line_width]
        doc.cap_style = old_settings[:cap_style]
        doc.join_style = old_settings[:join_style]
        doc.fill_color(old_settings[:fill_color])
        doc.stroke_color(old_settings[:stroke_color])
      end
    end
  end
end
