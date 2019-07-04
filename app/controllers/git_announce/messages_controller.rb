module GitAnnounce
  class MessagesController < ApplicationController
    
    def create

      request.body.rewind
      request_payload = JSON.parse(request.body.read)

      action_done = request_payload['pull_request']['action']
      editor      = request_payload['pull_request']
      repo_name   = request_payload['pull_request']['head']['repo']['name']
      link        = request_payload['pull_request']['url']
      
      if action_done == "labeled"
        full_message = "#{editor} added a label in [#{repo_name}](#{link})"

      elsif action_done == "unlabeled"
        full_message = "#{editor} removed a label in [#{repo_name}](#{link})"
      end

      Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)

    end

  end
end