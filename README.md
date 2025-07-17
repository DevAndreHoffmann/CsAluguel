# 🎪 CS Aluguel - Sistema de Gestão de Mesas e Pula Pula

Sistema completo para gerenciamento de aluguel de mesas, cadeiras e brinquedos infláveis com integração Supabase.

## 🚀 Deploy

**URL do Sistema**: https://cs-aluguel.vercel.app/

## 🔐 Credenciais de Acesso

- **Usuário**: `pedropsf2011@gmail.com`
- **Senha**: `123456789`

## 🛠️ Tecnologias

- **Frontend**: HTML5, CSS3, JavaScript Vanilla
- **Backend**: Supabase (PostgreSQL)
- **Deploy**: Vercel
- **Design**: Responsivo (Mobile-First)

## 📊 Funcionalidades

### ✅ Gestão de Clientes
- Cadastro completo com endereço principal e local da festa
- Validação de CPF em tempo real
- Busca e edição de dados

### ✅ Controle de Estoque
- Inventário dinâmico com preços flexíveis
- Cálculo automático de disponibilidade
- Gestão de custos vs preços de aluguel

### ✅ Sistema de Reservas
- Verificação automática de conflitos de horário
- Gestão de eventos com data e horário
- Cálculo automático de preços
- Status de pagamento

### ✅ Relatórios Financeiros
- Análise de lucro por período
- Relatórios de custos vs receitas
- Estatísticas de utilização de equipamentos

## 🗃️ Estrutura do Banco de Dados

### Tabela: `clients`
```sql
- id (varchar, PK)
- name (varchar)
- phone (varchar) 
- email (varchar)
- cpf (varchar)
- address (jsonb) - {street, number, city, zip}
- party_address (jsonb) - {street, number, city, zip}
```

### Tabela: `inventory`
```sql
- id (varchar, PK)
- name (varchar)
- quantity (integer)
- cost (numeric)
- rental_price (numeric)
```

### Tabela: `bookings`
```sql
- id (varchar, PK)
- client_id (varchar, FK)
- event_name (varchar)
- date (date)
- start_time (time)
- end_time (time)
- items (jsonb) - [{id, name, quantity}]
- price (numeric)
- payment_method (varchar)
- payment_status (varchar)
- event_address (jsonb)
- observations (text)
- contract_data_url (varchar)
```

## 🔧 Configuração Local

1. Clone o repositório:
```bash
git clone https://github.com/DevAndreHoffmann/CsAluguel.git
```

2. Configure as variáveis do Supabase em `supabase-config.js`:
```javascript
const SUPABASE_URL = 'https://auipbmfmzzftgareozly.supabase.co';
const SUPABASE_ANON_KEY = 'sua_chave_aqui';
```

3. Execute o schema SQL no Supabase:
```bash
# Execute o arquivo schema.sql no SQL Editor do Supabase
```

## 📱 Interface

- **Design Responsivo**: Otimizado para mobile e desktop
- **Navegação por Abas**: Clientes, Estoque, Reservas, Relatórios
- **Modais Dinâmicos**: Cadastro e edição em popups
- **Validação em Tempo Real**: CPF, conflitos de horário, disponibilidade

## 🎯 Status do Projeto

✅ **PROJETO LIMPO**: Repositório contém apenas os arquivos essenciais  
✅ **WEBSIM ELIMINADO**: Todas as referências foram removidas  
✅ **SUPABASE INTEGRADO**: Sistema 100% funcional  
✅ **DEPLOY ATIVO**: https://cs-aluguel.vercel.app/  

## 📄 Arquivos do Projeto

- `index.html` - Interface principal do sistema
- `script.js` - Lógica de negócio e manipulação do DOM
- `style.css` - Estilos responsivos e design
- `supabase-config.js` - Configuração e integração com Supabase
- `schema.sql` - Script de criação do banco de dados
- `package.json` - Configurações de deploy
- `vercel.json` - Configurações do Vercel
- `logo.png` + `cs.png` - Assets visuais
- `index-original.html` - Backup da versão original

---

**Desenvolvido com ❤️ para CS Aluguel** 