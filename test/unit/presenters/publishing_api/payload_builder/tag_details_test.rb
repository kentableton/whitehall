require "test_helper"

module PublishingApiPresenters
  module PayloadBuilder
    class TagDetailsTest < ActiveSupport::TestCase
      test "returns tag details for the item" do
        stubbed_item = stub(
          can_be_related_to_policies?: true,
          policies: [OpenStruct.new(slug: "a-policy")],
          primary_specialist_sector_tag: "ss_tag_1",
          secondary_specialist_sector_tags: %w{ss_tag_1 ss_tag_3}
        )
        expected_hash = {
          tags: {
            browse_pages: [],
            policies: %w{a-policy},
            topics: %w{ss_tag_1 ss_tag_1 ss_tag_3},
          }
        }

        assert_equal TagDetails.for(stubbed_item), expected_hash
      end
    end
  end
end
