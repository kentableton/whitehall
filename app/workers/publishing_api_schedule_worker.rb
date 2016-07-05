class PublishingApiScheduleWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(base_path, publish_timestamp)
    publish_intent = PublishingApiPresenters::PublishIntent.new(base_path, publish_timestamp)

    Whitehall.publishing_api_client.put_intent(base_path, publish_intent.as_json)
  end
end
