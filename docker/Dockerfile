FROM ruby:2.7

WORKDIR /usr/app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY . /usr/app
