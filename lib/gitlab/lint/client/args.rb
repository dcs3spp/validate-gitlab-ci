require 'optparse'
require 'uri'

require 'gitlab/lint/client/version'

module Gitlab
    module Lint
      module Client
        
        class Args
            API_PATH="/api/v4/ci/lint"
            
            attr_reader :baseUrl
            attr_reader :pathToYamlFile
            attr_reader :timeout
            attr_reader :url

            def initialize()
                @version = Gitlab::Lint::Client::VERSION
            end

            def get(args)
                options = {}
                optparse = OptionParser.new do|opt|
                    opt.banner = 'Usage: validate-gitlab-ci [options]'
                
                    opt.on('-f', '--yaml=YAML-PATH', 'Path to .gitlab-ci.yml') { |o| options[:yamlFile] = o }
                    opt.on('-u', '--base-url=BASE_URL', 'GitLab API url') { |o| options[:baseUrl] = o }

                    options[:timeout] = 10
                    opt.on('-t', '--timeout[=TIMEOUT]', Integer, 'Api timeout in seconds') { |o| options[:timeout] = o }
                
                    opt.on('-v', '--version', 'Program version') { |o| options[:version] = version() }
                end
                
                begin
                    optparse.parse!(args)
                    
                    if options[:version].nil?
                        mandatory = [:yamlFile, :baseUrl]
                        missing = mandatory.select{ |param| options[param].nil? }
                        if not missing.empty?
                            STDERR.puts "Required options #{missing[0]} are missing: #{missing.join(", ")}"
                            puts optparse.help
                            abort("Exiting due to error encountered while parsing arguments")
                        end
                    end

                rescue OptionParser::InvalidOption, OptionParser::MissingArgument => error
                    STDERR.puts error
                    puts optparse
                    abort("Exiting due to error encountered while parsing arguments...")
                end

                self.validateUrl!(options[:baseUrl])
                self.validateYamlFile!(options[:yamlFile])

                @baseUrl = options[:baseUrl]
                @url = options[:baseUrl] + API_PATH
                @pathToYamlFile = options[:yamlFile]
                @timeout = options[:timeout]
            end

            def validateUrl!(url)
                uri = URI.parse(url)
                valid = uri.is_a?(URI::HTTPS) && !uri.host.nil?
              
                raise URI::InvalidURIError unless valid
            end

            def validateYamlFile!(path)
                raise ArgumentError unless path.chars.last(4).join == ".yml" or path.chars.last(5).join == ".yaml"
                raise IOError unless ::File.exist?(path)
                raise RuntimeError unless ::File.readable?(path)
            end

            def version()
                string = "GitLab Lint Client Version: #{@version}"
                puts string
                exit 0
            end
        end
    end
end
end
