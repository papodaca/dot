# == Schema Information
#
# Table name: articles
#
#  id          :uuid             not null, primary key
#  title       :text
#  url         :text
#  remote_id   :text
#  description :text
#  author      :text
#  pub_date    :datetime
#  star        :boolean
#  read        :datetime
#  itunes      :json
#  kind        :enum             default("article")
#  feed_id     :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Article < ApplicationRecord
  include PgSearch::Model

  enum kind: %i[article podcast unknown].each_with_object({}) { |k, obj| obj[k] = k.to_s }
  belongs_to :feed
  has_and_belongs_to_many :tags
  self.ignored_columns = %w(tsv_description tsv_title)
  after_save :fetch

  pg_search_scope :search_title,
    against: :title,
    using: {
      tsearch: {
        tsvector_column: "tsv_title"
      },
      dmetaphone: {
        tsvector_column: ["tsv_title", "tsv_description"]
      },
      trigram: {}
    }
  multisearchable against: [:title, :description]

  scope :kinds, ->(kind) { where(kind: kind) }
  scope :articles, -> { kinds(:article) }
  scope :podcasts, -> { kinds(:podcast) }

  def self.from_item(feed, item)
    article = Article.find_by(feed_id: feed.id, remote_id: item[:guid])
    return article if article.present?
    article = Article.create(
      author: item[:author] || item[:creator],
      description: item[:content],
      feed_id: feed.id,
      itunes: item[:itunes]&.tap { |i| i[:enclosure] = item[:enclosure] },
      kind: item.has_key?(:itunes) ? :podcast : :article,
      pub_date: item[:pubDate] || item[:published] || item[:date] || item[:isoDate],
      remote_id: item[:guid] || item[:id] || item[:link],
      title: item[:title],
      url: item[:link]
    )
    article.tags = Tag.from_list(item[:categories]) if item.has_key?(:categories)
    article.save
    return article
  end

  def fetch
    FetchArticleJob.perform_later(id)
  end

  def remote_fetch
    article = ExternalTool.fetch_article(url) if kind != :podcast
    self.description = article[:content] if article
    update!(description: ApplicationController.helpers.sanitize_html(self))
  end
end
