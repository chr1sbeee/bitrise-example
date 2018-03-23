#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

# Prints env variables, remove at some point
pp ENV

# Map emails to slack
teamMembers = {
  'chris.blackmore@asos.com' => 'chris.blackmore',
}

# Constants
slackChannel = "bitrise-slack-test"
pullRequestURL = ENV['BITRISEIO_PULL_REQUEST_REPOSITORY_URL']
buildLogURL = ENV['BITRISE_BUILD_URL']
isPullRequest = pullRequestURL != nil
didFailBecauseOfTests = ENV['BITRISE_XCODE_TEST_RESULT'] == "failed"
authorEmailAddress = ENV['GIT_CLONE_COMMIT_AUTHOR_EMAIL']
authorSlackUsername = teamMembers[authorEmailAddress]
branch = ENV['BITRISE_GIT_BRANCH']

# Slack setup
Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
end
client = Slack::Web::Client.new
client.auth_test

if (didFailBecauseOfTests)
    if (isPullRequest)
        slackMessage = "@#{authorSlackUsername} your PR has fail testing - see #{buildLogURL} for more information."
        client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
    else
        slackMessage = "@here #{branch} has failed testing - see #{buildLogURL} for more information."
        client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
    end
end





