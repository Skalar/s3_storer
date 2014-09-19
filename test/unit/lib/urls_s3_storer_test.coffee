UrlsS3Storer = require '../../../lib/urls_s3_storer'

storer = null

urls =
  thumb: 'http://original.example.com/thumb-img.jpg'
  monitor: 'http://original.example.com/monitor-img.jpg'

options =
  awsAccessKeyId: process.env.TEST_AWS_ACCESS_KEY_ID
  awsSecretAccessKey: process.env.TEST_AWS_SECRET_ACCESS_KEY
  s3Bucket: process.env.TEST_S3_BUCKET
  s3Region: process.env.TEST_S3_REGION


describe "UrlsS3Storer", ->
  beforeEach ->
    storer = new UrlsS3Storer urls, options


  describe "success", ->
    # it "returns the cached url"

    it "returns the cached url with CloudFront when configured", ->
      storer.options.cloudfrontHost = process.env.TEST_CLOUDFRONT_HOST

      expect(storer.store()).to.eventually.have.deep.eq
        urls:
          thumb: 'foo'


  # describe "failures"
