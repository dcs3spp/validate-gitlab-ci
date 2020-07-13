require_relative 'lib/gitlab/lint/client/version'

Gem::Specification.new do |spec|
  spec.name          = "gitlab-lint-client"
  spec.version       = Gitlab::Lint::Client::VERSION
  spec.authors       = ["spears"]
  
  spec.summary       = %q{Call GitLab API to validate CI yaml file}
  spec.description   = %q{Call GitLab API to validate CI yaml file}
  spec.homepage      = "https://github.com/dcs3spp/validate-gitlab-ci"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.3")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dcs3spp/validate-gitlab-ci"
  spec.metadata["changelog_uri"] = "https://github.com/dcs3spp/validate-gitlab-ci/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   << 'glab-lint'
  spec.extra_rdoc_files = ["README.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "pry", "~> 0.13.1"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "webmock", "~> 3.8.3"
end
