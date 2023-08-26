# docker-compose 全て削除
docker-compose down --rmi all --volumes --remove-orphans

# setup
docker-compose build --no-cache & docker compose build
docker compose run --rm web bin/setup
docker compose run --rm web yarn install
docker compose up -d
docker compose run --rm web bundle exec rubocop -A
docker compose run --rm web bin/htmlbeautifier

### 共通 ###

# Docker ビルド
docker-compose run --rm web bundle install
docker-compose build

# DB接続
docker-compose exec db psql -U postgres -d myapp_development

### 💻 サインアップ、ログイン機能実装 ###

# devise インストール
docker-compose run --rm web rails g devise:install

# User モデル作成
docker-compose run --rm web rails g devise User
docker-compose run --rm web rails db:migrate

# ユーザー専用のControllerとViewの生成
docker-compose run --rm web rails g devise:controllers users
docker-compose run --rm web rails g devise:views users

# Calling `DidYouMean::SPELL_CHECKERS.merge!(error_name => spell_checker)' has been deprecated. Please call `DidYouMean.correct_error(error_name, spell_checker)' instead
bundle update --bundler

# ロールバック
docker compose run --rm web rails db:rollback

# データベースのリセット
docker compose run --rm web rails db:drop db:create db:migrate

# サインイン後のリダイレクト先を変更
docker-compose run --rm web rails g controller home index

# gem "slim-rails" "html2slim" 
docker-compose run --rm web bundle install
docker-compose build
docker-compose run --rm web bundle exec erb2slim app/views/ --delete

### 💻 githubログインの実装 ###
docker-compose run --rm web rails generate migration AddOmniauthToUsers provider:string uid:string
docker-compose run --rm web rails db:migrate
