require "spec_helper"

RSpec.describe Deployer::BaseDeployer do
  before(:each) do
    settings = Eh::Settings.load("spec/fixtures/eh2.json")
    Eh::Settings.current = settings
  end

  let!(:deployer) { Deployer::BaseDeployer.new(stage: "development") }

  it "has a a base_dir" do
    expect(deployer.send(:base_dir)).to eq("~/apps/event_hub")
  end

  it "has a config_source_dir" do
    expect(deployer.send(:config_source_dir, "what")).to eq("~/apps/event_hub/config/what")
  end

  it "has a deploy_log_file" do
    expect(deployer.send(:deploy_log_file)).to eq("~/apps/event_hub/shared/logs/deploy.log")
  end

  it "has deploy_via" do
    expect(deployer.send(:deploy_via)).to eq(nil)
  end

  it "has verbose?" do
    expect(deployer.send(:verbose?)).to eq(nil)
  end

  it "has via_scp?" do
    expect(deployer.send(:via_scp?)).to eq(false)
  end

  it "has shared_dir" do
    expect(deployer.send(:shared_dir)).to eq("~/apps/event_hub/shared")
  end

  it "has cached_copy_scp_dir" do
    expect(deployer.send(:cached_copy_scp_dir)).to eq("~/apps/event_hub/shared/cached_copy_scp")
  end

  it "has cached_copy_svn_dir" do
    expect(deployer.send(:cached_copy_svn_dir)).to eq("~/apps/event_hub/shared/cached_copy_svn")
  end

  it "has repository" do
    expect(deployer.send(:repository)).to eq("https://repo1.server1.com/branches/master/releases")
  end

  it "has inspector_command" do
    expect(deployer.send(:inspector_command, "action", "name")).to eq("curl -X POST --data '[{\"name\": \"name\",\"action\": \"action\"}]' --header \"Content-Type:application/json\" http://localhost:5500/applications")
  end
end
