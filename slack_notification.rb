#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

# Prints env variables, remove at some point
pp ENV

# Constants
slackChannel = "bitrise-slack-test"
pullRequestURL = ENV['BITRISEIO_PULL_REQUEST_REPOSITORY_URL']
isPullRequest = pullRequestURL != nil

# Slack setup
Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
end
client = Slack::Web::Client.new
client.auth_test

if (isPullRequest)
    client.chat_postMessage(channel: slackChannel, text: "Pull request finished.", as_user: true)
else
    # Message if failed
end
