FROM ruby:4.0.4-alpine

RUN apk add --update --no-cache build-base postgresql-dev git yaml-dev musl-dev libffi-dev curl

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
  CMD curl -f http://localhost:3000/healthcheck || exit 1
