require 'net/http'

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
      payload     
    end     
  end
end