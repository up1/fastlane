module Fastlane
  module Actions
    module SharedValues
      GET_GITHUB_RELEASE_INFO = :GET_GITHUB_RELEASE_INFO
    end

    class GetGithubReleaseAction < Action
      def self.run(params)
        Helper.log.info "Verifying release on GitHub (#{params[:url]}: #{params[:version]})"
        require 'excon'
        result = JSON.parse(Excon.get("https://api.github.com/repos/#{params[:url]}/releases").body)
        result.each do |current|
          if current['tag_name'] == params[:version]
            # Found it
            if current['body'].to_s.length > 0
              Actions.lane_context[SharedValues::GET_GITHUB_RELEASE_INFO] = current
              Helper.log.info "Version is already live on GitHub.com 🚁"
              return current
            else
              raise "No release notes found for #{params[:version]}"
            end
          end 
        end

        Helper.log.error "Couldn't find GitHub release #{params[:version]}".yellow
        return nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will verify if a given release version is avialable on GitHub"
      end

      def self.details
        sample = '
              {"url"=>"https://api.github.com/repos/KrauseFx/fastlane/releases/1537713",
                 "assets_url"=>"https://api.github.com/repos/KrauseFx/fastlane/releases/1537713/assets",
                 "upload_url"=>"https://uploads.github.com/repos/KrauseFx/fastlane/releases/1537713/assets{?name}",
                 "html_url"=>"https://github.com/KrauseFx/fastlane/releases/tag/1.8.0",
                 "id"=>1537713,
                 "tag_name"=>"1.8.0",
                 "target_commitish"=>"master",
                 "name"=>"1.8.0 Switch Lanes & Pass Parameters",
                 "draft"=>false,
                 "author"=>
                  {"login"=>"KrauseFx",
                   "id"=>869950,
                   "avatar_url"=>"https://avatars.githubusercontent.com/u/869950?v=3",
                   "gravatar_id"=>"",
                   "url"=>"https://api.github.com/users/KrauseFx",
                   "html_url"=>"https://github.com/KrauseFx",
                   "followers_url"=>"https://api.github.com/users/KrauseFx/followers",
                   "following_url"=>"https://api.github.com/users/KrauseFx/following{/other_user}",
                   "gists_url"=>"https://api.github.com/users/KrauseFx/gists{/gist_id}",
                   "starred_url"=>"https://api.github.com/users/KrauseFx/starred{/owner}{/repo}",
                   "subscriptions_url"=>"https://api.github.com/users/KrauseFx/subscriptions",
                   "organizations_url"=>"https://api.github.com/users/KrauseFx/orgs",
                   "repos_url"=>"https://api.github.com/users/KrauseFx/repos",
                   "events_url"=>"https://api.github.com/users/KrauseFx/events{/privacy}",
                   "received_events_url"=>"https://api.github.com/users/KrauseFx/received_events",
                   "type"=>"User",
                   "site_admin"=>false},
                 "prerelease"=>false,
                 "created_at"=>"2015-07-14T23:33:01Z",
                 "published_at"=>"2015-07-14T23:44:10Z",
                 "assets"=>[],
                 "tarball_url"=>"https://api.github.com/repos/KrauseFx/fastlane/tarball/1.8.0",
                 "zipball_url"=>"https://api.github.com/repos/KrauseFx/fastlane/zipball/1.8.0",
                 "body"=>
                "This is one of the biggest updates of `fastlane` yet"
              }'

        [
          "This will return all information about a release. For example:",
          sample
        ].join("\n")
      end

      def self.output
        [
          ['GET_GITHUB_RELEASE_INFO', 'Contains all the information about this release']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "FL_GET_GITHUB_RELEASE_URL",
                                       description: "The path to your repo, e.g. 'KrauseFx/fastlane'",
                                       verify_block: Proc.new do |value|
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.include?"github.com"
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.split('/').count != 2
                                       end),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_GET_GITHUB_RELEASE_VERSION",
                                       description: "The version tag of the release to check")
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end