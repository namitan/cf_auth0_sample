<CFCOMPONENT>

<!--- コンストラクタ --->
<CFFUNCTION name="init" returntype="any">
    <CFARGUMENT name="prop" required="yes" type="struct">
    <CFSET Variables.domain        = isDefined("prop.domain")? prop.domain : "">
    <CFSET Variables.client_id     = isDefined("prop.client_id")? prop.client_id : "">
    <CFSET Variables.client_secret = isDefined("prop.client_secret")? prop.client_secret : "">
    <CFSET Variables.redirect_uri  = isDefined("prop.redirect_uri")? prop.redirect_uri : "">
    <CFSET Variables.audience      = isDefined("prop.audience")? prop.audience : "">
    <CFSET Variables.scope         = isDefined("prop.scope")? prop.scope : "">
    <CFSET Variables.state         = isDefined("prop.state")? prop.state : "">
    <CFSET Variables.persist_id_token      = isDefined("prop.persist_id_token")? prop.persist_id_token : false>
    <CFSET Variables.persist_access_token  = isDefined("prop.persist_access_token")? prop.persist_access_token : false>
    <CFSET Variables.persist_refresh_token = isDefined("prop.persist_refresh_token")? prop.persist_refresh_token : false>
    <CFRETURN this>
</CFFUNCTION>

<!--- login --->
<CFFUNCTION name="login" returntype="void">
    <CFSET api("authorize", "GET_REDIRECT", {
        "audience"      : Variables.audience,
        "scope"         : Variables.scope,
        "response_type" : "code",
        "client_id"     : Variables.client_id,
        "redirect_uri"  : Variables.redirect_uri,
        "state"         : Variables.state
    })>
</CFFUNCTION>

<!--- logout --->
<CFFUNCTION name="logout" returntype="void">
    <CFLOCK scope="Session" type="exclusive" timeout="10">
        <CFIF structKeyExists(Session, "auth0")>
            <CFSET structDelete(Session, "auth0")>
        </CFIF>
    </CFLOCK>
    <CFSET api("v2/logout", "GET_REDIRECT", {
        "client_id" : Variables.client_id,
        "returnTo"  : Variables.redirect_uri
    })>
</CFFUNCTION>

<!--- get user --->
<CFFUNCTION name="getUser" returntype="struct">
    <CFSET return_value = structNew()>
    <CFLOCK scope="Session" type="exclusive" timeout="10">
        <!--- セッションにユーザー情報があればそこから返す --->
        <CFIF isDefined("Session.auth0") && structKeyExists(Session.auth0, "userInfo") && !structIsEmpty(Session.auth0.userInfo)>
            <CFSET return_value = structCopy(Session.auth0.userInfo)>
        <CFELSEIF isDefined("url.code")>
            <CFSET Session.auth0 = structNew()>
            <!--- アクセストークンを取得する --->
            <CFSET stTemp = api("oauth/token", "POST", {
                "grant_type"    : "authorization_code",
                "client_id"     : Variables.client_id,
                "client_secret" : Variables.client_secret,
                "code"          : url.code,
                "redirect_uri"  : Variables.redirect_uri
            })>
            <!--- アクセストークンをセッションに格納する --->
            <CFIF Variables.persist_id_token && isDefined("stTemp.id_token")>
                <CFSET Session.auth0["id_token"] = stTemp.id_token>
            </CFIF>
            <CFIF Variables.persist_access_token && isDefined("stTemp.access_token")>
                <CFSET Session.auth0["access_token"] = stTemp.access_token>
            </CFIF>
            <CFIF Variables.persist_refresh_token && isDefined("stTemp.refresh_token")>
                <CFSET Session.auth0["refresh_token"] = stTemp.refresh_token>
            </CFIF>
            <!--- ユーザー情報を取得する --->
            <CFSET return_value = api("userinfo", "GET", {
                "access_token" : stTemp.access_token
            })>
            <!--- ユーザー情報をセッションに格納する --->
            <CFSET Session.auth0.userInfo = structNew()>
            <CFLOOP array="#structKeyArray(return_value)#" index="key">
                <CFSET Session.auth0.userInfo[key] = return_value[key]>
            </CFLOOP>
        </CFIF>
    </CFLOCK>
    <CFRETURN return_value>
</CFFUNCTION>

<!--- Auth0 APIリクエスト --->
<CFFUNCTION name="api" returntype="struct">
    <CFARGUMENT name="endPoint" required="yes" type="string">
    <CFARGUMENT name="method" required="yes" type="string">
    <CFARGUMENT name="parameters" required="yes" type="struct">

    <CFIF method eq "POST">
        <!--- JSON生成 --->
        <CFSET aTemp = arrayNew(1)>
        <CFLOOP array="#structKeyArray(parameters)#" index="key">
            <CFSET arrayAppend(aTemp, '"#key#":"#parameters[key]#"')>
        </CFLOOP>
        <CFSET jsontext = '{#arrayToList(aTemp)#}'>
        <!--- httpリクエスト --->
        <CFHTTP url="https://#Application.AUTH0_DOMAIN#/#endPoint#" method="POST" result="result" timeout="60">
            <CFHTTPPARAM type="header" name="Content-Type" value="application/json" />
            <CFHTTPPARAM type="body" value="#jsontext#" />
        </CFHTTP>
    <CFELSE>
        <!--- パラメタ生成 --->
        <CFSET aTemp = arrayNew(1)>
        <CFLOOP array="#structKeyArray(parameters)#" index="key">
            <CFSET arrayAppend(aTemp, '#key#=#parameters[key]#')>
        </CFLOOP>
        <CFIF findNoCase("REDIRECT", method)>
            <!--- リダイレクト --->
            <CFLOCATION url="https://#Application.AUTH0_DOMAIN#/#endPoint#?#arrayToList(aTemp,"&")#" addtoken="false">
        <CFELSE>
            <!--- httpリクエスト --->
            <CFHTTP url="https://#Application.AUTH0_DOMAIN#/#endPoint#?#arrayToList(aTemp,"&")#" method="GET" result="result" timeout="60" />
        </CFIF>
    </CFIF>

    <CFRETURN deserializeJSON(result.FileContent)>
</CFFUNCTION>

</CFCOMPONENT>
