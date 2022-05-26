# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerStylelint do
    it "should be a plugin" do
      expect(Danger::DangerStylelint.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      let(:stylelint) { testing_dangerfile.stylelint }
      let(:warnings) { stylelint.status_report[:warnings] }
      let(:errors) { stylelint.status_report[:errors] }
      let(:messages) { stylelint.status_report[:messages] }
      let(:markdowns) { stylelint.status_report[:markdowns] }

      before do
        allow(stylelint.git).to receive(:deleted_files).and_return([])
        allow(stylelint.git).to receive(:added_files).and_return([])
        allow(stylelint.git).to receive(:modified_files).and_return([])
        allow(stylelint.git).to receive(:renamed_files).and_return([])
        stub_const("Danger::DangerStylelint::DEFAULT_BIN_PATH", "spec/fixtures/stylelint")
      end

      it "does not make an empty message" do
        allow(stylelint).to receive(:lint).and_return("[]")

        stylelint.lint

        expect(warnings).to eq([])
        expect(errors).to eq([])
        expect(messages).to eq([])
        expect(markdowns).to eq([])
      end

      it "fails if stylelint not installed" do
        allow(stylelint).to receive(:bin_path).and_return("")

        expect { stylelint.lint }.to raise_error("stylelint is not installed")
      end

      describe "#lint" do
        let(:valid_result) { JSON.parse(File.read("spec/fixtures/valid.json")) }
        let(:error_result) { JSON.parse(File.read("spec/fixtures/error.json")) }

        it "lints all files when changes_only is disabled by default" do
          allow(stylelint).to receive(:all_lintable_files).and_return("spec/fixtures/error.scss")
          allow(stylelint).to receive(:run_lint)
            .with(anything, /error.scss/).and_return(error_result)

          stylelint.lint

          expect(warnings.length).to eq(0)
          expect(errors.length).to eq(6)
          expect(messages.length).to eq(0)
          expect(markdowns.length).to eq(0)
          expect(errors).to eq(
            [
              "Expected a trailing semicolon (declaration-block-trailing-semicolon)",
              "Expected a trailing semicolon (declaration-block-trailing-semicolon)",
              "Expected a trailing semicolon (declaration-block-trailing-semicolon)",
              "Selector should be written in lowercase with hyphens (selector-class-pattern)",
              "Expected \".slickDots :global li.slick-active button::before\" to have no more than 3 compound selectors (selector-max-compound-selectors)",
              "Unexpected qualifying type selector (selector-no-qualifying-type)"
            ]
          )
        end

        it "lints only changed files when changes_only is enabled" do
          allow(stylelint.git).to receive(:modified_files)
            .and_return(["spec/fixtures/valid.scss"])
          allow(stylelint).to receive(:run_lint)
            .with(anything, /valid.scss/).and_return(valid_result)

          stylelint.changes_only = true
          stylelint.lint

          expect(warnings.length).to eq(0)
          expect(errors.length).to eq(0)
          expect(messages.length).to eq(0)
          expect(markdowns.length).to eq(0)
        end
      end
    end
  end
end
