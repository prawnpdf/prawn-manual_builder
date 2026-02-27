# frozen_string_literal: true

require_relative 'lib/prawn/manual_builder/version'

Gem::Specification.new do |spec|
  spec.name = 'prawn-manual_builder'
  spec.version = Prawn::ManualBuilder::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'A tool for writing manuals for Prawn and Prawn accessories'
  spec.description = 'A tool for writing manuals for Prawn and Prawn accessories'
  spec.licenses = %w[PRAWN GPL-2.0 GPL-3.0]

  spec.files = Dir.glob('{data,lib}/**/*') +
    ['README.md', 'LICENSE', 'COPYING', 'GPLv2', 'GPLv3']

  if File.basename($PROGRAM_NAME) == 'gem' && ARGV.include?('build')
    signing_key = File.expand_path('~/.gem/gem-private_key.pem')
    if File.exist?(signing_key)
      spec.cert_chain = ['certs/pointlessone.pem']
      spec.signing_key = signing_key
    else
      warn 'WARNING: Signing key is missing. The gem is not signed and its authenticity can not be verified.'
    end
  end

  spec.required_ruby_version = '>= 2.7'
  spec.add_dependency('prawn', '~> 2.4.0')
  spec.add_dependency('prism', '~> 1.0')

  spec.add_development_dependency('prawn-dev', '~> 0.6.0')

  spec.authors = ['Alexander Mankuta']
  spec.email = ['alex@pointless.one']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
