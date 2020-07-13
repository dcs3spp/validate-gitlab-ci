require "gitlab/lint/client/yml"

RSpec.describe Gitlab::Lint::Client::YamlFile do
    describe "#initialize" do
        context "valid filename" do
            it "should test that initialises with yml suffix" do
                fileName='test.yml'

                allow(File).to receive(:exist?).with(fileName).and_return(true)
                allow(File).to receive(:readable?).with(fileName).and_return(true)
            
                yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName)
                
                expect(yamlContent).to be_instance_of(Gitlab::Lint::Client::YamlFile)
                expect(yamlContent.file).to eq(fileName)
            end

            it "should test that initialises with yaml suffix" do
                fileName='test.yaml'

                allow(File).to receive(:exist?).with(fileName).and_return(true)
                allow(File).to receive(:readable?).with(fileName).and_return(true)
            
                yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName)

                expect(yamlContent).to be_instance_of(Gitlab::Lint::Client::YamlFile)
                expect(yamlContent.file).to eq(fileName)
            end
        end

        context "invalid filename" do
            it "should raise NameError when filename is nil" do 
                expect {yamlContent = Gitlab::Lint::Client::YamlFile.new(nil) }.to raise_error(NameError)
            end

            it "should raise ArgumentError when filename has an invalid suffix" do
                expect {yamlContent = Gitlab::Lint::Client::YamlFile.new('test.txt') }.to raise_error(ArgumentError)
            end

            it "should raise IOError when filename does not exist" do
                fileName='test.yaml'

                allow(File).to receive(:exist?).with(fileName).and_return(false)
                expect {yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName) }.to raise_error(IOError)
            end

            it "should raise RuntimeError when filename could not be read" do
                fileName='test.yaml'

                allow(File).to receive(:exist?).with(fileName).and_return(true)
                allow(File).to receive(:readable?).with(fileName).and_return(false)
                expect {yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName) }.to raise_error(RuntimeError)
            end
        end
    end

    describe "#get_content" do
        it "should return yaml file content" do
            fileName='test.yml'

            allow(File).to receive(:exist?).with(fileName).and_return(true)
            allow(File).to receive(:readable?).with(fileName).and_return(true)
            allow(YAML).to receive(:load_file).with(fileName).and_return("image: ruby:latest")
          
            yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName)
            content = yamlContent.get_content()

            expect(content).to eq(content)
        end

        it "should write error to stdout for invalid yaml" do
            expectedError="Failed to parse the YAML File: (spec/files/invalid.yml): could not find expected ':' while scanning a simple key at line 3 column 1\n" 
            fileName='spec/files/invalid.yml'

            allow(File).to receive(:exist?).with(fileName).and_return(true)
            allow(File).to receive(:readable?).with(fileName).and_return(true)
            
            yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName)
            expect { yamlContent.get_content() }.to output(expectedError).to_stdout
        end
    end

    describe "#get_json_content" do
        context "valid content" do
            it "should return escaped json for yaml file content" do
                fileName='test.yml'
                yamlContent= {
                    "image"=>"maven:latest",
                    "variables"=>{
                        "MAVEN_CLI_OPTS"=>"-s .m2/settings.xml --batch-mode",
                        "MAVEN_OPTS"=>"-Dmaven.repo.local=.m2/repository"
                    },
                    "stages"=>["build", "testing", "code-coverage"],
                    "compile"=>{
                        "stage"=>"build",
                        "script"=>["mvn $MAVEN_CLI_OPTS compile"]
                    }
                } 
                expectedJSON=JSON.dump(yamlContent)
            
                allow(File).to receive(:exist?).with(fileName).and_return(true)
                allow(File).to receive(:readable?).with(fileName).and_return(true)
                allow(YAML).to receive(:load_file).with(fileName).and_return(yamlContent)
          
                yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName)
                expect(yamlContent.get_json_content()).to eq(expectedJSON)
            end
        end

        context "invalid content" do
            it "should return nil on invalid content" do
                fileName='test.yml'

                allow(File).to receive(:exist?).with(fileName).and_return(true)
                allow(File).to receive(:readable?).with(fileName).and_return(true)
            
                yamlContent = Gitlab::Lint::Client::YamlFile.new(fileName)
                expect(yamlContent.file).to eq(fileName)
               
                allow(yamlContent).to receive(:get_content).and_return("invalid")
                allow(JSON).to receive(:generate).and_return("invalid")
                
                expect(yamlContent.get_json_content()).to eq(nil)
            end
        end
    end
end
