require 'backup_github_issues/github/issue'

module Github
  class Repository
    attr_accessor :client, :data

    def initialize(client, data)
      @client = client
      @data = data
    end

    def method_missing(method_name, *args, &block)
      data[method_name]
    end

    def issues
      client.issues(@data.full_name, state: :all).map do |data|
        Github::Issue.new(client, self, data)
      end
    end

    def issue(number)
      data = client.issue(@data.full_name, number)
      Github::Issue.new(client, self, data)
    end

    def markdown_path
      "#{owner_name}/#{@data.name}/index.md"
    end

    def download_blob(diff_file)
      client.blob(@data.full_name, diff_file.sha)
    end

    def owner_name
      @data.owner.login
    end
  end
end
