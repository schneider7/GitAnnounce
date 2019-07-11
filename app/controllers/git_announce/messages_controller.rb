module GitAnnounce
  class MessagesController < ApplicationController
    
    def receive

      request.body.rewind
      event_type = request.headers["X-GitHub-Event"]
      request_payload = JSON.parse(request.body.read)

      case event_type
      when 'pull_request'

        action_done   = request_payload['action']
        owner         = request_payload['pull_request']['user']['login']
        repo_name     = request_payload['pull_request']['head']['repo']['name']
        label         = request_payload['label']['name']
        title         = request_payload['pull_request']['title'] 
        link          = request_payload['pull_request']['_links']['html']['href']
        sender        = request_payload['sender']['login']
        merged_status = request_payload['pull_request']['merged']

        if ['A','E','I','O','U'].include?(label[0].upcase) # If first letter of label is a vowel
          article = "an"
        else
          article = "a"
        end
        
        unless GitAnnounce.ignore.include?(sender)
          name = GitAnnounce.developers[owner.to_s.to_sym]

          case action_done
          when 'labeled'    
            full_message = "@**#{name}**,  #{article} `#{label}` label was added to your PR:  [#{title}](#{link})."    

          when 'unlabeled'
            full_message = "@**#{name}**,  #{article} `#{label}` label was removed from your PR:  [#{title}](#{link})."

          when 'closed'
            if merged_status == "true"
              full_message = "@**#{name}**, your PR [#{title}](#{link}) was just merged."
            end

          end # case
        end # unless

      when 'issue_comment'
        action_done = request_payload['action']
        owner       = request_payload['issue']['user']['login']
        commenter   = request_payload['comment']['user']['login']
        repo_name   = request_payload['repository']['name']
        link        = request_payload['comment']['html_url']
        title       = request_payload['issue']['title']

        # If comment is made on a PR
        if action_done == "created" && commenter != owner
          owner_name     = GitAnnounce.developers[owner.to_s.to_sym]
          commenter_name = GitAnnounce.developers[commenter.to_s.to_sym]
          full_message = "@**#{commenter_name}** left a comment on @**#{owner_name}**'s PR [#{title}](#{link})."
        end

      when 'pull_request_review'
        action_done = request_payload['action']
        status      = request_payload['review']['state']
        owner       = request_payload['pull_request']['user']['login']
        reviewer    = request_payload['review']['user']['login']
        link        = request_payload['review']['html_url']
        title       = request_payload['pull_request']['title']     

        owner_name      = GitAnnounce.developers[owner.to_s.to_sym]
        reviewer_name   = GitAnnounce.developers[reviewer.to_s.to_sym]
        
        if action_done == 'submitted'        
          case status
          when 'approved'
            full_message = "@**#{owner_name}**, #{reviewer_name} just approved changes on your PR [#{title}](#{link})."
          when 'changes_requested'
            full_message = "@**#{owner_name}**, changes were requested on your PR [#{title}](#{link}) by #{reviewer_name}."
          end
        end #if

      end # switch

      Http.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)
      head :ok

    end # function
  end # class
end # module