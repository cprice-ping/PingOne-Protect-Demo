(function () {
    document.addEventListener('DOMContentLoaded', async () => {

        const oidcConfig = await fetch("/getRuntimeDetails").then(res => res.json())
        const oidcIssuer = "https://auth.pingone.com/"+oidcConfig.envId+"/as"

        console.log("Runtime: ", oidcConfig)
        console.log("OIDC Issuer: ", oidcIssuer)

        let client;
        let redirectUri = window.location.origin + "/dashboard.html"

        const clientOptions = {
            clientId: oidcConfig.clientId,
            redirectUri: redirectUri,
            scope: 'openid email profile',
            tokenAvailableCallback: async (token, state) => {
                
                // Don't wanna be on home page if we have a token
                if (!window.location.pathname.includes('/dashboard.html')) {
                    window.location.assign(redirectUri)
                }
            }
        };

        // Trigger OIDC Request
        client = await pingDevLib.default.fromIssuer(oidcIssuer, clientOptions);

        document.getElementById('loginButton')?.addEventListener('click', async () => {
            await client?.authorize();
        });
    });
})();