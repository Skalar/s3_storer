module.exports =
  type: "object"
  required: ['urls', 'options']
  properties:
    urls:
      type: "object"
      patternProperties:
        '^.+$':
          type: 'string'
          format: 'url'
    options:
      $ref: 'options'
