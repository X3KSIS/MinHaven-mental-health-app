class AppUser{
  final String uid;
  final String name; // new field
  final String email;


  AppUser({
    required this.uid,
    required this.name,
    required this.email,

  });

  Map<String, dynamic> toJson() {
    return{
      "uid": uid,
      "name": name, // include name
      "email": email,

    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser){
    return AppUser(
      uid: jsonUser['uid'],
      name: jsonUser['name'],
      email: jsonUser['email'],
       // include name
    );
  }
}





/*
class AppUser{
  final String uid;
  final String email;

  AppUser({
    required this.uid,
    required this.email
  });

  // Convert app user to Json file
  Map<String, dynamic> toJson() {
    return{
      "uid": uid,
      "email": email,
    };
  }

  // Convert Json to app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser){
    return AppUser(
        uid: jsonUser['uid'],
        email: jsonUser['email']
    );
  }
}

 */