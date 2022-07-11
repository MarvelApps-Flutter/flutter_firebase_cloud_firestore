import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_app/constants/app_constants.dart';
import 'package:firestore_app/mixins/validate_mixins.dart';
import 'package:firestore_app/share/reusable_widgets.dart';
import 'package:firestore_app/utils/app_config.dart';
import 'package:firestore_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddUserScreen extends StatefulWidget {
  final String? userKey;
  final bool? isViewMode;
  const AddUserScreen({Key? key, this.userKey, this.isViewMode})
      : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen>
    with InputValidationMixin {
  late AppConfig appC;
  GlobalKey<FormState>? formGlobalKey;
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _contactNumberController;
  TextEditingController? _ageController;
  TextEditingController? _dobController;
  var reference;
  Map<int, Color>? color;

  DateTime _currentDate = DateTime.now();
  Future _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
      builder: (BuildContext? context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(0xFFff4f5a, color!),
              primaryColorDark: Color(0xFFff4f5a),
              accentColor: Color(0xFFff4f5a),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _currentDate) {
      setState(() {
        _currentDate = picked;
        formatDate();
      });
    }
  }

  void formatDate() {
    final DateFormat formatter = DateFormat(AppConstants.dateFormatString);
    final String formatted = formatter.format(_currentDate);
    print(formatted);
    _dobController!.value = TextEditingValue(text: formatted);
  }

  init() {
    formGlobalKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _contactNumberController = TextEditingController();
    _ageController = TextEditingController();
    _dobController = TextEditingController();
    reference =
        FirebaseFirestore.instance.collection(AppConstants.userListString);
    color = {
      50: const Color(0xFFff4f5a),
      100: const Color(0xFFff4f5a),
      200: const Color(0xFFff4f5a),
      300: const Color(0xFFff4f5a),
      400: const Color(0xFFff4f5a),
      500: const Color(0xFFff4f5a),
      600: const Color(0xFFff4f5a),
      700: const Color(0xFFff4f5a),
      800: const Color(0xFFff4f5a),
      900: const Color(0xFFff4f5a),
    };
    if (widget.userKey != null) {
      getUserDetail();
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appC = AppConfig(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(),
        body: buildBody());
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      title: Text(
          (widget.isViewMode) == true
              ? AppConstants.viewUserString
              : (widget.isViewMode == false && widget.userKey != null)
                  ? AppConstants.editUserString
                  : AppConstants.createUserString,
          style: AppTextStyles.blackTextStyle),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios),
        iconSize: 24,
        color: Colors.black,
      ),
    );
  }

  Widget buildBody() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Form(
              key: formGlobalKey,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: appC.rH(22),
                          width: appC.rW(50),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage(AppConstants.headerAssetImageString),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        buildSizedBoxWidget(10),
                        // Text(
                        //     (widget.isViewMode) == true ? AppConstants.viewUserString : (widget.isViewMode == false && widget.userKey != null) ? AppConstants.editUserString : AppConstants.createUserString,
                        //     style: AppTextStyles.blackTextStyle),
                        //buildSizedBoxWidget(13),
                        const Text(
                          AppConstants.enterDetailsString,
                          style: AppTextStyles.lightTextStyle,
                        ),
                        buildSizedBoxWidget(15),
                        buildNameTextField(),
                        buildSizedBoxWidget(10),
                        buildEmailTextField(),
                        buildSizedBoxWidget(10),
                        buildContactNumberTextField(),
                        buildSizedBoxWidget(10),
                        buildAgeTextField(),
                        buildSizedBoxWidget(10),
                        buildDueDateTextField(),
                        buildSizedBoxWidget(100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 widget.isViewMode == false
                  ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: buildButtonWidget(
                        context,
                        widget.userKey != null
                            ? AppConstants.bigUpdateString
                            : AppConstants.bigCreateString, () {
                        if (formGlobalKey!.currentState!.validate()) {
                          if (_emailController!.text.toString().trim().length !=
                                  0 &&
                              _nameController!.text.toString().trim().length != 0 &&
                              _contactNumberController!.text
                                      .toString()
                                      .trim()
                                      .length !=
                                  0) {
                            if (widget.userKey != null) {
                              updateUser();
                            } else {
                              saveUser();
                            }
                          }
                        }
                      }),
                  )
                  : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNameTextField() {
    return TextFormField(
      controller: _nameController,
      cursorColor: Colors.black,
      readOnly: widget.isViewMode == true ? true : false,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        labelText: AppConstants.enterNameString,
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.3),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none)),
      ),
      validator: (name) {
        if (name!.isNotEmpty) {
          return null;
        } else {
          return AppConstants.enterAssigneeString;
        }
      },
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      cursorColor: Colors.black,
      readOnly: widget.isViewMode == true ? true : false,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.mail,
          color: Colors.grey,
        ),
        labelText: AppConstants.enterEmailString,
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.3),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none)),
      ),
      validator: (email) {
        if (isEmailValid(email!)) {
          return null;
        } else {
          return AppConstants.enterValidEmailString;
        }
      },
    );
  }

  Widget buildContactNumberTextField() {
    return TextFormField(
      controller: _contactNumberController,
      cursorColor: Colors.black,
      readOnly: widget.isViewMode == true ? true : false,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.phone,
          color: Colors.grey,
        ),
        labelText: AppConstants.enterContactNumberString,
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.3),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none)),
      ),
      validator: (number) {
        if (isPhoneNumberValid(number!)) {
          return null;
        } else {
          return AppConstants.enterValidContactNumberString;
        }
      },
    );
  }

  Widget buildAgeTextField() {
    return TextFormField(
      controller: _ageController,
      cursorColor: Colors.black,
      readOnly: widget.isViewMode == true ? true : false,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.add,
          color: Colors.grey,
        ),
        labelText: AppConstants.enterAgeString,
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.3),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none)),
      ),
      validator: (number) {
        if (number!.isNotEmpty) {
          return null;
        } else {
          return AppConstants.enterAgeString;
        }
      },
    );
  }

  Widget buildDueDateTextField() {
    return widget.isViewMode == false
        ? TextFormField(
            controller: _dobController,
            onTap: () async {
              await _selectDueDate(context);
              FocusScope.of(context).requestFocus(FocusNode());
            },
            cursorColor: Colors.black,
            autofocus: false,
            readOnly: true,
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.black.withOpacity(0.9)),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Colors.grey,
              ),
              labelText: AppConstants.enterDateOfBirthString,
              labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.grey.withOpacity(0.3),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(width: 0, style: BorderStyle.none)),
            ),
          )
        : TextFormField(
            controller: _dobController,
            cursorColor: Colors.black,
            readOnly: true,
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.black.withOpacity(0.9)),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Colors.grey,
              ),
              labelText: AppConstants.enterDateOfBirthString,
              labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.grey.withOpacity(0.3),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(width: 0, style: BorderStyle.none)),
            ),
          );
  }

  void saveUser() {
    Map<String, String> data = {
      AppConstants.nameString: _nameController!.text.toString().trim(),
      AppConstants.emailString: _emailController!.text.toString().trim(),
      AppConstants.contactNumberString:
          _contactNumberController!.text.toString().trim(),
      AppConstants.ageString: _ageController!.text.toString().trim(),
      AppConstants.dobString: _dobController!.text.toString().trim()
    };

    reference.add(data).then((value) {
      Navigator.pop(context);
    });
  }

  getUserDetail() async {
    DocumentSnapshot snapshot = await reference.doc(widget.userKey).get();

    _nameController!.text = snapshot[AppConstants.nameString];
    _contactNumberController!.text = snapshot[AppConstants.contactNumberString];
    _emailController!.text = snapshot[AppConstants.emailString];
    _ageController!.text = snapshot[AppConstants.ageString];
    _dobController!.text = snapshot[AppConstants.dobString];
  }

  void updateUser() {
    Map<String, String> data = {
      AppConstants.nameString: _nameController!.text.toString().trim(),
      AppConstants.emailString: _emailController!.text.toString().trim(),
      AppConstants.contactNumberString:
          _contactNumberController!.text.toString().trim(),
      AppConstants.ageString: _ageController!.text.toString().trim(),
      AppConstants.dobString: _dobController!.text.toString().trim()
    };

    reference.doc(widget.userKey!).update(data).then((value) {
      Navigator.pop(context);
    });
  }
}
