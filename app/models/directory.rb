# == Schema Information
#
# Table name: directories
#
#  id         :uuid             not null, primary key
#  title      :text
#  user_id    :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ancestry   :string
#
class Directory < ApplicationRecord
  belongs_to :user
  has_many :feeds
  has_many :articles, through: :feeds
  has_ancestry primary_key_format: /\A[\w\-]+(\/[\w\-]+)*\z/

  def unread_articles
    articles.where(read: nil)
  end

  def to_opml
    child_elements = [(children || []).map(&:to_opml), feeds.map(&:to_opml)].flatten.join('\n')
    binding.pry
    <<~OPML
      <outline text="#{title}" title="#{title}">
        #{child_elements.first}
      </outline>
    OPML
  end
end
