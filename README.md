# Danger Stylelint

This is a Danger Plugin for Ruby or Ruby on Rails projects to warn CSS issues. The checks are performed using [Stylelint](https://stylelint.io/)

## Prerequisites

To use this plugin, your project must have successfully setup [Danger](https://danger.systems/guides/getting_started.html)

You would also need to install `stylelint` into your project

    $ npm install -D stylelint

## Installation

Simply run the following in your project.

    $ gem install danger-stylelint


## Usage

To use the extension, add the following to your Dangerfile

```ruby
stylelint.lint
```

### Options

| Options               	| Required 	| Default Value                 	| Description                                	|
|-----------------------	|----------	|-------------------------------	|--------------------------------------------	|
| stylelint.config_file 	| No       	| nil                           	| Path to a Stylelint configuration file.    	|
| stylelint.changes_only   	| No       	| false                         	| Comment only on changed lines              	|
| stylelint.bin_path    	| No       	| ./node_modules/.bin/stylelint 	| Path to the node installation of Stylelint 	|

To use an option, add it before running stylelint

```ruby
stylelint.config_file = "./.stylelintrc"
stylelint.lint
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
