# encoding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "media_baron"
  s.version     = "0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Callum Jones"]
  s.email       = ["callum@callumj.com"]
  s.homepage    = "http://callumj.com"
  s.summary     = "Download your favourite online radio shows, such as BBC Radio 1"
                  
  s.description = "Download your favourite online radio shows, such as BBC Radio 1"
  
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency("activesupport")
  s.add_dependency("tzinfo")
  s.add_dependency("nokogiri")
  s.add_dependency("faraday")
  s.add_dependency("faraday_middleware")
  s.add_dependency("addressable")
  s.add_dependency("amatch")
 
  s.files        = Dir.glob("lib/**/*") +
    %w(README.md Rakefile)
  s.require_path = 'lib'
end