import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nidnNimCtrl = TextEditingController();
  final _prodiCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen to tab changes to clear NIP/NIM field
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _nidnNimCtrl.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nidnNimCtrl.dispose();
    _prodiCtrl.dispose();
    _semesterCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isLoading = true);

    try {
      final isLecturer = _tabController.index == 0;
      final user = await _authService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        role: isLecturer ? 'lecturer' : 'student',
        nidn: isLecturer ? _nidnNimCtrl.text.trim() : null,
        nim: !isLecturer ? _nidnNimCtrl.text.trim() : null,
        prodi: !isLecturer ? _prodiCtrl.text.trim() : null,
        semester: !isLecturer ? int.tryParse(_semesterCtrl.text) : null,
      );

      if (!mounted) return;
      
      if (user != null) {
        // Success: Go to Login or Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan Login.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(); // Go back to Login
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.statusAlfa,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: AppSizes.fontDisplay,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan isi data diri Anda untuk mendaftar',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Tab Toggle: Dosen / Mahasiswa
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontMd,
                  ),
                  tabs: const [
                    Tab(text: 'Dosen'),
                    Tab(text: 'Mahasiswa'),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      decoration: const InputDecoration(
                        labelText: AppStrings.name,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppUtils.validateEmail,
                      decoration: const InputDecoration(
                        labelText: AppStrings.email,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    TextFormField(
                      controller: _nidnNimCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty 
                          ? '${_tabController.index == 0 ? "NIDN" : "NIM"} tidak boleh kosong' 
                          : null,
                      decoration: InputDecoration(
                        labelText: _tabController.index == 0 ? AppStrings.nidn : AppStrings.nim,
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                    ),
                    if (_tabController.index == 1) ...[
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _prodiCtrl,
                        validator: (v) => v!.isEmpty ? 'Prodi tidak boleh kosong' : null,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          prefixIcon: Icon(Icons.school_outlined),
                          hintText: 'Contoh: Teknik Informatika',
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _semesterCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Semester tidak boleh kosong' : null,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          prefixIcon: Icon(Icons.calendar_view_day_outlined),
                          hintText: 'Contoh: 5',
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.md),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      validator: AppUtils.validatePassword,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    CustomButton(
                      label: AppStrings.registerButton,
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSizes.md),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(AppStrings.haveAccount),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            AppStrings.login,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
