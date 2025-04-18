FROM ruby:3.3.8-alpine

RUN apk add --update --no-cache bash build-base tzdata postgresql-dev git gcompat yaml yaml-dev

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code/

COPY docker/entrypoint-web.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint-web.sh
ENTRYPOINT ["entrypoint-web.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
