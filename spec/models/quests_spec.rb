describe "Quests: ", type: :model do
    context "when a user creates a new quest" do
        before do
            Quest.destroy_all
        end

        it "can create a new quest" do
            quest = Quest.new(name: "test", is_done: false)
            expect(quest.save).to be true
        end
    end
end
