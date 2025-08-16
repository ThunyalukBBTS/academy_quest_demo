include .env

.PHONY: run
run:
	./bin/dev;

.PHONY: db-up
db-up:
	docker compose up -d db;

.PHONY: db-down
db-down:
	docker compose down db;

.PHONY: migrate
migrate:
	DATABASE_URL=${DATABASE_URL} rails db:migrate;

.PHONY: db-reset
db-reset:
	DATABASE_URL=${DATABASE_URL} rails db:reset;

.PHONY: test
test:
	DATABASE_URL=${DATABASE_URL} bundle exec rspec