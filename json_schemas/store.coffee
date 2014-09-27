module.exports =
  type: "object"
  required: ['urls', 'options']
  properties:
    urls:
      type: "object"
      patternProperties:
        '^.+$':
          type: 'string'
          format: 'uri'
    options:
      $ref: 'options'
