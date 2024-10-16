import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/const/constant.dart';
import 'package:todolist/services/api_service.dart';
import 'package:todolist/ui/views/detail_list_item_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ApiService apiService = ApiService(baseUrl: base_url_api);
  late SharedPreferences prefs;
  TextEditingController nameTxt = TextEditingController();
  List? todolist;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    getDataChecklist();
  }

  void initData() async {
    prefs = await SharedPreferences.getInstance();
  }

  void getDataChecklist() async {
    prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    final response = await apiService.authenticatedRequest("/checklist", token);
    log("Data checklist ${response!.data}");
    if (response.data != null) {
      log("Data all ${response.data['data']}");
      setState(() {
        todolist = response.data['data'];
      });
    } else {
      todolist = [];
    }
  }

  void addTask() async {
    Map<String, dynamic> data = {"name": "${nameTxt.text}"};
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    final resp =
        await apiService.postRequest("/checklist", data, headers: headers);
    if (resp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${resp.data['message']}"),
        ),
      );
      getDataChecklist();
    }
    log("data berhasil save $resp");
  }

  void deleteTask(int id) async {
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    final resp =
        await apiService.deleteRequest("/checklist/$id", headers: headers);
    if (resp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${resp.data['message']}"),
        ),
      );
      getDataChecklist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Todo List"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameTxt,
                      decoration: InputDecoration(
                        hintText: "Masukan Task Baru",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: const EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        addTask();
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              todolist == null
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 50),
                      child: CircularProgressIndicator(),
                    )
                  : ListView.separated(
                      reverse: true,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: todolist!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailListItemView(
                                    name: todolist![index]['name'],
                                    id: todolist![index]['id']),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text("${todolist![index]['name']}")),
                              IconButton(
                                onPressed: () {
                                  deleteTask(todolist![index]['id']);
                                  log("detail ${todolist![index]['id']}");
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}
