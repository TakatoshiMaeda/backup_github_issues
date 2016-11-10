# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backup_github_issues/version'

Gem::Specification.new do |spec|
  spec.name          = "backup_github_issues"
  spec.version       = BackupGithubIssues::VERSION
  spec.authors       = ["Tomoki Yamashita"]
  spec.email         = ["tomorrowkey@gmail.com"]

  spec.summary       = %q{Backup Github issues}
  spec.description   = spec.summary
  spec.homepage      = "http://github.com/tomorrowkey/backup_github_issues"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
