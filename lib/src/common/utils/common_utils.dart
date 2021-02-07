

import 'package:Cruise/src/component/channel_compact_tile.dart';
import 'package:Cruise/src/component/channel_item_card.dart';
import 'package:Cruise/src/component/channel_item_tile.dart';
import 'package:Cruise/src/models/Channel.dart';
import 'package:flutter/cupertino.dart';

import '../view_manager.dart';

class CommonUtils{

  static Widget getChannelViewType(ViewType type, Channel item) {
    switch (type) {
      case ViewType.compactTile:
        return ChannelCompactTile(item: item);
        break;
      case ViewType.itemCard:
        return ChannelItemCard(item: item);
        break;
      case ViewType.itemTile:
        return ChannelItemTile(item: item);
        break;
      default:
        return ChannelItemCard(item: item);
        break;
    }
  }

}


