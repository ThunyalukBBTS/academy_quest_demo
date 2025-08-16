# Step

-   **Note:** for each step you should commit code.

## Setup

-   New rails project with postgresql and tailwind: `rails new acade --database=postgresql --css=tailwind`
-   Go to `config/database.yml` then use template
>[!NOTE] Please change `<database_name>` with your custom name

```yml
default: &default
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    url: <%= ENV.fetch("DATABASE_URL") { "postgres://localhost/<database_name>" } %>

development:
    <<: *default
    database: <database_name>_development

test:
    <<: *default
    database: <database_name>_test

production:
    primary: &primary_production
        <<: *default
        url: <%= ENV.fetch("DATABASE_URL") { "postgres://localhost/<database_name>" } %>
    cache:
        <<: *primary_production
    queue:
        <<: *primary_production
    cable:
        <<: *primary_production
```

-   Create `docker-compose.yml` to start up postgresql database

```yml
services:
    db:
        image: postgres:17.4-alpine
        restart: always
        environment:
            POSTGRES_USER: ${DB_USERNAME}
            POSTGRES_PASSWORD: ${DB_PASSWORD}
            POSTGRES_DB: ${DB_NAME}
        ports:
            - 5432:5432
        volumes:
            - rails-data:/var/lib/postgresql/data

volumes:
    rails-data:
```

-   Create `.env` file using template

```
DATABASE_URL=postgres://xxx:yyy@localhost/zzz
DB_USERNAME=xxx
DB_PASSWORD=yyy
DB_NAME=zzz
```

-   Run command `docker compose up -d db`
-   Start rails dev server using command `bin/dev` then go to web browser and should see rails starting web template. If show error please check `docker-compose.yml`, `.env`, and `config/database.yml`

## Create quest (home page)

-   Open website https://rails-generate.com/scaffold then config attributes and name then copy the **rails generate** command and run in terminal.
-   Run migrate `rails db:migrate` if error source the database url before commnad like `DATABASE_URL=XXX rails db:migrate`
-   Go to `config/routes.rb` then set root to created controller like

```rb
Rails.application.routes.draw do
  resources :quests
  get "up" => "rails/health#show", as: :rails_health_check
  root "quests#index"
end
```

-   Custom `app/views/quests/index.html.erb` with your style and use template like (to render quests and form using partial)

```erb
<div class="custom your style">
  <div class="custom your style">
    <div class="custom your style">
    --------------  Your name and other information  ------------
      <div class="my-5">
        <%= link_to "My brag document", brag_path %>
      </div>
      <%= image_tag "your_image_path", class: "custom your style" %>
    </div>
    <div class="custom your style">
      <%= turbo_frame_tag "new_quest_form" do %>
        <%= render "form", quest: @quest %>
      <% end %>
      <%= turbo_frame_tag "quests" do %>
        <%= render partial: "quest", collection: @quests, as: :quest %>
      <% end %>
    </div>
  </div>
</div>

```

-   In the `app/views/quests/_form.html.erb`

```erb
<%= form_with(model: quest, class: "contents") do |form| %>
    <%= form.text_field :name, class: "<custom your style>", required: true  %>
    <%= form.hidden_field :is_done, value: false %>
    <%= form.submit %>
<% end %>
```

-   Create `app/views/quests/create.turbo_stream.erb` file: **turbo template** to append a quest to quests list area when form submit and clear form

```erb
<%= turbo_stream.append "quests" do %>
  <%= render partial: "quest", locals: { quest: @quest } %>
<% end %>
<%= turbo_stream.replace "new_quest_form", partial: "form", locals: { quest: Quest.new } %>
```

-   Create `app/views/quests/update.turbo_stream.erb` file: **turbo template** to replace a quest partial when click checkbox

```erb
<%= turbo_stream.replace dom_id(@quest) do %>
  <%= render partial: "quest", locals: { quest: @quest } %>
<% end %>
```

-   Create `app/views/quests/destroy.turbo_stream.erb` file: **turbo template** to remove a quest from quests list area when click remove a quest

```erb
<%= turbo_stream.remove dom_id(@quest) %>
```

-   Update `app/views/quests/_quest.html.erb` to use stimulus when click checkbox call function submit to submit the form

```erb
<%= turbo_frame_tag dom_id(quest) do %>
  <div class="custom your style" >
    <div class="custom your style">
      <%= form_with model: quest, method: :patch do |f| %>
        <%= f.check_box :is_done,
    checked: quest.is_done, class: "custom your style", data: { controller: "checkbox", action: "change->checkbox#submit" }%>
      <% end %>
      <div class="custom your style <%= quest.is_done ? "line-through" : "" %>"><%= quest.name %></div>
    </div>
    <%= link_to quest_path(quest), data: { turbo_method: :delete }, class: "text-red-500" do %>
      ------- Delete button --------
    <% end %>
  </div>
<% end %>
```

-   Create stimulus controller using command

```bash
rails g stimulus checkbox
```

-   In the `app/javascript/controllers/checkbox_controller.js` file write function to click nearest form

```js
import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="checkbox"
export default class extends Controller {
    submit(event) {
        this.element.closest("form").requestSubmit();
    }
}
```

## Create brag document page

-   Generate controller

```bash
rails g controller Brag
```

-   Crete `app/views/brag/index.html.erb` file manually with your brag document information

```erb
<div class="your style">
  <div class="your style">
    <!-- back to home page button -->
    <%= link_to "Back", root_path %>
  </div>
</div>
```

-   Update `config/routes.rb` file to have path `/brag` that references to `brag` controller and method `index`

```rb
Rails.application.routes.draw do
  resources :quests
  get "up" => "rails/health#show", as: :rails_health_check
  get "/brag" => "brag#index", as: :brag
  root "quests#index"
end
```
