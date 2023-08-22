class EntriesController < ApplicationController
  def index
  end

  def new
    @entry = Entry.new
    @emotions = Emotion.all
  end

  def create
    @entry = Entry.new(entry_params)
    @entry.user = current_user
    if @entry.save
      redirect_to entries_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def entry_params
    params.require(:entry).permit(:situation, :action, :emotion_id, :consequence)
  end

end

# make array of emotions from user input
