FROM ruby:2.7.1-alpine3.11

# Add necessary packages
RUN apk --update add bash tzdata build-base ca-certificates postgresql-client postgresql-dev libev

# Create the run user and group
RUN addgroup --gid 18570 sse && adduser --uid 1984 docker -G sse -D

# set the timezone appropriatly
ENV TZ=UTC
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add necessary gems
RUN gem install bundler -v 2.1.4

# Specify home
ENV APP_HOME /virgo4-pda
WORKDIR $APP_HOME

# Copy the Gemfile into the image and temporarily set the working directory to where they are.
ADD Gemfile Gemfile.lock .ruby-gemset ./
#RUN rm -rf tmp/cache/*

# install the gems
RUN bundle install --jobs=4 --without="development test"

# install the app and bundle
COPY . $APP_HOME

# Update permissions
RUN chown -R docker $APP_HOME && chgrp -R sse $APP_HOME

# Specify the user
USER docker

# define port and startup script
EXPOSE 8080
CMD scripts/entry.sh

# move in the profile
COPY package/container_bash_profile /home/docker/.profile