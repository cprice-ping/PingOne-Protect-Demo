const oidcConfig = {
    "issuer": "https://auth.pingone.com/c85fe8e8-a62a-4acd-a4fa-8742ca4159e5/as",
    "client_id": "f53cbbc9-4273-4944-9178-d1de58324b64"
}

const clientOptions = {
    clientId: oidcConfig.client_id,
    redirectUri: 'http://localhost:3000/callback.html', 
    grantType: 'authorization_code', 
    // usePkce: false,
    // clientSecret: 'xxx',
    // clientSecretAuthMethod: 'basic',
    scope: 'openid profile email',
    // state: 'xyz', 
    // logLevel: 'debug',
    tokenAvailableCallback: token => {
      console.log(token);
    },
  };

async function invokeDVFlow() {
    oidcClient = await pingDevLib.default.fromIssuer(oidcConfig.issuer, clientOptions)

    // To authorize a user (note: this will use window.location.assign, thus redirecting the user):
    oidcClient.authorize(/* optional login_hint */);
  
    // To get the authorization url (if you wish to override the authorize() behavior and apply it to an anchor tag, for example)
    //   const authnUrl = await oidcClient.authorizeUrl(/* optional login_hint */);
  
  // After a user has been authorized and a token is available there is a built in user info call
  //const userInfo = await oidcClient.fetchUserInfo();
  //console.log(userInfo)
}  