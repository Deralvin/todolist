import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/const/constant.dart';
import 'package:todolist/services/api_service.dart';

class DetailListItemView extends StatefulWidget {
  const DetailListItemView({super.key, required this.id, required this.name});
  final int id;
  final String name;
  @override
  State<DetailListItemView> createState() => _DetailListItemViewState();
}

class _DetailListItemViewState extends State<DetailListItemView> {
  ApiService apiService = ApiService(baseUrl: base_url_api);
  late SharedPreferences prefs;
  TextEditingController itemText = TextEditingController();
  List? itemList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    getDataChecklistItem();
  }

  void initData() async {
    prefs = await SharedPreferences.getInstance();
  }

  void addItemTask() async {
    Map<String, dynamic> data = {"itemName": "${itemText.text}"};
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    final resp = await apiService
        .postRequest("/checklist/${widget.id}/item", data, headers: headers);
    if (resp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${resp.data['message']}"),
        ),
      );
      getDataChecklistItem();
    }
    log("data berhasil save $resp");
  }

  void getDataChecklistItem() async {
    prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    final response = await apiService.authenticatedRequest(
        "/checklist/${widget.id}/item", token);
    log("Data checklist ${response!.data}");
    if (response.data != null) {
      log("Data all ${response.data['data']}");
      setState(() {
        itemList = response.data['data'];
      });
    } else {
      // todolist = [];
    }
  }

  void updateItemTask(int id) async {
    Map<String, dynamic> data = {};
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    final resp = await apiService
        .putRequest("/checklist/${widget.id}/item/$id", data, headers: headers);
    if (resp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${resp.data['message']}"),
        ),
      );
      getDataChecklistItem();
    }
    log("data berhasil save $resp");
  }

  void getDataChecklistItemDetail(int id) async {
    prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    final response = await apiService.authenticatedRequest(
        "/checklist/${widget.id}/item/${id}", token);
    log("Data checklist ${response!.data}");
    if (response.data != null) {
      log("Data all ${response.data['data']}");
      setState(() {
        // itemList = response.data['data'];
      });
    } else {
      // todolist = [];
    }
  }

  void deleteTask(int id) async {
    final token = await prefs.getString(K_BEARER_TOKEN) ?? "";
    Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    final resp = await apiService
        .deleteRequest("/checklist/${widget.id}/item/$id", headers: headers);
    if (resp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${resp.data['message']}"),
        ),
      );
      getDataChecklistItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.name} Task"),
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
                      controller: itemText,
                      decoration: InputDecoration(
                        hintText: "Masukan Item Baru",
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
                        addItemTask();
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              itemList == null
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
                      itemCount: itemList!.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Checkbox(
                                value: itemList![index]['itemCompletionStatus'],
                                onChanged: (value) {
                                  updateItemTask(itemList![index]['id']);
                                }),
                            Expanded(
                                child: Text("${itemList![index]['name']}")),
                            IconButton(
                              onPressed: () {
                                deleteTask(itemList![index]['id']);
                                // log("detail ${todolist![index]['id']}");
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ],
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
