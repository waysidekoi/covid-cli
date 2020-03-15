RSpec.describe "`covid show` command", type: :cli do
  it "executes `covid help show` command successfully" do
    output = `covid help show`
    expected_output = <<-OUT
Usage:
  covid show [COUNTRY]

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
