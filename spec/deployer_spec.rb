require "spec_helper"

RSpec.describe Deployer::Executor do
  context "filter" do
    let(:executor) {
      Deployer::Executor.new(Deployer::Stage.new("test"))
    }

    it "removes secret" do
      expect(executor.send(:filter, "argument1 --password a_secret")).to eq("argument1 --password [FILTERED]")
    end

    it "removes another secret" do
      expect(executor.send(:filter, "argument1 --password a_secret argument2")).to eq("argument1 --password [FILTERED] argument2")
    end

    it "removes secret with special characters" do
      expect(executor.send(:filter, "argument1 --password !=?$*()ok")).to eq("argument1 --password [FILTERED]")
    end

    it "removes multiple secrets" do
      expect(executor.send(:filter, "argument1 --password a_secret --password !@#$%&")).to eq("argument1 --password [FILTERED] --password [FILTERED]")
    end

    it "ignores without secret" do
      expect(executor.send(:filter, "argument1 argument2")).to eq("argument1 argument2")
    end
  end
end
