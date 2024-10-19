import {
  APIGatewayAuthorizerResult,
  APIGatewayEventRequestContextWithAuthorizer,
  APIGatewayRequestAuthorizerEvent,
} from 'aws-lambda'

import jwt, { SigningKeyCallback } from 'jsonwebtoken'
import jwksClient from 'jwks-rsa'

import fs from 'node:fs'

const scopesMapFile = fs.readFileSync('./scopes.json').toString('utf8')

type ExtendedContext =
  APIGatewayEventRequestContextWithAuthorizer<undefined> & {
    operationName: string
  }

type ExtendedAuthorizerEvent = APIGatewayRequestAuthorizerEvent & {
  requestContext: ExtendedContext
}

type ScopesMap = Record<string, Array<string>>

const handler = async (
  event: ExtendedAuthorizerEvent
): Promise<APIGatewayAuthorizerResult> => {
  console.log(event)
  console.log(scopesMapFile)

  try {
    JSON.parse(scopesMapFile)
  } catch (error) {
    console.error(
      'Scopes map file was not valid, denying access for safety.',
      error
    )
    return Promise.resolve(generateDeny('user', event.methodArn))
  }

  // todo: actual parsing
  const scopesMap = JSON.parse(scopesMapFile) as ScopesMap

  const operation = event.requestContext.operationName
  if (!Object.keys(scopesMap).includes(operation)) {
    console.error(
      `The operation '${operation}' is not included in the scopes map file, assuming permission denied.`
    )
    return Promise.resolve(generateDeny('user', event.methodArn))
  }

  const requiredScopes = scopesMap[operation]!

  const authorizationHeader = event.headers?.['Authorization']
  if (!authorizationHeader) {
    console.error('Authorization header is missing, denying access.')
    return Promise.resolve(generateDeny('user', event.methodArn))
  }
  if (!authorizationHeader.startsWith('Bearer ')) {
    console.error(
      'Authorization header is not a valid bearer token, denying access.'
    )
    return Promise.resolve(generateDeny('user', event.methodArn))
  }
  const token = authorizationHeader.split(' ')[1]!

  // todo: put this in settings file
  const settings = {
    jwksUri: 'https://dev-bonemill.uk.auth0.com/.well-known/jwks.json',
  }

  try {
    const client = jwksClient({
      jwksUri: settings.jwksUri,
    })
    function getKey(header: jwt.JwtHeader, callback: SigningKeyCallback) {
      client.getSigningKey(header.kid, (_error, key) => {
        const signingKey = key?.getPublicKey()
        callback(null, signingKey)
      })
    }

    type Auth0AccessToken = jwt.JwtPayload & {
      scope?: string
    }

    const isAuth0Jwt = (
      thing: string | jwt.JwtPayload
    ): thing is Auth0AccessToken => typeof thing != 'string'

    // todo: check claims
    const options = {}
    const decoded = new Promise<Auth0AccessToken>((resolve, reject) => {
      jwt.verify(token, getKey, options, (error, decoded) => {
        if (error) {
          reject(error)
        } else if (decoded && isAuth0Jwt(decoded)) {
          resolve(decoded)
        }
      })
    })

    // verify scopes
    const result = await decoded
    console.log({ result })
    if (result.scope) {
      const assignedScopes = result.scope.split(' ')
      console.log({ assignedScopes, requiredScopes })
      const everyRequiredScopeIsIncludedInAssignedScopes = requiredScopes.every(
        (scope) => assignedScopes.includes(scope)
      )
      if (!everyRequiredScopeIsIncludedInAssignedScopes) {
        console.error('Required scopes are missing, denying access.')
        return Promise.resolve(generateDeny('user', event.methodArn))
      }
    } else {
      console.error('Scope claim on token is missing, denying access.')
      return Promise.resolve(generateDeny('user', event.methodArn))
    }
  } catch (error) {
    console.error('Failed to verify access token, denying access', error)
    return Promise.resolve(generateDeny('user', event.methodArn))
  }

  // finally, we have access...
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
var generateDeny = generatePolicy('Deny')

module.exports = {
  handler,
}
