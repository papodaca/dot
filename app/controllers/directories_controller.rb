class DirectoriesController  < ApplicationController
  before_action :set_directory, only: %i[ show edit update destroy ]

  def show
    @articles = @directory.unread_articles
  end

  private
  def set_directory
    @directory = Directory.find(params[:id])
  end
end
