# frozen_string_literal: true

require "mkmf"
require "json"

module Danger
  # Lint stylesheets using [stylelint](http://stylelint.io/).
  # Results are send as inline comment.
  #
  # @example Run stylelint with changed files only
  #
  #          stylelint.changes_only = true
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

    # Enable changes_only
    # Only show messages within changed files.
    # @return [Boolean]
    attr_accessor :changes_only

    # A path of stylelint's bin
    # @return [String]
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
      raise "stylelint is not installed" unless File.exist?(bin_path)

      bin_path
    end

    # Get all lintable files
    #
    # return [String]
    def all_lintable_files
      "**/*{#{target_extensions.join(',')}}"
    end

    # Get all the changed files
    #
    # return [Array]
    def all_changed_files
      ((git.modified_files - git.deleted_files - git.renamed_files.map { |r| r[:before] }) + git.added_files + git.renamed_files.map { |r| r[:after] })
    end

    # Get lint result with respect to the changes_only option
    #
    # return [Hash]
    def lint_results
      bin = stylelint_path
      return run_lint(bin, all_lintable_files) unless changes_only

      all_changed_files.select { |f| target_extensions.include?(File.extname(f)) }
        .map { |f| f.gsub("#{Dir.pwd}/", "") }
        .map { |f| run_lint(bin, f).first }
    end

    # Run stylelint against file(s).
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
