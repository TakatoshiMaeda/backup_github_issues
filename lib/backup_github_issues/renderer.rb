class Renderer
  class MarkdownActionView < ActionView::Base
    VIEW_ROOT = File.expand_path("./views")

    def initialize(assigns)
      super(VIEW_ROOT, assigns)
    end

    def code(text)
      text.nil? ? '' : "`#{text}`"
    end
  end

  BACKUP_DIR = 'backup'

  def config
    @config ||= Config.new
  end

  def render_issue_page(issue)
    md = render('issue.md.erb',
      repo: issue.repo,
      issue: issue,
      events: issue.events,
      diff_files: issue.diff_files_md,
    )
    write_file(issue.markdown_path, md)
  end

  def render_repository_page(repo, issues)
    issues, pulls = issues.
      group_by {|item| item.issue? ? :issue : :pull}.
      tap {|issues_and_pulls| break [ issues_and_pulls[:issue], issues_and_pulls[:pull] ] }

    md = render('repository.md.erb',
      repo: repo,
      issues: issues || [],
      pulls: pulls || [],
    )

    write_file(repo.markdown_path, md)
  end

  def render_index_page(org_name, repos)
    md = render('index.md.erb', org_name: org_name, repos: repos)
    write_file("index.md", md)
  end

  private

  def render(template, assigns)
    action_view = MarkdownActionView.new(assigns)
    action_view.render(template: template)
  end

  def write_file(filepath, body)
    real_filepath = "#{BACKUP_DIR}/#{filepath}"

    FileUtils.mkdir_p(Pathname.new(real_filepath).parent)
    File.write(real_filepath, body)
  end

end
