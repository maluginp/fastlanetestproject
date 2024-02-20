require 'fastlane'

module Deploy

  def self.run(debug: false)

    thread = BuildingSlackThread.start(
      ENV['SLACK_API_TOKEN'],
      ENV['SLACK_RELEASE_CHANNEL_BUILDS'],
      'Releasing build...',
      debug
    )

    begin

      Fastlane::Actions::GradleAction.run(
          task: 'assemble',
          flavor: '',
          build_type: 'Release',
          project_dir: "../",
          print_command: true,
          print_command_output: true
      )

      completed_apk_path = Fastlane::Actions.lane_context[
        Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH
      ]

      thread.attach_file('APK file', completed_apk_path, 'app.apk')

      Fastlane::Actions::GradleAction.run(
          task: 'bundle',
          flavor: '',
          build_type: 'Release',
          project_dir: "../",
          print_command: true,
          print_command_output: true
      )

      completed_aab_path = Fastlane::Actions.lane_context[
        Fastlane::Actions::SharedValues::GRADLE_AAB_OUTPUT_PATH
      ]

      thread.attach_file('Bundle file', completed_aab_path, 'app.aab')

      unless debug
        Fastlane::Actions::UploadToPlayStoreAction.run(
          aab: completed_aab_path,
          track: 'production',
          rollout: 0.1 # 10%
        )
      end

      thread.success('Releasing is completed and rollout on 10%')
    rescue
      thread.failure('Releasing is failed')
      raise # re-raise
    end

  end

end
