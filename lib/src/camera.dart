import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
import 'package:oskour/src/displayTrip.dart';
import 'package:oskour/src/displayPage.dart';
import 'package:oskour/src/Factory.dart';

DateTime now = DateTime.now();
Random rnd = Random();
Random rnd2 = Random(now.millisecondsSinceEpoch);

class CameraPage extends StatefulWidget {
  const CameraPage({Key key, this.title, this.token}) : super(key: key);

  final String title;
  final String token;

  @override
  _CameraPageState createState() => _CameraPageState();
}

Policies policies = Policies(
  fetch: FetchPolicy.networkOnly,
);

class _CameraPageState extends State<CameraPage> {
  File _image;
  ImagePicker picker = ImagePicker();
  String image64;
  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable<int>.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> getImage() async {
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        final Uint8List image = File(pickedFile.path).readAsBytesSync();
        image64 = base64Encode(image);
        print(image64);
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _displayProfile() {
    return Query(
        options: QueryOptions(
          documentNode: gql(getProfile),
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.loading) {
            return const Text('Loading');
          }
          print(result.data);
          final ProfileList profiles =
              ProfileList.fromJson(result.data['user'] as List<dynamic>);

          return Mutation(
              options: MutationOptions(
                documentNode: gql(uploadAvatar),
                update: (Cache cache, QueryResult result) {},
                // or do something with the result.data on completion
                onCompleted: (dynamic resultData) {
                  print(resultData);
                },
              ),
              builder: (RunMutation runMutation, QueryResult result) {
                print(result.exception);
                return MaterialApp(
                  home: Scaffold(
                    backgroundColor: Colors.teal.shade50,
                    body: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 80,
                                      backgroundImage: NetworkImage((() {
                                        if (profiles.profileItem[0].avatar !=
                                            null) {
                                          return profiles.profileItem[0].avatar;
                                        } else {
                                          return 'https://lunar-typhoon-spear.glitch.me/img/default-image.png';
                                        }
                                      })()),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () {
                                          _image == null
                                              ? print('error')
                                              : runMutation(<String, dynamic>{
                                                  'base64str': image64,
                                                  'name': getRandomString(15) +
                                                      '.jpg',
                                                  'type': 'image/jpeg'
                                                });
                                        },
                                        child: _image == null
                                            ? const Text('Select an image:')
                                            : const Icon(Icons.check_circle)),
                                    FloatingActionButton(
                                      onPressed: getImage,
                                      backgroundColor: Colors.teal[900],
                                      tooltip: 'Pick Image',
                                      child: const Icon(Icons.add_a_photo),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                              width: 200,
                              child: Divider(
                                color: Colors.teal[100],
                              ),
                            ),
                            Text("I'm a space explorer !"),
                            Card(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 25.0),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.email,
                                    color: Colors.teal[900],
                                  ),
                                  title: Text(
                                    profiles.profileItem[0].email,
                                    style: TextStyle(
                                        fontFamily: 'BalooBhai',
                                        fontSize: 20.0),
                                  ),
                                )),
                            Card(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 25.0),
                              child: ListTile(
                                leading: Icon(
                                  Icons.supervised_user_circle,
                                  color: Colors.teal[900],
                                ),
                                title: Text(
                                  profiles.profileItem[0].username,
                                  style: TextStyle(
                                      fontSize: 20.0, fontFamily: 'Neucha'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: HttpLink(
            uri: 'https://flutter-spacex.herokuapp.com/v1/graphql',
            headers: <String, String>{
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
      child: _displayProfile(),
      client: client,
    );
  }
}
