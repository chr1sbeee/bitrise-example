#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

# Prints env variables, remove at some point
pp ENV

# Slack constants
teamMembers = {
  'chris.blackmore@asos.com' => 'chris.blackmore',
}
authorEmailAddress = ENV['GIT_CLONE_COMMIT_AUTHOR_EMAIL']
authorSlackUsername = teamMembers[authorEmailAddress]

# URL's
pullRequestURL = ENV['BITRISEIO_PULL_REQUEST_REPOSITORY_URL']
buildLogURL = ENV['BITRISE_BUILD_URL']

# Branch constants
branch = ENV['BITRISE_GIT_BRANCH']
isBuiltFromDevelop = branch == "develop"
isBuiltFromRelease = branch.start_with?("release") 
isPullRequest = pullRequestURL != nil
didFailBecauseOfTests = ENV['BITRISE_XCODE_TEST_RESULT'] == "failed"

##########################################

# Slack setup
Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
end
client = Slack::Web::Client.new
client.auth_test

# Message based on circumstances
if (didFailBecauseOfTests)
     if (isBuiltFromDevelop || isBuiltFromRelease)
         slackMessage = "@`#{branch}` has failed testing, the last commiter was #{authorSlackUsername} - see #{buildLogURL} for more information."
         client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
     else
         slackMessage = "@#{authorSlackUsername} your PR has fail testing - see #{buildLogURL} for more information."
         client.chat_postMessage(channel: "bitrise-slack-test", text: slackMessage, as_user: true)
    end
end
