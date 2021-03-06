# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'estafeta/version'

Gem::Specification.new do |spec|
  spec.name          = 'estafeta'
  spec.version       = Estafeta::VERSION
  spec.authors       = ['Omar Garcia']
  spec.email         = ['isc.omargarcia@gmail.com']

  spec.summary       = 'The unofficial API for Estafeta postal service'
  spec.description   = <<-EOF
    This gem is a friendly way to retrieve the tracking information for a package
    sent via Estafeta's postal service.
    Currently to get the tracking information you have to visit the website and there's
    no official way to get this through a webservice or API and integrate into your own
    solution, thus this gem will do the heavy lifting for you.
  EOF
  spec.homepage      = "TODO: Put your gem's website or public repo URL here.'"
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'byebug', '~> 0'
  spec.add_development_dependency 'httparty', '~> 0'
  spec.add_development_dependency 'nokogiri', '~> 0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 0'
  spec.add_development_dependency 'vcr', '~> 0'
  spec.add_development_dependency 'webmock', '~> 0'
end
