require 'test_helper'

class PublishingApiPresenters::EditionTest < ActiveSupport::TestCase
  include GovukContentSchemaTestHelpers::TestUnit

  def present(edition, options = {})
    PublishingApiPresenters::Edition.new(edition, options)
  end

  # TEMPLATE
  test 'presents an Edition ready for adding to the publishing API' do
    pub_edition = create(
      :published_publication,
      title: 'The title',
      summary: 'The summary',
      primary_specialist_sector_tag: 'oil-and-gas/taxation',
      secondary_specialist_sector_tags: ['oil-and-gas/licensing']
    )

    public_path = Whitehall.url_maker.public_document_path(edition)

    expected_hash = {
      base_path: public_path,
      title: 'The title',
      description: 'The summary',
      schema_name: 'placeholder_publication',
      document_type: 'policy_paper',
      locale: 'en',
      need_ids: [],
      public_updated_at: edition.public_timestamp,
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

    expected_links_hash = {}

    presented_item = present(edition)
    assert_equal expected_hash, presented_item.content
    assert_equal expected_links_hash, presented_item.links
    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  # EXTRACT
  test 'minor changes are a "minor" update type' do
    edition = create(:case_study, minor_change: true)
    assert_equal 'minor', present(edition).update_type
  end

  # EXTRACT
  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    edition = create(:case_study)
    presented_item = present(edition, update_type: update_type_override)
    assert_equal update_type_override, presented_item.update_type
  end
end
