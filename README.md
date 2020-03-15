# Covid

Display the latest SARS-CoV-2 reported numbers via CLI. Global SARS-CoV-2 Confirmations, deaths, and
recovered numbers are fetched from the JHU team at https://github.com/CSSEGISandData/COVID-19.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'covid-cli'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install covid

## Getting Started

`./bin/setup` - Migrate and seed the SQLite database with the latest

## 1. Usage

To use all available commands, run the following in your terminal:
```
❯ bundle exec covid

Commands:
  covid compare NAMES...        # Get the reported numbers for several US state abbreviations or country names
  covid help [COMMAND]          # Describe available commands or one specific command
  covid show [STATE] [COUNTRY]  # Show reports for State or Country
  covid update                  # Fetch latest SARS-CoV-2 data from the JHU github repo, https://github.com/CSSEGISandData/COVID-19
  covid version                 # covid version
```

## 1. View a single US state, non-US state of a country, or a country
```
❯ bundle exec covid show --state=NY

Confirmed
┌────────────────┬──────────────┬──────────────┬──────────────┬──────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│        Location│    2020-03-02│    2020-03-03│    2020-03-04│    2020-03-05│   2020-03-06│   2020-03-07│   2020-03-08│   2020-03-09│   2020-03-10│   2020-03-11│   2020-03-12│   2020-03-13│   2020-03-14│
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│    New York, US│             5│             5│            28│            30│           31│           34│           39│           43│           56│           62│           73│           82│          102│
└────────────────┴──────────────┴──────────────┴──────────────┴──────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘
Deaths
┌────────────────┬──────────────┬──────────────┬──────────────┬──────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│        Location│    2020-03-02│    2020-03-03│    2020-03-04│    2020-03-05│   2020-03-06│   2020-03-07│   2020-03-08│   2020-03-09│   2020-03-10│   2020-03-11│   2020-03-12│   2020-03-13│   2020-03-14│
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│    New York, US│             0│             0│             0│             0│            0│            0│            0│            0│            0│            1│            1│            2│            2│
└────────────────┴──────────────┴──────────────┴──────────────┴──────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘
```

## 2. Compare multiple US states or countries

## Development
You can run `bin/console` for an interactive prompt that will allow you to experiment.
```
./bin/console
```
```
> Covid::Country.first
> Covid::State.first
> state = _
> state.deaths
> state.confirmed
> state.recovered
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/waysidekoi/covid-cli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/waysidekoi/covid/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the Covid project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/waysidekoi/covid/blob/master/CODE_OF_CONDUCT.md).
