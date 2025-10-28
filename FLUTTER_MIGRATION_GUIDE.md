# 🚀 Guia Completo de Migração DoPVision para Flutter

> **Status**: Projeto Flutter criado em `/Users/lucasfranco/development/dopvision_flutter`  
> **Data**: 28 de Outubro de 2025  
> **Versão Flutter**: 3.32.8  
> **Dependências**: Já instaladas ✅

---

## 📦 Dependências Instaladas

```yaml
dependencies:
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  firebase_storage: latest
  flutter_riverpod: latest  # State Management
  go_router: latest         # Navegação
  fl_chart: latest          # Gráficos
  intl: latest              # Formatação
  google_fonts: latest      # Fontes
```

---

## 📁 Estrutura Clean Architecture Criada

```
dopvision_flutter/
├── lib/
│   ├── core/
│   │   ├── models/          # Client, Campaign, Sale, etc
│   │   ├── services/        # Firebase services
│   │   ├── utils/           # Helpers, formatters
│   │   └── constants/       # Cores, strings, configs
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/        # Firebase auth repository
│   │   │   ├── domain/      # Use cases
│   │   │   └── presentation/ # Login/Register screens
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── client/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── shared/
│       ├── widgets/         # Botões, cards, etc
│       └── theme/           # App theme
```

---

## 🔥 Parte 1: Modelos (Core/Models)

### 1.1 `lib/core/models/client.dart`

