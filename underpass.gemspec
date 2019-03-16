Gem::Specification.new do |s|
  s.name = 'underpass'.freeze
  s.version = '0.0.4'

  s.required_rubygems_version = Gem::Requirement.new('>= 0'.freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ['lib'.freeze]
  s.authors = ['Janos Rusiczki'.freeze]
  s.date = '2019-02-26'
  s.description = 'A library that makes it easy to query the Overpass API and translate its responses into RGeo objects.'.freeze
  s.email = 'janos.rusiczki@gmail.com'.freeze
  s.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md'].to_a
  s.homepage = 'http://github.com/haiafara/underpass'.freeze
  s.licenses = ['MIT'.freeze]
  s.required_ruby_version = '>= 2.6.0'
  s.rubygems_version = '3.0.1'.freeze
  s.summary = 'A library that translates Overpass API responses into RGeo objects'.freeze

  if s.respond_to? :specification_version
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency('rgeo'.freeze, ['~> 2.0.0'])
      s.add_development_dependency('rspec'.freeze, ['~> 3.5.0'])
      s.add_development_dependency('simplecov'.freeze, ['~> 0.16.0'])
    else
      s.add_dependency('rgeo'.freeze, ['~> 2.0.0'])
      s.add_dependency('rspec'.freeze, ['~> 3.5.0'])
      s.add_dependency('simplecov'.freeze, ['~> 0.16.0'])
    end
  else
    s.add_dependency('rspec'.freeze, ['~> 3.5.0'])
    s.add_dependency('simplecov'.freeze, ['~> 0.16.0'])
  end
end
