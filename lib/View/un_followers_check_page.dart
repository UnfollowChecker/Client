import 'package:flutter/material.dart';
import 'package:github_unfollow_checker/Model/user.dart';
import 'package:github_unfollow_checker/View/web_view.dart';
import 'package:github_unfollow_checker/Model/user_list.dart';
import 'package:github_unfollow_checker/ViewModel/get_unfollow.dart';

class UnFollowCheckpage extends StatefulWidget {
  UnFollowCheckpage({Key? key, required this.userName}) : super(key: key);

  String userName;

  @override
  State<UnFollowCheckpage> createState() => _UnFollowCheckpageState();
}

class _UnFollowCheckpageState extends State<UnFollowCheckpage> {
  Future<UserList>? unfollower;
  List<User> list = List.empty(growable: true);
  List<User> searchResult = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    unfollower = getUnfollow(widget.userName, "unfollowers").then((value) {
      for (int i = 0; i < value.user!.length; i++) {
        list.add(value.user![i]);
      }
      return value;
    });
  }

  List<User> search(String query) {
    List<User> result = List.empty(growable: true);
    for (User user in list) {
      if (user.login!.contains(query)) {
        result.add(user);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchResult = search(value);
            });
          },
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: unfollower,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.user![0].htmlUrl == "1")
                return Text("얘 없음");
              else {
                return SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: MediaQuery.of(context).size.height - 200,
                  child: ListView.builder(
                    itemCount: searchResult.isEmpty
                        ? list.length
                        : searchResult.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 13.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: ListTile(
                          leading: Image.network(searchResult.isEmpty
                              ? list[index].avatarUrl.toString()
                              : searchResult[index].avatarUrl.toString()),
                          title: Text(searchResult.isEmpty
                              ? list[index].login.toString()
                              : searchResult[index].login.toString()),
                          onLongPress: () {
                            String url = searchResult.isEmpty
                                ? list[index].htmlUrl.toString()
                                : searchResult[index].htmlUrl.toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(url: url),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80, bottom: 65),
                    child: Image.asset(
                      'assets/noPerson.png',
                      width: 200,
                    ),
                  ),
                  const Text(
                    '존재하지 않는 유저입니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
