FROM ruby:2.4.1
RUN apt-get update && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir -p /orders
WORKDIR /orders
ADD . /orders
RUN bundle install
