#!/usr/bin/env ruby
require 'slack-ruby-client'

# Environment variables
branch_name = ENV['BITRISE_GIT_BRANCH']
build_log_url = ENV['BITRISE_BUILD_URL']
pull_request_number = ENV['BITRISE_PULL_REQUEST']
test_result = ENV['BITRISE_XCODE_TEST_RESULT']
slack_channel = ENV['ASOS_ERROR_REPORTING_SLACK_CHANNEL']
slack_token = ENV['ASOS_SLACK_API_TOKEN']

# Computed variables
asos_team_members = {
  'ana.padinha@asos.com' => 'ana.padinha',
  'annino.depetra' => 'annino.depetra@asos.com',
  'ben.marsh' => 'ben.marsh@asos.com',
  'bence.pattogato' => 'bence.pattogato@asos.com',
  'chris.blackmore@asos.com' => 'chris.blackmore',
  'christianr' => 'christianr@asos.com',
  'daniel.tavares' => 'daniel.tavares@asos.com',
  'david.roman' => 'david.roman@asos.com',
  'deepthini.lansakara' => 'deepthini.lansakara@asos.com',
  'dylan.lewis' => 'dylan.lewis@asos.com',
  'king.chan' => 'king.chan@asos.com',
  'marcin.religa' => 'marcin.religa@asos.com',
  'matthew.calliss' => 'matthew.calliss@asos.com',
  'michael.waterfall' => 'michael.waterfall@asos.com',
  'nathaniel.walker' => 'nathaniel.walker@asos.com',
  'nicolas.robin' => 'nicolas.robin@asos.com',
  'oletha.lai' => 'oletha.lai@asos.com',
  'peter.goldsmith' => 'peter.goldsmith@asos.com',
  'roman.shevtsov' => 'roman.shevtsov@asos.com',
  'sam.ogunwe' => 'sam.ogunwe@asos.com',
  'stefano.piamonti' => 'stefano.piamonti@asos.com',
  'umair.naru' => 'umair.naru@asos.com',
  'zeeshan.naseer' => 'zeeshan.naseer@asos.com',
}  
commit_author_email_address = `git show -s --format='%ae' $(git rev-list --topo-order --no-merges HEAD -n 1)`.strip
commit_author_slack_username = asos_team_members[commit_author_email_address]
pull_request_url = "https://github.com/asosteam/asos-native-ios/pull/#{pull_request_number}"
is_built_from_develop = branch_name == "develop"
is_built_from_release = branch_name.start_with?("release") 
is_pull_request = pull_request_number != nil
xcode_test_did_fail = test_result == "failed"

# Slack setup
Slack.configure do |config|
    config.token = slack_token
end
client = Slack::Web::Client.new
client.auth_test

if (xcode_test_did_fail)
    slack_message = ""
    if (is_built_from_develop || is_built_from_release)
        # release/develop
        slack_message = "<!here> The latest build for `#{branch_name}` has failed, <@#{commit_author_slack_username}> was the last known commit author.\n*Log:* #{build_log_url}"
    else
        # PR
        slack_message = "<@#{commit_author_slack_username}> your recent commit for `#{branch}` has failed.\n*PR:* #{pull_request_url}\n*Log:* #{build_log_url}"
    end 
    client.chat_postMessage(channel: slack_channel, text: slack_message, as_user: true)
end


