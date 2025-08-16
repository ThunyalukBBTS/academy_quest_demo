# Step

-   **Note:** for each step you should commit code.

## Setup

-   New rails project with postgresql and tailwind: `rails new acade --database=postgresql --css=tailwind`
-   Go to `config/database.yml` then use template
>[!NOTE]
>Please change `<database_name>` with your custom name

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

## Testing

-   Install **Rspec**: go to `Gemfile` in the section `group :test` add `gem "rspec-rails"` like

```Gemfile
group :test do
  gem "rspec-rails"
  gem "capybara"
  gem "selenium-webdriver"
end
```

-   Run command to install rspec

```bash
bundle exec rails generate rspec:install
```

-   Config `spec/rails_helper.rb`

```rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rspec'

# import all file in folder support
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|

  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
  config.use_transactional_fixtures = true

  # type ignore (P'Mac recommended)
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
```

-   Update `.rspec` to required rails_helper by default (you don't need to add `require 'rails_helper'` on the first line of the test file)

```
--require spec_helper
--require rails_helper
```

-   Write your **model, controller and E2E tests** (you can see the example of tests in `/spec`)
-   Run all your tests
    ```bash
    bundle exec rspec
    ```
    if the terminal shows database connection error you might try to source DATABASE_URL in the terminal before run test like
    ```bash
    DATABASE_URL=xxxxxx bundle exec rspec
    ```
    if active record error try
    ```bash
    bin/rails db:environment:set RAILS_ENV=test
    ```
## CI/CD
- Update `.github/workflows/ci.yml` with my custom GitHub actions template (use rspec to run test instead of minitest)
>[!WARNING]
>Should run lint before push and run CI using `bundle exec rubocop -a`
- Push code to GitHub repository then see the pipeline run in tab **Actions**
## Deployment
- Try to deploy on local machine docker. Add the app service to services of `docker-compose.yml`
  ```yaml
  app: 
      build: .
      container_name: academy-quest-boss-lepan-app
      command: bundle exec rails s
      environment:
        SECRET_KEY_BASE: ${SECRET_KEY_BASE}
        DATABASE_URL: ${DATABASE_URL_PRODUCTION}
      volumes:
        - .:/app
      ports:
        - 3000:3000 
  ```
  Then update `.env` file with
  ```env
  DATABASE_URL=postgres://xxx:yyy@localhost/zzz
  DATABASE_URL_PRODUCTION=postgres://xxx:yyy@db/zzz
  # change ip from local host to db          ^^
  ```
### Create Render database
- Go to [Render](https://render.com/) > Dashboard > login with your account > click `+ Add new` button > Postgres
- Edit `Name`, `Database`, `User` with your custom name
- For the best database latency should select `Region` to `Singapore (Southeast Asia)`  
>[!WARNING]
>**Plan Options** should select `free`
- Click `Create Database`
- Then can use `External Database URL` in local machine to render database
- Can use `Internal Database URL` in render container variables when you deployed app inside render 
### Create Supabase database
- Go to [Supabase](https://supabase.com) sign in
- Create organization
- **Copy the password** then save it
- Click connect button > Session pooler > Copy url that start with `postgresql://` to `.env` then replace `[YOUR-PASSWORD]` with password 
- Then can use the supabase database with `DATABASE_URL`
### Deploy web service on Render
>[!NOTE]
>Your code should be in the GitHub repository and the repository should be public 
- Go to [Render](https://render.com/) > Dashboard > login with your account > click `+ Add new` button > `Web Service`
- Source Code: Click `Public Git Repository` then copy url or the repository to repository url and naming the service
- Select `Region` to `Singapore (Southeast Asia)`
>[!WARNING]
>**Plan Options** should select `free`
- In the `Environment Variables` copy the variable name and value to render
  - `WEB_CONCURRENCY` use default render value
  - `RAILS_MASTER_KEY` the value is in the `config/master.key` file
  - `SECRET_KEY_BASE` the value is in the `config/credentials.yml.enc` file
  - `DATABASE_URL` from `Render` or `Supabase`
- Click `Deploy Web Service` and wait until render deploy success then you can access your project with public url like `https://test.onrender.com/`
- (Optional) For the best practice that we should deploy only the best code quality. we should setting render to re-deploy only the GitHub actions CI run passed only. Go to the render web service project > settings > `Auto-Deploy` change to `After CI Checks Pass`