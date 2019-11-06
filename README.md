# not Analytics

don't be creepy. 

## Setup

```sh
git clone https://github.com/12joan/not-analytics
cd not-analytics
vim app.rb # <-- Don't forget to use your own app ID
mkdir -p db/
rackup -o 0.0.0.0 -p PORT
```

Use your own app ID (any randomly generated string) for the hash in `App#app_id_valid?`

```ruby
def app_id_valid?
  { "14b6a51577c125505e0524226783c895" => true }.fetch(app_id, false)
end
```

**Warning:** Having `app_id_valid?` return true for arbitrary user input introduces a security vulnerability. See `db_path` to understand why. 

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

