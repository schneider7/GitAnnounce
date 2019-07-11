module GitAnnounce
  class MessagesController < ApplicationController
    
    def receive

      request.body.rewind
      event_type = request.headers["X-GitHub-Event"]
      payload = JSON.parse(request.body.read)

       
      case event_type       
      
      when 'pull_request'
        # Getting values from parsed JSON that we'll need as arguments later
        action_done   = payload['action']
        owner         = payload['pull_request']['user']['login']
        repo_name     = payload['pull_request']['head']['repo']['name']
        label         = payload['label']['name']
        title         = payload['pull_request']['title'] 
        link          = payload['pull_request']['_links']['html']['href']
        merged_status = payload['pull_request']['merged']
        # sender        = payload['sender']['login']

        # Making sure message is grammatically correct
        # if ['A','E','I','O','U'].include?(label[0]) # If first letter of label is a vowel
        #   article = "an"
        # else
        #   article = "a"
        # end 
          
        # unless GitAnnounce.ignore.include?(sender) # Ignore automatic changes by bots
        
        # If label is added
        if action_done == 'labeled'         
          full_message = "@**#{GitAnnounce.developers[owner.to_s.to_sym]}**, #{article} `#{label}` label was added to your PR: [#{title}](#{link})."
        
          
        # If label is removed  
        elsif action_done == 'unlabeled'
            full_message = "@**#{GitAnnounce.developers[owner.to_s.to_sym]}**, #{article} `#{label}` label was removed from your PR: [#{title}](#{link})."
          
        # If PR is merged (into master)
        elsif action_done == "closed" && merged_status == "true"
          full_message = "@**#{GitAnnounce.developers[owner.to_s.to_sym]}**, your PR [#{title}](#{link}) was just merged."
        end    
        # end

        Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)      
        head :ok
        
        
      when 'issue_comment'
        action_done = payload['action']
        owner       = payload['issue']['user']['login']
        repo_name   = payload['repository']['name']
        link        = payload['comment']['html_url']
        title       = payload['issue']['title']

        # If comment is made on PR
        if action_done == "created"
          full_message = <<~MESSAGE
            @**#{GitAnnounce.developers[name.to_s.to_sym]}**, someone left a comment on your PR (`#{title}`).
            Read it [here](#{link})
          MESSAGE
        end

        Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)      
        head :ok

      
      when 'pull_request_review'
        action_done = payload['action']
        status      = payload['review']['state']
        owner       = payload['review']['user']['login']
        link        = payload['review']['html_url']
        title       = payload['pull_request']['title'] 
        repo_name   = payload['pull_request']['head']['repo']['name']

        if action_done == "submitted"        
          case status
          when 'approved'
            full_message = <<~MESSAGE
              @**#{GitAnnounce.developers[name.to_s.to_sym]}**, a dev reviewer just approved changes on your PR 
              (`#{title}`). Check it out [here](#{link})
            MESSAGE

          when 'changes_requested'
            full_message = <<~MESSAGE
              @**#{GitAnnounce.developers[name.to_s.to_sym]}**, changes were requested on your PR 
              (`#{title}`). Read the comments [here](#{link})
            MESSAGE
          end
        end

        Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)      
        head :ok
      end      
    end

    # def zulip_name(name)
    #     GitAnnounce.developers[name.to_s.to_sym]
    # end

  end
end
