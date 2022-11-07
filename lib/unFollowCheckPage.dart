import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_unfollow_checker/model.dart';
import 'package:github_unfollow_checker/token.dart';
import 'package:http/http.dart' as http;

class FollowList {
  final List<Follow>? follow;

  FollowList({this.follow});

  factory FollowList.fromJson(List<dynamic> json) {
    List<Follow> follow = <Follow>[];
    follow = json.map((i) => Follow.fromJson(i)).toList();

    return FollowList(
      follow: follow,
    );
  }
}

Future<FollowList> getFollowApi() async {
  final response = await http.get(
      Uri.parse(
          'https://api.github.com/users/yeon0821/following?per_page=100'),
      headers: {'Authorization': 'Bearer $yourToken'});
  print(response.body);
  if (response.statusCode == 200) {
    return FollowList.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('예외');
  }
}

Future<String> getUnfollowApi(String login) async {
  final response = await http.get(
      Uri.parse('https://api.github.com/users/${login}/following/yeon0821'),
      headers: {'Authorization': 'Bearer $yourToken'});
  print(response.body);
  if (response.statusCode == 404) {
    print(login);
    return login;
  } else {
    throw Exception('요청 한도초과');
  }
}


class UnFollowCheckpage extends StatefulWidget {
  const UnFollowCheckpage({Key? key}) : super(key: key);

  @override
  State<UnFollowCheckpage> createState() => _UnFollowCheckpageState();
}


class _UnFollowCheckpageState extends State<UnFollowCheckpage> {
  Future<FollowList>? follow;
  Future<String>? unfollow;

  @override
  void initState() {
    super.initState();
    follow = getFollowApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: follow,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: 300,
                      height: 400,
                      child: ListView.builder(
                        itemCount: snapshot.data!.follow!.length,
                        itemBuilder: (context, index) {
                          unfollow = getUnfollowApi(snapshot.data!.follow![index].login.toString());
                          return FutureBuilder(
                            future: unfollow,
                            builder: (context, snapshot1) {
                              if (snapshot1.hasData) {
                                return Text(snapshot1.data.toString());
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('에러');
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
