import 'dart:async';
import 'dart:convert';
import 'MakerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;
var _uid;

Future<String> getUser() async {
  FirebaseUser user = await _auth.currentUser();
  return user.displayName;
}

class MerchantOrder extends StatefulWidget {
  @override
  _MerchantOrderState createState() => _MerchantOrderState();
}

class _MerchantOrderState extends State<MerchantOrder> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, "/MenuPage");
    } else if (_selectedIndex == 2) {
    } else if (_selectedIndex == 3) {
      Navigator.pushReplacementNamed(context, "/HomemakerProfilePage");
    }
  }

  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      drawer: MakerDrawerWidget(uid: s),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            height: 54,
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xffFE506D),
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment, color: Colors.black),
                  title: Text("Home"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_books, color: Color(0xffFE506D)),
                  title: Text("Shop"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border, color: Colors.black),
                  title: Text("Shop"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.perm_identity, color: Colors.black),
                  title: Text("Profile"),
                )
              ],
            ),
          )),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        elevation: 0,
      ),
      body: MerchantOrderBody(),
    );
  }
}

class MerchantOrderBody extends StatefulWidget {
  @override
  _MerchantOrderBodyState createState() => _MerchantOrderBodyState();
}

class _MerchantOrderBodyState extends State<MerchantOrderBody> {
  void getData() async {
    _auth.onAuthStateChanged.listen((user) async {
      setState(() {
        _uid = user.uid;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  bool change = false;
  List orders = [];
  static const String serverKey =
      "AAAAgNeqQUU:APA91bGf97wJkAGes42Tr8LeUexfwQT5YlkgnjYrVo0ZlYRyEpHonanba-qcL-SHv5vBpCZmfpJaKIEjEnnBGTDLBLxP1YAfUTTUpQsTmjpi2foUEledKs8zPklBCv_nj2_YnhkYBAKV";

  void editCallback(String orderId, String user) {
    Navigator.pushNamed(context, '/ReviewOrderPage',
        arguments: {'orderId': orderId, 'user': user});
  }

  void cancelCallback(String orderId, String user) async {
    firestore
        .collection('homemakers')
        .document(_uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] != orderId) {
          newOrders.add(item);
        }
      }
      firestore
          .collection('homemakers')
          .document(_uid)
          .updateData({'orders': newOrders});
    });
    firestore
        .collection('users')
        .document(user)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == orderId) {
          if (item['homemaker'] != _uid.toString()) {
            newOrders.add(item);
          }
        } else {
          newOrders.add(item);
        }
      }
      firestore
          .collection('users')
          .document(user)
          .updateData({'orders': newOrders});
    });
    await http
        .post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Order has been cancelled',
            'title': 'Order has been cancelled'
          },
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          //'to': order["token"],
        },
      ),
    )
        .then((value) {
      print(value.body);
    });
  }

  void acceptCallback(String orderId, String user, String type) async {
    firestore
        .collection('homemakers')
        .document(_uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == orderId) {
          item[type] = true;
          if (type == 'accepted') {
            item['order_accepted_at'] = Timestamp.now();
          } else {
            item['order_out_for_delivery_at'] = Timestamp.now();
          }
        }
        newOrders.add(item);
      }
      firestore
          .collection('homemakers')
          .document(_uid)
          .updateData({'orders': newOrders});
    });

    firestore
        .collection('users')
        .document(user)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == orderId && item['homemaker'] == _uid.toString()) {
          item[type] = true;
          if (type == 'accepted') {
            item['order_accepted_at'] = Timestamp.now();
          } else {
            item['order_out_for_delivery_at'] = Timestamp.now();
          }
        }
        newOrders.add(item);
      }
      firestore
          .collection('users')
          .document(user)
          .updateData({'orders': newOrders});
    });
  }

  int getPrice(List items, String item) {
    for (int i = 0; i < items.length; i++) {
      if (Map.from(items[i])['name'] == item)
        return Map.from(items[i])['price'];
    }
    return 0;
  }

  List menu;
  void getItems(String homemaker) async {
    await firestore
        .collection('homemakers')
        .document(homemaker)
        .get()
        .then((DocumentSnapshot snapshot) {
      menu = List.from(Map.from(snapshot.data)['menu']);
    });
  }

  @override
  Widget build(BuildContext context) {
    // String username;
    // getUser().then((value) => username = value);
    return SafeArea(
      child: StreamBuilder(
        stream: firestore
            .collection('homemakers')
            .document(_uid) //Replace using username
            .snapshots(),
        builder: (context, snapshot) {
          getItems(_uid);
          List<Widget> toShow = [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Text(
                  "Your pending orders,",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            )
          ];

          if (snapshot.connectionState == ConnectionState.waiting ||
              menu == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            List orders = List.from(snapshot.data['orders']);
            for (int i = 0; i < orders.length; i++) {
              List items = List.from(Map.from(orders[i])['items']);
              int cost = 0;
              if (!Map.from(orders[i])['out_for_delivery']) {
                for (int j = 0; j < items.length; j++) {
                  cost += Map.from(items[i])['quantity'] *
                      getPrice(menu, Map.from(items[i])['item']);
                }
                toShow.add(CustomCard(
                  type: "Live Order",
                  user: Map.from(orders[i])['user'],
                  orderId: Map.from(orders[i])['orderId'],
                  items: List.from(Map.from(orders[i])['items']),
                  cost: cost,
                  accepted: Map.from(orders[i])['accepted'],
                  cancelCallback: cancelCallback,
                  acceptCallback: acceptCallback,
                  editCallback: editCallback,
                ));
              }
            }
          }

          return toShow.length > 1
              ? ListView(shrinkWrap: true, children: toShow)
              : Center(
                  child: Text(
                    "No Pending Orders",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                );
        },
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String type, user, orderId;
  final List items;
  final Function cancelCallback, acceptCallback, editCallback;
  final int cost;
  final bool accepted;

  CustomCard(
      {this.type,
      this.orderId,
      this.user,
      this.items,
      this.cost,
      this.accepted,
      this.acceptCallback,
      this.cancelCallback,
      this.editCallback});

  List getChildren() {
    List<Widget> result = [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  type,
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xffFE506D),
                      fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    this.editCallback(this.orderId, this.user);
                  }),
            ],
          ),
        ),
      ),
    ];

    for (int i = 0; i < items.length; i++) {
      result.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${Map.from(items[i])['item']}",
                  style: TextStyle(fontSize: 15)),
              Text('x${Map.from(items[i])['quantity']}',
                  style: TextStyle(fontSize: 15)),
            ],
          )));
    }

    result.add(Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              "₹$cost",
              style: TextStyle(
                  fontSize: 15,
                  color: Color(0xffFE506D),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: OutlineButton(
            color: Color(0xffFE506D),
            textColor: Color(0xffFE506D),
            borderSide: BorderSide(
              color: Color(0xffFE506D),
              style: BorderStyle.solid,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Gilroy",
                ),
              ),
            ),
            onPressed: () {
              this.cancelCallback(this.orderId, this.user);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textColor: Colors.white,
            color: Color(0xffFE506D),
            child: !this.accepted
                ? Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Gilroy",
                      ),
                    ))
                : Icon(Icons.done),
            onPressed: () {
              !this.accepted
                  ? this.acceptCallback(this.orderId, this.user, 'accepted')
                  : this.acceptCallback(
                      this.orderId, this.user, 'out_for_delivery');
            },
          ),
        ),
      ],
    ));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 5.0),
            blurRadius: 6.0,
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      child: Column(
        children: getChildren(),
      ),
    );
  }
}
