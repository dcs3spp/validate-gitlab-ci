#!/usr/bin/env ruby


require 'json'
require 'net/http'
require 'optparse'
require 'yaml'


=begin
POST to GitLab api for linting ci yaml
Params:
+url+ :: Api url
+yaml+ :: Yaml payload for linting
Returns:
Json validation result from API for HTTP response Success
Aborts with HTTP Message for all other status codes
=end
def call_api(url, yaml)
    uri = URI.parse(url)
    
    req = Net::HTTP::Post.new(uri)
    req.content_type='application/json'
    req['Accept']='application/json'
    req.body = JSON.dump({"content" => yaml.to_json})
    
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    
    response = https.request(req)

    case response
        when Net::HTTPSuccess
            puts "request successful"
            return JSON.parse response.body
        when Net::HTTPUnauthorized
            abort("#{response.message}: invalid token in api request?")
        when Net::HTTPServerError
            abort('error' => "#{response.message}: server error, try again later?")
        when Net::HTTPBadRequest
            puts "Bad request..." + request.body
            abort("#{response.message}: bad api request?")
        when Net::HTTPNotFound
            abort("#{response.message}: api request not found?")
        else
            puts "Failed validation\nJSON payload :: #{request.body}\nHTTP Response: #{response.message}"
            abort("#{response.message}: failed api request?")
    end
end


=begin
Display exit report and raise the appropriate system exit code
Params:
+status+ :: Validation status string.  Legal values are valid or invalid
+errors+ :: String array storing errors if yaml was reported as invalid
Returns:
Exits with 0 when successful
Exits with 1 on validation errors or fails to parse legal status value
=end
def exit_report(status, errors)
    case status
        when "valid"
            puts ".gitlab-ci.yml is valid"
            exit(0)
        when "invalid"
            abort(".gitlab-ci.yml is invalid with errors:\n\n" + errors.join("\n"))
        else 
            abort("A problem was encountered parsing status : " + status)  
    end
end


=begin
Load yaml file from path and return contents
Params:
+path+ :: Absolute or relative path to .gitlab-ci.yml file
=end
def load_yaml(path)
    begin
        YAML.load_file(path)
    rescue Errno::ENOENT
        abort("Failed to load .gitlab-ci.yml")
    end
end

=begin
Parse command line options
Returns:
Hash containing keys: {:yaml_file,:url}
=end
def read_args()
    options = {}
    OptionParser.new do |opt|
        opt.on('-f', '--yaml YAML-PATH', 'Path to .gitlab-ci.yml') { |o| options[:yaml_file] = o }
        opt.on('-l', '--url GitLab url', 'GitLab API url') { |o| options[:url] = o }
    end.parse!

    options
end

=begin
Load yaml to send to GitLab API for linting
Display report of linting retrieved from api
Returns:
Exits with 0 upon success and 1 when errors encountered
=end
def main()
    # try and parse the arguments
    options = read_args()
    unless !options.has_key?(:yaml_file) || !options.has_key?(:url)
         # try and load the yaml from path
        puts "Loading file #{options[:yaml_file]}"
        yaml = load_yaml(options[:yaml_file])

        # make lint request to api
        puts "Making POST request to #{options[:url]}"
        response_data=call_api(options[:url], yaml)

        # display exit report and raise appropriate exit code
        unless !response_data.has_key?("status") || !response_data.has_key?("errors")
            exit_report response_data["status"], response_data["errors"]
        else
            puts "Something went wrong parsing the json response " + response_data
        end
    else
        abort("Missing required arguments yaml_file and url, use -h for usage")
    end
end

# start
main
