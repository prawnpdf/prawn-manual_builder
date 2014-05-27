# Intro hooray!
# 
# You better believe this is the best example ever.

require_relative "../../prawn/manual_builder"

Prawn::ManualBuilder::Example.generate("test.pdf") do
  text "HOWDY THERE Prawn::ManualBuilder!!!!!", :size => 36, :color => "0000ff"
end

