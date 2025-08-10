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
	rails db:migrate;

.PHONY: db-reset
db-reset:
	rails db:reset;