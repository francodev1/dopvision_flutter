#!/bin/bash

# 🔥 Limpeza e Verificação da Estrutura Firebase - DoPVision
# Remove todos os documentos e deixa apenas a estrutura configurada
# Autor: GitHub Copilot
# Data: 30/10/2025

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔥 Limpeza do Firestore - DoPVision                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_error "⚠️  ATENÇÃO: Este script irá DELETAR TODOS OS DADOS!"
print_warning "Isso inclui:"
echo "   - Todos os usuários"
echo "   - Todos os clientes"
echo "   - Todas as campanhas"
echo "   - Todas as vendas"
echo "   - Todas as notificações"
echo "   - Todas as configurações"
echo ""
read -p "Tem CERTEZA ABSOLUTA que deseja continuar? (digite 'SIM' em maiúsculas): " confirm
echo ""
if [ "$confirm" != "SIM" ]; then
    print_warning "Operação cancelada (você digitou: $confirm)"
    exit 0
fi
echo ""

# Verificar se Firebase CLI está instalado
print_step "Verificando Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI não encontrado!"
    echo "Instale com: npm install -g firebase-tools"
    exit 1
fi
print_success "Firebase CLI encontrado"
echo ""

# Verificar projeto
print_step "Verificando projeto..."
firebase use dopvision-c384b
print_success "Projeto: dopvision-c384b"
echo ""

# Deletar tudo
print_step "Deletando TODOS os documentos..."
firebase firestore:delete --all-collections -r
echo ""

# Redesenhar regras e índices
print_step "Redesenhando regras e índices..."
firebase deploy --only firestore:rules,firestore:indexes
echo ""

# Verificar status
print_step "Verificando índices..."
firebase firestore:indexes
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ Firestore Limpo e Pronto!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "📋 Estrutura configurada:"
echo "   ✅ Regras de segurança: ATIVAS"
echo "   ✅ 13 Índices composite: CRIADOS"
echo "   ✅ Banco de dados: LIMPO (0 documentos)"
echo ""
echo "📊 Coleções prontas para uso:"
echo "   • users/          (criar no primeiro registro)"
echo "   • clients/        (criar via app)"
echo "   • campaigns/      (criar via app)"
echo "   • sales/          (criar via app)"
echo "   • notifications/  (futuro)"
echo "   • settings/       (futuro)"
echo "   • analytics/      (futuro)"
echo ""
echo -e "${BLUE}🚀 Próximos passos:${NC}"
echo "   1. flutter run"
echo "   2. Criar sua primeira conta"
echo "   3. Criar um cliente"
echo "   4. Criar uma campanha"
echo "   5. Registrar uma venda"
echo ""
print_success "Tudo limpo e pronto! 🎉"
echo ""
