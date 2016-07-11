module PublishingApiPresenters
  class MinisterialRole
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItem.new(
        item,
        title: item.name,
        need_ids: [],
      ).base_attributes

      content.merge!(
        description: nil,
        base_path: base_path,
        details: {},
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "placeholder",
      )
      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      LinksPresenter.new(item).extract([:organisations])
    end

  private

    def base_path
      Whitehall.url_maker.polymorphic_path(item)
    end
  end
end
