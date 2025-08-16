describe QuestsController, type: :controller do
    before do
        Quest.destroy_all
    end
    let!(:quest) { Quest.create(name: "Test Quest", is_done: false) }

  describe "GET #index" do
    it "assigns all quests to @quests and initializes a new quest" do
      get :index
      expect(assigns(:quests)).to eq([ quest ])
      expect(assigns(:quest)).to be_a_new(Quest)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Quest and redirects to index" do
        expect {
          post :create, params: { quest: { name: "New Quest", is_done: false } }
        }.to change(Quest, :count).by(1)

        expect(response).to redirect_to(quests_path)
      end
    end

    context "with invalid params" do
      it "does not create a new Quest and re-renders index" do
        allow_any_instance_of(Quest).to receive(:save).and_return(false)

        expect {
          post :create, params: { quest: { name: "", is_done: false } }
        }.not_to change(Quest, :count)

        expect(response).to redirect_to(quests_path)
      end
    end
  end

  describe "PATCH #update" do
    it "updates the quest and redirects" do
      patch :update, params: { id: quest.id, quest: { name: "Updated" } }
      quest.reload
      expect(quest.name).to eq("Updated")
      expect(response).to redirect_to(quests_path)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the quest and returns turbo stream response" do
      expect {
        delete :destroy, params: { id: quest.id }, format: :turbo_stream
      }.to change(Quest, :count).by(-1)

      expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
    end
  end
end
