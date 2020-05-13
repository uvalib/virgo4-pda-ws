# PDA Request Service for Virgo 4

## Local Dev Setup

- Install ruby version matching `.ruby-version`
- Install Postgres
- run `bundle install`
- run `rake db:setup` including environment variables
- run `puma` with environment variables

## Required environment variables:

- PROQUEST_BASE_URL
- PROQUEST_API_KEY
- PROQUEST_ADMIN_EMAIL
- V4_JWT_KEY
- DBHOST
- DBNAME
- DBUSER
- DBPASS
