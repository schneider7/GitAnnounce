module GitAnnounce
  class MessagesController < ApplicationController
    
    def receive

      request.body.rewind
      event_type = request.headers["X-GitHub-Event"]
      request_payload = JSON.parse(request.body.read)

     

      case event_type

      when 'pull_request'

        action_done = request_payload['action']
        owner       = request_payload['pull_request']['user']['login']
        repo_name   = request_payload['pull_request']['head']['repo']['name']
        label       = request_payload['label']['name']
        title       = request_payload['pull_request']['title'] 
        link        = request_payload['pull_request']['_links']['html']['href']

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

      when 'issue_comment'
        action_done = request_payload['action']
        owner       = request_payload['issue']['user']['login']
        repo_name   = request_payload['repository']['name']
        link        = request_payload['comment']['html_url']
        title       = request_payload['issue']['title']

        # If comment is made on PR
        if action_done == "created"
          name = GitAnnounce.developers[owner.to_s.to_sym]
          full_message = "@**#{name}**, someone left a comment on your PR (`#{title}`). Read it [here](#{link})"
        end

        Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)
        head :ok
    


      end # when
    end # function
  end # class
end # module