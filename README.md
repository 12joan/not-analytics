# not Analytics

don't be creepy. 

## Usage with Docker

```bash
git clone https://github.com/12joan/not-analytics.git
cd not-analytics
docker-compose up -d --build 
```

## Registering an App

Access the Rails console using `docker-compose exec web rails c`.

```ruby
app_id = SecureRandom.hex
# => "87f7ac80212a68dd80ae3ad3341fda42"

App.create(id: app_id, name: 'My App')
```

Optionally, specify a secret key to protect against replay attacks.

```ruby
key = Base64.encode64(SecureRandom.random_bytes(32))
# => "aIT90JS5/wA2m8fBVDqHCH0ajNWgkUelFceaNNr1D3g=\n" 

App.create(id: app_id, name: 'My App', key: key)
```

## Record a hit

Hits can be recorded using the [not Analytics Client](https://github.com/12joan/not-analytics-client).

Alternatively, you can record hits manually using `curl`.

```bash
curl \
  https://hit.example.com/ \
  -H 'Content-Type: application/json' \
  -d '{
    "hit": {
      "app_id": "87f7ac80212a68dd80ae3ad3341fda42",
      "event": "/some/path"
    }
  }'
```

If a key was specified for the App, the request must be accompanied by a non-reusable nonce, and must be signed using AES-256-GCM.

```ruby
key = "aIT90JS5/wA2m8fBVDqHCH0ajNWgkUelFceaNNr1D3g=\n"

nonce = SecureRandom.hex
# => "6e550d9746e27c1e7a37e8d5f2e63269"

event = 'some/path'

cipher = OpenSSL::Cipher.new('aes-256-gcm')
cipher.encrypt
cipher.key = Base64.decode64(key)

{
  iv: cipher.random_iv,
  signature: cipher.update("#{nonce}:#{event}") + cipher.final,
  auth_tag: cipher.auth_tag,
}.transform_values { |v| Base64.encode64(v) }
# => {:iv=>"jrBi3VbhyE699L/2\n", :signature=>"1HdXQ+M3Fz1BzOVi7cw=\n", :auth_tag=>"rQuKyXuXZY91zLlsSQJBlg==\n"}
```

```bash
curl \
  https://hit.example.com/ \
  -H 'Content-Type: application/json' \
  -d '{
    "hit": {
      "app_id": "87f7ac80212a68dd80ae3ad3341fda42",
      "event": "/some/path",
      "nonce": "6e550d9746e27c1e7a37e8d5f2e63269",
      "signature": "1HdXQ+M3Fz1BzOVi7cw=",
      "iv": "jrBi3VbhyE699L/2",
      "auth_tag": "rQuKyXuXZY91zLlsSQJBlg=="
    }
  }'
```
