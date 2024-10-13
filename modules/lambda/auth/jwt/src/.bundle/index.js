"use strict";

// index.ts
var handler = async (event) => {
  console.log(event);
  return Promise.resolve(generateAllow("user", event.methodArn));
};
var generatePolicy = (effect) => (principalId, resource) => {
  const statement = effect && resource ? [
    {
      Action: "execute-api:Invoke",
      Effect: effect,
      Resource: resource
    }
  ] : [];
  const policyDocument = {
    Version: "2012-10-17",
    Statement: statement
  };
  var authResponse = {
    principalId,
    policyDocument
  };
  return authResponse;
};
var generateAllow = generatePolicy("Allow");
module.exports = {
  handler
};
