#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

pp ENV

# TODO: Map all emails to slack user names
teamMembers = {
  'chris.blackmore@asos.com' => '@chris.blackmore',
} 

# Since BR creates a separate merge commit we need to roll back to the last commit author that wasn't a merge
authorEmailAddress = `git show -s --format='%ae' $(git rev-list --topo-order --no-merges HEAD -n 1)`.strip
pullRequestNumber = ENV['BITRISE_PULL_REQUEST']
pullRequestURL = "https://github.com/asosteam/asos-native-ios/pull/#{pullRequestNumber}"
buildLogURL = ENV['BITRISE_BUILD_URL']
branch = ENV['BITRISE_GIT_BRANCH']
testResult = ENV['BITRISE_XCODE_TEST_RESULT']
authorSlackUsername = teamMembers[authorEmailAddress]
slackChannel = "bitrise-slack-test"
isBuiltFromDevelop = branch == "develop" 
isBuiltFromRelease = branch.start_with?("release") 
isPullRequest = pullRequestURL != nil
didFailBecauseOfTests = testResult == "failed"

# Early exit
if (!didFailBecauseOfTests)
    exit 0
end

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
         slackMessage = "<!here> a primary branch has failed testing.\n*Branch:* `#{branch}`\n*Log:* #{buildLogURL}"
         client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
     else
          slackMessage = "<#{authorSlackUsername}> your recent commit for `#{branch}` has failed unit/UI tests.\n*PR:* #{pullRequestURL}\n*Log:* #{buildLogURL}"
          client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
    end
end
