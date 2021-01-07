import 'package:Cruise/src/common/view_manager.dart';
import 'package:Cruise/src/component/compact_tile.dart';
import 'package:Cruise/src/component/item_card.dart';
import 'package:Cruise/src/component/item_tile.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:Cruise/src/common/auth.dart';
import 'package:Cruise/src/common/history.dart';
import 'package:Cruise/src/models/Item.dart';
import 'net/rest/http_result.dart';
import './global.dart';

void handleShare({String id, String title, String postUrl}) {
  String hnUrl = buildShareURL(id);
  String text =
      "Read it on Cruise: $hnUrl \r\r or go straight to the article: $postUrl";
  Share.share(text, subject: title);
}

String buildShareURL(String id) {
  return shareUrl + "/product/cruise/share/$id";
}

void handleUpvote(context, {Item item}) async {
  HistoryManager.addToVoteCache(item.id);
  AuthResult result = await Auth.vote(itemId: "${item.id}");

  if (result.result == Result.error) {
    HistoryManager.removeFromVoteCache(
        item.id); // ToDO: The UI won't update when we remove from cache here.
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.message)));
  } else if (result.result == Result.ok) {
    await HistoryManager.markAsVoted(item.id);
  }
}

Widget getViewType(ViewType type, Item item) {
  switch (type) {
    case ViewType.compactTile:
      return CompactTile(item: item);
      break;
    case ViewType.itemCard:
      return ItemCard(item: item);
      break;
    case ViewType.itemTile:
      return ItemTile(item: item);
      break;
    default:
      return ItemCard(item: item);
      break;
  }
}

Item getStatisticArticle() {
  Item item = new Item();
  item.title = "dfegeg";
  item.author = "dfe";
  item.pubTime = 0;
  item.id = 23433.toString();
  item.isFav = 1;
  item.link = "www.baidu.com";
  item.content = "fwegewg";
  return item;
}
