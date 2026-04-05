import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/screens/home_page_view.dart';

class AlertSystemView extends StatefulWidget {
  const AlertSystemView({super.key});

  @override
  State<AlertSystemView> createState() => _AlertSystemViewState();
}

class _AlertSystemViewState extends State<AlertSystemView> {
  late String email;
  String selectedCondition = 'Rain'; // chip selection
  String selectedSeverity = 'Medium'; // severity button
  bool repeatAlert = true; // toggle
  bool isActive = true; // toggle
  bool showSuccess = false; // success banner
  final List<String> conditions = [
    'Rain',
    'Snow',
    'Storm',
    'Fog',
    'Heat',
    'Wind',
  ];
  final List<String> severities = ['Low', 'Medium', 'High'];

  final cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    email = user?.email ?? '';
  }

  @override
  void dispose() {
    _cityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePageView()),
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ElevatedButton(
          onPressed: _handleSaveAlert,
          child: Text('Save alert'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set weather alert',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 4),
            Text(
              'Get notified when conditions match',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Alert will be sent to $email',
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('City', style: theme.textTheme.titleMedium),
                  SizedBox(height: 8),
                  _buildCityField(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('Condition', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  conditions.map((condition) {
                    return ChoiceChip(
                      label: Text(condition),
                      selected: selectedCondition == condition,
                      onSelected: (selected) {
                        setState(() {
                          selectedCondition = condition;
                        });
                      },
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color:
                            selectedCondition == condition
                                ? Colors.blue.shade800
                                : Colors.grey,
                        fontWeight:
                            selectedCondition == condition
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Severity threshold',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children:
                        severities.map((severity) {
                          // color changes based on severity
                          Color getColor() {
                            if (severity == 'Low') return Colors.green.shade100;
                            if (severity == 'Medium')
                              return Colors.orange.shade100;
                            return Colors.red.shade100;
                          }

                          return ChoiceChip(
                            label: Text(severity),
                            selected: selectedSeverity == severity,
                            onSelected:
                                (_) =>
                                    setState(() => selectedSeverity = severity),
                            selectedColor: getColor(),
                          );
                        }).toList(),
                  ),
                  Divider(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text('Repeat alerts', style: theme.textTheme.titleMedium),
                      Text(
                        'Notify every time condition is met',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Spacer(),

                  CupertinoSwitch(
                    // This bool value toggles the switch.
                    value: repeatAlert,
                    activeTrackColor: CupertinoColors.activeBlue,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        repeatAlert = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text('Active', style: theme.textTheme.titleMedium),
                      Text(
                        'Enable or pause this alert',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Spacer(),
                  CupertinoSwitch(
                    // This bool value toggles the switch.
                    value: isActive,
                    activeTrackColor: CupertinoColors.activeBlue,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future _handleSaveAlert() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('alerts').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'email': email,
      'city': _cityController.text,
      'condition': selectedCondition,
      'severity': selectedSeverity,
      'repeatAlert': repeatAlert,
      'isActive': isActive,
      'createdAt': DateTime.now(),
    });
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: _cityController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface, // ← typed text color
      ),
      decoration: _buildInputDecoration('City', 'Enter your city'),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter the city' : null,
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hintText, {
    Widget? suffixIcon,
  }) {
    final ThemeData theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.hintColor),
      hintText: hintText,
      hintStyle: TextStyle(color: theme.hintColor),

      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
