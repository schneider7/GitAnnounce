require 'net/http'

module GitAnnounce
  module GitHub

    def self.get_comment_owner(username, repo_name, id)

      uri = URI.parse("https://api.github.com/repos/#{username}/#{repo_name}/pulls/comments/#{id}")
   
      response = Net::HTTP.get_response(uri)

      Rails.logger.debug response
      
      # payload = JSON.parse(response.body.read)

      # payload['user']['login']
    end

      
  end
end