# not Analytics

don't be creepy. 

## Quick start

```sh
git clone https://github.com/12joan/not-analytics.git &&
cd not-analytics &&
bundle install &&
echo &&
echo "Your app id is..." &&
cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1 | tee conf/apps && # <-- Generate a random app id
echo &&
rm db/.deleteme &&
rackup --host 0.0.0.0 -p 8080
```

`conf/apps` should contain a list of allowed app ids, one per line.

## Docker

```
git clone https://github.com/12joan/not-analytics.git &&
docker build --tag not-analytics not-analytics &&
mkdir -p $HOME/not-analytics/{db,conf} &&
echo &&
echo "Your app id is..." &&
cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1 | tee $HOME/not-analytics/conf/apps && # <-- Generate a random app id
echo &&
docker run \
	--rm \
	-d \
	-p 8080:8080 \
	-v $HOME/not-analytics/db:/code/db \
	-v $HOME/not-analytics/conf:/code/conf \
	--name not-analytics \
	not-analytics
```

## Recording hits

For every hit you want to track, send a request to the metrics server.

```
https://metricsserver.com/app_id/path
```

For example, to register a hit to `/12joan/not-analytics`, send the following request.

```
https://metricsserver.com/14b6a51577c125505e0524226783c895/12joan/not-analytics
```

**Please filter out query parameters before pinging the metrics server.**

## Perusing data

Hits are logged to `db/app_id.yml` with a resolution of one hour

```yaml
$ cat db/14b6a51577c125505e0524226783c895.yml 
---
Wed  6 Nov 2019 09:00:
  "/about/us": 12
  "/": 31
Wed  6 Nov 2019 10:00:
  "/": 11
Wed  6 Nov 2019 11:00:
  "/": 2
  "/about/us": 2
```

## Privacy

Consider linking to this GitHub repo in your privacy policy, so that users can see for themselves how their data is collected. 

