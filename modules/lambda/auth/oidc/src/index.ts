import { SecretsManager } from '@aws-sdk/client-secrets-manager'
import serverlessExpress from '@codegenie/serverless-express'
import {
  CloudFrontRequestHandler,
  CloudFrontRequestEvent,
  CloudFrontRequestResult,
  Context,
  Callback,
} from 'aws-lambda'

import app from './middleware'
import AuthConfigSecretId from './secret.json'

const secretsManager = new SecretsManager()

const configSecret = secretsManager.getSecretValue({
  SecretId: AuthConfigSecretId,
})

const handler: CloudFrontRequestHandler = async (
  event: CloudFrontRequestEvent,
  context: Context,
  callback: Callback
): Promise<CloudFrontRequestResult> => {
  const passThru = event?.Records?.[0]?.cf?.request
  const auth0Config = JSON.parse((await configSecret).SecretString || '')

  const handler = serverlessExpress({ app: app(auth0Config) })
  const response = await handler(event, context, callback)

  if (response?.status == 203) {
    return passThru
  } else {
    return response
  }
}

module.exports = {
  handler,
}
