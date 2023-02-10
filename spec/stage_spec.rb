require "spec_helper"

RSpec.describe Deployer::Stage do
  let!(:stage) { Deployer::Stage.new("component") }

  it "adds host, port and user" do
    stage.host("host1", "port1", "user1")
    expect(stage.hosts.size).to eq(1)
    expect(stage.hosts[0]).to eq({host: "host1", port: "port1", user: "user1"})
  end

  it "returns one host" do
    stage.host("host1", "port1", "user1")
    single_host_stage = stage.single_host_stage
    expect(single_host_stage.hosts.size).to eq(1)
    expect(single_host_stage.hosts[0]).to eq({host: "host1", port: "port1", user: "user1"})
  end

  it "loads from yaml file" do
    stage = Deployer::Stage.load("component", "spec/fixtures/development.yml")
    expect(stage.hosts.size).to eq(1)
    expect(stage.hosts[0]).to eq({host: "host1", port: "port1", user: "user1"})
  end
end
