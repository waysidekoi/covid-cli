require_relative 'lib/covid/version'

Gem::Specification.new do |spec|
  spec.name          = "covid-cli"
  spec.license       = "MIT"
  spec.version       = Covid::VERSION
  spec.authors       = ["Wayne Yang"]
  spec.email         = ["waysidekoi@gmail.com"]

  spec.summary       = "Display the latest SARS-CoV-2 reported numbers via CLI"
  spec.description   = "Global SARS-CoV-2 Confirmations, deaths, and recovered numbers are fetched from the JHU team at https://github.com/CSSEGISandData/COVID-19"
  spec.homepage      = "https://github.com/waysidekoi/covid-cli"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "thor"
  spec.add_dependency "rake"
  spec.add_dependency "httparty"
  spec.add_dependency "activerecord"
  spec.add_dependency "actionview"
  spec.add_dependency "sqlite3"
  spec.add_dependency "tty-table"
  spec.add_development_dependency "pry"
end
