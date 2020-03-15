require 'covid/commands/show'

RSpec.describe Covid::Commands::Show do
  it "executes `show` command successfully" do
    output = StringIO.new
    country = nil
    options = {}
    command = Covid::Commands::Show.new(country, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
