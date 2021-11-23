# == Schema Information
#
# Table name: feeds
#
#  id           :uuid             not null, primary key
#  title        :text
#  url          :text
#  link         :text
#  icon         :text
#  description  :text
#  error        :json
#  directory_id :uuid             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  properties   :jsonb
#
class Feed < ApplicationRecord
  belongs_to :directory
  has_many :articles

  jsonb_accessor :properties,
    etag: :string

  def unread_articles
    articles.where(read: nil)
  end

  def to_opml
    <<~OPML
      <outline
        text="#{title}"
        type="rss"
        title="#{title}"
        xmlUrl="#{url}"
        htmlUrl="#{link}" />
    OPML
  end

  def remote_update
    rss = ExternalTool.fetch_feed(url, etag || "nil")
    return unless needs_update(rss)

    self.title = rss[:title] if title.nil?
    self.link = rss[:link] if link.nil?
    self.description = rss[:description] if description.nil?
    self.icon = Feed.get_icon(link || url) if icon.nil?
    self.etag = rss[:etag]
    self.save if self.changed?

    rss[:items].map do |item|
      Article.from_item(self, item)
    end&.compact&.each(&:fetch)
  end


  class << self
    def get_details(url)
      feed = ExternalTool.fetch_feed(url)

      first_article = feed[:items].first if feed
      link = first_article[:link] if first_article

      feed[:icon] = Feed.get_icon(link) if link
      feed&.slice(:icon, :title, :description, :link)
    end

    def get_icon(url)
      uri = URI(url)
      base = "#{uri.scheme}://#{uri.host}"

      res = HTTParty.get(base, follow_redirects: true, headers: {
        "Accept": "en",
        "Pragma": "no-cache",
        "Cache-Control": "no-cache",
        "User-Agent": "Dot/1.0.0 (https://github.com/papodaca/dot)"
      })
      doc = Nokogiri::HTML.parse(res.body)
      icons = [
        'link[rel="icon"][sizes="32x32"]',
        'link[rel="icon"]',
        'link[rel="shortcut icon"]'
      ].map do |query|
        doc.css(query)&.first&.attributes&.fetch("href")&.text
      end.compact
      icon_path = icons.first
      icon_path = "#{base}#{icon_path}" if icon_path&.start_with?("/")
      unless icon_path.nil?
        URI(icon_path).tap do |uri|
          uri.query = nil
        end.to_s
      end
    end
  end

  private

  def need_properties
    title.nil? || link.nil? || description.nil? || icon.nil?
  end

  def needs_update(rss)
    return false if rss.nil?
    date = rss[:lastBuildDate] || rss[:pubDate] || rss[:updated]
    date = extract_date(rss) unless date.present?
    raise StandardError.new("Failed to pull date from feed") unless date.present?
    date = Time.parse(date) if date.present? && date.is_a?(String)
    need_properties || updated_at.nil? || (date.present? && updated_at < date) || date.nil?
  end

  def extract_date(rss)
    if rss[:item][0][:pubDate].present?
      rss[:item].pluck(:pubDate).map { |date| Time.parse(date) }.max
    end
  end
end
