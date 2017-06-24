# S3 storer
Node app for receiving a set of keys and URLs, store the URLs on S3 and
return the set of keys with S3 (or CouldFront) URLs.

[ ![Codeship Status for inviso-org/s3_storer](https://www.codeship.io/projects/650e6580-2260-0132-8503-364bcc8fbc9d/status)](https://www.codeship.io/projects/36519)



# API Usage
API will return 200 OK, but errors may occur during requests. The reason for this is that we'll
start sending data to client right away, to keep connection open and stop Heroku from killing us.
We will know at a later point in time if some URLs fails or not and the status is serialized
in the JSON response. It will either be "ok", "error", or "timeout".

API request sanity validations will return 422 as they happen at the very beginning of each request.

A request to the API should behave in a transactional manner, meaning that either all
given URLs are successfully uploaded, or non will be stored on S3. We will try and clean
any uploaded files to S3 if other files fail.



#### Important - security of the API
In production all requests **must be sent over https** due to credentials being passed around. Please
see ENV variables `REQUIRE_SSL` which should be true in production, and `BEHIND_PROXY` if you for instance
are deploing on Heroku. You should also set `BASIC_AUTH_USER` and `BASIC_AUTH_PASSWORD` to restrict
access to your API.



## POST to `/store`
* Give key-value pairs of URLs to download, store on S3 and return URLs for.
* Available options
  * `awsAccessKeyId` AWS access key
  * `awsSecretAccessKey` AWS access secret
  * `s3Bucket` AWS bucket you want files uploaded to
  * `s3Region` AWS region you want files uploaded to
  * `cloudfrontHost` AWS cloud front, if any.
* Available HTTP headers
  * `Tag-Logs-With` A string you want this request to be tagged with.
    For instance `iweb prod asset-123` will log as `[iweb] [prod] [asset-123]`

```json
{
  "urls": {
    "thumb": "http://www.filepicker.com/api/XXX/convert/thumb",
    "monitor": "http://www.filepicker.com/api/XXX/convert/monitor"
  },
  "options": {
    "awsAccessKeyId": "xxx",
    "awsSecretAccessKey": "xxx",
    "s3Bucket": "xxx",
    "s3Region": "xxx",
    "cloudfrontHost": "xxx" # Optional
  }
}
```


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
      "downloadResponse": {
        "status": 502,
        "body": "Bad Gateway"
      }
    }
  }
}
```

### RESPONSE - failure from S3
* Status is `error`
* Keys with `null` was ok, but is cleaned from S3 due to other version failed.
* Keys with an object includes information about the s3 error.

```json
{
  "status": "error",
  "urls": {
    "thumb": null,
    "monitor": {
      "s3": "Some message or object(!) from s3 when we tried to upload this file"
    }
  }
}
```


### RESPONSE - failure timeout
* Status is `timeout` due to max keep alive time exceeded. See `lib/middleware/keep_alive.coffee`
  and `ENV` variables `KEEP_ALIVE_WAIT_SECONDS` and `KEEP_ALIVE_MAX_ITERATIONS`.
* Any uploads to S3 we have done will be cleaned.

```json
{
  "status": "timeout"
}
```

## DELETE to `/delete`
* The `/delete` action is more of a convenience action. I guess you applicaiton
  language have an AWS SDK available and you could potentially use that directly.
  If you feel like it's just as easy to make a DELETE call to the S3 Storage API
  feel free to do so.
* Give array of URLs to delete.
* Available options
  * `awsAccessKeyId` AWS access key
  * `awsSecretAccessKey` AWS access secret
  * `s3Bucket` AWS bucket you want files uploaded to
  * `s3Region` AWS region you want files uploaded to
* Available HTTP headers
  * `Tag-Logs-With` A string you want this request to be tagged with.
    For instance `iweb prod asset-123` will log as `[iweb] [prod] [asset-123]`

```json
{
  "urls": [
    "http://file.in.your.s3.bucket.com/object1",
    "http://file.in.your.s3.bucket.com/object2"
  ],
  "options": {
    "awsAccessKeyId": "xxx",
    "awsSecretAccessKey": "xxx",
    "s3Bucket": "xxx",
    "s3Region": "xxx",
  }
}
```

### RESPONSE - success
* Status is `ok`

```json
{
  "status": "ok"
}
```


### RESPONSE - failure
* Status is `error`

```json
{
  "status": "error",
  "description": "Some explantion of the error."
}
```

Errors isn't likely to happen, as we do not actually check if
bucket has given URLs / objects. We just make a deleteObjects call
to S3 and expect S3 to remove given object keys.


# Development

```bash
npm install
nodemon --exec coffee bin/www
```



### Tests
Tests are written using [Mocha](http://mochajs.org/) and
[Chai expect](http://chaijs.com/guide/styles/#expect) syntax style.
We use [Sinon](http://sinonjs.org/) for test utilities
and [SuperTest](https://github.com/visionmedia/supertest) for integration tests.

Run `grunt test` when you want to run tests.
You can also run `mocha path/to/test` if you want to run specific tests.

In our tests some ENV variables are important. They all start with `TEST_*`
and you find examples in `.envrc.example`. You need to create and configure your own bucket
for integration testing.



# Deployment
Is may deployed on Heroku. Do the normal `git push heroku master`, or deploy to other servers
you feel comfortable with.
