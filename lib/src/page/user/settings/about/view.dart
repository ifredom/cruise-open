import 'package:Cruise/src/page/user/settings/about/privicy/page.dart';
import 'package:Cruise/src/page/user/settings/about/version/page.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'contract/page.dart';
import 'state.dart';

Widget buildView(aboutState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    body: Form(
      child: ListView(
        children: [
          ListTile(
            title: Text("软件许可协议"),
            leading: Icon(Feather.moon),
            onTap: () {
              var data = {'name': "contractPage"};
              Widget contractPage = ContractPage().buildPage(data);
              Navigator.push(
                viewService.context,
                MaterialPageRoute(builder: (context) => contractPage),
              );
            },
          ),
          ListTile(
            title: Text("隐私政策"),
            leading: Icon(Feather.moon),
            onTap: () {
              var data = {'name': "privacyPage"};
              Widget privacyPage = PrivacyPage().buildPage(data);
              Navigator.push(
                viewService.context,
                MaterialPageRoute(builder: (context) => privacyPage),
              );
            },
          ),
          ListTile(
            title: Text("版本信息"),
            leading: Icon(Feather.moon),
            onTap: () {
              var data = {'name': "versionPage"};
              Widget versionPage = VersionPage().buildPage(data);
              Navigator.push(
                viewService.context,
                MaterialPageRoute(builder: (context) => versionPage),
              );
            },
          ),
        ],
      ),
    ),
  );
}
