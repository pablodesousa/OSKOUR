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
          final ProfileList profiles = ProfileList.fromJson(
              result.data['user'] as List<dynamic>);

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
                return CustomScrollView(slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return Column(
                            children: <Widget>[
                              Image.network((() {
                                if (profiles.profileItem[0].avatar != null) {
                                  return profiles.profileItem[0].avatar;
                                }
                                else {
                                  return 'https://lunar-typhoon-spear.glitch.me/img/default-image.png';
                                }
                              })()),
                              Text(
                                profiles.profileItem[0].email,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 50,
                                ),
                              ),
                              Text(
                                profiles.profileItem[0].username,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 50,
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    _image == null
                                        ? print('error')
                                        : runMutation(<String, dynamic>{'base64str': image64, 'name': getRandomString(15) + '.jpg', 'type': 'image/jpeg'});
                                  },
                                  child: _image == null
                                      ? const Text('dont has image')
                                      : const Text('has image')),
                              FloatingActionButton(
                                onPressed: getImage,
                                tooltip: 'Pick Image',
                                child: const Icon(Icons.add_a_photo),
                              )
                            ],
                          );
                        },
                        childCount: 1,
                      ))
                ]);
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
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          DisplayTrip(token: widget.token)));
            }
            if (value == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          DisplayPage(token: widget.token)));
            }
            if (value == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => const CameraPage()));
            }
          },
          items: const <BottomNavigationBarItem>[
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
        body: _displayProfile(),
      ),
      client: client,
    );
  }
}
