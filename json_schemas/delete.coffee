module.exports =
  type: "object"
  required: ['urls', 'options']
  properties:
    urls:
      type: "array"
      minItems: 1
      items:
        type: 'string'
        format: 'url'
    options:
      $ref: 'options'
