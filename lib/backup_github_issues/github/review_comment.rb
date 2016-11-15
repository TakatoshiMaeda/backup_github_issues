require 'backup_github_issues/github/body_convertor'
module Github
  class ReviewComment
    include Github::BodyConvertor

    attr_accessor :client, :repo, :issue, :data, :body

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
      'review_comments'
    end

    def username
      data.first.user.login
    end

    def diff_hunk
      data.first.diff_hunk
    end

    def comments
      data.map do |comment|
        body = convert_image_tag(comment.body, photo_save_prefix(comment))
        Hashie::Mash.new({ username: comment.user.login,
          body: body,
          created_at: comment.created_at.getlocal,
          updated_at: comment.updated_at.getlocal,
        })
      end
    end

    def path
      data.first.path
    end

    def created_at
      data.first.created_at.getlocal
    end

    def photo_save_prefix(comment)
      "#{issue.photo_save_prefix}/#{comment.id}"
    end
  end
end
