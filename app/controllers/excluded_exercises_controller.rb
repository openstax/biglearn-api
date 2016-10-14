class ExcludedExercisesController < JsonApiController

  def _exclusion_definitions
    {
      'exclusion': {
        'oneOf': [
          {'$ref': '#/definitions/specific_version_exclusion'},
          {'$ref': '#/definitions/any_version_exclusion'},
        ],
      },
      'specific_version_exclusion': {
        'type': 'object',
        'properties': {
          'exercise_uuid': {'$ref': '#/standard_definitions/uuid'},
        },
        'required': ['exercise_uuid'],
        'additionalProperties': false,
      },
      'any_version_exclusion': {
        'type': 'object',
        'properties': {
          'exercise_group_uuid': {'$ref': '#/standard_definitions/uuid'},
        },
        'required': ['exercise_group_uuid'],
        'additionalProperties': false,
      },
    }
  end

end