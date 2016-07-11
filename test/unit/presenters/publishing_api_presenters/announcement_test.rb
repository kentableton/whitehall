require 'test_helper'

module PublishingApiPresenters
  class AnnouncementTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    def present(announcement, options = {})
      PublishingApiPresenters::Announcement.new(announcement, options)
    end

    test 'presents an Announcement ready for adding to the publishing API' do
      announcement = create(:announcement)

      require 'pry-byebug';binding.pry;sleep 1


        # create(
        # :published_publication,
        # title: 'The title',
        # summary: 'The summary',
        # primary_specialist_sector_tag: 'oil-and-gas/taxation',
        # secondary_specialist_sector_tags: ['oil-and-gas/licensing']
      # )

      public_path = Whitehall.url_maker.public_document_path(announcement)

      expected_hash = {
        base_path: public_path,
        title: 'The title',
        description: 'The summary',
        schema_name: 'placeholder_announcement',
        document_type: 'policy_paper',
        locale: 'en',
        need_ids: [],
        public_updated_at: announcement.public_timestamp,
        publishing_app: 'whitehall',
        rendering_app: 'whitehall-frontend',
        routes: [
          { path: public_path, type: 'exact' }
        ],
        redirects: [],
        details: {
          tags: {
            browse_pages: [],
            policies: [],
            topics: ['oil-and-gas/taxation', 'oil-and-gas/licensing']
          }
        },
      }

      presented_item = present(announcement)
      assert_equal expected_hash, presented_item.content
      assert_equal expected_links_hash, presented_item.links
      assert_valid_against_schema(presented_item.content, 'placeholder')
    end
  end
end
