import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _badgeIdController = TextEditingController(text: 'BADGE-101');
  final _passcodeController = TextEditingController(text: 'OFFICER123');
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  int _selectedTab = 0; // 0 = Citizen, 1 = Officer Portal
  bool _loading = false;
  String? _errorText;
  String _selectedCountryCode = '+91';

  String _getFlag(String code) {
    switch (code) {
      case '+91':
        return '🇮🇳';
      case '+1':
        return '🇺🇸';
      case '+44':
        return '🇬🇧';
      default:
        return '🌐';
    }
  }

  String? _validatePhone(String? value) {
    if (_selectedTab != 0) return null;
    final digits = (value ?? '').trim();
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length < 7 || digits.length > 12) return 'Enter a valid phone number';
    return null;
  }

  Future<void> _sendOtp() async {
    setState(() => _errorText = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';

    await _authService.sendOtp(
      phone: phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              verificationId: verificationId,
              phoneDisplay: phone,
              isOfficerMode: _selectedTab == 1,
            ),
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorText = error.toString();
        });
      },
    );
  }

  Future<void> _loginWithOfficerBadge() async {
    setState(() => _errorText = null);
    final badgeId = _badgeIdController.text.trim();
    final passcode = _passcodeController.text.trim();

    if (badgeId.isEmpty) {
      setState(() => _errorText = 'Please enter your Officer Badge ID');
      return;
    }
    if (passcode.isEmpty) {
      setState(() => _errorText = 'Please enter your Department Passcode');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signInWithOfficerBadge(
        badgeId: badgeId,
        passcode: passcode,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _signInDemoRole(String role) async {
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await _authService.signInAsDemoRole(role: role);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await _authService.signInAnonymouslyCitizen();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _badgeIdController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Top Shield Circular Badge
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF281E23),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryCoral.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _selectedTab == 1 ? Icons.local_police_outlined : Icons.shield_outlined,
                      color: AppColors.primaryCoral,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title & Subtitle
                Text(
                  _selectedTab == 1 ? 'Officer Verification' : 'Secure Civic Access',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedTab == 1
                      ? 'Authorized Law Enforcement Portal'
                      : 'Verify identity to report or access civic safety tools',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Role Tab Bar (Citizen Portal vs Officer Portal)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedTab = 0;
                            _errorText = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? AppColors.surfaceElevated : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: _selectedTab == 0
                                  ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.4))
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: _selectedTab == 0 ? AppColors.primaryCoral : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Citizen Portal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedTab == 0 ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedTab = 1;
                            _errorText = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? AppColors.surfaceElevated : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: _selectedTab == 1
                                  ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.4))
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 18,
                                  color: _selectedTab == 1 ? AppColors.primaryCoral : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Officer Portal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedTab == 1 ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content View based on Selected Tab
                if (_selectedTab == 0) ...[
                  // CITIZEN TAB: PHONE NUMBER INPUT
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PHONE NUMBER',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _phoneController.text = '9999999999';
                                setState(() => _errorText = null);
                              },
                              child: const Text(
                                'Use Test Number',
                                style: TextStyle(
                                  color: AppColors.primaryCoral,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F202A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Row(
                                children: [
                                  Text(_getFlag(_selectedCountryCode), style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  DropdownButton<String>(
                                    value: _selectedCountryCode,
                                    underline: const SizedBox(),
                                    isDense: true,
                                    dropdownColor: AppColors.surfaceElevated,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: '+91', child: Text('+91')),
                                      DropdownMenuItem(value: '+1', child: Text('+1')),
                                      DropdownMenuItem(value: '+44', child: Text('+44')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCountryCode = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F202A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _errorText != null
                                        ? AppColors.criticalRed
                                        : AppColors.surfaceBorder,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    hintText: '98765 43210',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 15,
                                    ),
                                  ),
                                  validator: _validatePhone,
                                  onChanged: (_) {
                                    if (_errorText != null) {
                                      setState(() => _errorText = null);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCoral,
                        foregroundColor: AppColors.onCoralText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(AppColors.onCoralText),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Send OTP Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Anonymous Sign In Option
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _signInAnonymously,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.incognito, size: 18, color: AppColors.textSecondary),
                    label: const Text(
                      'Continue Anonymously (Quick Report)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                  ),
                ] else ...[
                  // OFFICER TAB: BADGE ID & PASSCODE
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OFFICER BADGE ID',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _badgeIdController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15.5),
                          decoration: InputDecoration(
                            hintText: 'e.g. BADGE-101',
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryCoral, size: 20),
                            filled: true,
                            fillColor: const Color(0xFF1F202A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'DEPARTMENT PASSCODE',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passcodeController,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15.5),
                          decoration: InputDecoration(
                            hintText: 'Passcode (Demo: OFFICER123)',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryCoral, size: 20),
                            filled: true,
                            fillColor: const Color(0xFF1F202A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Standard demo passcode is OFFICER123',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _loginWithOfficerBadge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCoral,
                        foregroundColor: AppColors.onCoralText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(AppColors.onCoralText),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Access Officer Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],

                if (_errorText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.criticalRed.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.criticalRed,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ⚡ QUICK DEMO MODE SWITCHER BAR
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1F28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bolt, color: AppColors.highPriorityAmber, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Demo Quick Access (No OTP Required)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading ? null : () => _signInDemoRole('citizen'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.surfaceBorder),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person, size: 16, color: AppColors.textPrimary),
                                  SizedBox(width: 6),
                                  Text('Demo Citizen', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading ? null : () => _signInDemoRole('officer'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primaryCoral.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_police, size: 16, color: AppColors.primaryCoral),
                                  SizedBox(width: 6),
                                  Text('Demo Officer', style: TextStyle(color: AppColors.primaryCoral, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Footer Links: Privacy Policy • Help Center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primaryCoral,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '•',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Help Center',
                        style: TextStyle(
                          color: AppColors.primaryCoral,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}