
conf = Rails.configuration.database_configuration
redis_options = conf.dig("redis", "jobs", Rails.env)

Redis.exists_returns_integer = false

Sidekiq.configure_server do |config|
  config.redis = redis_options
end

Sidekiq.configure_client do |config|
  config.redis = redis_options
end

schedule_file = Rails.root.join("config", "schedule.yml")

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
end
