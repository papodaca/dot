class FetchArticleJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(article_id)
    Article.find(article_id).remote_fetch
  end
end
