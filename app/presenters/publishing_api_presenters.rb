module PublishingApiPresenters
  def self.presenter_for(model, options={})
    presenter_class_for(model).new(model, options)
  end

  class UndefinedPresenterError < StandardError
  end

private
  def self.presenter_class_for(model)
    case model
    when ::Edition
      presenter_class_for_edition(model)
    when ::Unpublishing
      PublishingApiPresenters::Unpublishing
    when AboutPage
      PublishingApiPresenters::TopicalEventAboutPage
    when PolicyGroup
      PublishingApiPresenters::WorkingGroup
    when TakePartPage
      PublishingApiPresenters::TakePart
    when Topic
      PublishingApiPresenters::PolicyAreaPlaceholder
    when ::Organisation
      PublishingApiPresenters::Organisation
    when ::TopicalEvent
      PublishingApiPresenters::TopicalEvent
    when ::StatisticsAnnouncement
      if model.requires_redirect?
        PublishingApiPresenters::StatisticsAnnouncementRedirect
      else
        PublishingApiPresenters::StatisticsAnnouncement
      end
    when ::HtmlAttachment
      PublishingApiPresenters::HtmlAttachment
    when ::Person
      PublishingApiPresenters::Person
    when ::WorldLocation
      PublishingApiPresenters::WorldLocation
    when ::MinisterialRole
      PublishingApiPresenters::MinisterialRole
    when ::WorldwideOrganisation
      PublishingApiPresenters::WorldwideOrganisation
    else
      raise UndefinedPresenterError, "Could not find presenter class for: #{model.inspect}"
    end
  end

  def self.presenter_class_for_edition(edition)
    case edition
    when ::CaseStudy
      PublishingApiPresenters::CaseStudy
    when ::DocumentCollection
      PublishingApiPresenters::DocumentCollectionPlaceholder
    when ::DetailedGuide
      PublishingApiPresenters::DetailedGuide
    when ::Publication
      PublishingApiPresenters::Publication
    when Announcement
      PublishingApiPresenters::Announcement
    else
      # This is a catch-all clause for the following classes:
      # NewsArticle, WorldLocationNewsArticle, Speech, CorporateInformationPage,
      # Consultations, StatisticalDataSet
      # The presenter implementation for all of these models is identical and
      # the structure of the presented payload is the same.
      PublishingApiPresenters::GenericEdition
    end
  end
end
