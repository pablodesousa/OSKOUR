import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
import 'package:oskour/src/displayPage.dart';
import 'package:oskour/src/displayTrip.dart';
import 'package:oskour/src/Factory.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({Key key, this.title, this.id, this.token}) : super(key: key);

  final String title;
  final String token;
  final int id;

  @override
  _MissionPageState createState() => _MissionPageState();
}

final Policies policies = Policies(
  fetch: FetchPolicy.networkOnly,
);
class _MissionPageState extends State<MissionPage> {
  Widget _displayPlane() {

    return Query(
        options: QueryOptions(
          documentNode: gql(getMission),
          variables: <String, dynamic>{'id': widget.id}
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.loading) {
            return const Text('Loading');
          }
          final LaunchItem mission = LaunchItem.fromJson(result.data['launch'] as Map<String, dynamic>);

          return Mutation(
              options: MutationOptions(
                documentNode: gql(bookATrip),
                update: (Cache cache, QueryResult result) {
                },
                // or do something with the result.data on completion
                onCompleted: (dynamic resultData) {
                  print(resultData);
                },
              ),
              builder: (RunMutation runMutation, QueryResult result) {
                print(result.exception);
                return Container(
                      child: Column (
                        children: <Widget>[
                          Image.network(mission.mission.missionPatch),
                          Text(
                            mission.mission.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 50,
                            ),

                          ),
                          GestureDetector(
                            onTap: () {
                              runMutation(<String, dynamic> {'launch_id': widget.id});
                            },
                            child: Container(
                              child: const Text('Register'),
                            ),
                          )
                        ],
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
