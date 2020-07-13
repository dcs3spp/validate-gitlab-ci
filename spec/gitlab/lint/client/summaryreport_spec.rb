require "gitlab/lint/client/summaryreport"

RSpec.describe Gitlab::Lint::Client::SummaryReport do
    describe "#initialize" do
        it "should initialize" do
            summary = Gitlab::Lint::Client::SummaryReport.new('valid',[])

            expect(summary).to be_instance_of(Gitlab::Lint::Client::SummaryReport)
        end
    end

    describe "#summary" do
        context "valid status values" do
            it "should display success message when status is valid" do
                summary = Gitlab::Lint::Client::SummaryReport.new('valid',[])

                expect do
                    expect { summary.summary }.to output("GitLab yaml file passed linting").to_stdout
                end.to raise_error(SystemExit)
            end

            it "should display failure messages when status is invalid" do 
                summary = Gitlab::Lint::Client::SummaryReport.new('invalid',["error 1","error 2"])

                expect do
                    summary.summary
                end.to raise_error(SystemExit, "Gitlab yaml file is invalid with errors:\n\nerror 1\nerror 2")
            end
        end

        context "invalid status value" do
            it "should abort with message" do
                summary = Gitlab::Lint::Client::SummaryReport.new('unknown_key',["error 1","error 2"])

                expect do
                    summary.summary
                end.to raise_error(SystemExit, "A problem was encountered parsing status : unknown_key")
            end
        end
    end
end
