class ArticlesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  layout "default"

  def show
    @article = Article.find(params[:id])
  end

  def index 
    @non_featured = Article.non_featured
    @featured = Article.featured
  end

  def create
    a = Article.new(params[:article].merge(:user => current_user))
    if a.save
      flash[:notice] = "Your article, titled '#{a.headline}', has been submitted"
      redirect_to :action => "index"
    else
      logger.error("Article could not be saved: #{a.errors.inspect}")
      logger.error("HEADLINE: " + a.headline)
      logger.error("BODY: " + a.body)
      flash[:error] = "Your article could not be saved.  Please contact EVE-Trade administration and refer to time code #{Time.now.utc}"
      redirect_to "/corp_mgmt"
    end
  end

  def can_afford_featured_article
    render :json => current_user.balance >= Fee::FEATURED_ARTICLE
  end

  def render_to_html
    render :text => BlueCloth.new(params[:markdown]).to_html
  end
end
