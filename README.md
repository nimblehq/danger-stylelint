<p align="center">
  <img alt="Nimble logo" src="https://assets.nimblehq.co/logo/light/logo-light-text-320.png" />
</p>

<h2 align="center">Danger Stylelint</h3>
<p align="center">A Plugin for Ruby or Ruby on Rails projects to warn CSS issues. The checks are performed using <a href="https://stylelint.io/">Stylelint<a></p>

-------

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

## License

This project is Copyright (c) 2014-2022 Nimble. It is free software,
and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE.txt

## About

![Nimble](https://assets.nimblehq.co/logo/dark/logo-dark-text-160.png)

This project is maintained and funded by Nimble.

We love open source and do our part in sharing our work with the community!
See [our other projects][community] or [hire our team][hire] to help build your product.

[community]: https://github.com/nimblehq
[hire]: https://nimblehq.co/
