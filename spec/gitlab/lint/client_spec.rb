require "gitlab/lint/client"

RSpec.describe Gitlab::Lint::Client do
  describe "it makes a real API request with valid yaml" do
    before do
      WebMock.allow_net_connect!
    end
    
    after do
      WebMock.disable_net_connect!
    end

    it "should accept required arguments and output response from api for valid yaml" do
      
      expectedOutput = """The arguments have been initialised as follows::
Base url => https://gitlab.com
Yaml file => spec/files/valid.yml
Making lint request to GitLab with path => spec/files/valid.yml and url => https://gitlab.com/api/v4/ci/lint
reponse from server is :: {\"status\"=>\"valid\", \"errors\"=>[]}
GitLab yaml file passed linting
"""
      expect {
        begin Gitlab::Lint::Client.entry(["--base-url=https://gitlab.com", "--yaml=spec/files/valid.yml"])
          rescue SystemExit
        end
      }.to output(expectedOutput).to_stdout
    end

    it "should accept required arguments and output response from api for invalid yaml" do
      
      expectedOutput = """The arguments have been initialised as follows::
Base url => https://gitlab.com
Yaml file => spec/files/invalid.yml
Making lint request to GitLab with path => spec/files/invalid.yml and url => https://gitlab.com/api/v4/ci/lint
Failed to parse the YAML File: (spec/files/invalid.yml): could not find expected ':' while scanning a simple key at line 3 column 1
reponse from server is :: {\"status\"=>\"invalid\", \"errors\"=>[\"Invalid configuration format\"]}
"""

      expectedAbortMessage="""Gitlab yaml file is invalid with errors:

Invalid configuration format"""
      
      expect {
        begin Gitlab::Lint::Client.entry(["--base-url=https://gitlab.com", "--yaml=spec/files/invalid.yml"])
          rescue SystemExit => error
            expect(error.message).to eq(expectedAbortMessage)
        end
      }.to output(expectedOutput).to_stdout
    end
  end
end
