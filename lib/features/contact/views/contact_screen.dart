import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/features/contact/models/contact_message_model.dart';
import 'package:surdotv_app/features/contact/viewmodels/contact_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<ContactViewModel>();
    await vm.submit(
      ContactMessageModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        message: _messageController.text.trim(),
      ),
    );

    if (!mounted || vm.submissionMessage == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vm.submissionMessage!)),
    );

    if (vm.isSuccess) {
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _cityController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ContactViewModel>();

    return Scaffold(
      appBar: const SurdoLogoAppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Bizimlə Əlaqə',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Təklif, sual və ya iradlarınızı bizimlə paylaşa bilərsiniz.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField(
                    controller: _nameController,
                    hint: 'Ad Soyad',
                    validator: (value) => value.trim().isEmpty
                        ? 'Ad və soyad tələb olunur.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _emailController,
                    hint: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value.trim();
                      if (email.isEmpty) {
                        return 'E-mail tələb olunur.';
                      }
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Düzgün e-mail daxil edin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _phoneController,
                    hint: 'Mobil',
                    keyboardType: TextInputType.phone,
                    validator: (value) => value.trim().isEmpty
                        ? 'Telefon nömrəsi tələb olunur.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _cityController,
                    hint: 'Şəhər',
                    validator: (value) =>
                        value.trim().isEmpty ? 'Şəhər adı tələb olunur.' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _messageController,
                    hint: 'Mesajınız',
                    maxLines: 5,
                    validator: (value) =>
                        value.trim().isEmpty ? 'Mesaj boş ola bilməz.' : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: vm.isSubmitting ? null : _submit,
                      icon: vm.isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                          vm.isSubmitting ? 'Göndərilir...' : 'Mesajı Göndər'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Email: info@surdotv.az',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String value) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) => validator(value ?? ''),
      decoration: InputDecoration(hintText: hint),
    );
  }
}
