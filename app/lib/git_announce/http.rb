require 'net/http'

module GitAnnounce
  module Http

    def self.zulip_message(content)
      uri = URI.parse("https://zulip.sycamoreeducation.com/api/v1/messages")
      

      #Bot email is mgithub-updates-bot@zulip.sycamoreeducation.co
      #Bot key is 2nwoBCfZHkghL6paI7j9PIY8th03K54T
      request = Net::HTTP::Post.new(uri) 
      request.basic_auth("github-updates-bot@zulip.sycamoreeducation.com", "2nwoBCfZHkghL6paI7j9PIY8th03K54T") 
      request.body = "type=stream&to=GitHub Notifications&subject=Repo Name Here&content=#{content}" 
      
      req_options = { use_ssl: uri.scheme == "https", } 
      
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request) 
      end 
      
      JSON.parse response.body
    end 

  end
end