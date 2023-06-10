import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/class_details.dart';
import 'package:my_classroom/views/homepage.dart';

class ArchieveJoinedClass extends StatefulWidget {
  const ArchieveJoinedClass({super.key});

  @override
  State<ArchieveJoinedClass> createState() => _ArchieveJoinedClassState();
}

class _ArchieveJoinedClassState extends State<ArchieveJoinedClass> {
  var currentUser;

  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    fetchArchieveJoinedClass();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Archieve classes'),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => HomePage(),
              );
              Navigator.push(context, route);
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: StreamBuilder(
          stream: fetchArchieveJoinedClass(),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                              var currentUserName = FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .displayName;

                                              final refClass = FirebaseFirestore
                                                  .instance
                                                  .collection('joinClassUsers')
                                                  .doc('${currentUser}')
                                                  .collection('data')
                                                  .doc(data['refClassId']);

                                              final json = {
                                                'name': currentUserName,
                                                'classId': currentUser,
                                                'refClassId':
                                                    data['refClassId'],
                                                'className': data['className'],
                                                'classDesc': data['classDesc'],
                                                'role': 'teacher',
                                                'createdAt': data['createdAt'],
                                              };
                                              await refClass.set(json);
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      'archieveJoinedClass')
                                                  .doc('${currentUser}')
                                                  .collection('data')
                                                  .doc(data['refClassId'])
                                                  .delete();
                                              setState(() {});
                                            },
                                            child: Text('Un archieve class')),
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
    ));
  }

  Stream<List> fetchArchieveJoinedClass() {
    return FirebaseFirestore.instance
        .collection('archieveJoinedClass')
        .doc('${currentUser}')
        .collection('data')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
