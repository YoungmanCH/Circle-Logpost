import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/components/user_setting/sections/group_section/components/components/user_joined_group_tile.dart';

import '../providers/group/group/listen_joined_group_profile_provider.dart';

final joinedGroupListNotifierProvider =
    StateNotifierProvider<_JoinedGroupListNotifier, List<Widget>>(
  _JoinedGroupListNotifier.new,
);

class _JoinedGroupListNotifier extends StateNotifier<List<Widget>> {
  _JoinedGroupListNotifier(this.ref) : super([]) {
    _fetchGroupProfiles();
  }

  final Ref ref;

  Future<void> _fetchGroupProfiles() async {
    final groupsProfile =
        await ref.watch(listenJoinedGroupIdListProvider.future);
    state = _buildUserJoinedGroupTileList(groupsProfile);
  }

  List<Widget> _buildUserJoinedGroupTileList(List<String> groupProfiles) {
    return groupProfiles.map((groupId) {
      return UserJoinedGroupTile(groupId: groupId);
    }).toList();
  }
}
