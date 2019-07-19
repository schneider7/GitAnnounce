require 'net/http'
require 'json'

module GitAnnounce
  module GitHub

    @base_uri = "https://api.github.com/repos/"
    def self.get_comment_owner(username, repo_name, id)
      uri = URI.parse(@base_uri + "#{username}/#{repo_name}/pulls/comments/#{id}")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "token #{ENV["GITHUB_TOKEN"]}"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      payload = JSON.parse(response.body)     
      payload['user']['login']     
    end     

    def self.post_comment(id, repo, number, content)
      uri = URI.parse(@base_uri + "#{ENV["GITHUB_ORG"]}/#{repo}/pulls/#{number}/comments/")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request["Authorization"] = "token #{ENV["GITHUB_TOKEN"]}"
      
      request.body = JSON.dump({
        "body" => "#{content}",
        "in_reply_to" => "#{id}"
      })

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

    end

    
  end
end