\`\`\`dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String? id;
  final String name;
  final ClientType type;
  final String? userId;
  final String? segment;
  final double? monthlyGoal;
  final GoalType? goalType;
  final PlanType? plan;
  final List<ClientContact>? contacts;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.id,
    required this.name,
    required this.type,
    this.userId,
    this.segment,
    this.monthlyGoal,
    this.goalType,
    this.plan,
    this.contacts,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: data['name'] ?? '',
      type: ClientType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ClientType.online,
      ),
      userId: data['userId'],
      segment: data['segment'],
      monthlyGoal: data['monthlyGoal']?.toDouble(),
      goalType: data['goalType'] != null
          ? GoalType.values.firstWhere((e) => e.name == data['goalType'])
          : null,
      plan: data['plan'] != null
          ? PlanType.values.firstWhere((e) => e.name == data['plan'])
          : null,
      contacts: (data['contacts'] as List?)
          ?.map((c) => ClientContact.fromMap(c))
          .toList(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'userId': userId,
      'segment': segment,
      'monthlyGoal': monthlyGoal,
      'goalType': goalType?.name,
      'plan': plan?.name,
      'contacts': contacts?.map((c) => c.toMap()).toList(),
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ClientContact {
  final String name;
  final String? email;
  final String? phone;
  final String? role;

  ClientContact({
    required this.name,
    this.email,
    this.phone,
    this.role,
  });

  factory ClientContact.fromMap(Map<String, dynamic> map) {
    return ClientContact(
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

enum ClientType { physical, online, hybrid }
enum GoalType { leads, revenue }
enum PlanType { basic, pro, enterprise }
\`\`\`

### 1.2 `lib/core/models/campaign.dart`

\`\`\`dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String? id;
  final String name;
  final String clientId;
  final double budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final CampaignStatus status;
  final CampaignObjective objective;
  final Platform platform;
  final String? targetAudience;
  final List<Creative>? creatives;
  final CampaignMetrics? metrics;

  Campaign({
    this.id,
    required this.name,
    required this.clientId,
    required this.budget,
    this.startDate,
    this.endDate,
    this.status = CampaignStatus.testing,
    this.objective = CampaignObjective.leads,
    this.platform = Platform.facebook,
    this.targetAudience,
    this.creatives,
    this.metrics,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      name: data['name'] ?? '',
      clientId: data['clientId'] ?? '',
      budget: (data['budget'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CampaignStatus.testing,
      ),
      objective: CampaignObjective.values.firstWhere(
        (e) => e.name == data['objective'],
        orElse: () => CampaignObjective.leads,
      ),
      platform: Platform.values.firstWhere(
        (e) => e.name == data['platform'],
        orElse: () => Platform.facebook,
      ),
      targetAudience: data['targetAudience'],
      creatives: (data['creatives'] as List?)
          ?.map((c) => Creative.fromMap(c))
          .toList(),
      metrics: data['metrics'] != null
          ? CampaignMetrics.fromMap(data['metrics'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'clientId': clientId,
      'budget': budget,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status.name,
      'objective': objective.name,
      'platform': platform.name,
      'targetAudience': targetAudience,
      'creatives': creatives?.map((c) => c.toMap()).toList(),
      'metrics': metrics?.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class Creative {
  final String name;
  final CreativeType type;
  final String? url;
  final double? performance;

  Creative({
    required this.name,
    required this.type,
    this.url,
    this.performance,
  });

  factory Creative.fromMap(Map<String, dynamic> map) {
    return Creative(
      name: map['name'] ?? '',
      type: CreativeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CreativeType.image,
      ),
      url: map['url'],
      performance: map['performance']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'url': url,
      'performance': performance,
    };
  }
}

class CampaignMetrics {
  final int impressions;
  final int clicks;
  final int conversions;
  final double ctr;
  final double cpc;
  final double cpa;
  final double roas;
  final double cpm;
  final int leads;

  CampaignMetrics({
    this.impressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.ctr = 0.0,
    this.cpc = 0.0,
    this.cpa = 0.0,
    this.roas = 0.0,
    this.cpm = 0.0,
    this.leads = 0,
  });

  factory CampaignMetrics.fromMap(Map<String, dynamic> map) {
    return CampaignMetrics(
      impressions: map['impressions'] ?? 0,
      clicks: map['clicks'] ?? 0,
      conversions: map['conversions'] ?? 0,
      ctr: (map['ctr'] ?? 0).toDouble(),
      cpc: (map['cpc'] ?? 0).toDouble(),
      cpa: (map['cpa'] ?? 0).toDouble(),
      roas: (map['roas'] ?? 0).toDouble(),
      cpm: (map['cpm'] ?? 0).toDouble(),
      leads: map['leads'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'conversions': conversions,
      'ctr': ctr,
      'cpc': cpc,
      'cpa': cpa,
      'roas': roas,
      'cpm': cpm,
      'leads': leads,
    };
  }
}

enum CampaignStatus { active, paused, testing, completed }
enum CampaignObjective { leads, sales, remarketing, awareness }
enum Platform { facebook, google, tiktok, linkedin, other }
enum CreativeType { image, video, carousel }
\`\`\`

### 1.3 `lib/core/models/sale.dart`

\`\`\`dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String? id;
  final double amount;
  final String source;
  final DateTime date;
  final String? clientId;
  final String? productName;
  final String? customer;

  Sale({
    this.id,
    required this.amount,
    required this.source,
    required this.date,
    this.clientId,
    this.productName,
    this.customer,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      source: data['source'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      clientId: data['clientId'],
      productName: data['productName'],
      customer: data['customer'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'source': source,
      'date': Timestamp.fromDate(date),
      'clientId': clientId,
      'productName': productName,
      'customer': customer,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
\`\`\`

### 1.4 `lib/core/models/dashboard_metrics.dart`

\`\`\`dart
class DashboardMetrics {
  final double totalRevenue;
  final double totalInvested;
  final double roi;
  final double conversionRate;
  final double averageTicket;
  final int totalImpressions;
  final int totalClicks;
  final int totalLeads;
  final double ctr;
  final double cpm;
  final double cpl;

  DashboardMetrics({
    this.totalRevenue = 0.0,
    this.totalInvested = 0.0,
    this.roi = 0.0,
    this.conversionRate = 0.0,
    this.averageTicket = 0.0,
    this.totalImpressions = 0,
    this.totalClicks = 0,
    this.totalLeads = 0,
    this.ctr = 0.0,
    this.cpm = 0.0,
    this.cpl = 0.0,
  });
}

class ClientDashboard {
  final Client client;
  final List<Campaign> campaigns;
  final List<Sale> sales;
  final DashboardMetrics metrics;

  ClientDashboard({
    required this.client,
    required this.campaigns,
    required this.sales,
    required this.metrics,
  });
}
\`\`\`

---

## 🔐 Parte 2: Autenticação (Firebase Auth)

### 2.1 `lib/core/services/auth_service.dart`

\`\`\`dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;

  // Login
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro
  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return e.message ?? 'Erro de autenticação';
    }
  }
}
\`\`\`

---

## 📊 Parte 3: Firestore Services

### 3.1 `lib/core/services/firestore_service.dart`

\`\`\`dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../models/campaign.dart';
import '../models/sale.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== CLIENTS ==========
  
  Stream<List<Client>> getClients(String userId) {
    return _db
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList());
  }

  Future<void> addClient(Client client) async {
    await _db.collection('clients').add(client.toFirestore());
  }

  Future<void> updateClient(String id, Client client) async {
    await _db.collection('clients').doc(id).update(client.toFirestore());
  }

  Future<void> deleteClient(String id) async {
    await _db.collection('clients').doc(id).delete();
  }

  // ========== CAMPAIGNS ==========

  Stream<List<Campaign>> getCampaigns(String clientId) {
    return _db
        .collection('campaigns')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList());
  }

  Future<void> addCampaign(Campaign campaign) async {
    await _db.collection('campaigns').add(campaign.toFirestore());
  }

  Future<void> updateCampaign(String id, Campaign campaign) async {
    await _db.collection('campaigns').doc(id).update(campaign.toFirestore());
  }

  Future<void> deleteCampaign(String id) async {
    await _db.collection('campaigns').doc(id).delete();
  }

  // ========== SALES ==========

  Stream<List<Sale>> getSales(String clientId) {
    return _db
        .collection('sales')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  Future<void> addSale(Sale sale) async {
    await _db.collection('sales').add(sale.toFirestore());
  }

  Future<void> deleteSale(String id) async {
    await _db.collection('sales').doc(id).delete();
  }
}
\`\`\`

---

## 🎨 Parte 4: Theme & Constants

### 4.1 `lib/shared/theme/app_theme.dart`

\`\`\`dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}
\`\`\`

### 4.2 `lib/core/constants/firebase_config.dart`

\`\`\`dart
class FirebaseConfig {
  static const String apiKey = "AIzaSyA45Q-4d-KfoYCgE7jBk3DMm1J_khIGf5c";
  static const String authDomain = "dopvision-c384b.firebaseapp.com";
  static const String projectId = "dopvision-c384b";
  static const String storageBucket = "dopvision-c384b.firebasestorage.app";
  static const String messagingSenderId = "968393153974";
  static const String appId = "1:968393153974:web:4c5788770780c5cfe27517";
  static const String measurementId = "G-KTNQMB8GVL";
}
\`\`\`

---

## 🖥️ Parte 5: Tela de Login

### 5.1 `lib/features/auth/presentation/login_screen.dart`

\`\`\`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    if (!_formKey.currentState!.validate()) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.analytics_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'DoPVision',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Gestão de Performance em Vendas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite seu email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua senha';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Não tem conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
\`\`\`

---

## 📱 Parte 6: Dashboard Screen

### 6.1 `lib/features/dashboard/presentation/dashboard_screen.dart`

\`\`\`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/client.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final clientsStream = ref
        .watch(firestoreServiceProvider)
        .getClients(user?.uid ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Client>>(
        stream: clientsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final clients = snapshot.data ?? [];

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum cliente cadastrado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione seu primeiro cliente',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ClientCard(client: client);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add client screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Cliente'),
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to client details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _getClientIcon(client.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (client.segment != null)
                          Text(
                            client.segment!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                      ],
                    ),
                  ),
                  _getPlanBadge(context, client.plan),
                ],
              ),
              if (client.monthlyGoal != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Meta: ${_formatGoal(client.monthlyGoal!, client.goalType)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getClientIcon(ClientType type) {
    switch (type) {
      case ClientType.physical:
        return Icons.store;
      case ClientType.online:
        return Icons.language;
      case ClientType.hybrid:
        return Icons.sync;
    }
  }

  Widget _getPlanBadge(BuildContext context, PlanType? plan) {
    if (plan == null) return const SizedBox.shrink();

    Color color;
    String label;

    switch (plan) {
      case PlanType.basic:
        color = Colors.blue;
        label = 'Basic';
        break;
      case PlanType.pro:
        color = Colors.purple;
        label = 'Pro';
        break;
      case PlanType.enterprise:
        color = Colors.orange;
        label = 'Enterprise';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
\`\`\`

---

## 🚀 Parte 7: Main & Router

### 7.1 `lib/main.dart`

\`\`\`dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/firebase_config.dart';
import 'shared/theme/app_theme.dart';
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
\`\`\`

### 7.2 `lib/core/router/app_router.dart`

\`\`\`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
\`\`\`

---

## ✅ Checklist de Implementação

### Fase 1: Setup Base (✅ Completo)
- [x] Criar projeto Flutter
- [x] Instalar dependências
- [x] Criar estrutura de pastas

### Fase 2: Models & Core (Para fazer)
- [ ] Criar todos os models (Client, Campaign, Sale, etc)
- [ ] Implementar AuthService
- [ ] Implementar FirestoreService
- [ ] Configurar Firebase
- [ ] Criar theme customizado

### Fase 3: Telas de Autenticação (Para fazer)
- [ ] Tela de Login
- [ ] Tela de Registro
- [ ] Implementar router com go_router

### Fase 4: Dashboard (Para fazer)
- [ ] Tela principal de Dashboard
- [ ] Cards de clientes
- [ ] Listagem de campanhas
- [ ] Gráficos com fl_chart

### Fase 5: Features Avançadas (Para fazer)
- [ ] Tela de detalhes do cliente
- [ ] Formulário de nova campanha
- [ ] Exportação de relatórios
- [ ] Notificações push
- [ ] Modo offline

### Fase 6: Deploy (Para fazer)
- [ ] Build Android (APK/AAB)
- [ ] Build iOS (IPA)
- [ ] Deploy Web
- [ ] Desktop builds (opcional)

---

## 🎯 Próximos Passos

1. **Abra o VS Code na pasta do Flutter**:
   \`\`\`bash
   cd /Users/lucasfranco/development/dopvision_flutter
   code .
   \`\`\`

2. **Copie todos os arquivos deste guia** para as respectivas pastas

3. **Configure o Firebase**:
   - Crie `firebase_options.dart` com suas credenciais
   - Ou use FlutterFire CLI: `flutterfire configure`

4. **Rode o app**:
   \`\`\`bash
   flutter run
   \`\`\`

---

## 📦 Comandos Úteis

\`\`\`bash
# Rodar no Chrome (Web)
flutter run -d chrome

# Rodar no Android
flutter run -d android

# Rodar no iOS
flutter run -d ios

# Build para produção
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web

# Limpar cache
flutter clean && flutter pub get
\`\`\`

---

## 🆘 Troubleshooting

### Erro de dependências
\`\`\`bash
flutter pub get
flutter pub outdated
flutter pub upgrade
\`\`\`

### Erro no Firebase
\`\`\`bash
dart pub global activate flutterfire_cli
flutterfire configure
\`\`\`

### Erro no Android
\`\`\`bash
cd android
./gradlew clean
cd ..
flutter clean
\`\`\`

---

## 🎓 Recursos para Aprender Flutter

- **Documentação oficial**: https://docs.flutter.dev/
- **Flutter Cookbook**: https://docs.flutter.dev/cookbook
- **Riverpod Docs**: https://riverpod.dev/
- **Firebase Flutter**: https://firebase.flutter.dev/

---

**🚀 Boa sorte com a migração! Flutter é incrível!**

Se precisar de ajuda, me chame! 😊
