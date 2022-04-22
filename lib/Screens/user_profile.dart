import 'package:flutter/material.dart';
import 'package:hello_me/Repositories/ImageUploads.dart';
import 'package:hello_me/Repositories/firebase_repository.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import '../RandomWords.dart';
import '../Repositories/auth_repository.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  final snappingSheetController = SnappingSheetController();

  Widget _profile() {
    return Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const <Widget>[
            Expanded(
              child: ImageUploads(),
            ),
          ],
        ));
    // return ImageUploads();
  }

  Widget _grabbingWidget() {
    return GestureDetector(
      onTap: () {
        if (snappingSheetController.currentSnappingPosition !=
            const SnappingPosition.factor(positionFactor: 0.05)) {
          snappingSheetController.snapToPosition(
            const SnappingPosition.factor(positionFactor: 0.05),
          );
        } else {
          snappingSheetController.snapToPosition(
            const SnappingPosition.factor(positionFactor: 0.3),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                      'Welcome back, ${FirebaseRepository.instance.auth.currentUser?.email}')),
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            ),
            Container(
              child: const Icon(Icons.keyboard_arrow_up),
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
        builder: (ctx, auth, child) => Scaffold(
            body: (!auth.isAuthenticated)
                ? const RandomWords(key: GlobalObjectKey('randomWords'))
                : SnappingSheet(
                    controller: snappingSheetController,
                    child: const RandomWords(key: GlobalObjectKey('randomWords')),
                    grabbingHeight: 75,
                    grabbing: _grabbingWidget(),
                    sheetBelow: SnappingSheetContent(
                      sizeBehavior: SheetSizeStatic(size: 300),
                      draggable: true,
                      child: _profile(),
                    ),
                  )));
  }
}
