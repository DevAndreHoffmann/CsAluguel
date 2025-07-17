// ================================================================
// CONFIGURAÇÃO SUPABASE - CS ALUGUEL DE MESA E PULA PULA
// Sistema 100% Supabase
// ================================================================

console.log('🔧 Inicializando Supabase...');

// Verificar se supabase está disponível
if (typeof supabase === 'undefined') {
    console.error('❌ ERRO: Supabase JS não foi carregado!');
    throw new Error('Supabase JS library não encontrada');
}



// Configurações do Supabase
const SUPABASE_URL = 'https://auipbmfmzzftgareozly.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1aXBibWZtenpmdGdhcmVvemx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3NTkzODksImV4cCI6MjA2ODMzNTM4OX0.5zCJNljxLZ0eOLd17dJGazEhHIYpX_y5TcU-BzsVSkw';

// Inicializar cliente Supabase
const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

console.log('✅ Supabase Client criado:', supabaseClient);

// ================================================================
// CLASSE SUPABASE ROOM - INTERFACE DE DADOS
// ================================================================
class SupabaseRoom {
    constructor() {
        this.subscriptions = new Map();
    }

    // Interface de coleções
    collection(tableName) {
        return {
            // UPSERT (INSERT/UPDATE)
            upsert: async (data) => {
                try {
                    const { data: result, error } = await supabaseClient
                        .from(tableName)
                        .upsert(data)
                        .select();
                    
                    if (error) {
                        console.error(`Erro ao salvar em ${tableName}:`, error);
                        throw error;
                    }
                    
                    console.log(`✅ Dados salvos em ${tableName}:`, result);
                    return result;
                } catch (error) {
                    console.error(`❌ Falha ao salvar em ${tableName}:`, error);
                    throw error;
                }
            },

            // DELETE
            delete: async (id) => {
                try {
                    const { data, error } = await supabaseClient
                        .from(tableName)
                        .delete()
                        .eq('id', id);
                    
                    if (error) {
                        console.error(`Erro ao deletar de ${tableName}:`, error);
                        throw error;
                    }
                    
                    console.log(`🗑️ Item deletado de ${tableName}:`, id);
                    return data;
                } catch (error) {
                    console.error(`❌ Falha ao deletar de ${tableName}:`, error);
                    throw error;
                }
            },

            // SELECT/READ
            select: async (query = '*') => {
                try {
                    const { data, error } = await supabaseClient
                        .from(tableName)
                        .select(query);
                    
                    if (error) {
                        console.error(`Erro ao ler de ${tableName}:`, error);
                        throw error;
                    }
                    
                    return data || [];
                } catch (error) {
                    console.error(`❌ Falha ao ler de ${tableName}:`, error);
                    throw error;
                }
            },

            // SUBSCRIBE (Real-time)
            subscribe: (callback) => {
                console.log(`🔄 Criando subscription para ${tableName}`);
                
                // Carregar dados iniciais
                this.select().then(callback).catch(console.error);
                
                // Configurar subscription em tempo real
                const subscription = supabaseClient
                    .channel(`${tableName}-changes`)
                    .on('postgres_changes', 
                        { 
                            event: '*', 
                            schema: 'public', 
                            table: tableName 
                        }, 
                        async (payload) => {
                            console.log(`📡 Mudança detectada em ${tableName}:`, payload);
                            
                            // Recarregar todos os dados quando houver mudança
                            try {
                                const updatedData = await this.select();
                                callback(updatedData);
                            } catch (error) {
                                console.error(`Erro ao recarregar ${tableName}:`, error);
                            }
                        }
                    )
                    .subscribe();

                // Armazenar subscription para cleanup posterior
                this.subscriptions.set(tableName, subscription);
                
                return subscription;
            }
        };
    }

    // Método para limpar todas as subscriptions
    cleanup() {
        console.log('🧹 Limpando subscriptions...');
        this.subscriptions.forEach((subscription, tableName) => {
            supabaseClient.removeChannel(subscription);
            console.log(`❌ Subscription removida: ${tableName}`);
        });
        this.subscriptions.clear();
    }
}

// ================================================================
// INSTÂNCIA GLOBAL - ROOM SUPABASE
// ================================================================
console.log('🏠 Criando instância room...');
const room = new SupabaseRoom();
console.log('✅ Room criada:', room);

// Garantir que room está disponível globalmente
window.room = room;

// ================================================================
// FUNÇÕES AUXILIARES
// ================================================================

// Testar conexão com Supabase
async function testSupabaseConnection() {
    try {
        console.log('🔍 Testando conexão com Supabase...');
        
        const { data, error } = await supabaseClient
            .from('clients')
            .select('count')
            .limit(1);
        
        if (error && error.code !== 'PGRST116') { // PGRST116 = tabela não existe ainda
            throw error;
        }
        
        console.log('✅ Conexão com Supabase OK!');
        return true;
    } catch (error) {
        console.error('❌ Erro na conexão com Supabase:', error);
        return false;
    }
}

// Inicializar Supabase ao carregar a página
document.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 Inicializando Supabase...');
    
    const isConnected = await testSupabaseConnection();
    
    if (isConnected) {
        console.log('📊 Supabase configurado com sucesso!');
        console.log('🏢 URL:', SUPABASE_URL);
        console.log('🔑 Chave configurada');
    } else {
        console.warn('⚠️ Problema na conexão com Supabase. Verifique as credenciais.');
    }
});

// Cleanup ao sair da página
window.addEventListener('beforeunload', () => {
    room.cleanup();
});

// ================================================================
// FUNÇÕES DE DEBUG (OPCIONAL)
// ================================================================

// Função para debug - listar todas as tabelas
window.debugSupabase = {
    // Testar inserção
    testInsert: async () => {
        const testClient = {
            id: String(Date.now()),
            name: 'Cliente Teste',
            phone: '(11) 99999-9999',
            address: { city: 'São Paulo', state: 'SP' }
        };
        
        try {
            await room.collection('clients').upsert(testClient);
            console.log('✅ Teste de inserção OK');
        } catch (error) {
            console.error('❌ Falha no teste:', error);
        }
    },

    // Listar dados
    listAll: async () => {
        const clients = await room.collection('clients').select();
        const inventory = await room.collection('inventory').select();
        const bookings = await room.collection('bookings').select();
        
        console.log('👥 Clientes:', clients);
        console.log('📦 Estoque:', inventory);
        console.log('📅 Agendamentos:', bookings);
    },

    // Limpar dados de teste
    cleanup: async () => {
        console.log('🧹 Limpando dados de teste...');
        // Implementar se necessário
    }
};

console.log('🎯 Supabase configurado! Use window.debugSupabase para testes.'); 