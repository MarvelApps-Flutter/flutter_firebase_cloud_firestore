import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_app/constants/app_constants.dart';
import 'package:firestore_app/screens/add_user_screen.dart';
import 'package:firestore_app/utils/app_text_styles.dart';
import 'package:firestore_app/utils/trapezium_clipper_decoration.dart';
import 'package:flutter/material.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  State<HomeScreenPage> createState() => _MyHomeScreenPageState();
}

class _MyHomeScreenPageState extends State<HomeScreenPage> {
  TextEditingController? movieController;
  var reference;

  init()
  {
    movieController = TextEditingController();
    reference = FirebaseFirestore.instance.collection(AppConstants.userListString);
  }
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
        floatingActionButton: buildFloatingButton());
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: reference.snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  snapshot.hasData == true ? snapshot.data!.docs.length : 0,
              itemBuilder: (context, index) {
                DocumentSnapshot snap = snapshot.data!.docs[index];
                return buildItem(user: snap);
              });
        },
      ),
    );
  }

  Widget buildFloatingButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFff4f5a),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            return const AddUserScreen(isViewMode: false);
          }),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget buildItem({DocumentSnapshot? user}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                alignment: Alignment.topLeft,
                height: 120.0,
                width: 100.0,
                decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5.0)
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    image: DecorationImage(
                        image: AssetImage(AppConstants.displayAssetImageString),
                        fit: BoxFit.fill)),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 7.0, left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${user![AppConstants.nameString]!}".replaceFirst(
                              user[AppConstants.nameString][0], user[AppConstants.nameString][0].toUpperCase()),
                          style: AppTextStyles.boldColoredTextStyle,
                        ),
                      ),
                      buildCrud(user),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${user[AppConstants.contactNumberString]!}",
                          style: AppTextStyles.lightTextStyle,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${user[AppConstants.emailString]!}",
                          style: AppTextStyles.lightTextStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 170,
                    child: Text(
                      "${user[AppConstants.ageString]!}",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.lightTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [trapeziumClippers(context, user[AppConstants.dobString])],
                      ),
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget buildCrud(DocumentSnapshot? user) {
    return Container(
      alignment: Alignment.bottomRight,
      child: InkResponse(
        onTap: () {},
        child: PopupMenuButton(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
             AppConstants.bulletAssetImageString,
              //color: Colors.red,
              height: 20,
              width: 24,
            ),
          ),
          onSelected: (choose) async {
            if (choose == AppConstants.viewString) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddUserScreen(userKey: user!.id, isViewMode: true)));
            } else if (choose == AppConstants.editString) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddUserScreen(userKey: user!.id, isViewMode: false)));
            } else if (choose == AppConstants.deleteString) {
              _showDeleteDialog(user: user);
            }
          },
          itemBuilder: (context) {
            return popUpMenuDialog();
          },
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> popUpMenuDialog()
  {
    return <PopupMenuEntry<String>>[
      PopupMenuItem(
          value: AppConstants.viewString,
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(
                  Icons.remove_red_eye,
                  size: 17,
                ),
              ),
              Text(AppConstants.viewString)
            ],
          )),
      PopupMenuItem(
          value: AppConstants.editString,
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(
                  Icons.edit,
                  size: 17,
                ),
              ),
              Text(AppConstants.editString)
            ],
          )),
      PopupMenuItem(
          value: AppConstants.deleteString,
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(
                  Icons.delete,
                  size: 17,
                ),
              ),
              Text(AppConstants.deleteString)
            ],
          ))
    ];
  }

  _showDeleteDialog({DocumentSnapshot? user}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              '${AppConstants.deleteString} ${user![AppConstants.nameString]}',
              style: AppTextStyles.mediumTextStyle,
            ),
            content: const Text(
             AppConstants.deleteConfirmationMessageString,
              style: AppTextStyles.lightTextStyle,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    AppConstants.cancelString,
                    style: AppTextStyles.regularForSmallTextStyle,
                  )),
              TextButton(
                  onPressed: () {
                    reference
                        .doc(user.id)
                        .delete()
                        .whenComplete(() => Navigator.pop(context));
                  },
                  child: const Text(
                    AppConstants.deleteString,
                    style: AppTextStyles.regularForSmallTextStyle,
                  ))
            ],
          );
        });
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      title: const Text(
       AppConstants.manageUsersString,
        style: AppTextStyles.regularForLargeTextStyle,
      ),
    );
  }
}
