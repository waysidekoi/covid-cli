require 'covid/commands/compare'

RSpec.describe Covid::Commands::Compare do
  it "executes `compare` command successfully" do
    output = StringIO.new
    names = nil
    options = {}
    command = Covid::Commands::Compare.new(names, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
