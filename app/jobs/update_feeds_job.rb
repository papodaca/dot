class UpdateFeedsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform
    Feed.find_each do |feed|
      UpdateFeedJob.perform_later(feed.id)
    end
  end
end
