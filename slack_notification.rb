#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

pp ENV

puts "1"

markdownPath = ENV['BITRISE_STEP_FORMATTED_OUTPUT_FILE_PATH']
counter = 1
file = File.new(markdownPath, "r")
while (line = file.gets)
    puts line
    counter = counter + 1
end
file.close 

puts "2"


testResultPath = ENV['BITRISE_XCODE_RAW_TEST_RESULT_TEXT_PATH']
newCounter = 1
newFile = File.new(testResultPath, "r")
while (line = newFile.gets)
    puts line
    newCounter = newCounter + 1
end
newFile.close 

puts "3"


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
didFailBecauseOfTests = testResult == "failed"
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


