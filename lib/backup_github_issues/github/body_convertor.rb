require 'aws-sdk'
require 'down'

module Github
  module BodyConvertor

    IMG_TAG_PATTERNS = [
      /(\!\[.*\]\((.+)\))/,
      /(<img.*src=['"](.+?)['"].*>)/,
    ]

    def config
      @config ||= Config.new
    end

    def convert_image_tag(body, basekey)
      image_tag_matches = IMG_TAG_PATTERNS.map {|pattern|
        body.scan(pattern).map {|matches|
          Hashie::Mash.new({
            tag: matches[0],
            url: matches[1],
          })
        }
      }.flatten

      image_tag_matches.each.with_index {|matches, index|
        begin
          new_url = download_url_and_upload(matches.url, basekey, index)
          body.gsub!(matches.tag, "![](#{new_url})")
        rescue Down::NotFound
          # Do nothing
        end
      }

      body
    end

    def download_url_and_upload(url, basekey, idx = 0)
      download_and_upload(url, basekey, idx) do
        Down.download(url)
      end
    end

    def download_blob_and_upload(repo, diff_file, basekey, idx)
      download_and_upload(diff_file.filename, basekey, idx) do
        blob = repo.download_blob(diff_file)
        file = Tempfile.create('')
        File.open(file.path, 'wb') do |f|
          f.write(Base64.decode64(blob.content))
        end

        file
      end
    end

    def download_and_upload(url, basekey, idx)
      extname = File.extname(URI.parse(URI.encode(url)).path)
      key = "#{basekey}/#{idx}#{extname}"
      if s3.list_objects(bucket: config.bucket_name, prefix: key).contents.empty?
        puts "Copy an image to S3, from #{url} to #{key}"

        file = yield

        # Upload image to Aws::S3
        s3.put_object(bucket: config.bucket_name, key: key, body: file)

        sleep 0.5
      end

      # Return new url
      "http://#{config.bucket_name}.s3-website-#{config.region}.amazonaws.com/#{key}"
    end

    def s3
      @s3 = Aws::S3::Client.new(region: config.region)
    end

    def convert_issue_link(client, repo, issue, body)
      body.gsub(/#\d+( |\r\n)/) do |matched|
        begin
          matches = matched.match(/#(\d)(.+)/)
          issue = repo.issue(matches[1])

          "[##{issue.number}](./../../../#{repo.owner_name}/#{repo.name}/#{issue.type}/#{issue.number}.md)#{matches[2]}"
        rescue
          matched[0]
        end
      end
    end
  end
end
