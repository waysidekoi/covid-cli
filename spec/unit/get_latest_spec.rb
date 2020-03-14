require 'covid/commands/get_latest'

RSpec.describe Covid::Commands::GetLatest do
  it "executes `get_latest` command successfully" do
    output = StringIO.new
    options = {}
    command = Covid::Commands::GetLatest.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
