#
#
#

FROM public.ecr.aws/docker/library/ruby:3.2.4-alpine3.20

# Add necessary packages
RUN apk --update add bash tzdata build-base ca-certificates postgresql-client postgresql-dev libev && rm -rf /var/cache/apk/*

# Create the run user and group
RUN addgroup --gid 18570 sse && adduser --uid 1984 docker -G sse -D

# set the timezone appropriatly
ENV TZ=UTC
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Specify home
ENV APP_HOME /virgo4-pda
WORKDIR $APP_HOME

# Copy the Gemfile into the image and temporarily set the working directory to where they are.
ADD Gemfile Gemfile.lock .ruby-gemset ./

# install the gems
RUN bundle install --jobs=4 --without="development test"

# install the app and bundle
COPY . $APP_HOME

# Update permissions
RUN chown -R docker $APP_HOME && chgrp -R sse $APP_HOME

# Add the build tag
ARG BUILD_TAG
RUN test -n "$BUILD_TAG" && touch $APP_HOME/buildtag.build-$BUILD_TAG || touch $APP_HOME/buildtag.build-0

# Specify the user
USER docker

# define port and startup script
EXPOSE 8080
CMD scripts/entry.sh

# move in the profile
COPY package/container_bash_profile /home/docker/.profile

#
# end of file
#
