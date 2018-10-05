require "spec_helper"

module Rototiller
  # rubocop:disable Metrics/ModuleLength
  module Task
    # use each of these for the objects passed from it_behaves_like below
    #   (each of option from hash and from block)
    # rubocop:disable Metrics/BlockLength
    shared_examples "a Option object" do
      before(:each) do
        # stub out all the PRY env use, or the mocks for ENV below will break pry
        pryrc = ENV["PRYRC"]
        disable_pry = ENV["DISABLE_PRY"]
        home = ENV["HOME"]
        ansicon = ENV["ANSICON"]
        term = ENV["TERM"]
        pager = ENV["PAGER"]
        lines = ENV["LINES"]
        allow(ENV).to receive(:[]).with("PRYRC").and_return(pryrc)
        allow(ENV).to receive(:[]).with("DISABLE_PRY").and_return(disable_pry)
        allow(ENV).to receive(:[]).with("HOME").and_return(home)
        allow(ENV).to receive(:[]).with("ANSICON").and_return(ansicon)
        allow(ENV).to receive(:[]).with("TERM").and_return(term)
        allow(ENV).to receive(:[]).with("PAGER").and_return(pager)
        allow(ENV).to receive(:[]).with("LINES").and_return(lines)

        @option_name = random_string
        @argument_name = random_string
        @args = { name: @option_name, add_argument: { name: @argument_name } }
        @block = proc do |b|
          b.name = @option_name
          b.add_argument(name: @argument_name)
        end
      end

      describe "#name" do
        it "can directly set name" do
          expect { option.name = "wah" }.not_to raise_error
          expect(option.name).to eq("wah")
        end
        it "returns the name" do
          expect(option.name).to eq(@option_name)
        end
      end

      describe "#to_str" do
        it "returns the name" do
          expect(option.to_str).to eq("#{@option_name} #{@argument_name}")
        end
        # the rest of these perms are covered above, no need to repeat here
        it "can override option name with env_var" do
          # set env first, or option might not have it in time
          allow(ENV).to receive(:[]).with("BLAH").and_return("my_shiny_new_option")
          option.add_env(name: "BLAH")
          expect(option.to_str).to eq("my_shiny_new_option #{@argument_name}")
        end
      end
      it "fails when trying to set a message on an Option" do
        expect { option.message = "blah" }.to raise_error(NoMethodError)
      end
    end

    describe Option do
      it_behaves_like "a Option object" do
        let(:option)  { described_class.new(@args) }
      end
      it_behaves_like "a Option object" do
        let(:option)  { described_class.new(&@block) }
      end
    end
  end
end
