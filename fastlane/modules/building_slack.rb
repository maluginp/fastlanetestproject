require 'fastlane'

# Manage slack thread for building
class BuildingSlackThread

  attr_accessor :api_token, :thread_ts, :thread_channel, :debug

  def self.start(api_token, channel, message, debug = false)
    Fastlane::UI.message("Sending start building message to Slack channel #{channel}")

    if debug
      return BuildingSlackThread.new(api_token, channel, message, debug: debug)
    end

    thread_result = Fastlane::Actions::PostToSlackAction.run(
      api_token: @api_token,
      message: message,
      success: true,
      channel: @channel,
      payload: [],
      attachment_properties: {},
      default_payloads: %i[lane git_branch git_author last_git_commit],
    )

    thread_ts = thread_result[:json]["ts"]
    thread_channel = thread_result[:json]["channel"]

    Fastlane::UI.error("Failed sending message to Slack to #{channel} channel") unless thread_ts && thread_channel

    BuildingSlackThread(api_token, thread_ts, thread_channel, debug)
  end

  def initialize(api_token, thread_ts, thread_channel, debug: false)
    @api_token = api_token
    @thread_ts = thread_ts
    @thread_channel = thread_channel
    @debug = debug
  end

  def attach_file(message, file_path, file_name)
    ext = file_name.split('.').last

    Fastlane::UI.message("Attaching #{file_name} (ext = #{ext}) file is located in path #{file_path}")

    return if @debug

    Fastlane::Actions::FileUploadToSlackAction.run(
      api_token: @api_token,
      initial_comment: message,
      file_path: file_path,
      file_name: file_name,
      file_type: ext,
      channels: @thread_channel,
      thread_ts: @thread_ts
    )
  end

  def success(message)
    Fastlane::UI.message("Sending success building message")

    return if @debug

    Fastlane::Actions::UpdateSlackMessageAction.run(
      ts: @thread_ts,
      api_token: @api_token,
      message: message,
      success: true,
      channel: @thread_channel,
      payload: [],
      attachment_properties: {},
      default_payloads: %i[lane git_branch git_author last_git_commit],
    )
  end

  def failure(message)
    Fastlane::UI.message("Sending failure building message")

    return if @debug

    Fastlane::Actions::UpdateSlackMessageAction.run(
      ts: @thread_ts,
      api_token: @api_token,
      message: message,
      success: false,
      channel: @thread_channel,
      payload: [],
      attachment_properties: {},
      default_payloads: %i[lane git_branch git_author last_git_commit],
    )
  end
end
