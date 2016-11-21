require 'backup_github_issues/renderer'

class Executor
  def config
    @config ||= Config.new
  end

  def renderer
    @renderer ||= Renderer.new
  end

  def execute
    client = Github::Client.new(config.api_endpoint, config.access_token)
    (repos = client.org_repos(config.organization)).each do |repo|
      next unless target_repo?(repo)

      puts "# #{repo.full_name}"

      (issues = repo.issues).each do |issue|
        next if renderer.skip?(issue)
        next unless target_issue?(issue)

        puts "- #{issue.number} #{issue.title}"

        renderer.render_issue_page(issue)

        sleep 0.5
      end

      renderer.render_repository_page(repo, issues)
    end

    renderer.render_index_page(config.organization, repos)
  end

  def target_repo?(repo)
    ENV['REPO'] == repo.name
  end

  def target_issue?(issue)
    ENV['ISSUE_NUM'] == issue.number.to_s
  end
end
