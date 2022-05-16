# frozen_string_literal: true

require "mkmf"
require "json"

module Danger
  # Lint javascript files using [stylelint](http://stylelint.io/).
  # Results are send as inline comment.
  #
  # @example Run stylelint with changed files only
  #
  #          stylelint.filtering = true
  #          stylelint.lint
  #
  # @see  nimblehq/danger-stylelint
  # @tags lint, stylelint, css, scss, sass
  #
  class DangerStylelint < Plugin
    DEFAULT_BIN_PATH = "./node_modules/.bin/stylelint"

    # An path to stylelint's config file
    # @return [String]
    attr_accessor :config_file

    # An path to stylelint's ignore file
    # @return [String]
    attr_accessor :ignore_file

    # Enable filtering
    # Only show messages within changed files.
    # @return [Boolean]
    attr_accessor :filtering

    # A path of stylelint's bin
    attr_writer :bin_path

    def bin_path
      @bin_path ||= DEFAULT_BIN_PATH
    end

    # Specify extensions of target file
    # Default is [".css, .scss, .sass"]
    # @return [Array]
    attr_writer :target_extensions

    def target_extensions
      @target_extensions ||= %w(.css .scss .sass)
    end

    # Lints css files.
    # Generates `errors` and `warnings` according to stylelint's config.
    #
    # @return  [void]
    #
    def lint
      lint_results
        .reject { |result| result.nil? || result["warnings"].length.zero? }
        .map { |result| send_comment result }
    end

    private

    # Get stylelint bin path
    #
    # return [String]
    def stylelint_path
      File.exist?(bin_path) ? bin_path : find_executable("stylelint")
    end

    # Get all lintable files
    #
    # return [String]
    def all_lintable_files
      "**/*{#{target_extensions.join(',')}}"
    end

    # Get lint result regards the filtering option
    #
    # return [Hash]
    def lint_results
      bin = stylelint_path
      raise "stylelint is not installed" unless bin

      return run_lint(bin, all_lintable_files) unless filtering

      ((git.modified_files - git.deleted_files - git.renamed_files.map { |r| r[:before] }) + git.added_files + git.renamed_files.map { |r| r[:after] })
        .select { |f| target_extensions.include?(File.extname(f)) }
        .map { |f| f.gsub("#{Dir.pwd}/", "") }
        .map { |f| run_lint(bin, f).first }
    end

    # Run stylelint against a single file.
    #
    # @param   [String] bin
    #          The binary path of stylelint
    #
    # @param   [String] file
    #          File to be linted
    #
    # return [Hash]
    def run_lint(bin, file)
      command = "#{bin} -f json"
      command << " --config #{config_file}" if config_file
      command << " --ignore-path #{ignore_file}" if ignore_file
      result = `#{command} "#{file}"`
      JSON.parse(result)
    end

    # Send comment with danger's warn or fail method.
    #
    # @return [void]
    def send_comment(result)
      dir = "#{Dir.pwd}/"
      result["warnings"].each do |warning|
        filename = result["source"].gsub(dir, "")
        method = warning["severity"] == "error" ? "fail" : "warn"
        send(method, warning["text"], file: filename, line: warning["line"])
      end
    end
  end
end
