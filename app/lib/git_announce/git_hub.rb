require 'net/http'
require 'json'

module GitAnnounce
  module GitHub

    def self.get_comment_owner(username, repo_name, id)
      uri = URI.parse("https://api.github.com/repos/#{username}/#{repo_name}/pulls/comments/#{id}")
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


    ###########################################################################
    ##   Method below doesn't work. I'm leaving it here because if it worked ##
    ##   as intended, it'd be a really helpful tool. On my to-fix list.      ##
    ###########################################################################

    # def self.post_comment(id, repo, number, content)
    #   uri = URI.parse("https://api.github.com/repos/#{ENV["GITHUB_ORG"]}/#{repo}/pulls/#{number}/comments")
    #   request = Net::HTTP::Post.new(uri)
    #   request.content_type = "application/json"
    #   request["Authorization"] = "token #{ENV["GITHUB_TOKEN"]}"
    #   request.body = JSON.dump({
    #     "body" => "#{content}",
    #     "in_reply_to" => id
    #   })

    #   req_options = {
    #     use_ssl: uri.scheme == "https",
    #   }

    #   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #     http.request(request)
    #   end
    # end
   
  end
end