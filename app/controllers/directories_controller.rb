class DirectoriesController  < ApplicationController
  before_action :set_directory, only: %i[ show edit update destroy ]
  before_action :set_page, only: %i[ show ]

  def show
    @articles = @directory.unread_articles.page(@page)
  end

  def new
    @directory = Directory.new
  end

  def update

  end

  def edit

  end

  def update

  end

  def destroy

  end

  private
  def set_directory
    @directory = Directory.find(params[:id])
  end

  def set_page
    @page = params[:page] || 1
  end
end
