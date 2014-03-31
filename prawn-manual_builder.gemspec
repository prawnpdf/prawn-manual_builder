Gem::Specification.new do |spec|
  spec.name = 'prawn-manual_builder'
  spec.version = '0.0.1'
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A tool for writing manuals for Prawn and Prawn accessories"
  spec.description = "A tool for writing manuals for Prawn and Prawn accessories"

  spec.files =  Dir.glob("{lib,data,examples}/**/*") +
    ['README.md']
 #   ['CHANGELOG', 'README.rdoc', 'COPYING', 'LICENSE', 'GPLv2', 'GPLv3']
  spec.required_ruby_version = '>= 1.9.3'
  spec.add_development_dependency("coderay", "~> 1.0.7")

  spec.authors = ["Felipe Doria", "Gregory Brown"]
  spec.email = ["felipe.doria@gmail.com", "gregory.t.brown@gmail.com"]
end
