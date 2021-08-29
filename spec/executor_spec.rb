RSpec.describe Deployer::Executor do
  let!(:executor) {
    stage = Deployer::Stage.new("test")
    stage.host("localhost", 23, "a_user")
    Deployer::Executor.new(stage)
  }

  it "collect commands" do
    executor.execute_add("host1", "command1")
    executor.execute_add("host1", "command2")
    executor.execute_add("host2", "command1")
    executor.execute_add("host2", "command2")
    executor.execute_add("host3", "command1")
    expect(executor.commands).to eq(
      {
        "host1" => ["command1", "command2"],
        "host2" => ["command1", "command2"],
        "host3" => ["command1"]
      }
    )
  end

  it "collect commands via execute" do
    executor.execute("date")
    executor.execute("uptime")
    expect(executor.commands).to eq(
      {{host: "localhost", port: 23, user: "a_user"} => ["date", "uptime"]}
    )
  end

  it "fails to execute commands locally" do
    executor.execute("date")
    executor.execute("uptime")
    expect { executor.execute_commands }.to raise_error(Errno::ECONNREFUSED, "Connection refused - connect(2) for [::1]:23")
  end
end
