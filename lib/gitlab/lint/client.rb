require "gitlab/lint/client/api"
require "gitlab/lint/client/args"
require "gitlab/lint/client/version"
require "gitlab/lint/client/summaryreport"

module Gitlab
  module Lint
    module Client
      def self.entry(cliArgs)

        args = Gitlab::Lint::Client::Args.new
        args.get(cliArgs)
        
        api = Gitlab::Lint::Client::Api.new

        headers = ENV.has_key?('GITLAB_API_TOKEN') ? {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Private-Token" => ENV['GITLAB_API_TOKEN'] 
        } : {
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        }

        puts "The arguments have been initialised as follows::"
        puts "Base url => #{args.baseUrl}"
        puts "Yaml file => #{args.pathToYamlFile}"

        response = api.lint(args.url, args.pathToYamlFile, headers, args.timeout)

        puts "reponse from server is :: #{response}"
        report = Gitlab::Lint::Client::SummaryReport.new(response['status'], response['errors'])
        report.summary()
      end
    end
  end
end
