import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:my_classroom/services/firebase_api.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/class_details.dart';
import 'package:my_classroom/views/create_category/archieve_created_class.dart';
import 'package:my_classroom/views/create_category/archieve_joined_class.dart';
import 'package:my_classroom/views/create_category/createJoin_class.dart';
import 'package:my_classroom/views/create_class.dart';
import 'package:my_classroom/views/join_class.dart';
import 'package:my_classroom/views/signin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List? uniqueId;
  bool isCreated = false;
  bool isJoined = true;
  var currentUser;
  List? userData;
  bool isLoading = false;
  var archieveCreatedClass = 0;
  var archieveJoinedClass = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;

    fetchCreatedClass();
    fetchArchieveCreatedClassLength();
    fetchArchieveJoinedClassLength();
    fetchJoinedClass();
    // fetchUniqueId(currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('HomePage'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  final route = MaterialPageRoute(
                    builder: (context) => SigninPage(),
                  );
                  Navigator.push(context, route);
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.logout)))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Created Classes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            archieveCreatedClass == 0
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      final route = MaterialPageRoute(
                        builder: (context) => ArchieveCreatedClass(),
                      );
                      Navigator.push(context, route);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            color: constant().colorWhite,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            archieveCreatedClass > 1
                                ? '$archieveCreatedClass   Archieve classes'
                                : '$archieveCreatedClass   Archieve class',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: constant().colorWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            isCreated == true
                ? Center(
                    child: CircularProgressIndicator(
                      color: constant().primary,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fetchCreatedClass(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: documents.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final document = documents[index];
                              if (document['classId'] == currentUser) {
                                return GestureDetector(
                                  onTap: () {
                                    final route = MaterialPageRoute(
                                      builder: (context) => ClassDetails(
                                          classId: document['refClassId'],
                                          className: document['className'],
                                          role: document['role']),
                                    );
                                    Navigator.push(context, route);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: constant().primary,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                'Role: ${document['role']}',
                                                style: TextStyle(
                                                  color: constant().colorWhite,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              child: Text(
                                                'Classname: ${document['className']}',
                                                style: TextStyle(
                                                  color: constant().colorWhite,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              child: Text(
                                                  'Class descrition: ${document['classDesc']}',
                                                  style: TextStyle(
                                                    color:
                                                        constant().colorWhite,
                                                  )),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            PopupMenuButton(
                                              itemBuilder: (context) {
                                                return [
                                                  PopupMenuItem(
                                                      // value: 1,
                                                      onTap: () async {
                                                        await Clipboard.setData(
                                                                ClipboardData(
                                                                    text: document[
                                                                        'refClassId']))
                                                            .then((value) => ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Class id copied to clipboard"))));
                                                        // copied successfully
                                                      },
                                                      child:
                                                          Text('Get class id')),
                                                  PopupMenuItem(
                                                      // value: 1,
                                                      onTap: () async {
                                                        var currentUserName =
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .displayName;

                                                        final refClass =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'archieveCreatedClass')
                                                                .doc(document[
                                                                    'refClassId']);

                                                        final json = {
                                                          'name':
                                                              currentUserName,
                                                          'classId':
                                                              currentUser,
                                                          'refClassId':
                                                              document[
                                                                  'refClassId'],
                                                          'className': document[
                                                              'className'],
                                                          'classDesc': document[
                                                              'classDesc'],
                                                          'role': 'teacher',
                                                          'createdAt': document[
                                                              'createdAt'],
                                                        };
                                                        await refClass
                                                            .set(json);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('class')
                                                            .doc(document[
                                                                'refClassId'])
                                                            .delete();
                                                        setState(() {});
                                                      },
                                                      child: Text(
                                                          'Archieve class')),
                                                ];
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox();
                              }
                            },
                          );
                        }
                        return Text('No Classes found');
                      },
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Joined Classes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // isJoined == true
            //     ? Center(
            //         child: CircularProgressIndicator(
            //           color: constant().primary,
            //         ),
            //       )
            //     :

            archieveJoinedClass == 0
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      final route = MaterialPageRoute(
                        builder: (context) => ArchieveJoinedClass(),
                      );
                      Navigator.push(context, route);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            color: constant().colorWhite,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            archieveJoinedClass > 1
                                ? '$archieveJoinedClass   Archieve classes'
                                : '$archieveJoinedClass   Archieve class',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: constant().colorWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder(
                stream: fetchJoinedClass(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docs = snapshot.data;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: docs!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var data = docs[index];
                          if (data['classId'] == currentUser) {
                            return GestureDetector(
                              onTap: () {
                                final route = MaterialPageRoute(
                                  builder: (context) => ClassDetails(
                                      classId: data['refClassId'],
                                      className: data['className'],
                                      role: data['role']),
                                );
                                Navigator.push(context, route);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                    color: constant().primary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            'Role: ${data['role']}',
                                            style: TextStyle(
                                              color: constant().colorWhite,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Text(
                                            'Classname: ${data['className']}',
                                            style: TextStyle(
                                              color: constant().colorWhite,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Text(
                                              'Class descrition: ${data['classDesc']}',
                                              style: TextStyle(
                                                color: constant().colorWhite,
                                              )),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        PopupMenuButton(
                                          itemBuilder: (context) {
                                            return [
                                              PopupMenuItem(
                                                  // value: 1,
                                                  onTap: () async {
                                                    var currentUserName =
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .displayName;

                                                    final refClass =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'archieveJoinedClass')
                                                            .doc(
                                                                '${currentUser}')
                                                            .collection('data')
                                                            .doc(data[
                                                                'refClassId']);

                                                    final json = {
                                                      'name': currentUserName,
                                                      'classId': currentUser,
                                                      'refClassId':
                                                          data['refClassId'],
                                                      'className':
                                                          data['className'],
                                                      'classDesc':
                                                          data['classDesc'],
                                                      'role': 'teacher',
                                                      'createdAt':
                                                          data['createdAt'],
                                                    };
                                                    await refClass.set(json);
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'joinClassUsers')
                                                        .doc('${currentUser}')
                                                        .collection('data')
                                                        .doc(data['refClassId'])
                                                        .delete();
                                                    setState(() {});
                                                  },
                                                  child:
                                                      Text('Archieve class')),
                                            ];
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }
                  return Text('No class created by this user');
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: constant().primary,
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => CreateJoinClass(),
            );
            Navigator.push(context, route);
          },
          child: Icon(
            Icons.add,
          )),
    ));
  }

  Stream<QuerySnapshot> fetchCreatedClass() {
    return FirebaseFirestore.instance.collection('class').snapshots();
  }

  fetchArchieveCreatedClassLength() async {
    var docRef = FirebaseFirestore.instance.collection('archieveCreatedClass');
    setState(() {
      // archieveCreatedClass = docRef;
    });
    docRef.get().then((value) {
      setState(() {
        archieveCreatedClass = value.docs.length;
      });
    });
  }

  fetchArchieveJoinedClassLength() async {
    var docRef = FirebaseFirestore.instance
        .collection('archieveJoinedClass')
        .doc('${currentUser}')
        .collection('data');
    setState(() {
      // archieveCreatedClass = docRef;
    });
    docRef.get().then((value) {
      setState(() {
        archieveJoinedClass = value.docs.length;
      });
    });
  }

  Stream<List> fetchJoinedClass() {
    return FirebaseFirestore.instance
        .collection('joinClassUsers')
        .doc('${currentUser}')
        .collection('data')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
