(function () {
    document.addEventListener('DOMContentLoaded', async () => {

        const oidcConfig = await fetch("/getRuntimeDetails").then(res => res.json())
        const oidcIssuer = "https://auth.pingone.com/"+oidcConfig.envId+"/as"

        let client;
        let redirectUri = window.location.origin + "/dashboard.html"

        const clientOptions = {
            clientId: oidcConfig.clientId,
            redirectUri: redirectUri,
            scope: 'openid profile',
            tokenAvailableCallback: async (token, state) => {

                const userInfo = await client?.fetchUserInfo();

                document.getElementById('name').innerHTML = `${userInfo?.given_name} ${userInfo?.family_name}`;
                document.getElementById('email').innerHTML = userInfo?.preferred_username;

                const accessTokenPayload = JSON.parse(atob(token?.access_token.split(".")[1]))
                document.getElementById('access-token').innerHTML = "<pre>"+JSON.stringify(accessTokenPayload, null, 2)+"</pre>";

                const idTokenPayload = JSON.parse(atob(token?.id_token.split(".")[1]))
                document.getElementById('id-token').innerHTML = "<pre>"+JSON.stringify(idTokenPayload, null, 2)+"</pre>";

                document.getElementById('user-info').innerHTML = "<pre>"+JSON.stringify(userInfo, null, 2)+"</pre>";
            }
        };

        client = await pingDevLib.default.fromIssuer(oidcIssuer, clientOptions);

        if (window.location.pathname.includes('dashboard.html')) {
            // Don't want to allow an unauthenticated user access to dashboard
            setTimeout(async () => {
                try {
                    await client?.getToken();
                } catch (error) {
                    window.location.assign(redirectUri.replace('/dashboard.html', '/oidc.html'));
                }
            }, 1000); // This is 🤮, ticket to make this better is in PT
        }

        document.getElementById('logout')?.addEventListener('click', async () => {
            try {
                // await client?.revokeToken();
                // window.location.assign(redirectUri.replace('/dashboard.html', ''));
                localStorage.removeItem("oidc-client:response")
                window.location.assign(oidcIssuer+"/signoff?post_logout_redirect_uri="+window.location.origin)
            } catch (error) {
                console.error(error)
            };
        });
    });
})();