<CFCOMPONENT>

<CFSETTING showdebugoutput="true" enablecfoutputonly="true" requesttimeout="60">
<CFSET This.sessionManagement = true>
<CFSET This.name = "Auth0 sample">

<CFFUNCTION name="onApplicationStart">
    <CFSET Application.AUTH0_CLIENT_ID     = "your client id">
    <CFSET Application.AUTH0_DOMAIN        = "yourdomain.auth0.com">
    <CFSET Application.AUTH0_CLIENT_SECRET = "your client secret">
    <CFSET Application.AUTH0_CALLBACK_URL  = "http://127.0.0.1:8500/">
    <CFSET Application.AUTH0_AUDIENCE      = "">
</CFFUNCTION>

</CFCOMPONENT>
