import 'package:cruise/src/page/story_page.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cruise/src/component/compact_tile.dart';
import 'package:cruise/src/component/item_card.dart';
import 'package:cruise/src/component/item_tile.dart';
import 'package:cruise/src/models/Item.dart';
import 'package:cruise/src/common/view_manager.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StoryList extends HookWidget {
  StoryList({
     Key? key,
    required this.articles,
     this.storiesType,
  }) : super(key: key);

  final List<Item> articles;

  final StoriesType? storiesType;

  _getViewType(ViewType type, Item item) {
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

  final pageStorageBucket = PageStorageBucket();
  final Map<String, ScrollController> scrollController = new Map();

  Widget build(BuildContext context) {
    if (articles != null && articles.length > 0) {
      articles.forEach((element) {
        scrollController.putIfAbsent(
            element.toString(), () => new ScrollController());
      });
    }
    final currentView = ViewManager.fromViewName("itemCard");

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        /*if (articles != null) {
          articles.forEach((element) {
            return Slidable(
              key: Key(element.id.toString()),
              closeOnScroll: true,
              actionPane: SlidableScrollActionPane(),
              actions: <Widget>[
                IconSlideAction(
                  color: Colors.deepOrangeAccent,
                  icon: Feather.arrow_up_circle,
                  //onTap: () => handleUpvote(context, item: item),
                ),
              ],
              dismissal: SlidableDismissal(
                closeOnCanceled: true,
                dismissThresholds: {
                  SlideActionType.primary: 0.2,
                  SlideActionType.secondary: 0.2,
                },
                child: SlidableDrawerDismissal(),
                onWillDismiss: (actionType) {
                  //handleUpvote(context, item: item);
                  return false;
                },
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OpenContainer(
                  tappable: true,
                  closedElevation: 0,
                  closedColor: Theme.of(context).scaffoldBackgroundColor,
                  openColor: Theme.of(context).scaffoldBackgroundColor,
                  transitionDuration: Duration(milliseconds: 500),
                  closedBuilder: (BuildContext c, VoidCallback action) =>
                      _getViewType(currentView, element),
                  openBuilder: (BuildContext c, VoidCallback action) =>
                      StoryPage(
                    item: element,
                    pageStorageBucket: pageStorageBucket,
                    scrollControllers: scrollController,
                  ),
                ),
              ),
            );
          });
        }*/
        return null;
      }),
    );
  }
}
