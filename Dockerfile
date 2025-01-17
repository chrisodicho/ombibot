FROM ruby:2.3.0

RUN sudo apt-get update && sudo apt-get -y install build-essential

# Update and install all of the required packages.
# At the end, remove the apk cache

RUN mkdir /usr/app
WORKDIR /usr/app
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN gem install bundler -v 1.17
RUN bundle install
COPY . /usr/app
CMD ["bundle", "exec", "foreman", "start"]
