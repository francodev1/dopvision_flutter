# 📊 Diagrama de Estrutura do Banco de Dados - DoPVision

```
┌─────────────────────────────────────────────────────────────────┐
│                     🔥 FIREBASE FIRESTORE                       │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  👤 USERS                                                        │
│  /users/{userId}                                                 │
├──────────────────────────────────────────────────────────────────┤
│  • uid: string                                                   │
│  • email: string                                                 │
│  • displayName: string                                           │
│  • photoURL: string?                                             │
│  • phoneNumber: string?                                          │
│  • createdAt: timestamp                                          │
│  • updatedAt: timestamp                                          │
│  • isDeleted: boolean                                            │
└──────────────────────────────────────────────────────────────────┘
       │
       │ 1:N
       ▼
┌──────────────────────────────────────────────────────────────────┐
│  🏢 CLIENTS                                                      │
│  /clients/{clientId}                                             │
├──────────────────────────────────────────────────────────────────┤
│  • id: string                                                    │
│  • userId: string ────────────┐ (FK)                             │
│  • name: string               │                                  │
│  • type: ClientType           │                                  │
│  • segment: string?           │                                  │
│  • monthlyGoal: number?       │                                  │
│  • goalType: GoalType?        │                                  │
│  • plan: PlanType?            │                                  │
│  • status: ClientStatus       │                                  │
│  • contacts: Contact[]        │                                  │
│  • address: Address?          │                                  │
│  • socialMedia: SocialMedia?  │                                  │
│  • tags: string[]             │                                  │
│  • notes: string?             │                                  │
│  • createdAt: timestamp       │                                  │
│  • updatedAt: timestamp       │                                  │
│  • deletedAt: timestamp?      │                                  │
│  • isDeleted: boolean         │                                  │
└───────────────────────────────┼──────────────────────────────────┘
       │                        │
       │ 1:N                    │
       ▼                        │
┌──────────────────────────────────────────────────────────────────┐
│  📢 CAMPAIGNS                                                    │
│  /campaigns/{campaignId}                                         │
├──────────────────────────────────────────────────────────────────┤
│  • id: string                                                    │
│  • clientId: string ──────────┘ (FK)                             │
│  • userId: string ────────────────────┐ (FK)                     │
│  • name: string                       │                          │
│  • platform: Platform                 │                          │
│  • status: CampaignStatus             │                          │
│  • type: CampaignType                 │                          │
│  • objective: string?                 │                          │
│  • budget: number?                    │                          │
│  • dailyBudget: number?               │                          │
│  • startDate: timestamp?              │                          │
│  • endDate: timestamp?                │                          │
│  • metrics: CampaignMetrics?          │                          │
│  • audience: Audience?                │                          │
│  • creative: Creative?                │                          │
│  • tags: string[]                     │                          │
│  • notes: string?                     │                          │
│  • externalId: string?                │                          │
│  • syncData: SyncData?                │                          │
│  • createdAt: timestamp               │                          │
│  • updatedAt: timestamp               │                          │
│  • deletedAt: timestamp?              │                          │
│  • isDeleted: boolean                 │                          │
└───────────────────────────────────────┼──────────────────────────┘
       │                                │
       │ 1:N                            │
       ▼                                │
┌──────────────────────────────────────────────────────────────────┐
│  💰 SALES                                                        │
│  /sales/{saleId}                                                 │
├──────────────────────────────────────────────────────────────────┤
│  • id: string                                                    │
│  • clientId: string ──────────┐ (FK)                             │
│  • userId: string ─────────────────────┘ (FK)                    │
│  • campaignId: string? ───────┘ (FK - opcional)                  │
│  • amount: number                                                │
│  • status: SaleStatus                                            │
│  • date: timestamp                                               │
│  • customerName: string?                                         │
│  • customerEmail: string?                                        │
│  • customerPhone: string?                                        │
│  • productName: string?                                          │
│  • quantity: number?                                             │
│  • paymentMethod: string?                                        │
│  • transactionId: string?                                        │
│  • notes: string?                                                │
│  • tags: string[]                                                │
│  • createdAt: timestamp                                          │
│  • updatedAt: timestamp                                          │
│  • deletedAt: timestamp?                                         │
│  • isDeleted: boolean                                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  🔔 NOTIFICATIONS (Futuro)                                       │
│  /notifications/{notificationId}                                 │
├──────────────────────────────────────────────────────────────────┤
│  • id: string                                                    │
│  • userId: string ────────────┐ (FK)                             │
│  • type: NotificationType     │                                  │
│  • title: string              │                                  │
│  • message: string            │                                  │
│  • data: map?                 │                                  │
│  • read: boolean              │                                  │
│  • readAt: timestamp?         │                                  │
│  • createdAt: timestamp       │                                  │
│  • expiresAt: timestamp?      │                                  │
└───────────────────────────────┼──────────────────────────────────┘
                                │
┌──────────────────────────────────────────────────────────────────┐
│  ⚙️  SETTINGS (Futuro)                                           │
│  /settings/{userId}                                              │
├──────────────────────────────────────────────────────────────────┤
│  • theme: string              │                                  │
│  • language: string           │                                  │
│  • notifications: map         │                                  │
│  • privacy: map               │                                  │
│  • updatedAt: timestamp       │                                  │
└───────────────────────────────┼──────────────────────────────────┘
                                │
┌──────────────────────────────────────────────────────────────────┐
│  📊 ANALYTICS (Cloud Functions)                                  │
│  /analytics/{analyticId}                                         │
├──────────────────────────────────────────────────────────────────┤
│  • userId: string ────────────┘ (FK)                             │
│  • period: string (daily/weekly/monthly)                         │
│  • date: timestamp                                               │
│  • metrics: map<string, number>                                  │
│  • generatedAt: timestamp                                        │
└──────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════
                      📁 FIREBASE STORAGE
═══════════════════════════════════════════════════════════════════

/users/{userId}/
  ├── profile/              → 👤 Fotos de perfil (5MB max)
  └── documents/            → 📄 Documentos gerais (10MB max)

/clients/{clientId}/
  ├── images/               → 🖼️  Logos e imagens (5MB max)
  └── documents/            → 📄 Contratos, etc (20MB max)

/campaigns/{campaignId}/
  ├── creatives/
  │   ├── images/          → 🎨 Imagens criativas (10MB max)
  │   └── videos/          → 🎬 Vídeos (50MB max)
  └── reports/             → 📊 Relatórios (15MB max)

/exports/{userId}/         → 📦 Exports gerados (somente leitura)

/temp/{userId}/            → ⏱️  Temporários (auto-delete 24h)


═══════════════════════════════════════════════════════════════════
                        🔐 SECURITY RULES
═══════════════════════════════════════════════════════════════════

✅ Autenticação Obrigatória
   └─> Todos os acessos exigem request.auth != null

✅ Isolamento por Usuário
   └─> Cada usuário só acessa seus próprios dados (userId)

✅ Soft Delete Pattern
   └─> Deleções físicas bloqueadas
   └─> Usar isDeleted: true e deletedAt: timestamp

✅ Validação de Dados
   └─> Campos obrigatórios verificados
   └─> Tipos validados
   └─> Valores sanitizados

✅ Campos Protegidos
   └─> createdAt, userId, uid não podem ser modificados

✅ Integridade Relacional
   └─> FKs validados (ex: clientId deve existir e pertencer ao user)


═══════════════════════════════════════════════════════════════════
                      📈 COMPOSITE INDEXES
═══════════════════════════════════════════════════════════════════

CLIENTS (3 índices)
├─> userId + isDeleted + name (asc)
├─> userId + isDeleted + status + name (asc)
└─> userId + isDeleted + createdAt (desc)

CAMPAIGNS (4 índices)
├─> clientId + isDeleted + createdAt (desc)
├─> clientId + isDeleted + status + createdAt (desc)
├─> userId + isDeleted + createdAt (desc)
└─> userId + status + isDeleted + createdAt (desc)

SALES (5 índices)
├─> clientId + isDeleted + date (desc)
├─> campaignId + isDeleted + date (desc)
├─> userId + date (asc) + isDeleted
├─> userId + isDeleted + date (desc)
└─> userId + status + date (desc)

NOTIFICATIONS (1 índice)
└─> userId + read + createdAt (desc)

TOTAL: 13 Composite Indexes


═══════════════════════════════════════════════════════════════════
                        📊 DATA FLOW
═══════════════════════════════════════════════════════════════════

┌─────────┐
│  USER   │ Cria conta
└────┬────┘
     │
     ├─────────> ┌──────────┐
     │           │ CLIENTS  │ Adiciona clientes
     │           └────┬─────┘
     │                │
     │                ├──────> ┌────────────┐
     │                │        │ CAMPAIGNS  │ Cria campanhas
     │                │        └─────┬──────┘
     │                │              │
     │                └──────────────┼──────> ┌───────┐
     │                               │        │ SALES │ Registra vendas
     │                               │        └───────┘
     │                               │
     └───────────────────────────────┘

Relacionamentos:
• User 1:N Clients (um usuário tem vários clientes)
• Client 1:N Campaigns (um cliente tem várias campanhas)
• Campaign 1:N Sales (uma campanha tem várias vendas)
• Client 1:N Sales (um cliente tem várias vendas - diretas ou via campanha)


═══════════════════════════════════════════════════════════════════
                      🎯 ENUMS & TYPES
═══════════════════════════════════════════════════════════════════

ClientType
├─> physical
├─> online
└─> hybrid

ClientStatus
├─> active
├─> inactive
└─> suspended

GoalType
├─> leads
└─> sales

PlanType
├─> free
├─> basic
├─> pro
└─> enterprise

CampaignPlatform
├─> facebook
├─> google
├─> tiktok
├─> linkedin
└─> other

CampaignStatus
├─> draft
├─> active
├─> paused
├─> testing
└─> completed

CampaignType
├─> traffic
├─> awareness
├─> leads
├─> sales
└─> remarketing

SaleStatus
├─> pending
├─> approved
├─> cancelled
└─> refunded
```
