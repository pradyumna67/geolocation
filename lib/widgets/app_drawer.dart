import 'package:flutter/material.dart';

import '../homepage.dart';
import '../second.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(title: Text('Dynamic Markers Needed!!'),
            automaticallyImplyLeading: false,
          ),
          Container(
            margin: EdgeInsets.only(top: 20,bottom: 20),
            height: 100,
            width: 100,
            child:CircleAvatar(
              backgroundImage: NetworkImage("https://cdn.dribbble.com/users/528264/screenshots/3140440/firebase_logo.png"),
            ),
          ),

          Divider(),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Add Markers'),
            onTap: (){
              //Navigator.of(context).pushNamed(UserProduct.userProduct);
              Data data = new Data();
              data.text="";
              data.dateTime="";
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Second(data: data,)),
              );
            },
          )
        ],
      ),
    );
  }
}
