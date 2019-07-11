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
        sender      = request_payload['sender']['login']

        if ['A','E','I','O','U'].include?(label[0]) # If first letter of label is a vowel
          article = "an"
        else
          article = "a"
        end
        
        unless GitAnnounce.ignore.include?(sender)
          name = GitAnnounce.developers[owner.to_s.to_sym]
          
          if action_done == "labeled"    
            full_message = "@**#{name}**,  #{article} `#{label}` label was added to your PR:  [#{title}](#{link})."    

          elsif action_done == "unlabeled"
            full_message = "@**#{name}**,  #{article} `#{label}` label was removed from your PR:  [#{title}](#{link})."

          end
          Http.zulip_message(ENV["ZULIP_DOMAIN"], ENV["STREAM_NAME"], repo_name, full_message)
          head :ok
        end # unless

      when 'issue_comment'
        action_done = request_payload['action']
        owner       = request_payload['issue']['user']['login']
        repo_name   = request_payload['repository']['name']
        link        = request_payload['comment']['html_url']
        title       = request_payload['issue']['title']

        # If comment is made on PR
        if action_done == "created"
          name = GitAnnounce.developers[owner.to_s.to_sym]
          full_message = "@**#{name}**, someone left a comment on your PR '#{title}'. Read it [here](#{link})"
        end

        Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)
        head :ok

      when 'pull_request_review'
        action_done = payload['action']
        status      = payload['review']['state']
        owner       = payload['review']['user']['login']
        link        = payload['review']['html_url']
        title       = payload['pull_request']['title']     

        name = GitAnnounce.developers[owner.to_s.to_sym]
        
        if action_done == "submitted"        
          case status
          when 'approved'
            full_message = "@**#{name}**, a dev reviewer just approved changes on your PR (`#{title}`). Check it out [here](#{link})"
          when 'changes_requested'
            full_message = "@**#{name}**, changes were requested on your PR (`#{title}`). Read the comments [here](#{link})"
          end
        end

        Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)
        head :ok

      end # when
    end # function
  end # class
end # module