import 'package:flutter/material.dart';


class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(

    ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Home Page, click on the "+" Icon to add product, on the "Profile" icon to access your Profile',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
        bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.search,
                    size: 35,
                    color: Colors.black
              ),
              onPressed: () {
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_box,
                size: 37,
                color: Colors.black,
              ),
              onPressed: () {
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.person,
                size: 35,
                color: Colors.black,
              ),

              onPressed: () {
              },
            ),

          ],
        ),
      ),
    );
  }
}
