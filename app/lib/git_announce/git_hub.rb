require 'net/http'

module GitAnnounce
  module GitHub

    def self.get_comment_owner(username, repo_name, id)
      uri = URI.parse("https://api.github.com/repos/#{username}/#{repo_name}/pulls/comments/#{id}")
      request = Net::HTTP.Get.new(uri)
      request["Authorization"] = "Authorization: token #{ENV["GITHUB_TOKEN"]}"
      
      payload = JSON.parse(response.body)      
      payload['user']['login']      
    end     
  end
end