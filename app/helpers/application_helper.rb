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

  def fa_icon(name, options = {})
    "<i class=\"fa fa-#{name} #{options[:class]}\"></i>".html_safe
  end

  def fas_icon(name, options = {})
    "<i class=\"fas fa-#{name} #{options[:class]}\"></i>".html_safe
  end

  # const fixUrl = (url) => `${(new URL(article.url)).origin}/${url}`;
  def fix_url(url, article_url)
    uri = URI(article_url)
    "#{uri.scheme}://#{uri.host}/#{url}"
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
