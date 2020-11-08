import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
import 'package:oskour/src/missionPage.dart';
import 'package:oskour/src/displayTrip.dart';
import 'package:oskour/src/camera.dart';
import 'package:oskour/src/Factory.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({Key key, this.title, this.token}) : super(key: key);

  final String title;
  final String token;

  @override

  _DisplayPageState createState() => _DisplayPageState();
}

final Policies policies = Policies(
  fetch: FetchPolicy.networkOnly,
);

class _DisplayPageState extends State<DisplayPage> {

  Widget _displayPlane() {
    return Query(
        options: QueryOptions(
          documentNode: gql(getPlane),
          // this is the query string you just created
          pollInterval: 50,
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.loading) {
            return const Text('Loading');
          }
          final LaunchList launches = LaunchList.fromJson(result.data['launches']['launches'] as List<dynamic>);
          return ListView.builder(
              itemCount: launches.launchList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context,int index) {
                final LaunchItem launch = launches.launchList[index];
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute<void>(builder: (BuildContext context) => MissionPage(id: launch.missionID, token: widget.token)));
                    },
                  child: Card(
                    child: ListTile(
                      title: Text(launch.mission.name),
                    )
                  )
                );
              });
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
    return GraphQLProvider(
      child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(.60),
            selectedFontSize: 14,
            unselectedFontSize: 14,
            onTap: (int value) {
              if (value == 1) {
                Navigator.push(
                    context, MaterialPageRoute<void>(builder: (BuildContext context) => DisplayTrip(token: widget.token)));
              }
              if(value == 0) {
                Navigator.push(
                    context, MaterialPageRoute<void>(builder: (BuildContext context) => DisplayPage(token: widget.token)));
              }
              if(value == 2) {
                Navigator.push(
                    context, MaterialPageRoute<void>(builder: (BuildContext context) => CameraPage(token: widget.token)));
              }
            },
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
              )
            ],
          ),
          body: _displayPlane()
      ),
      client: client,
    );
  }
}
