require 'fastlane'

# Unit test methods
module UnitTests

  def self.run(throw_if_fails: true)
    Fastlane::Actions::GradleAction.run(
      task: 'test',
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
