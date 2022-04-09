import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hexcolor/hexcolor.dart';
import 'package:simple_gravatar/simple_gravatar.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const String RABBIT_OAUTH_DOMAIN = 'uat-api-sso.rabbit.co.th';
const String RABBIT_OAUTH_CLIENT_ID = 'mooner-flutter-app';
const String RABBIT_OAUTH_REDIRECT_URI = 'com.mooner.app://oauth2redirect';
const String RABBIT_OAUTH_ISSUER = 'https://$RABBIT_OAUTH_DOMAIN';

final List<String> _scopes = <String>[
  'offline',
  'offline_access',
  'openid',
  'phone',
  'email',
  'profile',
];

final AuthorizationServiceConfiguration _serviceConfiguration =
    const AuthorizationServiceConfiguration(
        '$RABBIT_OAUTH_ISSUER/sso-oauth/oauth2/auth',
        '$RABBIT_OAUTH_ISSUER/sso-oauth/oauth2/token');

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
  // String? _codeVerifier;
  // String? _authorizationCode;
  // String? _refreshToken;
  String? _accessToken;
  String errorMessage = '';
  String email = '';
  String phone = '';
  String picture = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:
            AppBar(title: Text('Mooner'), backgroundColor: HexColor("#ff821d")),
        body: Center(
          child: isBusy
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Profile(logoutAction, email, phone, picture)
                  : Login(loginAction, errorMessage),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    const String url = 'https://$RABBIT_OAUTH_DOMAIN/sso-oauth/userinfo';
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      log(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> loginAction({bool preferEphemeralSession = false}) async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          RABBIT_OAUTH_CLIENT_ID,
          RABBIT_OAUTH_REDIRECT_URI,
          serviceConfiguration: _serviceConfiguration,
          scopes: _scopes,
          preferEphemeralSession: preferEphemeralSession,
        ),
      );

      if (result != null) {
        _processAuthTokenResponse(result);
        final Map<String, dynamic> profile =
            await getUserDetails(_accessToken!);
        debugPrint('response: $profile');
        await secureStorage.write(
            key: 'refresh_token', value: result.refreshToken);

        var userPicture = profile['picture'];
        if (profile['picture'] == null) {
          var gravatar = Gravatar(profile['email']);
          userPicture = gravatar.imageUrl(
            size: 100,
            defaultImage: GravatarImage.retro,
            rating: GravatarRating.pg,
            fileExtension: true,
          );
        }

        setState(() {
          isBusy = false;
          isLoggedIn = true;
          email = profile['email'];
          phone = profile['phone_number'];
          picture = userPicture;
        });
      }
    } on Exception catch (e, s) {
      debugPrint(
          'login error XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX : $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = response.accessToken!;
    });
  }

  // Future<void> initAction() async {
  //   var secureStorage2 = secureStorage;
  //   final String? storedRefreshToken =
  //       await secureStorage2.read(key: 'refresh_token');
  //   if (storedRefreshToken == null) return;

  //   setState(() {
  //     isBusy = true;
  //   });

  //   try {
  //     final TokenResponse? response = await appAuth.token(TokenRequest(
  //         RABBIT_OAUTH_CLIENT_ID, RABBIT_OAUTH_REDIRECT_URI,
  //         authorizationCode: storedRefreshToken, scopes: _scopes));

  //     final Map<String, Object> profile =
  //         await getUserDetails(response.accessToken);

  //     await secureStorage.write(
  //         key: 'refresh_token', value: response.refreshToken);
  //     var gravatar = Gravatar(profile['email']);
  //     var url = gravatar.imageUrl(
  //       size: 100,
  //       defaultImage: GravatarImage.retro,
  //       rating: GravatarRating.pg,
  //       fileExtension: true,
  //     );
  //     setState(() {
  //       isBusy = false;
  //       isLoggedIn = true;
  //       name = profile['given_name'];
  //       picture = url;
  //     });
  //   } on Exception catch (e, s) {
  //     debugPrint('error on refresh token: $e - stack: $s');
  //     await logoutAction();
  //   }
  // }

  Future<void> logoutAction() async {
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }
}

class Login extends StatelessWidget {
  final Future<void> Function() loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
            onPressed: () async {
              await loginAction();
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(300, 50),
              primary: HexColor("#ff821d"),
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('CONNECT WITH RABBIT')),
        Text(loginError),
      ],
    );
  }
}

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String email;
  final String phone;
  final String picture;

  const Profile(this.logoutAction, this.email, this.phone, this.picture,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 4),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(picture),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Email: $email'),
        Text('Phone: $phone'),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () async {
            await logoutAction();
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(240, 60),
            primary: HexColor("#ff821d"),
            textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
