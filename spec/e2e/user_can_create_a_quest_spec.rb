describe "User can create a quest", type: :feature do
    before do
        Quest.destroy_all
    end

    context "when a user be in the home page" do
        before do
            go_to_home_page
        end

        it "should see home detail on the home page" do
            should_see_title_on_home_page
            should_see_quest_form
        end

        it "allows user to create a new quest" do
            fill_in_the_quest_name_field_with "Test Enter Quest Name"
            click_the_submit_button
            should_see_the_new_quest_name "Test Enter Quest Name"
        end
    end

    context "when a quest exists" do
        let!(:quest) { Quest.create(name: "Test Quest", is_done: false) }

        before do
            go_to_home_page
        end

        it "should see the quest on the home page" do
            new_quest = find("[data-testid='quest-name-#{quest.id}']")
            expect(new_quest.text).to eq("Test Quest")
        end
    end
end

def go_to_home_page
    visit root_path
end

def should_see_title_on_home_page
    title = find("[data-testid='boss-name']")
    expect(title.text).to eq("Boss | Thunyaluk Sasiwarinkul")
end

def should_see_quest_form
    form = find("[data-testid='quest-form']")
    name_field = find("[data-testid='quest-form-name']")
    submit_button = find("[data-testid='quest-form-submit']")
    expect(form).to be_visible
    expect(name_field).to be_visible
    expect(submit_button).to be_visible
end

def fill_in_the_quest_name_field_with(name)
    name_field = find("[data-testid='quest-form-name']")
    name_field.fill_in with: name
end

def click_the_submit_button
    submit_button = find("[data-testid='quest-form-submit']")
    submit_button.click
end

def should_see_the_new_quest_name(name)
    expect(page).to have_content name
end