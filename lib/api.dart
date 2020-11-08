const String getUserLogin = r'''
query LoginUser($username: String!, $password: String!) {
  Login(username: $username, password: $password) {
    id
    token
  } 
}
''';

const String bookATrip = r'''
mutation bookATrip($launch_id: Int!) {
  bookTrip(launch_id: $launch_id) {
    launch_id
    user_id
  }
}
''';

const String uploadAvatar = r'''
mutation uploadAvatar($base64str: String!, $name: String!, $type: String!) {
  uploadAvatar(base64str: $base64str, name: $name, type: $type) {
    avatar
  }
}
''';

const String signUpUser = r'''
mutation Signup($username: String!, $password: String!, $email: String!) {
  Signup(email: $email, password: $password, username: $username) {
    id
    token
  }
}
''';

const String getPlane = r'''
query launches() {
  launches {
    launches {
      id
      mission {
        missionPatch
        name
      }
      rocket {
        name
        type
      }
    }
    hasMore
    cursor
  }
}
''';

const String getTrip = r'''
query AllTrip() {
  trips {
    spaceX {
      mission {
        missionPatch
        name
      }
    }
  }
}
''';

const String getMission = r'''
query launches($id: Int!) {
  launch(id: $id) {
    id
    mission {
      missionPatch
      name
    }
    rocket {
      name
      type
    }
    site
  }
}
''';

const String getProfile = r'''
query user() {
  user {
    avatar
    email
    username
  }
}
''';