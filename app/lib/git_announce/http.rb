require 'net/http'

module GitAnnounce
  module Http

    def self.zulip_message(domain, stream_name, repo_name, content)
      uri = URI.parse("https://zulip.#{domain}.com/api/v1/messages")
      

      #Bot email is github-updates-bot@zulip.sycamoreeducation.com
      #Bot key is 2nwoBCfZHkghL6paI7j9PIY8th03K54T
      request = Net::HTTP::Post.new(uri) 
      request.basic_auth('github-updates-bot@zulip.sycamoreeducation.com', '2nwoBCfZHkghL6paI7j9PIY8th03K54T') 
      request.body = "type=stream&to=#{stream_name}&subject=#{repo_name}&content=#{content}" 
      
      req_options = { use_ssl: uri.scheme == "https", } 
      
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request) 
      end 
      
      JSON.parse response.body
    end 

  end
end