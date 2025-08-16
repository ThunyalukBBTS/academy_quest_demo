class QuestsController < ApplicationController
  before_action :set_quest, only: %i[ update destroy ]

  # GET /quests or /quests.json
  def index
    @quests = Quest.all.order(id: :asc)
    @quest = Quest.new
  end

  # POST /quests or /quests.json
  def create
    @quest = Quest.new(quest_params)

    respond_to do |format|
      if @quest.save
        format.turbo_stream
        format.html { redirect_to quests_path, notice: "Quest was successfully created." }
      else
        format.turbo_stream
        format.html { redirect_to quests_path, notice: "Quest was successfully created." }
      end
    end
  end

  # PATCH/PUT /quests/1 or /quests/1.json
  def update
    respond_to do |format|
      if @quest.update(quest_params)
        format.turbo_stream
        format.html { redirect_to quests_path }
      end
    end
  end

  # DELETE /quests/1 or /quests/1.json
  def destroy
    @quest.destroy!

    respond_to do |format|
        format.turbo_stream
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quest
      @quest = Quest.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def quest_params
      params.expect(quest: [ :name, :is_done ])
    end
end
