tv4 = require 'tv4'
formats = require 'tv4-formats'
_ = require 'lodash'

tv4.addFormat formats

tv4.addSchema 'options',  require '../json_schemas/options'
tv4.addSchema 'store',    require '../json_schemas/store'
tv4.addSchema 'delete',   require '../json_schemas/delete'


prepareForResponse = (validation) ->
  errors = {}

  for error in validation.errors
    key = error.dataPath
    key = '/' if key is ''

    errors[key] ?= []
    errors[key].push error.message

  errors


# Public: Validates json against schema.
#
# json    - JSON data we want to validate
# schema  - schema, or schema name, we want to validate against.
#
# returns null for no errors, or an error object
#
#         Error object has keys mapping to json path of the error
#         and value is an array with error messages
validate = (json, schema) ->
  result = tv4.validateMultiple json, schema, false, true

  if _.isEmpty result.errors
    null
  else
    prepareForResponse result


exports.prepareForResponse = prepareForResponse
exports.validate = validate
