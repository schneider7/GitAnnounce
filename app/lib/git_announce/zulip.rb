require 'net/http'

module GitAnnounce
  module Zulip

    def self.zulip_message(domain, stream_name, repo_name, content)
      uri = URI.parse("https://zulip.#{domain}.com/api/v1/messages")
      
      request = Net::HTTP::Post.new(uri) 
      request.basic_auth(ENV["BOT_EMAIL"], ENV["BOT_API_KEY"]) 
      request.body = "type=stream&to=#{stream_name}&subject=#{repo_name}&content=#{content}" 
      
      req_options = { use_ssl: uri.scheme == "https", }       
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request) 
      end 
      
      JSON.parse response.body
    end 

    ###########################################################################
    ##   Method below works fine, but is part of a process overall didn't    ##
    ##   work as I intended.                                                 ##
    ##   I'm leaving it here because I think it'd be a really helpful tool,  ##
    ##   if only GitHub::post_comment worked as intended.                    ##
    ##   It's on my to-fix list.                                             ##
    ###########################################################################

    # def self.zulip_private_message(domain, recipients=[], content)
    #   uri = URI.parse("https://zulip.#{domain}.com/api/v1/messages")
    #   request = Net::HTTP::Post.new(uri) 
    #   request.basic_auth(ENV["BOT_EMAIL"], ENV["BOT_API_KEY"]) 

    #   to = "#{recipients.join(", ")}"
      
    #   request.body = "type=private&to=#{to}&content=#{content}"
      
    #   req_options = { use_ssl: uri.scheme == "https", }

    #   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #     http.request(request) 
    #   end 
      
    #   JSON.parse response.body

    # end
  end
end