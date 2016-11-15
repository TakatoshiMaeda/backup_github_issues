require 'backup_github_issues/github/body_convertor'

module Github
  class IssueEvent
    IGNORE_EVENTS = %w[mentioned subscribed head_ref_deleted referenced]

    attr_accessor :client, :repo, :issue, :data

    def initialize(client, repo, issue, data)
      @client = client
      @repo = repo
      @issue = issue
      @data = data
    end

    def method_missing(method_name, *args, &block)
      data[method_name]
    end

    def kind
      'issue_events'
    end

    def username
      data.actor.login
    end

    def created_at
      data.created_at.getlocal
    end

    def ignore?
      IGNORE_EVENTS.include?(data.event)
    end
  end
end
