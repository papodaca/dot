# == Schema Information
#
# Table name: tags
#
#  id         :uuid             not null, primary key
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  has_and_belongs_to_many :articles

  def self.from_list(list)
    list.map { |item| item.split(',') }.flatten.map do |item|
      Tag.find_or_create_by(title: item)
    end
  end

  def self.from_article_list(articles)
    sql = <<-SQL
      SELECT article_id, title
      FROM tags
      INNER JOIN articles_tags ON articles_tags.tag_id = tags.id
      WHERE articles_tags.article_id IN ( :article_ids ) ;
    SQL
    ActiveRecord::Base.connection.execute(
      ApplicationRecord.sanitize_sql_for_assignment([sql, article_ids: articles.pluck(:id)])
    ).map { |tag| OpenStruct.new(tag) }
  end
end
