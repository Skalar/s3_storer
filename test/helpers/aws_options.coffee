module.exports = ->
  {
    awsAccessKeyId: process.env.TEST_AWS_ACCESS_KEY_ID
    awsSecretAccessKey: process.env.TEST_AWS_SECRET_ACCESS_KEY
    s3Bucket: process.env.TEST_S3_BUCKET
    s3Region: process.env.TEST_S3_REGION
  }
