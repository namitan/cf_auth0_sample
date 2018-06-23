<CFSET domain        = Application.AUTH0_DOMAIN>
<CFSET client_id     = Application.AUTH0_CLIENT_ID>
<CFSET client_secret = Application.AUTH0_CLIENT_SECRET>
<CFSET redirect_uri  = Application.AUTH0_CALLBACK_URL>
<CFSET audience      = Application.AUTH0_AUDIENCE>

<CFIF audience eq "">
  <CFSET audience = "https://#domain#/userinfo">
</CFIF>

<CFSET auth0 = createObject("component", "Auth0").init({
  'domain' : domain,
  'client_id' : client_id,
  'client_secret' : client_secret,
  'redirect_uri' : redirect_uri,
  'audience' : audience,
  'scope' : 'openid profile',
  'persist_id_token' : true,
  'persist_access_token' : true,
  'persist_refresh_token' : true
})>

<CFSET auth0.login()>
