# frozen_string_literal: true

require_relative 'lib/prawn/manual_builder/version'

Gem::Specification.new do |spec|
  spec.name = 'prawn-manual_builder'
  spec.version = Prawn::ManualBuilder::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A tool for writing manuals for Prawn and Prawn accessories"
  spec.description = "A tool for writing manuals for Prawn and Prawn accessories"
  spec.licenses = %w(PRAWN GPL-2.0 GPL-3.0)

  spec.files =  Dir.glob("{data,lib}/**/*") +
    ['README.md', "LICENSE", "COPYING", "GPLv2", "GPLv3"]

  spec.required_ruby_version = '>= 2.7'
  spec.add_dependency("prawn", "~> 2.4.0")
  spec.add_dependency("prism", "~> 0.22.0")

  spec.authors = ["Alexander Mankuta"]
  spec.email = ["alex@pointless.one"]
end
