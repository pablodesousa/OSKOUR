import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
import 'package:oskour/src/Factory.dart';

class DisplayTrip extends StatefulWidget {
  const DisplayTrip({Key key, this.title, this.token}) : super(key: key);
  final String title;
  final String token;
  @override
  _DisplayTripState createState() => _DisplayTripState();
}

final Policies policies = Policies(
  fetch: FetchPolicy.networkOnly,
);

class _DisplayTripState extends State<DisplayTrip> {

  Widget _displayPlane() {
    return Query(
        options: QueryOptions(
          documentNode: gql(getTrip),
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
          final SpaceList trips = SpaceList.fromJson(result.data['trips'] as List<dynamic>);
          return ListView.builder(
              itemCount: trips.spaceList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final SpaceXItem trip = trips.spaceList[index];
                return GestureDetector(
                    child: Card(
                        child: ListTile(
                          title: Text(trip.spaceX.mission.name),
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
      child: _displayPlane(),
      client: client,
    );
  }
}
