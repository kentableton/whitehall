module PublishingApi
  class OrganisationPresenter
    include ApplicationHelper

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
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        need_ids: [],
      ).base_attributes

      content.merge!(
        description: nil,
        details: details,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: schema_name,
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {}
    end

  private

    def schema_name
      "placeholder"
    end

    def details
      {
        brand: brand,
        logo: {
          formatted_title: formatted_title,
          crest: crest,
        },
      }
    end

    def crest
      crest_is_publishable? ? item.organisation_logo_type.class_name : nil
    end

    def crest_is_publishable?
      class_name = item.organisation_logo_type.class_name
      class_name != "no-identity" && class_name != "custom"
    end

    def formatted_title
      format_with_html_line_breaks(item.logo_formatted_name)
    end

    def brand
      brand_colour = item.organisation_brand_colour
      brand_colour ? brand_colour.class_name : nil
    end
  end
end
