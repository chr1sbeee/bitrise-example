#!/usr/bin/env ruby
require 'slack-ruby-client'

# TODO: REMOVE
require 'pp'
pp ENV

# ENV
pullRequestURL = ENV['BITRISEIO_PULL_REQUEST_REPOSITORY_URL']
buildLogURL = ENV['BITRISE_BUILD_URL']
authorEmailAddress = ENV['GIT_CLONE_COMMIT_AUTHOR_EMAIL']
branch = ENV['BITRISE_GIT_BRANCH']
testResult = ENV['BITRISE_XCODE_TEST_RESULT']
slackAPIToken = ENV['SLACK_API_TOKEN']

teamMembers = {
  'chris.blackmore@asos.com' => 'chris.blackmore',
}

slackChannel = "bitrise-slack-test"
isPullRequest = pullRequestURL != nil
didFailBecauseOfTests = testResult == "failed" # "failed" if test fails or it fails to compile
authorSlackUsername = teamMembers[authorEmailAddress]

# Slack setup
Slack.configure do |config|
    config.token = slackAPIToken
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

counter = 1
file = File.new("/var/folders/90/5stft2v13fb_m_gv3c8x9nwc0000gn/T/bitrise757480219/formatted_output.md", "r")
puts file
while (line = file.gets)
    puts line
    counter = counter + 1
end
file.close 
