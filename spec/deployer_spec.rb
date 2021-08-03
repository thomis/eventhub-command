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

    it "ignores without secret value" do
      expect(executor.send(:filter, "argument1 --password")).to eq("argument1 --password")
    end

    it "ignores without secret value but with space" do
      expect(executor.send(:filter, "argument1 --password ")).to eq("argument1 --password ")
    end
  end

  context "log_command" do
    let(:executor) {
      Deployer::Executor.new(Deployer::Stage.new("test"))
    }

    it "logs given text" do
      expect {
        executor.send(:log_command, "just a text")
      }.to output("just a text".blue + "\n").to_stdout
    end

    it "logs given text with secret" do
      expect {
        executor.send(:log_command, "just a text --password ???")
      }.to output("just a text --password [FILTERED]".blue + "\n").to_stdout
    end
  end
end
