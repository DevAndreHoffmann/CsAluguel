-- ================================================================
-- SCHEMA SUPABASE - CS ALUGUEL DE MESA E PULA PULA
-- Sistema: CS Aluguel de Mesa e Pula Pula
-- Data: $(date)
-- Versão: 1.0.0
-- ================================================================

-- Remover tabelas se existirem (cuidado em produção!)
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS clients CASCADE;

-- ================================================================
-- TABELA 1: CLIENTS (Gestão de Clientes)
-- ================================================================
CREATE TABLE clients (
    id TEXT PRIMARY KEY,                    -- ID único (gerado via Date.now())
    name TEXT NOT NULL,                     -- Nome completo (obrigatório)
    phone TEXT,                             -- Telefone (opcional)
    email TEXT,                             -- Email (opcional)
    cpf TEXT,                               -- CPF/CNPJ (opcional)
    address JSONB NOT NULL DEFAULT '{}',    -- Endereço principal
    party_address JSONB DEFAULT '{}',       -- Endereço da festa (opcional)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ================================================================
-- TABELA 2: INVENTORY (Controle de Estoque)
-- ================================================================
CREATE TABLE inventory (
    id TEXT PRIMARY KEY,                    -- ID único (slug do nome)
    name TEXT NOT NULL,                     -- Nome do item
    quantity INTEGER NOT NULL DEFAULT 0,   -- Quantidade em estoque
    cost DECIMAL(10,2) DEFAULT 0,          -- Custo de aquisição
    rental_price DECIMAL(10,2) DEFAULT 0,  -- Preço de aluguel por unidade
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ================================================================
-- TABELA 3: BOOKINGS (Agendamentos/Reservas)
-- ================================================================
CREATE TABLE bookings (
    id TEXT PRIMARY KEY,                        -- ID único (gerado via Date.now())
    client_id TEXT NOT NULL,                    -- FK para clients.id
    event_name TEXT NOT NULL,                   -- Nome do evento
    date DATE NOT NULL,                         -- Data do evento (YYYY-MM-DD)
    start_time TIME,                           -- Hora de início (HH:MM)
    end_time TIME,                             -- Hora de término (HH:MM)
    items JSONB NOT NULL DEFAULT '{}',         -- Itens reservados {item_id: quantidade}
    price DECIMAL(10,2),                       -- Preço total negociado
    payment_method TEXT,                       -- Forma de pagamento
    payment_status TEXT DEFAULT 'Pendente',   -- Status: Pendente|Pago|Parcial
    event_address JSONB DEFAULT '{}',          -- Endereço do evento
    observations TEXT,                         -- Observações adicionais
    contract_data_url TEXT,                    -- URL do contrato anexado
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT fk_booking_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    CONSTRAINT check_end_after_start CHECK (end_time > start_time),
    CONSTRAINT check_payment_status CHECK (payment_status IN ('Pendente', 'Pago', 'Parcial')),
    CONSTRAINT check_payment_method CHECK (payment_method IN ('Pix', 'Cartão de Crédito', 'Cartão de Débito', 'Dinheiro', 'Transferência'))
);

-- ================================================================
-- ÍNDICES PARA PERFORMANCE
-- ================================================================

-- Índices para tabela clients
CREATE INDEX idx_clients_name_lower ON clients(LOWER(name));
CREATE INDEX idx_clients_cpf ON clients(cpf);
CREATE INDEX idx_clients_phone ON clients(phone);

-- Índices para tabela inventory  
CREATE INDEX idx_inventory_name ON inventory(name);
CREATE INDEX idx_inventory_quantity ON inventory(quantity);

-- Índices para tabela bookings (CRÍTICOS para performance)
CREATE INDEX idx_bookings_date ON bookings(date);
CREATE INDEX idx_bookings_client_id ON bookings(client_id);
CREATE INDEX idx_bookings_date_time ON bookings(date, start_time, end_time);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX idx_bookings_event_name ON bookings(event_name);

-- ================================================================
-- FUNÇÕES E TRIGGERS PARA UPDATED_AT
-- ================================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para todas as tabelas
CREATE TRIGGER update_clients_updated_at 
    BEFORE UPDATE ON clients 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at 
    BEFORE UPDATE ON inventory 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at 
    BEFORE UPDATE ON bookings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================================
-- DADOS INICIAIS (OPCIONAL)
-- ================================================================

-- Inserir itens padrão do estoque (Quick Add Items)
INSERT INTO inventory (id, name, quantity, cost, rental_price) VALUES
('mesa-redonda', 'Mesa Redonda', 10, 50.00, 100.00),
('mesa-retangular', 'Mesa Retangular', 15, 60.00, 120.00),
('cadeira-plastica', 'Cadeira Plástica', 100, 15.00, 30.00),
('toalha-de-mesa', 'Toalha de Mesa', 25, 10.00, 20.00),
('tenda-3x3', 'Tenda 3x3', 5, 300.00, 600.00),
('pula-pula', 'Pula Pula', 2, 1500.00, 200.00),
('jogo-de-mesa', 'Jogo de Mesa', 20, 80.00, 150.00),
('aparelho-de-som', 'Aparelho de Som', 3, 500.00, 1000.00);

-- ================================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ================================================================

-- Estrutura JSONB para address/party_address:
-- {
--   "zip": "00000-000",
--   "street": "Rua/Av",
--   "number": "123",
--   "complement": "Apto 45",
--   "neighborhood": "Bairro",
--   "city": "Cidade",
--   "state": "SP"
-- }

-- Estrutura JSONB para items em bookings:
-- {
--   "mesa-redonda": 5,
--   "cadeira-plastica": 20,
--   "tenda-3x3": 1
-- }

-- ================================================================
-- FIM DO SCHEMA
-- ================================================================

-- Para executar este arquivo no Supabase:
-- 1. Acesse o dashboard do Supabase
-- 2. Vá em "SQL Editor"
-- 3. Cole este código e execute
-- 4. Verifique se todas as tabelas foram criadas
-- 5. Teste inserindo alguns dados de exemplo

SELECT 'Schema criado com sucesso! Tabelas: clients, inventory, bookings' as status; 