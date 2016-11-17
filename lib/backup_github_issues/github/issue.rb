require 'backup_github_issues/github/issue_comment'
require 'backup_github_issues/github/issue_event'
require 'backup_github_issues/github/review_comment'
require 'backup_github_issues/github/body_convertor'

module Github
  class Issue
    include Github::BodyConvertor

    attr_accessor :client, :repo, :data

    def initialize(client, repo, data)
      @client = client
      @repo = repo
      @data = data
    end

    def method_missing(method_name, *args, &block)
      data[method_name]
    end

    def issue?
      data.pull_request.nil?
    end

    def type
      issue? ? 'issue' : 'pull'
    end

    def body
      return @body if @body.present?

      @body = convert_image_tag(data.body || '', photo_save_prefix)
      @body = convert_issue_link(client, repo, issue, @body)
    end

    def created_at
      data.created_at.getlocal
    end

    def issue_events
      client.issue_events(repo.full_name, data.number).
        map {|event| Github::IssueEvent.new(client, repo, self, event) }.
        reject {|event| event.ignore? }
    end

    def issue_comments
      client.issue_comments(repo.full_name, data.number).
        map {|comment| Github::IssueComment.new(client, repo, self, comment) }
    end

    def review_comments
      return [] if issue?

      client.review_comments(repo.full_name, data.number).
        group_by {|comment| comment[:original_position]}.
        map {|key, comments| Github::ReviewComment.new(client, repo, self, comments) }
    end

    def events
      (issue_events + issue_comments + review_comments).
        sort_by {|event| event.created_at }
    end

    IMG_EXTNAMES = %w[.png .jpg .jpeg .gif]

    def diff_files_md
      return if issue?

      diff_files = client.pull_files(repo.full_name, data.number).map.with_index do |diff_file, idx|
        if IMG_EXTNAMES.include?(File.extname(diff_file.filename))
          begin
            basekey = "#{photo_save_prefix}/diff_file"
            if diff_file.sha.nil?
              image_url = client.get(diff_file.contents_url).download_url
              new_url = download_url_and_upload(image_url, basekey, idx)
            else
              new_url = download_blob_and_upload(repo, diff_file, basekey, idx)
            end

            diff_file[:markdown] = <<~EOS
            #{diff_file.status}
            ![](#{new_url})
            EOS
          rescue Octokit::NotFound, Down::NotFound => e
            diff_file[:markdown] = 'No Available Image'
          end
        else
          diff_file[:markdown] = <<~EOS
          ```diff
          #{diff_file.patch}
          ```
          EOS
        end

        diff_file
      end
    end

    def skip?(backup_dir)
      File.exists?("#{backup_dir}/#{markdown_path}")
    end

    def markdown_path
      "#{repo.owner_name}/#{repo.name}/#{self.type}/#{self.number}.md"
    end

    def photo_save_prefix
      "#{repo.full_name}/#{self.type}/#{self.number}"
    end
  end
end
