module GitAnnounce
  class MessagesController < ApplicationController
    
    def create

      request.body.rewind
      request_payload = JSON.parse(request.body.read)

      action_done = request_payload['action'] 
      editor      = request_payload['pull_request']['user']['login']
      number      = request_payload['number']
      repo_name   = request_payload['pull_request']['head']['repo']['name']
      link        = request_payload['pull_request']['_links']['html']['href']
         
      # Rails.logger.debug 
      #   "#{editor}, #{link}, #{action_done}, #{repo_name}, #{number}"
      
      if action_done == "labeled"
        # full_message = "#{editor} added a label on pull request #{number} in [#{repo_name}](#{link})"
        Http.zulip_message("labeled")
        

      elsif action_done == "unlabeled"
        # full_message = "#{editor} removed a label on pull request #{number} in [#{repo_name}](#{link})"
        Http.zulip_message("unlabeled")
        
      end
      
      head :ok

    end

  end
end