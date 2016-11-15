require 'backup_github_issues/github/body_convertor'

module Github
  class IssueComment
    include Github::BodyConvertor

    attr_accessor :client, :repo, :issue, :data, :body

    def initialize(client, repo, issue, data)
      @client = client
      @repo = repo
      @issue = issue
      @data = data
      @body = convert_image_tag(@data.body, photo_save_prefix)
    end

    def method_missing(method_name, *args, &block)
      data[method_name]
    end

    def kind
      'issue_comments'
    end

    def username
      data.user.login
    end

    def updated_at
      data.updated_at.getlocal
    end

    def photo_save_prefix
      "#{issue.photo_save_prefix}/#{@data.id}"
    end
  end
end
