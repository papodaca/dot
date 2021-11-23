# == Schema Information
#
# Table name: articles_tags
#
#  article_id :uuid             not null
#  tag_id     :uuid             not null
#
class ArticlesTag < ApplicationRecord
  belongs_to :article
  belongs_to :tag
end
