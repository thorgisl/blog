TITLE ?= New Post
NEW_CMD=rake post title="$(TITLE)"

GEM_PATH=/Users/oubiwann/.chefdk/gem/ruby/2.1.0/bin
NEW_PATH=$(PATH):$(GEM_PATH)

STAGING_HOST=staging-blog.lfe.io
STAGING_PATH=/var/www/lfe/staging-blog

SRC=./src
BASE_DIR=$(shell pwd)
PROD_DIR=prod
PROD_PATH=$(BASE_DIR)/$(PROD_DIR)
STAGE_DIR=stage
STAGE_PATH=$(BASE_DIR)/$(STAGE_DIR)

update-gems:
	cd $(SRC) && PATH=$(PATH):$(GEM_PATH) \
	sudo gem update --system

install-jekyll: update-gems
	cd $(SRC) && PATH=$(PATH):$(GEM_PATH) \
	sudo gem install bundler
	cd $(SRC) && PATH=$(PATH):$(GEM_PATH) \
	bundle install

update: install-jekyll
	cd $(SRC) && PATH=$(PATH):$(GEM_PATH) \
	bundle update

clean:
	rm -rf $(STAGE_PATH)

$(STAGE_DIR):
	cd $(SRC) && \
	bundle exec jekyll build --destination $(STAGE_PATH)

run-stage: clean
	cd $(SRC) && \
	bundle exec jekyll serve --destination $(STAGE_PATH)

build:
	cd $(SRC) && \
	bundle exec jekyll build --destination $(PROD_PATH)

run:
	cd $(SRC) && \
	bundle exec jekyll serve --destination $(PROD_PATH)

staging: $(STAGE_DIR)
	git pull --all && \
	rsync -azP ./$(STAGE_DIR)/* $(STAGING_HOST):$(STAGING_PATH)
	make clean

publish: clean build
	git commit -a && git push --all
	git subtree push --prefix $(PROD_DIR) origin gh-pages

new:
	@OUT=$$(cd $(SRC); PATH=$(NEW_PATH) $(NEW_CMD)) ; \
	vim $(SRC)/$$(echo $$OUT | cut -d ' ' -f 4-)
