# Rabbit Connect Flutter Example

An Example for Flutter Application to demonstrate how to implement Rabbit Connect.
We recommend using AppAuth instead of implementing it by yourself. 
Because it easy to implement no need to customize with the wrong way.

A few resources to get you started if this is your first Flutter project:
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

Let explore more about AppAuth
- [AppAuth IOS](https://github.com/openid/AppAuth-iOS)
- [AppAuth Android](https://github.com/openid/AppAuth-Android)
- [AppAuth JS](https://github.com/openid/AppAuth-JS)
- [AppAuth Flutter](https://pub.dev/packages/flutter_appauth)

## Getting Started

Prepare Your credentails and update code with your credentails

```
const String RABBIT_OAUTH_DOMAIN = 'RABBIT_OAUTH_DOMAIN';
const String RABBIT_OAUTH_CLIENT_ID = 'CLIENT_ID';
const String RABBIT_OAUTH_REDIRECT_URI = 'REDIRECT_URI';
const String RABBIT_OAUTH_ISSUER = 'OAUTH_ISSUER';
```

```
final AuthorizationServiceConfiguration _serviceConfiguration =
    const AuthorizationServiceConfiguration(
        'AUHORIZATION_ENDPOINT', 'GET_TOKEN_ENDPOINT');
```

Extra for android Go to ../android/app/build.gradle

```
defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "com.example.mooner"
        minSdkVersion localProperties.getProperty('flutter.minSdkVersion').toInteger()
        targetSdkVersion localProperties.getProperty('flutter.targetSdkVersion').toInteger()
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        manifestPlaceholders += [
                'appAuthRedirectScheme': '<YOUR_REDIRECT_URI_SCHEME>'
        ]
    }
```

Then biuld and run to see the result

## Need help?
We allow you to request an issue or email to our [team](mailto:digital@rabbit.co.th)