FROM ruby:4.0.2-alpine

RUN apk add --update --no-cache build-base tzdata postgresql-dev git gcompat yaml yaml-dev musl-dev libffi-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1
RUN bundle install

COPY . .

RUN chmod +x /app/docker/entrypoint-web.sh
ENTRYPOINT ["/app/docker/entrypoint-web.sh"]

EXPOSE 3000

ENV RAILS_ENV=production
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

HEALTHCHECK --start-period=1s --start-interval=1s \
  CMD curl -f http://localhost/healthcheck || exit 1
