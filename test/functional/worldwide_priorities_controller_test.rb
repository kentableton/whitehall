# encoding: utf-8
require "test_helper"

class WorldwidePrioritiesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :worldwide_priorities
  should_show_the_world_locations_associated_with :worldwide_priority
  should_display_inline_images_for :worldwide_priority

  view_test "show displays worldwide priority details" do
    priority = create(:published_worldwide_priority,
      title: "priority-title",
      body: "priority-body",
    )

    get :show, id: priority.document

    assert_select ".title", "priority-title"
    assert_select ".body", "priority-body"
  end

  view_test "should display the associated organisations" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    third_organisation = create(:organisation)
    edition = create(:published_worldwide_priority, organisations: [first_organisation, second_organisation])

    get :show, id: edition.document

    assert_select_object first_organisation
    assert_select_object second_organisation
    refute_select_object third_organisation
  end

  view_test "should not display an empty list of organisations" do
    edition = create(:published_worldwide_priority, organisations: [])

    get :show, id: edition.document

    refute_select "#organisations"
  end

  view_test "should display translated page labels when requested in a different locale" do
    edition = create(:published_worldwide_priority)

    get :show, id: edition.document, locale: 'fr'

    assert_select ".page_title", /Priorité mondiale/
    assert_select ".change-notes-title", /Publié/
  end
end