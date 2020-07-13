require "gitlab/lint/client/api"
require "gitlab/lint/client/yml"

RSpec.describe Gitlab::Lint::Client::Api do
    
    describe "#initialize" do
        it "initialises" do          
            api = Gitlab::Lint::Client::Api.new
            expect(api).to be_instance_of(Gitlab::Lint::Client::Api)
        end
    end

    describe "#lint" do
        before(:each) do
            @defaultHeaders = {
                'Accept'=>'*/*', 
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
                'Content-Type'=>'application/json',
                'Host'=>'gitlab.com',
                'User-Agent'=>'Ruby'
            }            
            @endpointUrl = 'https://gitlab.com/api/v4/ci/lint'
            @fileName='test.yml'
            
            allow(File).to receive(:exist?).with(@fileName).and_return(true)
            allow(File).to receive(:readable?).with(@fileName).and_return(true)
        end

        context "valid https request" do
            it "calls API and returns linting response" do
                yamlContent = "image: ruby:latest"
                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                expectedResponse = { 'status' => 'valid', 'errors' => [] }.to_json

                stub_request(:post, @endpointUrl).to_return(status: 200, body: expectedResponse)
                
                api = Gitlab::Lint::Client::Api.new
                response = api.lint(@endpointUrl, @fileName)

                expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: @defaultHeaders).once
                expect(response).to eq(JSON.parse(expectedResponse))
            end

            it "accepts custom headers" do
                yamlContent = "image: ruby:latest"
                expectedHeaders = {
                    'Accept'=>'application/json', 
                    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
                    'Content-Type'=>'application/json',
                    'Host'=>'gitlab.com',
                    'User-Agent'=>'Ruby'
                }        

                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                expectedResponse = { 'status' => 'valid', 'errors' => [] }.to_json

                stub_request(:post, @endpointUrl).to_return(status: 200, body: expectedResponse)
                
                api = Gitlab::Lint::Client::Api.new
                response = api.lint(@endpointUrl, @fileName, expectedHeaders)

                expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: expectedHeaders).once
                expect(response).to eq(JSON.parse(expectedResponse))
            end

            # it "accepts custom timeout period" do
            #     yamlContent = "image: ruby:latest"
            #     expectedTimeout = 5
            #     allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

            #     mockHttps = instance_double(Net::HTTP)
            #     stub_request(:post, @endpointUrl).to_timeout
                
            #     expect do
            #         api = Gitlab::Lint::Client::Api.new
            #         response = api.lint(@endpointUrl, @fileName, @defaultHeaders, expectedTimeout)    
            #     end.to raise_error(Net::OpenTimeout)

            #     expect(mockHttps.read_timeout).to eq(expectedTimeout)
            #     expect(mockHttps.open_timeout).to eq(expectedTimeout)
            # end
        end

        context "Invalid Yaml to json" do
            it "aborts when YAML fails to generate json content" do
                expect do
                    yamlContent = 'invalid'
                    allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)
                    allow(JSON).to receive(:generate).and_return(yamlContent)
                    
                    api = Gitlab::Lint::Client::Api.new
                    response = api.lint(@endpointUrl, @fileName)
                    
                    expect(a_request(:any, @endpointUrl)).not_to have_been_made
                end.to raise_error(SystemExit, "\nLint request failed, problem encountered reading yaml file")
            end
        end

        context "HTTP Errors" do
            it "aborts when receive Bad Request" do
                yamlContent = "image: ruby:latest"
                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                
                stub_request(:post, @endpointUrl).to_return(status: [400, 'bad request'])
                
                expect do
                    api = Gitlab::Lint::Client::Api.new
                    response = api.lint(@endpointUrl, @fileName)
                    
                    expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: @defaultHeaders).once
                end.to raise_error(SystemExit, 'bad request: bad api request?')
            end

            it "aborts when receive Unauthorized Request" do
                yamlContent = "image: ruby:latest"
                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                
                stub_request(:post, @endpointUrl).to_return(status: [401, 'Unauthorized'])
                
                expect do
                    api = Gitlab::Lint::Client::Api.new
                    response = api.lint(@endpointUrl, @fileName)
                    
                    expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: @defaultHeaders).once
                end.to raise_error(SystemExit, 'Unauthorized: invalid token in api request?')
            end

            it "aborts when receive Unauthorized Request" do
                yamlContent = "image: ruby:latest"
                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                
                stub_request(:post, @endpointUrl).to_return(status: [500, 'Internal Server Error'])
                
                expect do
                    api = Gitlab::Lint::Client::Api.new
                    response = api.lint(@endpointUrl, @fileName)
                    
                    expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: @defaultHeaders).once
                end.to raise_error(SystemExit, 'Internal Server Error: server error, try again later?')
            end

            it "aborts when receive Not Found" do
                yamlContent = "image: ruby:latest"
                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                
                stub_request(:post, @endpointUrl).to_return(status: [404, 'Not Found'])
                
                expect do
                    api = Gitlab::Lint::Client::Api.new
                    response = api.lint(@endpointUrl, @fileName)
                    
                    expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: @defaultHeaders).once
                end.to raise_error(SystemExit, 'Not Found: api request not found?')
            end

            it "aborts for unexpected HTTP error status" do
                yamlContent = "image: ruby:latest"
                allow(YAML).to receive(:load_file).with(@fileName).and_return(yamlContent)

                expectedRequest = '{"content":"\"image: ruby:latest\""}'
                
                stub_request(:post, @endpointUrl).to_return(status: [403, 'Forbidden'])
                
                expect do
                    api = Gitlab::Lint::Client::Api.new
                    response = api.lint(@endpointUrl, @fileName)
                    
                    expect(WebMock).to have_requested(:post, @endpointUrl).with(body: expectedRequest, headers: @defaultHeaders).once
                end.to raise_error(SystemExit, 'Forbidden: failed api request?')
            end
        end

    end
end
