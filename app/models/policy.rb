# A model to represent policies that are published by policy-publisher
# and stored in the publishing-api / content-store.
class Policy
  attr_reader :base_path, :content_id, :title, :internal_name

  def initialize(attributes)
    @content_id = attributes["content_id"]
    @title = attributes["title"]
    @base_path = attributes["base_path"]
    @internal_name = attributes["internal_name"]
  end

  def self.find(content_id)
    if (attributes = find_policy(content_id))
      new(attributes)
    end
  end

  def self.all
    linkables.map { |attrs| new(attrs) }
  end

  def self.from_content_ids(content_ids)
    content_ids.map { |content_id| find(content_id) }.compact
  end

  def topics
    []
  end

  def slug
    @slug ||= base_path.split('/').last
  end

private

  def self.linkables
    Rails.cache.fetch('policy.linkables', expires_in: 5.minutes) do
      publishing_api.get_linkables(document_type: "policy").to_a
    end
  rescue GdsApi::TimedOutException, GdsApi::HTTPServerError => e
    Airbrake.notify_or_ignore(e)
    # This call normally takes ~20ms. If it takes longer than a second, fetch a stale value from
    # cache. Rails adds 5 minutes to the `expires_in` value above to generate the TTL it sends to
    # memcached, so we will have 5 minutes of staleness before the key is evicted.
    # If there's no key in the cache, just return an empty array. Incomplete data is more desirable
    # than 504s / 500s
    Rails.cache.fetch('policy.linkables') || []
  end

  def self.find_policy(content_id)
    linkables.find { |p| p["content_id"] == content_id }
  end

  def self.publishing_api
    @publishing_api ||= Whitehall.publishing_api_v2_client.dup.tap do |client|
      client.options[:timeout] = 1
    end
  end
end
