# frozen_string_literal: true

require_relative "lib/opening_hours/version"

Gem::Specification.new do |spec|
  spec.name = "power-hours"
  spec.version = OpeningHours::VERSION
  spec.authors = ["Kevin Melchert"]
  spec.email = ["kevin.melchert@gmail.com"]

  spec.summary = "Simple opening-hours DSL with overnight window support."
  spec.description = "Power Hours models weekly opening windows, including overnight ranges, with a small Ruby DSL and optional model mixin helpers."
  spec.homepage = "https://github.com/max-power/power-hours"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true)
      .select { |f| File.file?(File.join(__dir__, f)) }
      .reject do |f|
        (f == gemspec) || f.end_with?(".gem") || f.start_with?(*%w[bin/ Gemfile .gitignore test/])
      end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
