// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mslr/domain/services/referendum_services.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/helpers/modal_loading.dart';
import 'package:mslr/presentation/helpers/show_message.dart';
import 'package:mslr/presentation/helpers/validate_form.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class CreateReferendumScreen extends StatefulWidget {
  const CreateReferendumScreen({super.key});

  @override
  State<CreateReferendumScreen> createState() => _CreateReferendumScreenState();
}

class _CreateReferendumScreenState extends State<CreateReferendumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  late FormValidators _validators;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _validators = FormValidators(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    } else {
      ShowMessage.error(context, 'Minimum 2 options required');
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check for duplicate options
    final options = _optionControllers.map((c) => c.text.trim()).toList();
    final uniqueOptions = options.toSet();
    if (options.length != uniqueOptions.length) {
      ShowMessage.error(context, 'Duplicate options are not allowed');
      return;
    }

    LoadingModal.show(context, message: 'Creating referendum...');

    final result = await referendumService.createReferendum(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      options: options,
    );

    LoadingModal.dismiss(context);

    if (mounted) {
      if (result['success']) {
        ShowMessage.success(context, 'Referendum created successfully');
        Navigator.pop(context, true);
      } else {
        ShowMessage.error(context, result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsCustom.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsCustom.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextCustom(
          text: 'Create New Referendum',
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 28),
            _buildOptionsSection(),
            const SizedBox(height: 32),
            _buildCreateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsCustom.secondaryColor.withOpacity(0.1),
            ColorsCustom.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorsCustom.secondaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsCustom.secondaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: ColorsCustom.secondaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextCustom(
                  text: 'Important Information',
                  fontSize: 15,
                  color: ColorsCustom.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.lock_clock,
            'Referendum will be created as closed',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.lock_open,
            'You can open it later from the dashboard',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.edit_off,
            'Once opened, details become read-only',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ColorsCustom.secondaryColor.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextCustom(
            text: text,
            fontSize: 13,
            color: ColorsCustom.secondaryColor.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextCustom(
          text: 'Referendum Title',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter a clear and descriptive title',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.title_rounded,
                color: ColorsCustom.primaryColor,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 15),
            validator: _validators.referendumTitleValidator.call,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextCustom(
          text: 'Description',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Provide detailed information about the referendum',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.description_outlined,
                color: ColorsCustom.primaryColor,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            maxLines: 5,
            style: const TextStyle(fontSize: 15),
            validator: _validators.referendumDescriptionValidator.call,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextCustom(
              text: 'Referendum Options',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorsCustom.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextCustom(
                text: '${_optionControllers.length} options',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorsCustom.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextCustom(
          text: 'Minimum 2 options required',
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 16),
        ..._optionControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return _buildOptionField(index, controller);
        }),
        const SizedBox(height: 12),
        _buildAddOptionButton(),
      ],
    );
  }

  Widget _buildOptionField(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Enter option ${index + 1}',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorsCustom.primaryColor,
                  ColorsCustom.primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: TextCustom(
                text: '${index + 1}',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          suffixIcon: _optionControllers.length > 2
              ? IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: ColorsCustom.errorColor,
                  ),
                  onPressed: () => _removeOption(index),
                  tooltip: 'Remove option',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(fontSize: 14),
        validator: _validators.referendumOptionValidator.call,
      ),
    );
  }

  Widget _buildAddOptionButton() {
    return InkWell(
      onTap: _addOption,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ColorsCustom.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ColorsCustom.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: ColorsCustom.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            const TextCustom(
              text: 'Add Another Option',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ColorsCustom.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleCreate,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsCustom.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 22),
            SizedBox(width: 10),
            TextCustom(
              text: 'Create Referendum',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
