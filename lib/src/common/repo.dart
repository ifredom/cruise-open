import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cruise/src/common/config/global_config.dart' as global;
import 'package:cruise/src/common/cruise_user.dart';
import 'package:cruise/src/common/log/cruise_log_handler.dart';
import 'package:cruise/src/common/net/rest/rest_clinet.dart';
import 'package:cruise/src/models/Channel.dart';
import 'package:cruise/src/models/Item.dart';
import 'package:cruise/src/models/request/article/article_request.dart';
import 'package:http/http.dart' as http;

import 'log/cruise_api_error.dart';

class Repo {
  static final _itemsCache = <int, Item>{};
  static final _itemsChannelCache = <int, Channel>{};
  static final _usersCache = <String, CruiseUser>{};
  final baseUrl = global.baseUrl;

  static Future<List<Item>> getArticles(ArticleRequest request) async {
    List<Item> articles = await _getArticles(request);
    return articles;
  }

  static Future<List<Channel>> getChannels(ArticleRequest request) async {
    List<Channel> channels = await _getChannels(request);
    return channels;
  }

  static Future<List<String>> getCommentsIds({required Item item}) async {
    Stream<Item> stream = lazyFetchComments(item: item, assignDepth: false);
    List<String> comments = [];
    await for (Item comment in stream) {
      comments.add(comment.id);
    }
    return comments;
  }

  static Stream<Item> lazyFetchComments({required Item item, int depth = 0, bool assignDepth = true}) async* {
    if (item.kids!.isEmpty) return;
    for (int kidId in item.kids!) {
      Item kid = (await fetchArticleItem(kidId))!;
      if (assignDepth) kid.depth = depth;
      yield kid;
      /*Stream stream = lazyFetchComments(item: kid, depth: kid.depth + 1);
      await for (Item grandkid in stream) {
        yield grandkid;
      }*/
    }
  }

  static Future<List<Item>> prefetchComments({required Item item}) async {
    List<Item> result = [];
    if (item.parent != null) result.add(item);
    if (item.kids!.isEmpty) return Future.value(result);

    await Future.wait(item.kids!.map((kidId) async {
      Item kid = (await fetchArticleItem(kidId))!;
      if (kid != null) {
        await prefetchComments(item: kid);
      }
    }));
    return Future.value(result);
  }

  static Future<List<Item?>> fetchByIds(List<int> ids) async {
    return Future.wait(ids.map((itemId) {
      return fetchArticleItem(itemId);
    }));
  }

  static Future<List<Channel>> _getChannels(ArticleRequest articleRequest) async {
    final typeQuery = _getStoryTypeQuery(articleRequest.storiesType);
    Map jsonMap = articleRequest.toMap();
    final response = await RestClient.postHttp("$typeQuery", jsonMap);
    if (response.statusCode == 200 && response.data["statusCode"] == "200") {
      Map result = response.data["result"];
      if (result == null) {
        return List.empty();
      }
      List channels = result["list"];
      List<Channel> items = List.empty(growable: true);
      channels.forEach((element) {
        if (element != null) {
          HashMap<String, Object> map = HashMap.from(element);
          Channel item = Channel.fromMap(map);
          items.add(item);
        } else {
          print("null channel");
        }
      });
      return items;
    }
    return List.empty();
  }

  static Future<List<Item>> _getArticles(ArticleRequest articleRequest) async {
    final typeQuery = _getStoryTypeQuery(articleRequest.storiesType);
    Map jsonMap = articleRequest.toMap();
    final response = await RestClient.postHttp("$typeQuery", jsonMap);
    if (response.statusCode == 200 && response.data["statusCode"] == "200") {
      Map result = response.data["result"];
      if (result == null) {
        return List.empty();
      }
      List articles = result["list"];
      List<Item> items = List.empty(growable: true);
      articles.forEach((element) {
        if (element != null) {
          HashMap<String, Object> map = HashMap.from(element);
          Item item = Item.fromMap(map);
          items.add(item);
        } else {
          print("null article");
        }
      });
      return items;
    }
    return List.empty();
  }

  static Future<Item?> fetchArticleItem(int id) async {
    if (_itemsCache.containsKey(id)) {
      return _itemsCache[id];
    } else {
      final response = await RestClient.getHttp("/post/article/$id");
      if (response.statusCode == 200 && response.data["statusCode"] == "200") {
        Map articleResult = response.data["result"];
        String articleJson = JsonEncoder().convert(articleResult);
        Item parseItem = Item.fromJson(articleJson);
        _itemsCache[id] = parseItem;
      } else {
        CruiseLogHandler.logError(CruiseApiError('Item $id failed to fetch.'), JsonEncoder().convert(response));
      }
      return _itemsCache[id];
    }
  }

  static Future<Channel?> fetchChannelItem(int id) async {
    if (_itemsChannelCache.containsKey(id)) {
      return _itemsChannelCache[id];
    } else {
      final response = await RestClient.getHttp("/post/sub/source/detail/$id");
      if (response.statusCode == 200 && response.data["statusCode"] == "200") {
        Map channelResult = response.data["result"];
        if (channelResult != null) {
          // Pay attention: channelResult would be null sometimes
          String jsonContent = JsonEncoder().convert(channelResult);
          Channel parseItem = Channel.fromJson(jsonContent);
          _itemsChannelCache[id] = parseItem;
        }
      } else {
        CruiseLogHandler.logError(CruiseApiError('Item $id failed to fetch.'), JsonEncoder().convert(response));
      }
    }
    return _itemsChannelCache[id];
  }

  static Future<CruiseUser?> fetchUser(String id) async {
    if (_usersCache.containsKey(id)) {
      return _usersCache[id];
    } else {
      String url = global.baseUrl + "/user/$id.json";
      Uri uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        if (response.body == "null") return null;
        _usersCache[id] = CruiseUser.fromJson(response.body);
      } else {
        CruiseLogHandler.logError(CruiseApiError('User $id failed to fetch.'), JsonEncoder().convert(response));
      }
    }
    return _usersCache[id];
  }

  static String _getStoryTypeQuery(StoriesType type) {
    switch (type) {
      case StoriesType.channels:
        return "/post/sub/source/page/cache";
      case StoriesType.subStories:
        return "/post/article/substories";
      case StoriesType.topStories:
        return "/post/article/newstories";
      case StoriesType.showStories:
        return "/post/article/newstories";
      case StoriesType.jobStories:
        return "/post/article/newstories";
      case StoriesType.favStories:
        return "/post/user/fav/article";
      case StoriesType.originalStories:
        return "/post/article/originalstories";
      case StoriesType.channelStories:
        return "/post/article/channelstories";
      default:
        return "/post/article/newstories";
    }
  }
}
