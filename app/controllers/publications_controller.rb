class PublicationsController < DocumentsController
  def index
    @publications = all_publications

    if params[:keywords].present?
      @keywords = params[:keywords].split(/\s+/)
      @publications = @publications.with_content_containing(*@keywords)
    end

    if params[:date].present?
      @date = Date.parse(params[:date])
    end

    if params[:direction].present?
      @direction = params[:direction]
      if @date.present?
        case @direction
        when "before"
          @publications = @publications.published_before(@date)
        when "after"
          @publications = @publications.published_after(@date)
        end
      end
    end

    if "after" == @direction
      @publications = @publications.in_chronological_order
    else
      @publications = @publications.in_reverse_chronological_order
    end

    @all_topics = Topic.with_content.order(:name)
    @selected_topics = []
    if params[:topics].present? && !params[:topics].include?("all")
      @selected_topics = Topic.where(slug: params[:topics])
      @publications = @publications.in_topic(@selected_topics)
    end

    @all_organisations = Organisation.ordered_by_name_ignoring_prefix
    @selected_departments = []
    if params[:departments].present? && !params[:departments].include?("all")
      @selected_departments = Organisation.where(slug: params[:departments])
      @publications = @publications.in_organisation(@selected_departments)
    end

  end

  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
  end

  def all_publications
    Publication.published.includes(:document, :organisations, :attachments)
  end

  def document_class
    Publication
  end
end
