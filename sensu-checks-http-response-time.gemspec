# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


if RUBY_VERSION < '2.0.0'
  require 'sensu-checks-http-response-time'
else
  require_relative 'lib/sensu-checks-http-response-time'
end


Gem::Specification.new do |spec|
  spec.name          = "sensu-checks-http-response-time"
  spec.version       = SensuChecksHttpResponseTime::Version::VER_STRING
  spec.authors       = ["vmpublishing development"]
  spec.email         = ["dev@vmpublishing.com"]

  spec.summary       = 'sensu gem to get http response time checks and metrics.'
  spec.description   = 'sensu gem to get http response time checks and metrics. uses curl to query the target host'
  spec.homepage      = "https://github.com/vmpublishing/sensu-checks-http-response-time"
  spec.license       = 'Nonstandard'


  spec.files         = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md)
  spec.executables   = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'sensu-plugin', '~> 1.2'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end

