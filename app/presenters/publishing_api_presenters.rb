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
      PublishingApi::PolicyAreaPlaceholderPresenter
    when ::Organisation
      PublishingApi::OrganisationPresenter
    when ::TopicalEvent
      PublishingApiPresenters::TopicalEvent
    when ::StatisticsAnnouncement
      if model.requires_redirect?
        PublishingApi::StatisticsAnnouncementPresenterRedirect
      else
        PublishingApi::StatisticsAnnouncementPresenter
      end
    when ::HtmlAttachment
      PublishingApi::HtmlAttachmentPresenter
    when ::Person
      PublishingApi::PersonPresenter
    when ::WorldLocation
      PublishingApiPresenters::WorldLocation
    when ::MinisterialRole
      PublishingApi::MinisterialRolePresenter
    when ::WorldwideOrganisation
      PublishingApiPresenters::WorldwideOrganisation
    else
      raise UndefinedPresenterError, "Could not find presenter class for: #{model.inspect}"
    end
  end

  def self.presenter_class_for_edition(edition)
    case edition
    when ::CaseStudy
      PublishingApi::CaseStudyPresenter
    when ::DocumentCollection
      PublishingApi::DocumentCollectionPlaceholderPresenter
    when ::DetailedGuide
      PublishingApi::DetailedGuidePresenter
    when ::Publication
      PublishingApi::PublicationPresenter
    else
      # This is a catch-all clause for the following classes:
      # NewsArticle, WorldLocationNewsArticle, Speech, CorporateInformationPage,
      # Consultations, StatisticalDataSet
      # The presenter implementation for all of these models is identical and
      # the structure of the presented payload is the same.
      PublishingApi::GenericEditionPresenter
    end
  end
end
