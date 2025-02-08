import express from 'express'
import { ConfigParams, auth } from 'express-openid-connect'
import { getCurrentInvoke } from '@codegenie/serverless-express'
import { CloudFrontRequestEvent } from 'aws-lambda'

export default (config: ConfigParams) => {
  console.log(JSON.stringify(config, null, 2))
  const app = express()

  // auth router attaches /login, /logout, and /callback routes to the baseURL
  app.use(auth(config))

  // req.isAuthenticated is provided from the auth router
  app.all(/.+/, (req, res) => {
    console.log(JSON.stringify(req, null, 2))
    if (req.oidc.isAuthenticated()) {
      console.log('authenticated: passthru')
      // authenticated: passthru
      const invoke = getCurrentInvoke()
      const event = invoke.event as CloudFrontRequestEvent
      if (event?.Records?.[0]) {
        delete event.Records[0]?.cf?.request?.headers?.['cookie']
        delete event.Records[0]?.cf?.request?.headers?.['Cookie']
        event.Records[0].cf.request.headers['Authorization'] = [
          {
            key: 'Authorization',
            value: `${req?.oidc?.accessToken?.token_type} ${req?.oidc?.accessToken?.access_token}`,
          },
        ]
      }
      return res.sendStatus(203)
    }
    return res.sendStatus(500)
  })

  return app
}
