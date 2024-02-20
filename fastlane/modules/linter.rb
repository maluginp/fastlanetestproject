require 'fastlane'

# Linter methods
module Linter

  def self.detekt(throw_if_fails: true)
    Fastlane::Actions::GradleAction.run(
      task: 'detekt',
      project_dir: '../',
      print_command: true,
      print_command_output: true
    )
    true
  rescue FastlaneCore::Interface::FastlaneShellError
    raise if throw_if_fails

    false
  end

  def self.lint(throw_if_fails: true)
    Fastlane::Actions::GradleAction.run(
      task: 'lint',
      project_dir: '../',
      print_command: true,
      print_command_output: true
    )
    true
  rescue FastlaneCore::Interface::FastlaneShellError
    raise if throw_if_fails

    false
  end
end
