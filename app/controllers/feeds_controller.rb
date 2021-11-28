class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy ]
  before_action :set_page, only: %i[ index show ]

  # GET /feeds
  def index
    @articles = current_user.root.unread_articles.order(:pub_date).page(@page)
    @tags = Tag.from_article_list(@articles)
  end

  # GET /feeds/1
  def show
    @articles = @feed.unread_articles.order(:pub_date).page(@page)
    @tags = Tag.from_article_list(@articles)
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds
  def create
    @feed = Feed.new(feed_params)

    if @feed.save
      redirect_to @feed, notice: "Feed was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /feeds/1
  def update
    if @feed.update(feed_params)
      redirect_to @feed, notice: "Feed was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /feeds/1
  def destroy
    @feed.destroy
    redirect_to feeds_url, notice: "Feed was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    def set_page
      @page = params[:page] || 1
    end

    # Only allow a list of trusted parameters through.
    def feed_params
      params.require(:feed).permit(:title, :url, :link, :icon, :description, :error, :user_id, :directory_id)
    end
end
