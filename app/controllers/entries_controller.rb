class EntriesController < ApplicationController

  before_action :authenticate_user!

  def index
    @entries = Entry.where(user: current_user).order("entries.created_at DESC")
    # @entries = @entries.includes([:emotion])
    if params[:query].present?
      if Emotion::EMOTIONS.include?(params[:query])
        parent_emotion = Emotion.find_by_name(params[:query])
        @entries = @entries.joins(:emotion).where(emotions: { emotion_id: parent_emotion.id })
      else
        @entries = @entries.search_by_sac(params[:query])
      end


      stats(@entries)


      if params[:datefilter].present?
        start_date = Date.parse(params[:datefilter].split(" to ").first)
        end_date = Date.parse(params[:datefilter].split(" to ").last)
      @entries_count = @entries.where(created_at: start_date.beginning_of_day..end_date.end_of_day).count
      else
        @entries_count = @entries.count
      end
      # raise
    end

    # @entries = @entries.search_by_sac(params[:query]) if params[:query].present?



    # @entries = @entries.where("created_at >= ? and created_at <= ?", *params[:datefilter].split(" to ")) if params[:datefilter].present?   Past calendar search, keep for now.

    if params[:datefilter].present?
      start_date = Date.parse(params[:datefilter].split(" to ").first)
      end_date = Date.parse(params[:datefilter].split(" to ").last)
      @entries = @entries.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    @parent_emotions = Emotion.where(parent_emotion: nil)
    # @entries = @entries.includes([:emotion])
    @entry = Entry.new

    @pagy, @entries = pagy(@entries)

    date = Date.today
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "kanwa #{date}", template: "entries/_entries", formats: [:html]
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
    @entry = Entry.new(entry_params.except(:specific_emotion_id))

    @entry.emotion = Emotion.find(entry_params[:specific_emotion_id])

    @entry.user = current_user
    if @entry.save
      redirect_to dashboard_path
      flash[:success] =
        if @entry.action == 'Yes'
          "A new entry was added"
        else
          "A new entry was added"
        end
      flash[:success_two] =
        if @entry.action == 'Yes'
          "Congratulations, you are becoming the master of your actions!"
        else
          "Don't get discouraged, the experience makes the master"
        end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def entry_params
    params.require(:entry).permit(:situation, :action, :consequence, :specific_emotion_id, :situation_details)
  end

  def pdf_params
    params.require(:query)
    params.require(:datafilter)
  end

  def action_count(entries)
    yes = 0
    no = 0
    entries.each do |entry|
      if entry.action == "Yes"
         yes += 1
      else
        no +=1
      end
    end
    return{yes: yes, no: no}
  end
end
# make array of emotions from user input

# group the entries by emotion
# for each entry in each emotion we find the situation
# count the sitaution, display
