import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../core/navigation/route_names.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  String _nationalId = '';
  String _registryNumber = '';
  String _employeeNumber = '';
  String _specialization = '';
  String _hireDate = '';
  String _employmentType = '';
  String _email = '';
  final ImagePicker _picker = ImagePicker();
  XFile? _avatarFile;
  String? _avatarUrl;
  bool _loadingProfile = false;
  bool _isSaving = false;
  Map<String, String?> _fieldErrors = {};
  bool _saveSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  String? _initialsFromName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

    Future<void> _loadProfile() async {
    final authCubit = context.read<AuthCubit>();
    final token = authCubit.sessionToken;

    if (token == null || token.isEmpty) return;

    setState(() => _loadingProfile = true);

    try {
      final authRepo = RepositoryProvider.of<AuthRepository>(context);
      final profile = await authRepo.fetchProfile(token);

      if (!mounted) return;

      final data = profile['data'] is Map<String, dynamic>
        ? profile['data'] as Map<String, dynamic>
        : <String, dynamic>{};
      final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};
      final teacher = user['teacher'] is Map<String, dynamic>
        ? user['teacher'] as Map<String, dynamic>
        : <String, dynamic>{};

      setState(() {
        _nameController.text = user['name']?.toString() ?? '';
        _roleController.text = user['role']?.toString() ?? '';
        _emailController.text = user['email']?.toString() ?? '';
        _email = user['email']?.toString() ?? '';
        _phoneController.text = teacher['phone_alt']?.toString() ??
            user['phone']?.toString() ??
            '';
        _addressController.text = teacher['address']?.toString() ?? '';
        _experienceController.text = teacher['experience_years']?.toString() ?? '';
        _nationalId = teacher['national_id']?.toString() ?? '';
        _registryNumber = teacher['registry_number']?.toString() ?? '';
        _employeeNumber = teacher['employee_number']?.toString() ?? '';
        _specialization = teacher['specialization']?.toString() ??
            user['role']?.toString() ??
            '';
        _hireDate = teacher['hire_date']?.toString() ?? '';
        _employmentType = teacher['employment_type']?.toString() ?? '';
        _avatarUrl = _resolveAvatarUrl(user['avatar']?.toString());
        _avatarFile = null;
        _fieldErrors.clear();
      });
    } catch (e) {
      if (!mounted) return;

      showAppFeedback(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final trimmedEmail = _emailController.text.trim();
    final trimmedAddress = _addressController.text.trim();
    final trimmedPhone = _phoneController.text.trim();
    final trimmedExperience = _experienceController.text.trim();
    final data = <String, dynamic>{
      'email': trimmedEmail,
      'address': trimmedAddress,
      if (trimmedPhone.isNotEmpty) 'phone_alt': trimmedPhone,
      if (trimmedExperience.isNotEmpty)
        'experience_years': int.tryParse(trimmedExperience),
    };

    setState(() {
      _isSaving = true;
      _fieldErrors.clear();
    });

    try {
      await context.read<AuthCubit>().updateProfile(
            data,
            avatarPath: _avatarFile?.path,
          );
      await _loadProfile();
      if (!mounted) return;
      setState(() {
        _saveSuccess = true;
        _isEditing = false;
      });
      showAppFeedback(context, message: 'تم حفظ المعلومات بنجاح', isError: false);
      // clear success indicator after short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _saveSuccess = false);
      });
    } catch (error) {
      if (!mounted) return;
      showAppFeedback(context, message: error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  void _onLogout() {
    context.read<AuthCubit>().logout();
  }

  String? _resolveAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return avatarPath;
    }

    final baseUrl = ApiClient().baseUrl;
    if (avatarPath.startsWith('/')) {
      return '$baseUrl$avatarPath';
    }
    return '$baseUrl/$avatarPath';
  }

  Future<void> _editAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _avatarFile = picked;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppFeedback(
        context,
        message: 'فشل اختيار الصورة: ${error.toString()}',
        isError: true,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الملف الشخصي',
      currentIndex: 0,
      actions: [
        IconButton(
          onPressed: _onLogout,
          icon: const Icon(Icons.logout),
          tooltip: 'تسجيل الخروج',
        ),
      ],
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            if (!mounted) {
              return;
            }
            Navigator.pushReplacementNamed(context, RouteNames.login);
            return;
          }

          if (state is AuthValidationFailure) {
            // show inline validation errors
            final errors = state.errors;
            if (!mounted) return;
            setState(() {
              _fieldErrors = errors.map((key, val) {
                if (val is List && val.isNotEmpty) return MapEntry(key, val.first.toString());
                return MapEntry(key, val?.toString());
              });
            });
            return;
          }

          if (state is AuthFailure) {
            showAppFeedback(context, message: state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoggingOut = state is AuthLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // header row: title + avatar
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الملف الشخصي',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'قم بتحديث بياناتك الوظيفية وتابع أداء الصف بسهولة.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Hero(
                        tag: 'teacher-avatar',
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _editAvatar,
                                borderRadius: BorderRadius.circular(80),
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.12),
                                  child: _avatarFile != null
                                      ? ClipOval(
                                          child: Image.file(
                                            File(_avatarFile!.path),
                                            width: 92,
                                            height: 92,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (_avatarUrl != null
                                          ? ClipOval(
                                              child: Image.network(
                                                _avatarUrl!,
                                                width: 92,
                                                height: 92,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 92,
                                                    height: 92,
                                                    color: AppColors.surfaceVariant,
                                                    child: Center(
                                                      child: Text(
                                                        _initialsFromName(_nameController.text) ?? 'م',
                                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                              fontWeight: FontWeight.w700,
                                                              color: AppColors.onSurface,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 40,
                                              backgroundColor: AppColors.surfaceVariant,
                                              child: Text(
                                                _initialsFromName(_nameController.text) ?? '',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.onSurface,
                                                    ),
                                              ),
                                            )),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: AppColors.secondary,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: _editAvatar,
                                  customBorder: const CircleBorder(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.person,
                          label: 'الاسم',
                          value: _nameController.text,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.school,
                          label: 'التخصص',
                          value: _roleController.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            if (_loadingProfile)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Container(height: 16, width: double.infinity, color: AppColors.surfaceVariant),
                      const SizedBox(height: AppSpacing.sm),
                      Container(height: 12, width: double.infinity, color: AppColors.surfaceVariant),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        Expanded(child: Container(height: 80, color: AppColors.surfaceVariant)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Container(height: 80, color: AppColors.surfaceVariant)),
                      ])
                    ],
                  ),
                ),
              ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),

              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        const Text('معلومات الوظيفة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3.2,
                      children: [
                        _ProfileDetailTile(icon: Icons.badge_outlined, label: 'الرقم الوطني', value: _nationalId.isNotEmpty ? _nationalId : 'غير متوفر'),
                        _ProfileDetailTile(icon: Icons.work_outline, label: 'رقم التوظيف', value: _employeeNumber.isNotEmpty ? _employeeNumber : 'غير متوفر'),
                        _ProfileDetailTile(icon: Icons.app_registration_outlined, label: 'رقم التسجيل', value: _registryNumber.isNotEmpty ? _registryNumber : 'غير متوفر'),
                        _ProfileDetailTile(icon: Icons.phone_android_outlined, label: 'رقم الهاتف', value: _phoneController.text.isNotEmpty ? _phoneController.text : 'غير متوفر'),
                        _ProfileDetailTile(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: _email.isNotEmpty ? _email : 'غير متوفر'),
                        _ProfileDetailTile(icon: Icons.calendar_today_outlined, label: 'تاريخ التعيين', value: _hireDate.isNotEmpty ? _hireDate : 'غير محدد'),
                        _ProfileDetailTile(icon: Icons.location_on_outlined, label: 'العنوان', value: _addressController.text.isNotEmpty ? _addressController.text : 'غير محدد'),
                        _ProfileDetailTile(icon: Icons.timeline_outlined, label: 'سنوات الخبرة', value: _experienceController.text.isNotEmpty ? _experienceController.text : 'غير محددة'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.work_history_outlined, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'سنوات الخبرة: ${_experienceController.text.isNotEmpty ? _experienceController.text : 'غير محددة'}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            _isEditing ? _buildEditSection() : _buildActionSection(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      if (isLoggingOut)
        Container(
          color: Colors.black.withValues(alpha: 0.08),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      if (_loadingProfile)
        Container(
          color: Colors.black.withValues(alpha: 0.04),
          child: const Center(child: CircularProgressIndicator()),
        ),
      if (_isSaving)
        Container(
          color: Colors.black.withValues(alpha: 0.04),
          child: const Center(child: CircularProgressIndicator()),
        ),
    ],
  );
},
),
);
}

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _toggleEdit,
          icon: const Icon(Icons.edit),
          label: const Text('تعديل الملف الشخصي'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('تسجيل الخروج'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: AppColors.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildEditSection() {
    return Form(
      key: _formKey,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('تعديل المعلومات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'الوظيفة / التخصص',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                onChanged: (v) => setState(() => _fieldErrors.remove('email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'الرجاء إدخال البريد الإلكتروني';
                  if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(value!.trim())) {
                    return 'البريد الإلكتروني غير صالح';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: const OutlineInputBorder(),
                  errorText: _fieldErrors['email'],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                onChanged: (v) => setState(() => _fieldErrors.remove('phone_alt')),
                decoration: InputDecoration(
                  labelText: 'الهاتف',
                  border: const OutlineInputBorder(),
                  errorText: _fieldErrors['phone_alt'],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.trim().isEmpty ?? true ? 'الرجاء إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _addressController,
                onChanged: (v) => setState(() => _fieldErrors.remove('address')),
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: const OutlineInputBorder(),
                  errorText: _fieldErrors['address'],
                ),
                validator: (value) => value?.trim().isEmpty ?? true ? 'الرجاء إدخال العنوان' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _experienceController,
                onChanged: (v) => setState(() => _fieldErrors.remove('experience_years')),
                decoration: InputDecoration(
                  labelText: 'سنوات الخبرة',
                  border: const OutlineInputBorder(),
                  errorText: _fieldErrors['experience_years'],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'الرجاء إدخال سنوات الخبرة';
                  if (int.tryParse(value!.trim()) == null) return 'اكتب رقماً صالحاً';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _isSaving
                          ? 'جارٍ الحفظ...'
                          : (_saveSuccess ? 'تم' : 'حفظ التعديل'),
                      onPressed: _isSaving ? () {} : _saveProfile,
                      icon: _isSaving
                          ? Icons.hourglass_top
                          : (_saveSuccess ? Icons.check : Icons.save),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleEdit,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('إلغاء'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

