require 'fileutils'

class ImportOpmlJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(file_path, current_user_id)
    Opml.import(file_path, User.find(current_user_id))
    FileUtils.rm_rf(tmp_file)
  end
end
