module GitAnnounce
  class MessagesController < ApplicationController
    
    def create

      request.body.rewind
      request_payload = JSON.parse(request.body.read)
      
      editor      = request_payload['pull_request']['user']['login']
      link        = request_payload['pull_request']['url']
      action_done = request_payload['pull_request']['action']
      repo_name   = request_payload['pull_request']['head']['repo']['name']
      number      = request_payload['pull_request']['number']
      
      
      if action_done == "labeled"
        full_message = "#{editor} added a label on pull request #{number} in [#{repo_name}](#{link})"
        Http.zulip_message(repo_name, full_message)
        

      elsif action_done == "unlabeled"
        full_message = "#{editor} removed a label on pull request #{number} in [#{repo_name}](#{link})"
        Http.zulip_message(repo_naSme, full_message)
        
      end
      
      head :ok

    end

  end
end