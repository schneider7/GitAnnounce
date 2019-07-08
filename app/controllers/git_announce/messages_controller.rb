module GitAnnounce
  class MessagesController < ApplicationController
    
    def create

      request.body.rewind
      request_payload = JSON.parse(request.body.read)

      action_done = request_payload['action'] 
      editor      = request_payload['pull_request']['user']['login']
      repo_name   = request_payload['pull_request']['head']['repo']['name']
      label       = request_payload['pull_request']['label']['name']
      title       = request_payload['pull_request']['title']
      link        = request_payload['pull_request']['_links']['html']['href']
         
      # Rails.logger.debug 
      #   "#{editor}, #{link}, #{action_done}, #{repo_name}, #{number}"
      
      if action_done == "labeled"
        full_message = "#{editor} added a '#{label}' label on [#{title}](#{link}) in #{repo_name}."
        Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)        

      elsif action_done == "unlabeled"
        full_message = "#{editor} removed a '#{label}' label on [#{title}](#{link}) in #{repo_name}."
        Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)
        
      end
      
      head :ok

    end

  end
end