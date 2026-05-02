FROM ruby:4.0.2-alpine

RUN apk add --update --no-cache bash build-base tzdata postgresql-dev git gcompat yaml yaml-dev musl-dev libffi-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

COPY docker/entrypoint-web.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint-web.sh
ENTRYPOINT ["entrypoint-web.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

HEALTHCHECK --start-period=1s --start-interval=1s \
  CMD curl -f http://localhost/healthcheck || exit 1
