#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

# Constants
slackChannel = "bitrise-slack-test"
slackFailureMessage = "*Build finished.*"

# Slack setup
Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
end
client = Slack::Web::Client.new
client.auth_test

# Configure message
#slackMessage = slackFailureMessage
#slackMessage = "#{slackMessage}\nIPA Path: #{ipaPath}"
#slackMessage = "#{slackMessage}\nPR: #{pullRequestURL}"
#slackMessage = "#{slackMessage}\nTrigger: #{trigger}"
#slackMessage = "#{slackMessage}\nLog: #{buildLogURL}"

# Prints env variables, remove at some point
pp ENV

# Send
client.chat_postMessage(channel: slackChannel, text: "Slack is working.", as_user: true)
