import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:Cruise/src/component/compact_tile.dart';
import 'package:Cruise/src/component/item_card.dart';
import 'package:Cruise/src/component/item_tile.dart';
import 'package:Cruise/src/component/loading_item.dart';
import 'package:Cruise/src/common/helpers.dart';
import 'package:Cruise/src/models/Item.dart';
import 'package:Cruise/src/page/stories_page.dart';
import 'package:Cruise/src/page/story_page.dart';
import 'package:Cruise/src/common/view_manager.dart';

class StoryList extends HookWidget {
  const StoryList({
    Key key,
    @required this.ids,
    @required this.storiesType,
  }) : super(key: key);

  final List<int> ids;

  final StoriesType storiesType;

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

  Widget build(BuildContext context) {
    final currentView = useProvider(viewProvider.state);
    var counter = useState<StoriesType>(storiesType);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Consumer(
            (context, read) {
              return read(storyProvider(ids[index])).when(
                loading: () => LoadingItem(count: 1),
                error: (err, trace) => Text("Error: $err"),
                data: (item) {
                  return Slidable(
                    key: Key(item.id.toString()),
                    closeOnScroll: true,
                    actionPane: SlidableScrollActionPane(),
                    actions: <Widget>[
                      IconSlideAction(
                        color: Colors.deepOrangeAccent,
                        icon: Feather.arrow_up_circle,
                        onTap: () => handleUpvote(context, item: item),
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
                        handleUpvote(context, item: item);
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
                            _getViewType(currentView, item),
                        openBuilder: (BuildContext c, VoidCallback action) =>
                            StoryPage(item: item),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        childCount: ids.length,
      ),
    );
  }
}
