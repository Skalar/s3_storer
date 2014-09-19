# S3 storer

Node app for receiving a set of keys and URLs, store the URL on S3 and
return the set of keys with S3 (or could front) URLs.




# API Usage

API will always return 200 OK, but errors may occur. Reason for this is that we'll
start sending data to client, to keep connection open and stop Heroku from killing us.
We will know at a later point in time if some URLs fails or not and the status is serialized
in the JSON response. It will either be "ok", "error", or "timeout".

### POST to `/store` (auth header to be added)
```json
{
  "urls": {
    "thumb": "http://www.filepicker.com/api/XXX/convert/thumb",
    "monitor": "http://www.filepicker.com/api/XXX/convert/monitor"
  },
  "options": {
    "minBodyLength": 300,
    "tagLogsWith": "iweb-production asset-123"
  }
}
```
* Give key-value pairs of URLs to download, store on S3 and return URLs for.
* Available options
  * `minBodyLength` A response body length below this counts as an error.
  * `tagLogsWith` A string you want tag all logs related to this request with.

--------------------------------

### RESPONSE - success
* Status is `ok`
* All URLs are swapped out for stored URLs.

```json
{
  "status": "ok",
  "urls": {
    "thumb": "http://s3.com/sha1-of-thumb-url",
    "monitor": "http://s3.com/sha1-of-monitor-url"
  }
}
```

--------------------------------


### RESPONSE - failure from server we GET data from
* Status is `error`
* Keys with `null` was ok, but is cleaned from S3 due to other version failed.
* Keys with an object includes information about the response.

```json
{
  "status": "error",
  "urls": {
    "thumb": null,
    "monitor": {
      "response": {
        "status": 502,
        "body": "Bad Gateway"
      }
    }
  }
}
```

### RESPONSE - failure timeout
* Status is `timeout` due to max keep alive time exceeded.
* Any uploads to S3 we have done will be cleaned.

```json
{
  "status": "timeout"
}
```



# Development

```bash
npm install
nodemon --exec coffee bin/www
```




### Tests
Tests are written using [Mocha](http://visionmedia.github.io/mocha/) and
[Chai expect](http://chaijs.com/guide/styles/#expect) syntax style.
We use [Sinon](http://sinonjs.org/) for test utilities
and ..maybe [SuperTest](https://github.com/visionmedia/supertest) for integration tests(?).

Run `grunt test` when you want to run tests.




# Deployment
Is done to Heroku. Right now this app is just a test on how to keep
connection open on Heroku more than it's 30 / 55 seconds.
