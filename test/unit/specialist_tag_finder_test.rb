require "test_helper"
require "gds_api/test_helpers/content_store"

class SpecialistTagFinderTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  test "#topics returns all linked topics" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApi::Edition.new(edition).base_path
    content_item = content_item_for_base_path(edition_base_path).merge!({
      "links" => {
        "topics" => [
          { "title" => "topic-1" },
          { "title" => "topic-2" },
        ]
      }
    })

    content_store_has_item(edition_base_path, content_item)

    assert_equal ["topic-1", "topic-2"], SpecialistTagFinder.new(edition).topics.map { |topic| topic["title"] }
  end

  test "#topics returns empty array if no content item found" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApi::Edition.new(edition).base_path

    content_store_does_not_have_item(edition_base_path)

    assert_equal [], SpecialistTagFinder.new(edition).topics
  end

  test "#topics returns empty array if content item has no topics link" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApi::Edition.new(edition).base_path
    content_item = content_item_for_base_path(edition_base_path).merge!(
      "links" => { "other" => [] }
    )

    content_store_has_item(edition_base_path, content_item)

    assert_equal [], SpecialistTagFinder.new(edition).topics
  end

  test "#top_level_topic returns the parent of the edition's parent topic" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApi::Edition.new(edition).base_path
    parent_base_path = "/parent-item"
    edition_content_item = content_item_for_base_path(edition_base_path).merge!({
      "links" => { "parent" => [{ "base_path" => parent_base_path }] }
    })
    parent_content_item = content_item_for_base_path(parent_base_path).merge!({
      "links" => { "parent" => [{ "base_path" => "/grandpa" }] }
    })

    content_store_has_item(edition_base_path, edition_content_item)
    content_store_has_item(parent_base_path, parent_content_item)

    assert_equal "/grandpa", SpecialistTagFinder.new(edition).top_level_topic.base_path
  end

  test "#top_level_topic returns nil if no parents" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApi::Edition.new(edition).base_path
    edition_content_item = content_item_for_base_path(edition_base_path).merge!({
      "links" => { }
    })

    content_store_has_item(edition_base_path, edition_content_item)

    assert_equal nil, SpecialistTagFinder.new(edition).top_level_topic
  end

  test "#top_level_topic returns nil if not content item found" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApi::Edition.new(edition).base_path

    content_store_does_not_have_item(edition_base_path)

    assert_equal nil, SpecialistTagFinder.new(edition).top_level_topic
  end
end
