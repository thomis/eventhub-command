RSpec.describe Deployer::Executor do
  let!(:executor) {
    stage = Deployer::Stage.new("test")
    stage.host("localhost", 23, "a_user")
    Deployer::Executor.new(stage)
  }

  it "has intital empty command list" do
    expect(executor.commands).to eq({})
  end

  it "execute later" do
    executor.execute_later("command1")
    executor.execute_later("command2")
    expect(executor.commands).to eq(
      {
        {host: "localhost", port: 23, user: "a_user"} => ["command1", "command2"]
      }
    )
  end

  it "fails to execute commands locally" do
    executor.execute_later("date")
    executor.execute_later("uptime")
    expect { executor.execute_batch }.to raise_error(Errno::ECONNREFUSED, "Connection refused - connect(2) for 127.0.0.1:23")
  end

  it "resets command list" do
    executor.execute_later("command1")
    executor.execute_later("command2")
    executor.reset_commands
    expect(executor.commands).to eq({})
  end
end
