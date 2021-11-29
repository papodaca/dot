module ApplicationHelper
  def load_articles_counts(user_id)
    sql = <<-SQL
      select feeds.id as feed_id, count(articles.id) as total
      from feeds
      left join articles on articles.feed_id = feeds.id
      join directories on directories.id = feeds.directory_id
      where directories.user_id = :user_id
      group by feeds.id;
    SQL
    totals = ActiveRecord::Base.connection.execute(
      ApplicationRecord.sanitize_sql_for_assignment([sql, user_id: user_id])
    )
    totals.each_with_object({}) do |item, obj|
      obj[item["feed_id"]] = item["total"]
    end
  end

  def load_tree(user_id)
    totals = load_articles_counts(user_id)

    directories = Directory.where(user_id: user_id)
    feeds = Feed.joins(:directory).where("directories.user_id = ?", user_id)

    root = directories.select { |dir| dir.title == 'Root' }.first

    OpenStruct.new({
      totals: totals,
      item: root,
      children: load_children(root, directories, feeds),
      feeds: load_feeds(root, feeds)
    })
  end

  def load_children(directory, directories, feeds, level=0)
    directories.select do |dir|
      parts = dir.ancestry&.split(':')
      parts[level] == directory.id if parts.present?
    end.map do |dir|
      OpenStruct.new({
        item: dir,
        children: load_children(dir, directories, feeds, level+1),
        feeds: load_feeds(dir, feeds)
      })
    end
  end

  def load_feeds(directory, feeds)
    feeds.select { |f| f.directory_id == directory.id }
  end

  def feed_icon(feed, size)
    if feed.icon.present?
      "<img width=\"#{size}\" height=\"#{size}\" src=\"#{feed.icon}\"/>".html_safe
    else
      fa_icon "rss-square"
    end
  end

  def fa_icon(name, options = {})
    "<i class=\"fa fa-#{name} #{options[:class]}\"></i>".html_safe
  end

  def fas_icon(name, options = {})
    "<i class=\"fas fa-#{name} #{options[:class]}\"></i>".html_safe
  end

  # const fixUrl = (url) => `${(new URL(article.url)).origin}/${url}`;
  def fix_url(url, article_url)
    uri = URI(article_url)
    if url.start_with?("/")
      "#{uri.scheme}://#{uri.host}#{url}"
    else
      "#{uri.scheme}://#{uri.host}/#{url}"
    end
  end

  def sanitize_html(article)
    html_doc = Nokogiri::HTML(article.description)
    html_doc.css("a").each do |el|
      url = el["href"]
      el["href"] = fix_url(url, article.url) if url.start_with?("/")
      el["target"] = "_blank"
      el["rel"] = "noopener noreferrer"
      el.remove_attribute("onclick")
    end
    html_doc.css('link[rel="stylesheet"], script, style').each(&:remove)
    html_doc.css("img").each do |el|
      url = el["src"]
      el["src"] = fix_url(url, article.url) if url.start_with?("/")
      el.remove_attribute("width")
      el.remove_attribute("height")
      el.remove_attribute("style")
    end
    html_doc.css("img, video").each do |el|
      el.add_class("img-fluid")
    end

    html_doc.css('body').children.to_s
  end

  def mark_safe(content)
    content.html_safe
  end
end
