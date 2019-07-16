module GitAnnounce
  class MessagesController < ApplicationController
    
    def receive

      request.body.rewind
      event_type = request.headers["X-GitHub-Event"]
      request_payload = JSON.parse(request.body.read)

      case event_type
      when 'pull_request'
        # Get values from the parsed JSON that we'll need as arguments later.
        # These reappear in every section because the format of 
        # The webhook received is slightly different for each event_type.
        action_done   = request_payload['action']
        owner         = request_payload['pull_request']['user']['login']
        repo_name     = request_payload['pull_request']['head']['repo']['name']
        title         = request_payload['pull_request']['title'] 
        link          = request_payload['pull_request']['_links']['html']['href']
        sender        = request_payload['sender']['login']
        merged        = request_payload['pull_request']['merged']
        sender_name   = GitAnnounce.developers[sender.to_sym]
        name          = GitAnnounce.developers[owner.to_s.to_sym]

        # If first letter of label is a vowel
        if ['A','E','I','O','U'].include?(label[0].upcase)
          article = "an"
        else
          article = "a"
        end

        unless GitAnnounce.ignore.include?(sender)
          
          case action_done 
          when 'review_requested'
            requested_reviewer = request_payload['requested_reviewer']['login']
            reviewer_name = GitAnnounce.developers[requested_reviewer.to_sym]
            full_message = "@**#{requested_reviewer}** -- #{sender_name} 
            requested a dev review from you on [#{title}](#{link})"

          when 'labeled' 
            unless sender == owner
              label         = request_payload['label']['name']             
              full_message = "@**#{name}** --  #{article} `#{label}` label was 
                            added to your PR by #{sender_name} 
                            [#{title}](#{link})."
            end
          
          when 'unlabeled'
            label         = request_payload['label']['name']
            unless sender == owner 
              full_message = "@**#{name}** --  #{article} `#{label}` label
                             was removed from your PR by #{sender_name} 
                             [#{title}](#{link})."
            end

          end # switch
        end # unless

      when 'issue_comment'
        action_done = request_payload['action']
        owner       = request_payload['issue']['user']['login']
        commenter   = request_payload['comment']['user']['login']
        repo_name   = request_payload['repository']['name']
        link        = request_payload['comment']['html_url']
        title       = request_payload['issue']['title']

        # If comment is made on a PR
        if action_done == 'created' && commenter != owner
          owner_name     = GitAnnounce.developers[owner.to_s.to_sym]
          commenter_name = GitAnnounce.developers[commenter.to_s.to_sym]
          full_message   = "#{commenter_name} just left a comment on 
                           @**#{owner_name}**'s PR [#{title}](#{link})."
        end

      when 'pull_request_review'
        action_done   = request_payload['action']
        owner         = request_payload['pull_request']['user']['login']
        reviewer      = request_payload['review']['user']['login']
        title         = request_payload['pull_request']['title'] 
        link          = request_payload['review']['html_url']  
        repo_name     = request_payload['pull_request']['head']['repo']['name']
        owner_name    = GitAnnounce.developers[owner.to_s.to_sym]
        reviewer_name = GitAnnounce.developers[reviewer.to_s.to_sym]
        

        if action_done == "submitted"
          status = request_payload['review']['state']

          case status
          when 'approved'
            full_message = "@**#{owner_name}** -- #{reviewer_name}
                           just approved your PR [#{title}](#{link})."
          when 'changes_requested'
            full_message = "@**#{owner_name}** -- #{reviewer_name} 
                           just requested changes on your PR [#{title}](#{link})."
          when 'commented'
            full_message = "@**#{owner_name}** -- #{reviewer_name} just 
                           left a review on your PR [#{title}](#{link})."
          end
        end

      when 'pull_request_review_comment'
        action_done   = request_payload['action']
        repo_owner    = request_payload['repository']['owner']['login']
        repo_name     = request_payload['pull_request']['head']['repo']['name']
        title         = request_payload['pull_request']['title']
        link          = request_payload['comment']['html_url']
        replier       = request_payload['comment']['user']['login']

        # if the comment made, was a reply to something
        if request_payload['comment'].key?("in_reply_to_id") 
          id            = request_payload['comment']['in_reply_to_id']
          comment_owner = GitHub.get_comment_owner(repo_owner, repo_name, id)
          replied_to    = GitAnnounce.developers[comment_owner.to_sym]
          who_replied   = GitAnnounce.developers[replier.to_sym]
          full_message  = "@**#{replied_to}** -- #{who_replied} responded 
                          to your comment on [#{title}](#{link})."
        end

      end # switch

      Zulip.zulip_message(ENV['ZULIP_DOMAIN'], ENV['STREAM_NAME'], repo_name, full_message)
      head :ok

    end # method
  end # class
end # module