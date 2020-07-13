require "gitlab/lint/client/yml"

require 'json'
require 'net/http'

module Gitlab
  module Lint
    module Client
      
      class Api

        def lint (url, path, headers={ "Content-Type" => "application/json" }, timeout=10)
            puts "Making lint request to GitLab with path => #{path} and url => #{url}"
            if yamlContent = Gitlab::Lint::Client::YamlFile.new(path).get_json_content()
            
              uri = URI.parse(url)

              req = Net::HTTP::Post.new(uri, headers)
              req.body = { content: yamlContent }.to_json
              
              https = Net::HTTP.new(uri.host, uri.port)
              https.open_timeout = timeout
              https.read_timeout = timeout
              https.use_ssl = true
              https.verify_mode = OpenSSL::SSL::VERIFY_PEER
              
              response = https.request(req)
              
              case response
                  when Net::HTTPSuccess
                      return JSON.parse(response.body)
                  when Net::HTTPUnauthorized
                      abort("#{response.message}: invalid token in api request?")
                  when Net::HTTPServerError
                      abort("#{response.message}: server error, try again later?")
                  when Net::HTTPBadRequest
                      puts "Bad request..." + req.body
                      abort("#{response.message}: bad api request?")
                  when Net::HTTPNotFound
                      abort("#{response.message}: api request not found?")
                  else
                      abort("#{response.message}: failed api request?")
              end
            else
              abort("\nLint request failed, problem encountered reading yaml file")
            end
        end
      end
    end
  end
end

