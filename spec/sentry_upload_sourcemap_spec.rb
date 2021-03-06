describe Fastlane do
  describe Fastlane::FastFile do
    describe "upload_sourcemap" do
      it "fails with invalid sourcemap path" do
        sourcemap_path = File.absolute_path './assets/this_does_not_exist.js.map'
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            sentry_upload_sourcemap(
              org_slug: 'some_org',
              api_key: 'something123',
              project_slug: 'some_project',
              sourcemap: '#{sourcemap_path}')
          end").runner.execute(:test)
        end.to raise_error("Could not find sourcemap at path '#{sourcemap_path}'")
      end
      it "accepts app_identifier" do
        expect(Fastlane::Helper::SentryHelper).to receive(:check_sentry_cli!).and_return(true)
        allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).with(:app_identifier).and_return(false)
        expect(Fastlane::Helper::SentryConfig).to receive(:parse_api_params).and_return(true)
        expect(Fastlane::Helper::SentryHelper).to receive(:call_sentry_cli).with("sentry-cli releases files 'app.idf-1.0' upload-sourcemaps 1.map     --dist 'dem'").and_return(true)
        expect(File).to receive(:exist?).with("1.map").and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
            sentry_upload_sourcemap(
              org_slug: 'some_org',
              api_key: 'something123',
              project_slug: 'some_project',
              version: '1.0',
              dist: 'dem',
              sourcemap: '1.map',
              app_identifier: 'app.idf')
        end").runner.execute(:test)
      end
    end
  end
end
