import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/auth/auth_controller.dart';
import '../../../../database/group/invitation/invitation_controller.dart';
import '../../../../database/user/user.dart';
import '../../../../database/user/user_controller.dart';
import '../../../../validation/validation.dart';

class GroupInvitationLink {
  GroupInvitationLink._internal();
  static final GroupInvitationLink _instance = GroupInvitationLink._internal();
  static GroupInvitationLink get instance => _instance;

  static Future<String?> readGroupInvitationLink(String groupId) async {
    try {
      final invitationData = await GroupInvitationController.create(groupId);
      final invitationLink = invitationData.invitationLink;
      return invitationLink;
    } on FirebaseException catch (e) {
      throw Exception('Failed to read invitation link. $e');
    }
  }
}

final memberAddProvider = StateNotifierProvider<MemberAddData, UserProfile?>(
  (ref) => MemberAddData(),
);

class MemberAddData extends StateNotifier<UserProfile?> {
  MemberAddData() : super(null) {
    accountIdController.addListener(accountDataController);
  }

  TextEditingController accountIdController = TextEditingController();
  List<UserProfile>? users;
  UserProfile? user;
  String? username;
  String? userImage;
  String? userDescription;

  void resetState() {
    accountIdController.text = '';
    state = null;
  }

  Future<void> accountDataController() async {
    await accountIdLengthChecker();
    await memberAddController();
  }

  Future<String?> accountIdLengthChecker() async {
    final accountId = accountIdController.text;
    const maxLength64Validation = MaxLength64Validation();

    final accountIdMaxLength64Validation = maxLength64Validation.validate(
      accountId,
      'accountId',
    );
    if (accountIdMaxLength64Validation) {
      return null;
    }
    return 'Maximum length is 64 characters.';
  }

  Future<void> memberAddController() async {
    final myDocId = await AuthController.getCurrentUserId();
    final myAccount = await UserController.read(myDocId!);

    final accountId = accountIdController.text;
    users = await UserController.readWithAccountId(accountId);

    //アカウントIDが見つからない場合は、nullを返す。
    if (users!.isEmpty) {
      username = null;
      userImage = null;
      userDescription = null;
      state = null;
    } else {
      user = users!.first;
      //自分のアカウントを検索した場合は、何も返さない。
      if (myAccount.accountId != user!.accountId) {
        username = user!.name;
        userImage = user!.image;
        userDescription = user!.description;
        state = user;
      }
    }
  }
}
