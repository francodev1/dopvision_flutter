 # 🚀 Guia TestFlight - DoPVision v2.0.0

## ✅ PRÉ-REQUISITOS COMPLETOS

### 1. Código
- ✅ Flutter analyze: 0 issues
- ✅ Exclusão de clientes funcionando (softDelete)
- ✅ Tela de detalhes do cliente criada
- ✅ Input formatters implementados (telefone, email, budget)
- ✅ Navegação funcionando
- ✅ Toasts configurados corretamente
- ⚠️ Pequeno overflow no header (não crítico, pode subir assim)

### 2. Certificados Apple
- Apple Developer Account ativo
- Certificados de distribuição configurados
- Provisioning Profile para produção

### 3. App Store Connect
- App criado no App Store Connect
- Bundle ID configurado: `com.dopvision.flutter` (verificar no Xcode)

---

## 📱 PASSOS PARA TESTFLIGHT

### Passo 1: Abrir no Xcode
```bash
cd /Users/lucasfranco/development/dopvision_flutter
open ios/Runner.xcworkspace
```

### Passo 2: Configurar Versão e Build
1. No Xcode, selecione o target **Runner**
2. Na aba **General**:
   - **Version**: `2.0.0`
   - **Build**: `1` (incrementar a cada upload)
3. **Bundle Identifier**: Confirme que está correto (ex: `com.dopvision.flutter`)

### Passo 3: Selecionar Dispositivo
- No topo do Xcode, selecione: **Any iOS Device (arm64)**

### Passo 4: Arquivar (Archive)
1. Menu: **Product** → **Archive**
2. Aguarde a compilação (pode levar 5-10 minutos)
3. Quando terminar, abrirá o **Organizer**

### Passo 5: Distribuir para TestFlight
1. No **Organizer**, selecione o archive criado
2. Clique em **Distribute App**
3. Selecione: **App Store Connect**
4. Clique em **Upload**
5. Deixe as opções padrão selecionadas:
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number
6. Clique em **Next** e depois **Upload**

### Passo 6: Processar no App Store Connect
1. Acesse: https://appstoreconnect.apple.com
2. Vá em **My Apps** → **DoPVision**
3. Aba **TestFlight**
4. Aguarde o processamento (10-30 minutos)
5. Status mudará de "Processing" para "Ready to Test"

### Passo 7: Adicionar Testadores
1. Em **TestFlight** → **Internal Testing**
2. Adicione testadores (você e sua equipe)
3. Eles receberão email com link do TestFlight

### Passo 8: Testar no iPhone Real
1. Baixe o app **TestFlight** na App Store
2. Abra o link do email
3. Instale o DoPVision
4. Teste todas as funcionalidades! 🎉

---

## 🎨 NORMALIZAÇÃO DOS ÍCONES (OPCIONAL - PARA PRÓXIMA VERSÃO)

Você mencionou normalizar os ícones. Aqui está como fazer:

### Usar flutter_launcher_icons

1. **Adicionar ao pubspec.yaml**:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  remove_alpha_ios: true
  adaptive_icon_background: "#0A0E27"
  adaptive_icon_foreground: "assets/images/logo_foreground.png"
```

2. **Gerar ícones**:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

3. **Verificar ícones gerados**:
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Android: `android/app/src/main/res/mipmap-*/`

---

## 🐛 PROBLEMAS CONHECIDOS (Não críticos)

### 1. Overflow no Header (33 pixels)
- **Onde**: Tela de detalhes do cliente
- **Impacto**: Visual menor, não afeta funcionalidade
- **Fix**: Já tentamos ajustar tamanhos, mas persiste em alguns casos
- **Prioridade**: BAIXA - Pode subir assim

### 2. Funcionalidades Futuras
- ✅ Exclusão: IMPLEMENTADA
- ⏳ Edição: Botão existe mas não faz nada (esperando tela de edição)
- ⏳ Funil de vendas: Card placeholder criado
- ⏳ Exportar/WhatsApp: Botões preparados

---

## 📊 FEATURES IMPLEMENTADAS v2.0.0

### ✅ Dashboard
- Lista de clientes com cards lindos
- Badges por tipo (Físico, Online, Híbrido)
- Status online/offline
- Busca e filtros
- Adicionar novo cliente

### ✅ Formulário de Cliente
- Validação completa
- Formatação automática:
  - Telefone: (XX) XXXXX-XXXX
  - Email: lowercase automático
  - Budget: R$ X.XXX,XX
- Tipos: Físico, Online, Híbrido
- Upload de foto

### ✅ Tela de Detalhes
- Header com gradiente e badges
- Cards organizados:
  - Informações de contato
  - Métricas (budget)
  - Funil de vendas (placeholder)
  - Ações rápidas
- Botões de editar (preparado) e excluir (funcionando)
- Design responsivo (mobile e desktop)

### ✅ Exclusão de Cliente
- Dialog customizado escuro
- Soft delete (mantém histórico)
- Toast de sucesso verde
- Atualização automática da lista

---

## 🎯 PRÓXIMOS PASSOS (Após TestFlight)

1. **Normalizar ícones** (seguir guia acima)
2. **Implementar tela de edição**
3. **Desenvolver funil de vendas**
4. **Adicionar exportação Excel/PDF**
5. **Integração WhatsApp**
6. **Features de IA e automação**

---

## 📞 COMANDOS ÚTEIS

### Limpar build
```bash
flutter clean
flutter pub get
```

### Verificar certificados
```bash
security find-identity -v -p codesigning
```

### Build iOS local (testar antes de arquivar)
```bash
flutter build ios --release
```

### Ver logs do dispositivo
```bash
flutter logs
```

---

## 🎉 CHECKLIST FINAL

Antes de arquivar, confirme:

- [ ] Version no pubspec.yaml: `2.0.0+1`
- [ ] Version no Xcode: `2.0.0`
- [ ] Build number incrementado
- [ ] Bundle ID correto
- [ ] Certificados válidos
- [ ] Testou no simulador
- [ ] Não tem erros de compilação
- [ ] Firebase configurado (GoogleService-Info.plist presente)

---

## 🚨 SE DER ERRO

### "Signing for Runner requires a development team"
1. Xcode → Target Runner → Signing & Capabilities
2. Selecione seu Team no dropdown
3. Deixe "Automatically manage signing" marcado

### "Archive failed"
1. Limpe: Product → Clean Build Folder (⇧⌘K)
2. Feche e reabra o Xcode
3. Tente arquivar novamente

### "No such module 'Firebase'"
1. Feche o Xcode
2. Terminal:
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```
3. Reabra o Xcode

---

**Última atualização**: 30/10/2025  
**Versão do App**: 2.0.0+1  
**Status**: ✅ Pronto para TestFlight

**Bora subir! 🚀**
