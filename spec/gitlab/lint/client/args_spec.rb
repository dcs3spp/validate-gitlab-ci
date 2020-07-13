require 'stringio'
require "gitlab/lint/client/args"
require "gitlab/lint/client/version"

RSpec.describe Gitlab::Lint::Client::Args do
    describe "#version" do
        it "returns version number and exits" do
            expect do
                args = Gitlab::Lint::Client::Args.new
                
                expect(args.version).to.eq(Gitlab::Lint::Client::VERSION)
            end.to raise_error(SystemExit)
        end
    end

    describe "#initialize" do
        it "initialises with arguments unset" do
            args = Gitlab::Lint::Client::Args.new

            expect(args).to be_instance_of(Gitlab::Lint::Client::Args)
            expect(args.baseUrl).to be_nil()
            expect(args.url).to be_nil()
            expect(args.timeout).to be_nil()
            expect(args.pathToYamlFile).to be_nil()
        end
    end

    describe "#get" do
        context "when arguments are valid" do
            before do
                fileName='valid.yml'
                
                allow(File).to receive(:exist?).with(fileName).and_return(true)
                allow(File).to receive(:readable?).with(fileName).and_return(true)
            end

            it "sets baseUrl and pathToYamlFile with default timeout" do
                expectedBaseUrl = "https://gitlab.com"
                expectedPathToYamlFile = "valid.yml"
                expectedTimeout = 10
                expectedUrl = expectedBaseUrl + "/api/v4/ci/lint"

                args = Gitlab::Lint::Client::Args.new
                args.get(["--base-url=https://gitlab.com", "--yaml=valid.yml"])
               
                expect(args.baseUrl).to eq(expectedBaseUrl)
                expect(args.url).to eq(expectedUrl)
                expect(args.pathToYamlFile).to eq(expectedPathToYamlFile)
                expect(args.timeout).to eq(expectedTimeout)
            end

            it "sets baseUrl, pathToYamlFile and timeout" do
                expectedBaseUrl = "https://gitlab.com"
                expectedPathToYamlFile = "valid.yml"
                expectedTimeout = 5
                expectedUrl = expectedBaseUrl + "/api/v4/ci/lint"

                args = Gitlab::Lint::Client::Args.new
                args.get(["--base-url=https://gitlab.com", "--yaml=valid.yml", "--timeout=5"])
               
                expect(args.baseUrl).to eq("https://gitlab.com")
                expect(args.url).to eq(expectedUrl)
                expect(args.pathToYamlFile).to eq("valid.yml")
                expect(args.timeout).to eq(expectedTimeout)
            end

            it "returns version when --version option is issued" do
                expectedOutput = "GitLab Lint Client Version: #{Gitlab::Lint::Client::VERSION}\n"

                expect {
                    begin
                        args = Gitlab::Lint::Client::Args.new
                        args.get(["--version"])

                        rescue SystemExit
                    end
                }.to output(expectedOutput).to_stdout
            end
        end

        context "when arguments are missing" do
            it "raises an error when baseUrl option is missing" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--yaml=valid.yml",])
                end.to raise_error(SystemExit)
            end
    
            it "raises an error when pathToYamlFile option is missing" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--base-url=https://gitlab.com"])
                end.to raise_error(SystemExit)
            end
        end

        context "when argument options provided without values" do
            it "raises an error when base-url option value is missing" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--base-url", "--yaml=valid.yml"])
                end.to raise_error(SystemExit)
            end

            it "raises an error when yaml option value is missing" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--base-url", "--yaml"])
                end.to raise_error(SystemExit)
            end

        end

        context "when arguments are incorrectly formatted" do
            it "raises InvalidURIError for bad url argument" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--base-url=xxxx", "--yaml=valid.yml"])
                end.to raise_error(URI::InvalidURIError)
            end

            it "raises NameError for nil" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--base-url=", "--yaml=valid.yml"])
                end.to raise_error(URI::InvalidURIError) 
            end

            it "raises ArgumentError for a yaml file with invalid suffix" do
                expect do
                    args = Gitlab::Lint::Client::Args.new
                    args.get(["--base-url=https://gitlab.com","--yaml=valid.err"])
                end.to raise_error(ArgumentError)
            end

            it "raises IOError for a yaml file that does not exist" do
                expect do   
                    args = Gitlab::Lint::Client::Args.new

                    fileName='test.yaml'
                    allow(File).to receive(:exist?).with(fileName).and_return(false)

                    args.get(["--base-url=https://gitlab.com","--yaml=#{fileName}"])
                end.to raise_error(IOError)
            end

            it "raises RunetimeError for a yaml file that cannot be read" do
                expect do
                    args = Gitlab::Lint::Client::Args.new

                    fileName='test.yaml'
                    allow(File).to receive(:exist?).with(fileName).and_return(true)
                    allow(File).to receive(:readable?).with(fileName).and_return(false)

                    args.get(["--base-url=https://gitlab.com","--yaml=#{fileName}"])
                end.to raise_error(RuntimeError)
            end
        end
    end
end
