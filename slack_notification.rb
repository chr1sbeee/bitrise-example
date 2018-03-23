#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'pp'

# Prints env variables, remove at some point
pp ENV

# Slack constants
teamMembers = {
  'chris.blackmore@asos.com' => '@chris.blackmore',
}
authorEmailAddress = ENV['GIT_CLONE_COMMIT_AUTHOR_EMAIL']
authorSlackUsername = teamMembers[authorEmailAddress] ?? 
slackChannel = "bitrise-slack-test"

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
         slackMessage = "<!here> a primary branch has failed testing.\n*Branch:* `#{branch}`\n*Last commit author:* #{authorSlackUsername}\n*Log:* #{buildLogURL}"
         client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
     else
         slackMessage = "A Pull Request branch has failed testing.\n*Branch:* `#{branch}`\n*PR:* #{pullRequestURL}\n*Last commit author:* #{authorSlackUsername}\n*Log:* #{buildLogURL}"
         client.chat_postMessage(channel: slackChannel, text: slackMessage, as_user: true)
    end
end
