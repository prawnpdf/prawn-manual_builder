module Prawn
  module ManualBuilder
    DATADIR = File.dirname(__FILE__) + "/../../data"
    NOT_SET = Object.new.freeze

    # Values used for the manual design:

    # Default margin
    PAGE_MARGIN = 36

    # Additional indentation to keep the line measure with a reasonable size
    INNER_MARGIN = 30

    # Vertical Rhythm settings
    RHYTHM = 10
    LEADING = 2

    # Colors
    BLACK = "000000"
    LIGHT_GRAY = "F2F2F2"
    GRAY = "DDDDDD"
    DARK_GRAY = "333333"
    BROWN = "A4441C"
    ORANGE = "F28157"
    LIGHT_GOLD = "FBFBBE"
    DARK_GOLD = "EBE389"
    BLUE = "0000D0"

    HEADER_FONT = "DejaVu"
    HEADER_FONT_SIZE = 18

    CODE_FONT = 'Iosevka'
    CODE_FONT_SIZE = 9

    TEXT_FONT = 'DejaVu'
    TEXT_FONT_SIZE = 10
  end
end

require_relative "manual_builder/manual"
