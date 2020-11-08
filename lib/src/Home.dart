import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/src/displayPage.dart';
import 'package:oskour/src/displayTrip.dart';
import 'package:oskour/src/camera.dart';
import 'package:oskour/redux.dart' as connect;
import 'package:oskour/src/loginPage.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class DisplayHome extends StatefulWidget {
  const DisplayHome({Key key, this.title, this.token, this.store}) : super(key: key);

  final String title;
  final String token;
  final Store<bool> store;

  @override

  _DisplayHomeState createState() => _DisplayHomeState();
}

final Policies policies = Policies(
  fetch: FetchPolicy.networkOnly,
);

class _DisplayHomeState extends State<DisplayHome> {
  int _currentIndex = 0;
  void onTabTapped(int index) {
    if(index == 3)
      {
        widget.store.dispatch(connect.Actions.Connected);
        Navigator.push(
            context, MaterialPageRoute<void>(builder: (BuildContext context) => LoginPage(store: widget.store)));
        return;
      }
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: HttpLink(uri: 'https://flutter-spacex.herokuapp.com/v1/graphql', headers: <String, String> {
          'Authorization': 'Bearer ' + widget.token,
        }),
        cache: InMemoryCache(),
        defaultPolicies: DefaultPolicies(
          watchQuery: policies,
          query: policies,
          mutate: policies,
        ),
      ),
    );
    final List<Widget> _children = <Widget>[
      DisplayPage(token: widget.token),
      DisplayTrip(token: widget.token),
      CameraPage(token: widget.token),
    ];
    return StoreProvider<bool>(
      child: GraphQLProvider(
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(.60),
            selectedFontSize: 14,
            unselectedFontSize: 14,
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: const <BottomNavigationBarItem> [
              BottomNavigationBarItem(
                title: Text('Home',
                    style: TextStyle(
                      color: Colors.black,
                    )),
                icon: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
              ),
              BottomNavigationBarItem(
                title: Text('Your trip',
                    style: TextStyle(
                      color: Colors.black,
                    )),
                icon: Icon(
                  Icons.airplanemode_active,
                  color: Colors.black,
                ),
              ),
              BottomNavigationBarItem(
                title: Text('Profile',
                    style: TextStyle(
                      color: Colors.black,
                    )),
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
              BottomNavigationBarItem(
                title: Text('Signout',
                    style: TextStyle(
                      color: Colors.black,
                    )),
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                ),
              )
            ],
          ),
          body: _children[_currentIndex],
        ),
        client: client,
      ),
      store: widget.store,
    );
  }
}
