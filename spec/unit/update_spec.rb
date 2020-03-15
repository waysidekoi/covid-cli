require 'covid/commands/update'

RSpec.describe Covid::Commands::Update do
  it "executes `update` command successfully" do
    output = StringIO.new
    options = {}
    command = Covid::Commands::Update.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
