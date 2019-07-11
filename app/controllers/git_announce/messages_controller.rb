module GitAnnounce
  class MessagesController < ApplicationController
    
    def receive

      request.body.rewind
      event_type = request.headers["X-GitHub-Event"]
      request_payload = JSON.parse(request.body.read)

      action_done = request_payload['action']
      owner       = request_payload['pull_request']['user']['login']
      repo_name   = request_payload['pull_request']['head']['repo']['name']
      label       = request_payload['label']['name']
      title       = request_payload['pull_request']['title'] 
      link        = request_payload['pull_request']['_links']['html']['href']

      case event_type

      when 'pull_request'

        if ['A','E','I','O','U'].include?(label[0]) # If first letter of label is a vowel
          article = "an"
        else
          article = "a"
        end
          
        if action_done == "labeled"
          
          name = GitAnnounce.developers[owner.to_s.to_sym]
          full_message = "@**#{name}**,  #{article} `#{label}` label was added to your PR:  [#{title}](#{link})."
          Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)        

        elsif action_done == "unlabeled"
          name = GitAnnounce.developers[owner.to_s.to_sym]
          full_message = "@**#{name}**,  #{article} `#{label}` label was removed from your PR:  [#{title}](#{link})."
          Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)

        end
        
        head :ok
      end
    end
  end
end