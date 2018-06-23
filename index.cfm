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

<CFSET userInfo = auth0.getUser()>

<CFOUTPUT>
<html>
    <head>
        <script src="http://code.jquery.com/jquery-3.1.0.min.js" type="text/javascript"></script>

        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- font awesome from BootstrapCDN -->
        <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet">
        <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet">

        <link href="public/app.css" rel="stylesheet">

    </head>
    <body class="home">
        <div class="container">
            <div class="login-page clearfix">
              <CFIF !isDefined("userInfo") || structIsEmpty(userInfo)>
              <div class="login-box auth0-box before">
                <img src="https://i.cloudup.com/StzWWrY34s.png" />
                <h3>Auth0 Example</h3>
                <p>Zero friction identity infrastructure, built for developers</p>
                <a class="btn btn-primary btn-lg btn-login btn-block" href="login.cfm">Sign In</a>
              </div>
              <CFELSE>
              <div class="logged-in-box auth0-box logged-in">
                <h1 id="logo"><img src="//cdn.auth0.com/samples/auth0_logo_final_blue_RGB.png" /></h1>
                <img class="avatar" src="#userInfo['picture']#"/>
                <h2>Welcome <span class="nickname">#userInfo['nickname']#</span></h2>
                <a class="btn btn-warning btn-logout" href="logout.cfm">Logout</a>
              </div>
              </CFIF>
            </div>
        </div>
    </body>
</html>
</CFOUTPUT>
