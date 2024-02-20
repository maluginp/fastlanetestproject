require 'fastlane'

# Safe merge for actual branch
module SafeMerge

  def self.main_branch?
    ENV['MAIN_BRANCH'] == fetch_local_branch
  end

  def self.merge_main_no_commit
    main_branch = ENV['MAIN_BRANCH']

    local_git_branch = fetch_local_branch

    command = [
        'git',
        'merge',
        main_branch,
        '--no-commit',
        '--no-ff'
      ]

      Fastlane::Actions.sh(command.join(' '))
      Fastlane::UI.success("Successfully merged #{main_branch} (main branch) to #{local_git_branch}")
  end

  def self.fetch_local_branch
    local_git_branch = Fastlane::Actions.git_branch_name_using_HEAD
    local_git_branch = Fastlane::Actions.git_branch unless local_git_branch && local_git_branch != 'HEAD'
    local_git_branch
  end
end
