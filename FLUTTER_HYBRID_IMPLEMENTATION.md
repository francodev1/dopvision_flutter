# 🎨 Guia Completo: UI Híbrida (Material 3 + Cupertino)

> **Implementação do melhor dos dois mundos para DoPVision**

---

## 🏆 **ESTRATÉGIA HÍBRIDA**

### **O que vamos usar:**

✅ **Material Design 3** para:
- Estrutura base (Scaffold, AppBar)
- Sistema de theme
- Componentes complexos (DataTable, Drawer)
- Navegação
- Dialogs e Modals

✅ **Cupertino** para:
- Buttons (mais elegantes)
- TextFields (look iOS)
- Switches, Sliders
- Navigation Bar (quando adequado)
- Context Menus
- Pickers

✅ **Adaptive Widgets** para:
- Detectar plataforma automaticamente
- iOS = Cupertino
- Android/Web = Material
- macOS = Cupertino

---

## 📦 **1. Dependências Necessárias**

### **pubspec.yaml**

```yaml
name: dopvision_flutter
description: DoPVision - UI Híbrida Premium
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.8
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Navigation
  go_router: ^14.6.2
  
  # UI Híbrida
  cupertino_icons: ^1.0.8        # Ícones iOS
  google_fonts: ^6.3.2           # Typography
  flutter_platform_widgets: ^7.0.1  # Widgets adaptativos
  
  # Charts
  fl_chart: ^0.69.2
  
  # Utils
  intl: ^0.20.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## 🎨 **2. Theme Híbrido (Material + Cupertino)**

### **lib/shared/theme/hybrid_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class HybridTheme {
  // Cores compartilhadas
  static const Color primary = Color(0xFF6366F1);        // Indigo
  static const Color secondary = Color(0xFF8B5CF6);      // Purple
  static const Color success = Color(0xFF10B981);        // Green
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color danger = Color(0xFFEF4444);         // Red
  static const Color bgDark = Color(0xFF0F172A);         // Dark Blue
  static const Color bgLight = Color(0xFFF8FAFC);        // Light Gray
  static const Color cardDark = Color(0xFF1E293B);       // Card Dark
  static const Color cardLight = Color(0xFFFFFFFF);      // Card Light
  static const Color textDark = Color(0xFFF1F5F9);       // Text Dark
  static const Color textLight = Color(0xFF0F172A);      // Text Light
  static const Color textMuted = Color(0xFF94A3B8);      // Muted

  // ========== MATERIAL THEME ==========
  static ThemeData get materialDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: cardDark,
        error: danger,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),

      scaffoldBackgroundColor: bgDark,

      // Typography (Inter)
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textMuted,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input Decoration (vamos sobrescrever com Cupertino)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),
    );
  }

  static ThemeData get materialLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: cardLight,
        error: danger,
        onPrimary: Colors.white,
        onSurface: textLight,
      ),

      scaffoldBackgroundColor: bgLight,

      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ========== CUPERTINO THEME ==========
  static CupertinoThemeData get cupertinoTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: bgDark,
      barBackgroundColor: cardDark,
      textTheme: CupertinoTextThemeData(
        primaryColor: textDark,
        textStyle: GoogleFonts.inter(
          fontSize: 17,
          color: textDark,
          letterSpacing: -0.4,
        ),
        navTitleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.4,
        ),
        navLargeTitleTextStyle: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
```

---

## 🧱 **3. Widgets Híbridos Customizados**

### **lib/shared/widgets/hybrid_button.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/hybrid_theme.dart';

class HybridButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const HybridButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Usa Cupertino Button (mais elegante)
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: isPrimary ? HybridTheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CupertinoActivityIndicator(color: Colors.white)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : HybridTheme.primary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
    );
  }
}
```

### **lib/shared/widgets/hybrid_text_field.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/hybrid_theme.dart';

class HybridTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const HybridTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: HybridTheme.textMuted,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Usa CupertinoTextField (mais elegante)
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: HybridTheme.textDark,
            letterSpacing: -0.4,
          ),
          placeholderStyle: const TextStyle(
            fontSize: 16,
            color: HybridTheme.textMuted,
            letterSpacing: -0.4,
          ),
          prefix: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: HybridTheme.textMuted,
                  ),
                )
              : null,
          suffix: suffix,
        ),
      ],
    );
  }
}
```

### **lib/shared/widgets/hybrid_card.dart**

```dart
import 'package:flutter/material.dart';
import '../theme/hybrid_theme.dart';

class HybridCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const HybridCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usa Material Card (mais robusto)
    return Card(
      color: HybridTheme.cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

### **lib/shared/widgets/hybrid_metric_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/hybrid_theme.dart';
import 'hybrid_card.dart';

class HybridMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const HybridMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return HybridCard(
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (iconColor ?? HybridTheme.primary).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? HybridTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: HybridTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: HybridTheme.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
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
```

