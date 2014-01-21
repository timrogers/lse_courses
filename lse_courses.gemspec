# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lse_courses/version'

Gem::Specification.new do |spec|
  spec.name          = "lse_courses"
  spec.version       = LSECourses::VERSION
  spec.summary       = %Q{Access to data on courses at the London School of Economics and Political Science (LSE)}
  spec.authors       = ["Tim Rogers"]
  spec.email         = ["t.d.rogers@lse.ac.uk"]
  spec.description   = %Q{Access to data on courses at the London School of Economics and Political Science (LSE)}
  spec.homepage      = "https://github.com/timrogers/lse_courses"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri"
end
