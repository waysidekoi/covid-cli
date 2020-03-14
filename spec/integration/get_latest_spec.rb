RSpec.describe "`covid get_latest` command", type: :cli do
  it "executes `covid help get_latest` command successfully" do
    output = `covid help get_latest`
    expected_output = <<-OUT
Usage:
  covid get_latest

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
