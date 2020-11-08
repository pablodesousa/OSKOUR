import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
import 'package:oskour/src/signup.dart';
import 'package:oskour/redux.dart' as connect;
import 'package:redux/redux.dart';
import 'package:oskour/src/Home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key, this.title, this.store}) : super(key: key);

  final String title;
  final Store<bool> store;
  @override
  _LoginPageState createState() => _LoginPageState();
}

final Policies policies = Policies(
  fetch: FetchPolicy.networkOnly,
);

ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: HttpLink(uri: 'https://flutter-spacex.herokuapp.com/v1/graphql'),
    cache: InMemoryCache(),
    defaultPolicies: DefaultPolicies(
      watchQuery: policies,
      query: policies,
      mutate: policies,
    ),
  ),
);

class _LoginPageState extends State<LoginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            const Text('Back',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String title, {bool isPassword = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              controller: password,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  hintText: 'Password',
                  filled: true))
        ],
      ),
    );
  }

  Widget _usernameField(String title, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              controller: username,

              decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  hintText: 'Username',
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Mutation(
        options: MutationOptions(
          documentNode: gql(getUserLogin),
          update: (Cache cache, QueryResult result) {
          },
          // or do something with the result.data on completion
          onCompleted: (dynamic resultData) {
            if (resultData['Login'] != null) {
              widget.store.dispatch(connect.Actions.Connected);
              Navigator.push(
                  context, MaterialPageRoute<void>(builder: (BuildContext context) => DisplayHome(token: resultData['Login']['token'] as String, store: widget.store)));
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult result) {

          return GestureDetector(
            onTap: () {
              runMutation(<String, dynamic> {'username': username.text, 'password': password.text});
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          );
        });
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute<void>(builder: (BuildContext context) => SignUpPage(store: widget.store,)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'OSKOUR',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.store.state);
    final double height = MediaQuery.of(context).size.height;
    return GraphQLProvider (
      child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              image: const DecorationImage(
                image: AssetImage('assets/img/Background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            height: height,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: height * .2),
                        _title(),
                        const SizedBox(height: 50),
                        _usernameField('username'),
                        const SizedBox(height: 50),
                        _passwordField('password'),
                        const SizedBox(height: 20),
                        _submitButton(),
                        SizedBox(height: height * .055),
                        _createAccountLabel(),
                      ],
                    ),
                  ),
                ),
                Positioned(top: 40, left: 0, child: _backButton()),
              ],
            ),
          )),
      client: client,
    );
  }
}
