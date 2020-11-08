import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
import 'package:oskour/src/missionPage.dart';
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
                return  ListView.builder(
                    itemCount: launches.launchList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final LaunchItem launch = launches.launchList[index];
                      return GestureDetector(
                          onTap: () {
                            runMutation(<String, dynamic> {'launch_id': launch.missionID});
                          },
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Image.network((() {
                                    if (launch.mission.missionPatch != null) {
                                      return launch.mission.missionPatch;
                                    }
                                    else {
                                      return 'https://lunar-typhoon-spear.glitch.me/img/default-image.png';
                                    }
                                  })()),
                                  title: Text(launch.mission.name),
                                  subtitle: Text(launch.rocket.name),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    const SizedBox(width: 8),
                                    RaisedButton(
                                      child: const Text('Partir en voyage'),
                                      onPressed: () {runMutation(<String, dynamic> {'launch_id': launch.missionID});},
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      );
                    });
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
      child:  _displayPlane(),
      client: client,
    );
  }
}
