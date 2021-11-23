class UpdateFeedJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(feed_id)
    Feed.find(feed_id).remote_update
  end
end
