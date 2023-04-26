(function () {
    document.addEventListener('DOMContentLoaded', async () => {

        const oidcConfig = await fetch("/getRuntimeDetails").then(res => res.json())
        const oidcIssuer = "https://auth.pingone.com/"+oidcConfig.envId+"/as"

        console.log(oidcConfig)
        console.log(oidcIssuer)

        let client;
        let redirectUri = window.location.origin + "/dashboard.html"

        const clientOptions = {
            clientId: oidcConfig.clientId,
            redirectUri: redirectUri,
            scope: 'openid profile',
            tokenAvailableCallback: async (token, state) => {
                console.log("Token: ", token)
                // Don't wanna be on home page if we have a token
                if (!window.location.pathname.includes('/dashboard.html')) {
                    window.location.assign(redirectUri)
                }

                // const userInfo = await client?.fetchUserInfo();
            }
        };

        // Trigger OIDC Request
        client = await pingDevLib.default.fromIssuer(oidcIssuer, clientOptions);

        document.getElementById('loginButton')?.addEventListener('click', async () => {
            await client?.authorize();
        });
    });
})();