---

## 🖥️ **4. Login Screen (Híbrida)**

### **lib/features/auth/presentation/login_screen_hybrid.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/theme/hybrid_theme.dart';
import '../../../shared/widgets/hybrid_button.dart';
import '../../../shared/widgets/hybrid_text_field.dart';
import '../../../shared/widgets/hybrid_card.dart';

class LoginScreenHybrid extends ConsumerStatefulWidget {
  const LoginScreenHybrid({super.key});

  @override
  ConsumerState<LoginScreenHybrid> createState() => _LoginScreenHybridState();
}

class _LoginScreenHybridState extends ConsumerState<LoginScreenHybrid> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        // Usa Cupertino Alert Dialog (mais elegante)
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Erro no Login'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HybridTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HybridTheme.bgDark,
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              HybridTheme.primary,
                              HybridTheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: HybridTheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.eye_fill,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      '👁️ Bem-vindo',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: HybridTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Faça login para acessar sua conta',
                      style: TextStyle(
                        fontSize: 15,
                        color: HybridTheme.textMuted,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Card Container
                    HybridCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          HybridTextField(
                            controller: _emailController,
                            label: 'Email',
                            placeholder: 'seu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: CupertinoIcons.mail,
                          ),
                          const SizedBox(height: 20),

                          // Password
                          HybridTextField(
                            controller: _passwordController,
                            label: 'Senha',
                            placeholder: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: CupertinoIcons.lock,
                            suffix: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() =>
                                    _obscurePassword = !_obscurePassword);
                              },
                              child: Icon(
                                _obscurePassword
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                size: 20,
                                color: HybridTheme.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Login Button (Cupertino style)
                          HybridButton(
                            text: 'Entrar',
                            onPressed: _handleLogin,
                            isLoading: _isLoading,
                            icon: CupertinoIcons.arrow_right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register Link
                    CupertinoButton(
                      onPressed: () => context.go('/register'),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Não tem conta? ',
                          style: TextStyle(
                            color: HybridTheme.textMuted,
                            fontSize: 15,
                            letterSpacing: -0.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'Crie uma agora →',
                              style: TextStyle(
                                color: HybridTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 📊 **5. Dashboard Screen (Híbrida)**

### **lib/features/dashboard/presentation/dashboard_screen_hybrid.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/client.dart';
import '../../../shared/theme/hybrid_theme.dart';
import '../../../shared/widgets/hybrid_metric_card.dart';
import '../../../shared/widgets/hybrid_card.dart';
import '../../../shared/widgets/hybrid_button.dart';

class DashboardScreenHybrid extends ConsumerWidget {
  const DashboardScreenHybrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final clientsStream = ref
        .watch(firestoreServiceProvider)
        .getClients(user?.uid ?? '');

    return Scaffold(
      backgroundColor: HybridTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HybridTheme.bgDark,
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar (Material)
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          HybridTheme.primary,
                          HybridTheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.eye_fill,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DoPVision',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: HybridTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                // Cupertino Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                  },
                  child: const Icon(
                    CupertinoIcons.square_arrow_right,
                    color: HybridTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    const Text(
                      'Visão completa dos seus clientes e campanhas',
                      style: TextStyle(
                        color: HybridTheme.textMuted,
                        fontSize: 15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metrics Grid
                    StreamBuilder<List<Client>>(
                      stream: clientsStream,
                      builder: (context, snapshot) {
                        final clients = snapshot.data ?? [];

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            HybridMetricCard(
                              icon: CupertinoIcons.money_dollar_circle_fill,
                              label: 'Receita Total',
                              value: 'R\$ 0',
                              iconColor: HybridTheme.success,
                            ),
                            HybridMetricCard(
                              icon: CupertinoIcons.chart_bar_alt_fill,
                              label: 'ROI Médio',
                              value: '0%',
                              iconColor: HybridTheme.primary,
                            ),
                            HybridMetricCard(
                              icon: CupertinoIcons.creditcard_fill,
                              label: 'Investimento',
                              value: 'R\$ 0',
                              iconColor: HybridTheme.warning,
                            ),
                            HybridMetricCard(
                              icon: CupertinoIcons.person_3_fill,
                              label: 'Clientes',
                              value: '${clients.length}',
                              iconColor: HybridTheme.secondary,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Clients List
                    StreamBuilder<List<Client>>(
                      stream: clientsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }

                        final clients = snapshot.data ?? [];

                        if (clients.isEmpty) {
                          return _buildEmptyState();
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: clients.length,
                          itemBuilder: (context, index) {
                            return _ClientCard(client: clients[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Material FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add client
        },
        backgroundColor: HybridTheme.primary,
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Novo Cliente'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_pie,
            size: 80,
            color: HybridTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum cliente ainda',
            style: TextStyle(
              color: HybridTheme.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comece adicionando seu primeiro cliente',
            style: TextStyle(
              color: HybridTheme.textMuted,
              fontSize: 15,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 24),
          HybridButton(
            text: 'Adicionar Primeiro Cliente',
            onPressed: () {
              // TODO
            },
            icon: CupertinoIcons.add,
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return HybridCard(
      onTap: () {
        // TODO: Navigate
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HybridTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getClientIcon(client.type),
                  color: HybridTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(
                        color: HybridTheme.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (client.segment != null)
                      Text(
                        client.segment!,
                        style: const TextStyle(
                          color: HybridTheme.textMuted,
                          fontSize: 12,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (client.monthlyGoal != null)
            Row(
              children: [
                const Icon(
                  CupertinoIcons.flag_fill,
                  size: 14,
                  color: HybridTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Meta: ${_formatGoal(client.monthlyGoal!, client.goalType)}',
                  style: const TextStyle(
                    color: HybridTheme.textMuted,
                    fontSize: 12,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getClientIcon(ClientType type) {
    switch (type) {
      case ClientType.physical:
        return CupertinoIcons.building_2_fill;
      case ClientType.online:
        return CupertinoIcons.globe;
      case ClientType.hybrid:
        return CupertinoIcons.arrow_2_squarepath;
    }
  }

  String _formatGoal(double goal, GoalType? type) {
    if (type == GoalType.revenue) {
      return NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 0,
      ).format(goal);
    }
    return '${goal.toInt()} leads';
  }
}
```

---

## 🚀 **6. Main.dart (Configuração Híbrida)**

### **lib/main.dart**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/firebase_config.dart';
import 'shared/theme/hybrid_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      authDomain: FirebaseConfig.authDomain,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      appId: FirebaseConfig.appId,
      measurementId: FirebaseConfig.measurementId,
    ),
  );

  runApp(
    const ProviderScope(
      child: DoPVisionApp(),
    ),
  );
}

class DoPVisionApp extends ConsumerWidget {
  const DoPVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DoPVision',
      // Material Theme
      theme: HybridTheme.materialLightTheme,
      darkTheme: HybridTheme.materialDarkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Cupertino Theme Builder
      builder: (context, child) {
        return CupertinoTheme(
          data: HybridTheme.cupertinoTheme,
          child: child!,
        );
      },
    );
  }
}
```

---

## ✅ **7. Vantagens da Abordagem Híbrida**

### **Material 3 usado para:**
- ✅ Scaffold (estrutura)
- ✅ AppBar
- ✅ Cards (sistema robusto)
- ✅ FloatingActionButton
- ✅ Theme system
- ✅ Navegação

### **Cupertino usado para:**
- ✅ Buttons (mais elegantes)
- ✅ TextFields (look iOS)
- ✅ Icons (SF Symbols style)
- ✅ AlertDialogs
- ✅ Activity Indicator
- ✅ Typography style

---

## 🎯 **8. Instalação Rápida**

```bash
cd /Users/lucasfranco/development/dopvision_flutter

# Instale os pacotes
flutter pub add cupertino_icons google_fonts flutter_platform_widgets

# Rode o app
flutter run -d chrome
```

---

## 📊 **9. Resultado Final**

### **Visual:**
- Background gradiente (Material)
- Cards elevados (Material)
- Buttons arredondados (Cupertino)
- Inputs elegantes (Cupertino)
- Icons SF Symbols style (Cupertino)
- Typography Inter (Híbrido)

### **Performance:**
- ⚡ Rápido (widgets nativos)
- 📱 Adaptativo
- 🎨 Elegante
- 💪 Robusto

---

## 🏆 **Comparação:**

| Elemento | Framework |
|----------|-----------|
| Scaffold | Material |
| Cards | Material |
| Buttons | Cupertino ⭐ |
| TextFields | Cupertino ⭐ |
| Dialogs | Cupertino ⭐ |
| Icons | Cupertino ⭐ |
| AppBar | Material |
| FAB | Material |
| Theme | Híbrido |

---

## ✅ **Checklist de Implementação**

- [ ] Copie `hybrid_theme.dart`
- [ ] Copie todos os widgets híbridos
- [ ] Copie `login_screen_hybrid.dart`
- [ ] Copie `dashboard_screen_hybrid.dart`
- [ ] Atualize `main.dart`
- [ ] Rode `flutter pub get`
- [ ] Teste `flutter run`

---

**Pronto! Agora você tem o melhor dos dois mundos! 🎨✨**

Quer que eu crie mais componentes (dialogs, forms, charts)? Me avisa! 🚀
