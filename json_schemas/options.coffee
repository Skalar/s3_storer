module.exports =
  type: "object"
  required: ['awsAccessKeyId', 'awsSecretAccessKey', 's3Bucket', 's3Region']
  properties:
    awsAccessKeyId:
      type: 'string'
    awsSecretAccessKey:
      type: 'string'
    s3Bucket:
      type: 'string'
    s3Region:
      type: 'string'
    cloudfrontHost:
      type: 'string'
      format: 'url'
    makePublic:
      type: ['boolean', 'null']
