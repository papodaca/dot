require 'open3'
require 'fileutils'
require 'fast_jsonparser'

class ExternalTool
  def self.fetch_article(url)
    external_tool('fetch_article', url)
  end

  def self.fetch_feed(url)
    external_tool('fetch_feed', url, etag)
  end

  def self.external_tool(tool, url, etag=nil)
    tmp_file = File.join(
      "/",
      "dev",
      "shm",
      "dot.fetch.#{(0...16).map { (65 + rand(26)).chr }.join}"
    )
    stdin, stdout, stderr, wait_thr = Open3.popen3(
      'node',
      File.join("lib", "js_shims", "#{tool}.js"),
      url,
      etag || "nil",
      tmp_file,
      chdir: Rails.root
    )

    stdout.gets(nil)
    stdout.close
    stderr.gets(nil)
    stderr.close
    if wait_thr.value == 0
      data = FastJsonparser.load(tmp_file)
      FileUtils.rm_rf(tmp_file)
      return data
    end
  end
end
