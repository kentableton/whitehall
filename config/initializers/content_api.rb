require 'gds_api/content_api'

class GdsApi::ContentApi::Fake
  def tag(_tag, _tag_type)
    {}
  end

  def tags(_tag_type, _options = {})
    []
  end

  def artefact(*_args)
    nil
  end
end

if Rails.env.test?
  Whitehall.content_api = GdsApi::ContentApi::Fake.new
else
  Whitehall.content_api = GdsApi::ContentApi.new(Plek.find("contentapi"))
end
