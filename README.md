# 🚀 DoPVision Flutter

**Gestão de Performance em Vendas** - Aplicativo multiplataforma para gerenciamento de clientes, campanhas e análise de métricas de vendas.

![Flutter](https://img.shields.io/badge/Flutter-3.32.8-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Sobre o Projeto

DoPVision é uma solução completa para gestão de performance em vendas, permitindo:

- 📊 **Dashboard Interativo** - Visualize métricas em tempo real
- 👥 **Gestão de Clientes** - Controle completo de clientes e contatos
- 📈 **Campanhas** - Gerenciamento de campanhas publicitárias
- 💰 **Análise de Vendas** - ROI, conversões e métricas detalhadas
- 🔐 **Autenticação Segura** - Firebase Authentication
- ☁️ **Sincronização em Nuvem** - Firestore Database

## 🏗️ Arquitetura

Projeto desenvolvido seguindo **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── core/
│   ├── constants/     # Constantes e configurações
│   ├── models/        # Modelos de dados
│   ├── services/      # Serviços (Firebase, Auth, etc)
│   ├── router/        # Navegação com GoRouter
│   └── utils/         # Utilitários
├── features/
│   ├── auth/          # Autenticação (Login, Register)
│   ├── dashboard/     # Dashboard principal
│   └── client/        # Gestão de clientes
└── shared/
    ├── theme/         # Tema Material 3
    └── widgets/       # Componentes reutilizáveis
```

## 🛠️ Tecnologias

- **Flutter 3.32.8** - Framework multiplataforma
- **Firebase** - Backend as a Service
  - Authentication (Email/Password)
  - Firestore Database
  - Cloud Storage
- **Riverpod** - State Management
- **GoRouter** - Navegação e rotas
- **Material 3** - Design System
- **Google Fonts** - Tipografia (Inter)
- **FL Chart** - Gráficos e visualizações

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (3.32.8 ou superior)
- Dart SDK
- Firebase CLI
- Conta Firebase

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/francodev1/dopvision_flutter.git
cd dopvision_flutter
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o app:
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 🔥 Configuração do Firebase

O projeto já está configurado com Firebase. Para usar em outro ambiente:

1. Instale o FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure o Firebase:
```bash
flutterfire configure
```

3. Ative os serviços no Firebase Console:
   - Authentication (Email/Password)
   - Firestore Database
   - Cloud Storage (opcional)

## 📦 Build para Produção

### Web
```bash
flutter build web --release
```

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 Features

- ✅ Autenticação com email/senha
- ✅ Dashboard com métricas em tempo real
- ✅ CRUD de clientes
- ✅ Gestão de campanhas
- ✅ Registro de vendas
- ✅ Cálculo automático de ROI, CTR, CPA
- ✅ Tema claro/escuro
- ✅ Responsive design
- 🔄 Sincronização offline (em breve)
- 🔄 Exportação de relatórios (em breve)
- 🔄 Notificações push (em breve)

## 📝 Modelos de Dados

### Client
```dart
- id, name, type (physical/online/hybrid)
- segment, monthlyGoal, goalType
- plan (basic/pro/enterprise)
- contacts, notes
```

### Campaign
```dart
- id, name, clientId, budget
- startDate, endDate, status
- platform (facebook/google/tiktok/linkedin)
- creatives, metrics (impressions, clicks, conversions)
```

### Sale
```dart
- id, amount, source, date
- clientId, productName, customer
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## 📄 Licença

Este projeto está sob a licença MIT.

## 👨‍💻 Autor

**Lucas Franco** - [GitHub](https://github.com/francodev1)

---

⭐ Se este projeto foi útil, considere dar uma estrela!
