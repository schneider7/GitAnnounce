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

    def self.zulip_group_message(domain, recipients=[], content)
      uri = URI.parse("https://zulip.#{domain}.com/api/v1/messages")
      request = Net::HTTP::Post.new(uri) 
      request.basic_auth(ENV["BOT_EMAIL"], ENV["BOT_API_KEY"]) 

      Rails.logger.debug recipients.inspect
      
      request.body = "type=private&to=#{recipients[0]}, #{recipients[1]}&content=#{content}"
      
      req_options = { use_ssl: uri.scheme == "https", }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request) 
      end 
      
      JSON.parse response.body

    end
  end
end