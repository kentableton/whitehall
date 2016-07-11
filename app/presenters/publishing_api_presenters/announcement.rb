module PublishingApiPresenters
  class Announcement
    include PublishingApiPresenters::UpdateTypeHelper

    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || default_update_type(item)
    end

    def content_id
      item.content_id
    end

    def content
      content = PublishingApiPresenters::BaseItem.new(item).base_attributes
      content.merge!(
        description: item.summary,
        details: PayloadBuilder::TagDetails.for(item),
        document_type: item.display_type_key,
        public_updated_at: item.public_timestamp || item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: "placeholder_#{item.class.name.underscore}",
      )
      content.merge!(PublishingApiPresenters::PayloadBuilder::PublicDocumentPath.for(item))
      content.merge!(PublishingApiPresenters::PayloadBuilder::AccessLimitation.for(item))
      content.merge!(PublishingApiPresenters::PayloadBuilder::WithdrawnNotice.for(item))
    end

    def links
      PublishingApiPresenters::LinksPresenter.new(item).extract(
        [
          :document_collections,
          :organisations,
          :parent,
          :related_policies,
          :topics,
          :world_locations,
          :worldwide_organisations,
        ]
      )
    end

  private

    def first_public_at
      return item.first_public_at if item.document.published?
      item.document.created_at.iso8601
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
    end

    def image_details
      {
        url: Whitehall.public_asset_host + presented_case_study.lead_image_path,
        alt_text: presented_case_study.lead_image_alt_text,
        caption: presented_case_study.lead_image_caption,
      }
    end

    def image_available?
      item.images.any? || emphasised_organisation_default_image_available?
    end

    def emphasised_organisation_default_image_available?
      item.lead_organisations.first.default_news_image.present?
    end

    def presented_case_study
      CaseStudyPresenter.new(item)
    end
  end
end
