import 'package:cruise/src/page/user/settings/cruisesetting/state.dart';
import 'package:cruise/src/models/Item.dart';
import 'package:cruise/src/page/channel/channellistdefault_component/state.dart';
import 'package:cruise/src/page/home/components/homelistdefault_component/state.dart';
import 'package:cruise/src/page/user/discover/state.dart';
import 'package:cruise/src/page/user/fav/state.dart';
import 'package:fish_redux/fish_redux.dart';

import '../../state.dart';

class HomeListState implements Cloneable<HomeListState> {

  StoriesType currentStoriesType = StoriesType.topStories;
  HomeListDefaultState homeListDefaultState = HomeListDefaultState();
  ChannelListDefaultState channelListDefaultState = ChannelListDefaultState();
  CruiseSettingState cruiseSettingState = CruiseSettingState();

  @override
  HomeListState clone() {
    return HomeListState()
    ..currentStoriesType = this.currentStoriesType
    ..homeListDefaultState = this.homeListDefaultState
    ..channelListDefaultState = this.channelListDefaultState
    ..cruiseSettingState = this.cruiseSettingState;
  }
}

class HomeListConnector extends ConnOp<HomeState, HomeListState> {
  @override
  HomeListState get(HomeState state) {
    HomeListState subState = state.homeListState.clone();
    return subState;
  }

  @override
  void set(HomeState state, HomeListState subState) {
    state.homeListState = subState;
  }
}


class FavArticleConnector extends ConnOp<FavArticleState, HomeListState> {
  @override
  HomeListState get(FavArticleState state) {
    HomeListState subState = state.homeListState.clone();
    subState.currentStoriesType = state.currentStoriesType;
    return subState;
  }

  @override
  void set(FavArticleState state, HomeListState subState) {
    state.homeListState = subState;
  }
}

class DiscoverConnector extends ConnOp<DiscoverState, HomeListState> {
  @override
  HomeListState get(DiscoverState state) {
    HomeListState substate = state.homeListState.clone();
    substate.currentStoriesType = state.currentStoriesType;
    return substate;
  }

  @override
  void set(DiscoverState state, HomeListState subState) {
    state.homeListState = subState;
  }
}