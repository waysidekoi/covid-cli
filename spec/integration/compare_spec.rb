RSpec.describe "`covid compare` command", type: :cli do
  it "executes `covid help compare` command successfully" do
    output = `covid help compare`
    expected_output = <<-OUT
Usage:
  covid compare NAMES...

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
