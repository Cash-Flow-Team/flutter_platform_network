import 'dart:async';

import 'package:example/api/application_api.dart';
import 'package:example/api/models/user_response_model.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    @required this.apiClient,
  }) : super(key: key);

  final ApplicationApi apiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Platform Network Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Platform Network Page',
        apiClient: apiClient,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
    this.title,
    @required this.apiClient,
  }) : super(key: key);

  final String title;
  final ApplicationApi apiClient;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  StreamSubscription subscription;
  List<UserResponseModel> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: isLoading ? _getProgressWidget() : getUsersWidget(users),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserList,
        tooltip: 'Load a user list',
        child: Icon(Icons.update),
      ),
    );
  }

  Widget getUsersWidget(List<UserResponseModel> users) {
    return ListView.separated(
      itemBuilder: (context, i) => _createUserItemWidget(users[i]),
      itemCount: users.length,
      separatorBuilder: (context, i) => const Divider(),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadUserList();
  }

  void showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('An error occurred while loading data'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _createUserItemWidget(UserResponseModel user) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(user.avatar),
        ),
        const SizedBox(width: 8),
        Text(
          user.id.toString(),
          style: Theme.of(context).textTheme.display1,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.subtitle,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.subhead,
            ),
          ],
        ),
      ]),
    );
  }

  Widget _getProgressWidget() {
    return Center(child: const CircularProgressIndicator());
  }

  void _loadUserList() {
    subscription?.cancel();

    subscription = widget.apiClient
        .getUserList()
        .doOnListen(() => setState(() => isLoading = true))
        .doOnDone(() => setState(() => isLoading = false))
        .listen(
          (result) => setState(() => users = result.data),
          onError: (e) => showErrorDialog(),
        );
  }
}
