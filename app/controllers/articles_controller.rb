class ArticlesController < ApplicationController
  def index
    articles_id = PgSearch.multisearch(params[:q]).map(&:searchable_id)
    @articles = Article.where(feed_id: current_user.feeds.pluck(:id), id: articles_id).page(params[:page] || 1).order(pub_date: :desc)
    @tags = Tag.from_article_list(@articles)
  end
end
