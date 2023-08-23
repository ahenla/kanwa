class EntriesController < ApplicationController
  def index
    @entries = Entry.all
    @entries = @entries.search_by_sac(params[:query]) if params[:query].present?
    @entries = @entries.where("created_at >= ? and created_at <= ?", params[:datefilter].split(" - ").first, params[:datefilter].split(" - ").last) if params[:datefilter].present?
    @entry = Entry.new

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "kanwa_entries_file#{Date.now.strftime('%d %b %Y')}",
               template: 'pdf_entries/entries.html.erb'
      end
    end
  end

  def new
    @entry = Entry.new
    @parent_emotions = Emotion.where(parent_emotion: nil)
    respond_to do |format|
      format.html # Follow regular flow of Rails
      @child_emotions = Emotion.find(params[:query]).child_emotions if params[:query]
      format.text { render partial: "entries/new_child", locals: { emotions: @child_emotions }, formats: [:html] }
    end
  end

  def create
    @entry = Entry.new(entry_params)
    emotion = Emotion.find(params[:specific])
    @entry.emotion = emotion
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
    params.require(:entry).permit(:situation, :action, :consequence)
  end

end

# make array of emotions from user input