# frozen_string_literal: true

require 'pathname'
require 'prawn'

require_relative 'part'
require_relative 'section'
require_relative 'peritext'
require_relative 'chapter'

module Prawn
  module ManualBuilder
    class Manual
      def initialize(root_path, document_options = {}, &block)
        @root_path = Pathname(root_path)
        @document_options = document_options
        @content = []
        @container = self
        instance_eval(&block) if block
      end

      attr_reader :root_path, :content

      def generate(filename = nil)
        doc = Prawn::Document.new({ skip_page_creation: true, margin: PAGE_MARGIN }.merge(@document_options)) do
          jigmo_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/Jigmo.ttf"
          jigmo2_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/Jigmo2.ttf"
          jigmo3_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/Jigmo3.ttf"
          dejavu_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans.ttf"
          dejavu_bold_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans-Bold.ttf"
          dejavu_italic_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans-Oblique.ttf"
          dejavu_bold_italic_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans-BoldOblique.ttf"
          iosevka_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/iosevka-po-regular.ttf"
          iosevka_bold_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/iosevka-po-bold.ttf"
          font_families.update(
            'Jigmo' => { normal: jigmo_file },
            'Jigmo2' => { normal: jigmo2_file },
            'Jigmo3' => { normal: jigmo3_file },
            'DejaVu' => {
              normal: dejavu_file,
              bold: dejavu_bold_file,
              italic: dejavu_italic_file,
              bold_italic: dejavu_bold_italic_file,
            },
            'Iosevka' => {
              normal: iosevka_file,
              bold: iosevka_bold_file,
            }
          )

          class << self
            attr_accessor :new_page_callback

            def start_new_page(options = {})
              super

              if new_page_callback
                new_page_callback.call(self)
              end
            end
          end
        end

        render_content(doc)
        build_outline(doc)
        if filename
          doc.render_file(filename)
        else
          doc.render
        end
      end

      protected

      attr_reader :content

      private

      def title(title = NOT_SET)
        if title == NOT_SET
          @title
        else
          @title = title
        end
      end

      # Groups chapters into sections. This is primarily used to structure manual outline.
      def section(title)
        section = Section.new(title)
        @container.content << section
        parent_container = @container
        @container = section
        yield
      ensure
        @container = parent_container
      end

      # Adds manual content. Chapter usually produces some content and is added to the document outline.
      def chapter(relative_path)
        part = load_part(relative_path)
        @container.content << part
      end

      def part(relative_path)
        part = load_part(relative_path)
        @container.content << part
      end

      def load_part(relative_path)
        part_path = File.join(root_path, "#{relative_path}.rb")
        if File.exist?(part_path)
          part = eval(File.read(part_path), TOPLEVEL_BINDING, part_path)
          if part.is_a?(Part)
            part.auto_render = false
            part.path = part_path
            part.manual = self
          else
            raise ArgumentError, "#{relative_path} doesn't evaluate to a Part object"
          end

          part
        else
          raise ArgumentError, "#{relative_path} not found"
        end
      end

      def render_content(doc)
        content.each do |part|
          render_part(doc, part)
        end
      end

      def render_part(doc, part)
        case part
        when Section
          part.content.each do |subpart|
            render_part(doc, subpart)
          end
        when Chapter, Peritext
          part.render(doc)
        else
          raise ArgumentError, "Unknown part type #{part.class}"
        end
      end

      def build_outline(doc)
        doc.outline.section(title) do
          content.each do |part|
            add_part_to_outline(doc, part)
          end
        end
      end

      def add_part_to_outline(doc, part)
        case part
        when Section
          doc.outline.section(part.title, destination: part.page_number) do
            part.content.each do |subpart|
              add_part_to_outline(doc, subpart)
            end
          end
        when Chapter
          doc.outline.page(title: part.title, destination: part.page_number)
        when Peritext
          # Skip
        else
          raise ArgumentError, "Unknown part type #{part.class}"
        end
      end
    end
  end
end
