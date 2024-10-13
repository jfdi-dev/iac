import {
  APIGatewayAuthorizerEvent,
  APIGatewayAuthorizerHandler,
  APIGatewayAuthorizerResult,
} from 'aws-lambda'

const handler: APIGatewayAuthorizerHandler = async (
  event: APIGatewayAuthorizerEvent
): Promise<APIGatewayAuthorizerResult> => {
  console.log(event)

  return Promise.resolve(generateAllow('user', event.methodArn))
}

// Help function to generate an IAM policy
var generatePolicy =
  (effect: 'Allow' | 'Deny') =>
  (principalId: string, resource: string): APIGatewayAuthorizerResult => {
    const statement =
      effect && resource
        ? [
            {
              Action: 'execute-api:Invoke',
              Effect: effect,
              Resource: resource,
            },
          ]
        : []
    const policyDocument = {
      Version: '2012-10-17',
      Statement: statement,
    }

    // Optional output with custom properties of the String, Number or Boolean type.
    // authResponse.context = {
    //   stringKey: 'stringval',
    //   numberKey: 123,
    //   booleanKey: true,
    // }
    var authResponse = {
      principalId,
      policyDocument,
    }

    return authResponse
  }

var generateAllow = generatePolicy('Allow')
//var generateDeny = generatePolicy('Deny')

module.exports = {
  handler,
}
