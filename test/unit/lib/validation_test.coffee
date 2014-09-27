require('../../spec_helper')()

validation = require '../../../lib/validation'
prepareForResponse = validation.prepareForResponse

describe "#prepareForResponse", ->
  validation =
    errors:
      [
        {
          message: 'Missing required property: urls',
          code: 302,
          dataPath: '',
          schemaPath: '/required/0',
          subErrors: null
        }
        {

          message: 'Format validation failed (URI expected)',
          code: 500,
          dataPath: '/urls/1',
          schemaPath: '/properties/urls/items/format',
          subErrors: null,
        }
        {

          message: 'Other error on urls/1',
          code: 500,
          dataPath: '/urls/1',
          schemaPath: '/properties/urls/items/format',
          subErrors: null,
        }
      ]

  it "transform errors were dataPath is '' to '/' and include expected error", ->
    transformed = prepareForResponse validation
    expect(transformed['/']).to.include 'Missing required property: urls'

  it "transform errors and groups data paths together", ->
    transformed = prepareForResponse validation
    expect(transformed['/urls/1']).to.deep.eq [
      'Format validation failed (URI expected)',
      'Other error on urls/1'
    ]
