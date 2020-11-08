import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oskour/api.dart';
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
                return Container(
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
                  child: SafeArea(
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
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 75,
                                        backgroundImage: NetworkImage((() {
                                          if (profiles.profileItem[0].avatar !=
                                              null) {
                                            return profiles.profileItem[0].avatar;
                                          } else {
                                            return 'https://lunar-typhoon-spear.glitch.me/img/default-image.png';
                                          }
                                        })()),
                                      ),
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
                                            ? const Text('Select an image:', style: TextStyle(color: Colors.white),)
                                            : const Icon(Icons.check_circle, color: Colors.white,)),
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
                          Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 25.0),
                              child: ListTile(
                                leading: Icon(
                                  Icons.email,
                                  color: Colors.teal[900],
                                ),
                                title: Text(
                                  profiles.profileItem[0].email,
                                  style: const TextStyle(
                                      fontFamily: 'BalooBhai', fontSize: 20.0),
                                ),
                              )),
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 25.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.supervised_user_circle,
                                color: Colors.teal[900],
                              ),
                              title: Text(
                                profiles.profileItem[0].username,
                                style: const TextStyle(
                                    fontSize: 20.0, fontFamily: 'Neucha'),
                              ),
                            ),
                          ),
                        ],
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
