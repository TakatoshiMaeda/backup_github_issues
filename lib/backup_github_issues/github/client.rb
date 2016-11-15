require 'backup_github_issues/github/repository'

module Github
  class Client
    def initialize(api_endpoint, access_token)
      @client = Octokit::Client.new(
        access_token: access_token,
        api_endpoint: api_endpoint,
        auto_paginate: true,
      )
    end

    def org_repos(org_name)
      @client.org_repos(org_name).map do |data|
        Github::Repository.new(@client, data)
      end
    end

    def repos
      @client.list_repos.map do |data|
        Github::Repository.new(@client, data)
      end
    end
  end
end
