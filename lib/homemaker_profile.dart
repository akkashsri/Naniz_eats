import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/MakerDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomemakerProfile extends StatefulWidget {
  @override
  _HomemakerProfileState createState() => _HomemakerProfileState();
}

class _HomemakerProfileState extends State<HomemakerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var _uid;
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, "/MenuPage");
    } else if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, "/MerchantOrderPage",
          arguments: _uid);
    } else if (_selectedIndex == 2) {
      
    }
  }

  void getData() async {
    var temp;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('homemakers').document(user.uid).get();
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
      drawer: MakerDrawerWidget(
        uid: _uid,
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('homemakers')
              .document(_uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                      height:
                          MediaQuery.of(context).padding.top + height * 0.01),
                  Container(
                      width: 91,
                      height: 91,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: new NetworkImage(
                                  "${snapshot.data['image']}")))),
                  SizedBox(
                    height: 10,
                  ),
                  Text('${snapshot.data['name']}\'s Kitchen',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontFamily: "Gilroy",
                        fontSize: 20.0,
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(snapshot.data['mealtype'][0] + '  |  ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w900,
                            fontFamily: "Gilroy",
                            fontSize: 13.0,
                          )),
                      RatingBarIndicator(
                        rating: snapshot.data['rating'].toDouble(),
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(snapshot.data['city'],
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Gilroy",
                        fontSize: 13.0,
                      )),
                  SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Colors.redAccent, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text('Operating ' + snapshot.data['ohours'],
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w800,
                                fontFamily: "Gilroy",
                                fontSize: 12.0,
                              )),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Colors.redAccent, width: 1)),
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: (snapshot.data['delivery'])
                                ? Text('Delivery Available',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: "Gilroy",
                                      fontSize: 12.0,
                                    ))
                                : Text('Delivery Not Available',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: "Gilroy",
                                      fontSize: 12.0,
                                    ))),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ListTile(
                    title: Text('Dishes',
                        style: TextStyle(
                          color: Color(0xffFE4E74),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gilroy",
                          fontSize: 25.0,
                        )),
                    trailing: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              width: 1,
                              color: Colors.redAccent,
                            )),
                        child: Text('View All',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 18.0,
                            )),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed("/MenuPage");
                        }),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    height: 200,
                    child: ListView.builder(
                        itemCount: 3, //Later Change to 5
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(snapshot.data['menu'][index]['name'],
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "Gilroy",
                                  fontSize: 20.0,
                                )),
                            trailing: Text(
                                '₹ ' +
                                    snapshot.data['menu'][index]['price']
                                        .toString(),
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Gilroy",
                                  fontSize: 20.0,
                                )),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        title: Text('Pending Payout',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 22.0,
                            )),
                        subtitle: Text(
                            '₹ 15,825', //Make it Dynamic after adding data to firestore
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Gilroy",
                              fontSize: 18.0,
                            )),
                        trailing: MaterialButton(
                            color: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.redAccent,
                                )),
                            child: Text('Cash In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "Gilroy",
                                  fontSize: 18.0,
                                )),
                            onPressed: () {
                              // TODO
                            }),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        title: Text('Pending Orders',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 22.0,
                            )),
                        subtitle: Text(
                            '23', //Make it Dynamic after adding data to firestore
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Gilroy",
                              fontSize: 18.0,
                            )),
                        trailing: MaterialButton(
                            color: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.redAccent,
                                )),
                            child: Text('View Orders',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "Gilroy",
                                  fontSize: 18.0,
                                )),
                            onPressed: () {
                              //TODO
                              Navigator.of(context).pushReplacementNamed(
                                  "/MerchantOrderPage",
                                  arguments: _uid);
                            }),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        title: Text('Linked Account',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 22.0,
                            )),
                        subtitle: Text(
                            '1234567890 (HDFC)', //Make it Dynamic after adding data to firestore
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              fontSize: 15.0,
                            )),
                        trailing: MaterialButton(
                            color: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.redAccent,
                                )),
                            child: Text('Manage',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "Gilroy",
                                  fontSize: 18.0,
                                )),
                            onPressed: () {}),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        title: Text('View Your Analytics',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 20.0,
                            )),
                        // subtitle: Text(
                        //     '₹ 15,825', //Make it Dynamic after adding data to firestore
                        //     style: TextStyle(
                        //       color: Colors.black45,
                        //       fontWeight: FontWeight.w700,
                        //       fontFamily: "Gilroy",
                        //       fontSize: 18.0,
                        //     )),
                        trailing: MaterialButton(
                            color: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.redAccent,
                                )),
                            child: Text('Analytics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "Gilroy",
                                  fontSize: 18.0,
                                )),
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                  "/AnalyticsPage",
                                  arguments: _uid);
                            }),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          }),
    );
  }
}
