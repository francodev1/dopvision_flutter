#!/bin/bash

# 🔥 Script de Deploy Firebase - DoPVision
# Autor: GitHub Copilot
# Data: 30/10/2025

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✔${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

# Banner
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔥 Firebase Deploy - DoPVision      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 1. Verificar se Firebase CLI está instalado
print_step "Verificando Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI não encontrado!"
    echo ""
    echo "Instale com: npm install -g firebase-tools"
    exit 1
fi
print_success "Firebase CLI encontrado: $(firebase --version)"
echo ""

# 2. Verificar login
print_step "Verificando autenticação..."
if ! firebase projects:list &> /dev/null; then
    print_warning "Não autenticado. Iniciando login..."
    firebase login
else
    print_success "Já autenticado"
fi
echo ""

# 3. Verificar/Selecionar projeto
print_step "Verificando projeto..."
CURRENT_PROJECT=$(firebase use 2>&1 | grep "Active Project" | awk '{print $3}' || echo "nenhum")

if [ "$CURRENT_PROJECT" != "dopvision-c384b" ]; then
    print_warning "Projeto atual: $CURRENT_PROJECT"
    print_step "Selecionando projeto dopvision-c384b..."
    firebase use dopvision-c384b
fi
print_success "Projeto: dopvision-c384b"
echo ""

# 4. Confirmar deploy
echo -e "${YELLOW}Você está prestes a fazer deploy de:${NC}"
echo "  📊 Firestore Rules"
echo "  📇 Firestore Indexes"
echo ""
echo -e "${BLUE}ℹ️  Storage não será deployado (plano gratuito)${NC}"
echo ""
read -p "Deseja continuar? (s/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_warning "Deploy cancelado pelo usuário"
    exit 0
fi
echo ""

# 5. Deploy Firestore Rules
print_step "Deploy das regras do Firestore..."
if firebase deploy --only firestore:rules; then
    print_success "Regras do Firestore deployadas"
else
    print_error "Falha ao deploar regras do Firestore"
    exit 1
fi
echo ""

# 6. Deploy Firestore Indexes
print_step "Deploy dos índices do Firestore..."
if firebase deploy --only firestore:indexes; then
    print_success "Índices do Firestore deployados"
    print_warning "⏳ Índices podem levar alguns minutos para serem criados"
else
    print_error "Falha ao deploar índices do Firestore"
    exit 1
fi
echo ""

# 7. Verificar status dos índices
print_step "Verificando status dos índices..."
echo ""
firebase firestore:indexes
echo ""

# 8. Resumo final
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✅ Deploy Concluído!           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "📊 Firestore Rules:  ✅ Deployado"
echo "📇 Firestore Indexes: ✅ Deployado (aguardando criação)"
echo "💾 Storage:          ⏭️  Pulado (não disponível no plano gratuito)"
echo ""
echo -e "${BLUE}🔗 Links úteis:${NC}"
echo "   Console: https://console.firebase.google.com/project/dopvision-c384b"
echo "   Firestore: https://console.firebase.google.com/project/dopvision-c384b/firestore"
echo ""
echo -e "${YELLOW}⚠️  Próximos passos:${NC}"
echo "   1. Aguardar criação dos índices (5-10 minutos)"
echo "   2. Testar o app: flutter run"
echo "   3. Monitorar uso: Firebase Console > Usage"
echo ""
echo -e "${BLUE}ℹ️  Nota sobre Storage:${NC}"
echo "   Upload de imagens não estará disponível sem Firebase Storage."
echo "   Alternativas gratuitas: Cloudinary, ImgBB, ou Base64 no Firestore."
echo ""
print_success "Tudo pronto! 🎉"
echo ""

echo ""

# Verificar índices
echo "🔍 Verificando índices criados..."
firebase firestore:indexes

echo ""
echo "📚 Próximos passos:"
echo "1. Verifique no Firebase Console:"
echo "   https://console.firebase.google.com/project/$PROJECT"
echo ""
echo "2. Teste as regras de segurança:"
echo "   - No Firebase Console > Firestore > Rules > Playground"
echo "   - Ou localmente: firebase emulators:start"
echo ""
echo "3. Monitore os logs:"
echo "   - Firebase Console > Firestore > Usage"
echo ""

echo -e "${GREEN}🎉 Tudo pronto!${NC}"
