import 'package:flutter/material.dart';
import 'package:expensemate/features/user/widgets/user_text_field.dart';
import 'package:expensemate/features/user/widgets/primary_button.dart';
import 'package:expensemate/core/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    return null;
  }

  String? _validateNew(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value != _newController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    setState(() => _loading = true);
    final success = await AuthService().changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                UserTextField(
                  controller: _currentController,
                  label: 'Current password',
                  hint: '••••••••',
                  obscureText: !_showCurrent,
                  validator: _validateRequired,
                  textInputAction: TextInputAction.next,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _showCurrent = !_showCurrent),
                    child: Text(_showCurrent ? 'Hide' : 'Show',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                UserTextField(
                  controller: _newController,
                  label: 'New password',
                  hint: '••••••••',
                  obscureText: !_showNew,
                  validator: _validateNew,
                  textInputAction: TextInputAction.next,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _showNew = !_showNew),
                    child: Text(_showNew ? 'Hide' : 'Show',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                UserTextField(
                  controller: _confirmController,
                  label: 'Confirm new password',
                  hint: '••••••••',
                  obscureText: !_showConfirm,
                  validator: _validateConfirm,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    child: Text(_showConfirm ? 'Hide' : 'Show',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Save', isLoading: _loading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
