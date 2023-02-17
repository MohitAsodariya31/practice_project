import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:practice_project/add_to_do_screen.dart';
import 'package:practice_project/to_do_model_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferences? prefs;
  ToDoModel? toDoModel;

  getInstance() async {
    prefs = await SharedPreferences.getInstance();
    getData();
  }

  getData() {
    if (prefs!.containsKey("ToDoData")) {
      dynamic data = prefs!.getString("ToDoData");
      debugPrint("data ------>>> $data");
      toDoModel = ToDoModel.fromJson(jsonDecode(data));
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: toDoModel == null || toDoModel!.todoList!.isEmpty
          ? const Center(
              child: Text(
                "No Data Found",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.separated(
              itemCount: toDoModel!.todoList!.length,
              padding: const EdgeInsets.all(15),
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) => Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    toDoModel!.todoList!.removeAt(index);
                    prefs!.setString("ToDoData", jsonEncode(toDoModel));
                  } else if (direction == DismissDirection.startToEnd) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddToDoScreen(
                          data: toDoModel!.todoList![index],
                          index: index,
                        ),
                      ),
                    ).then((value) => getData());
                  }
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  color: Colors.blue,
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  tileColor: Colors.grey.shade300,
                  title: Text("Title: ${toDoModel!.todoList![index].title}"),
                  subtitle: Text("Description: ${toDoModel!.todoList![index].description}"),
                  trailing: Column(
                    children: [
                      Text("Time: ${toDoModel!.todoList![index].time}"),
                      Text("Date: ${toDoModel!.todoList![index].date}"),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddToDoScreen(),
            ),
          ).then((value) => getData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
