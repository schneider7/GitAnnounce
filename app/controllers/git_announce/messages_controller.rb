module GitAnnounce
  class MessagesController < ApplicationController
    
    def receive

      request.body.rewind
      request_payload = JSON.parse(request.body.read)
      action_done = request_payload['action']
      owner       = request_payload['pull_request']['user']['login']
      repo_name   = request_payload['pull_request']['head']['repo']['name']
      label       = request_payload['label']['name']
      title       = request_payload['pull_request']['title'] 
      link        = request_payload['pull_request']['_links']['html']['href']
         
      if action_done == "labeled"
        
        name = GitAnnounce.developers[owner.to_s.to_sym]
        full_message = "@**#{name}**,  a `#{label}` label was added to your PR:  [#{title}](#{link})."
        Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)        

      elsif action_done == "unlabeled"
        name = GitAnnounce.developers[owner.to_s.to_sym]
        full_message = "@**#{name}**,  a `#{label}` label was removed from your PR:  [#{title}](#{link})."
        Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)

      end
      
      head :ok
    end
  end
end