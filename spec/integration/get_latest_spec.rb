RSpec.describe "`covid update` command", type: :cli do
  it "executes `covid help update` command successfully" do
    output = `covid help update`
    expected_output = <<-OUT
Usage:
  covid update

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
