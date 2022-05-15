# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerStylelint do
    it "should be a plugin" do
      expect(Danger::DangerStylelint.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe "with Dangerfile" do
      let(:stylelint) { testing_dangerfile.stylelint }

      before do
        allow(stylelint.git).to receive(:deleted_files).and_return([])
        allow(stylelint.git).to receive(:added_files).and_return([])
        allow(stylelint.git).to receive(:modified_files).and_return([])
        allow(stylelint.git).to receive(:renamed_files).and_return([])
        stub_const("Danger::DangerStylelint::DEFAULT_BIN_PATH", "spec/fixtures/stylelint.config.js")
      end

      it "does not make an empty message" do
        allow(stylelint).to receive(:lint).and_return("[]")

        expect(stylelint.status_report[:errors].first).to be_nil
        expect(stylelint.status_report[:warnings].first).to be_nil
        expect(stylelint.status_report[:markdowns].first).to be_nil
      end

      it "fails if stylelint not installed" do
        allow(stylelint).to receive(:stylelint_path).and_return(nil)

        expect { stylelint.lint }.to raise_error("stylelint is not installed")
      end

      describe "#lint" do
        let(:error_result) { JSON.parse(File.read("spec/fixtures/error.json")) }

        it "lints only changed files when filtering enabled" do
          allow(stylelint).to receive(:run_lint)
            .with(anything, /error.scss/).and_return(error_result)
          allow(stylelint.git).to receive(:modified_files)
            .and_return(["spec/fixtures/error.scss"])

          stylelint.filtering = true
          stylelint.lint
          error = stylelint.status_report[:errors].first

          expect(error).to eq("Expected a trailing semicolon (declaration-block-trailing-semicolon)")
          expect(stylelint.status_report[:warnings].length).to be(0)
        end
      end
    end
  end
end
