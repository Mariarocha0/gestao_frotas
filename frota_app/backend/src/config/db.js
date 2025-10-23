import pkg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const { Pool } = pkg;

// 🔥 Pool global (não crie dentro de cada rota)
export const pool = new Pool({
  host: process.env.PGHOST || '127.0.0.1',
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  port: process.env.PGPORT || 5432,
  max: 10, // até 10 conexões abertas simultaneamente
  idleTimeoutMillis: 30000, // fecha conexões ociosas
  connectionTimeoutMillis: 2000 // tempo máximo pra abrir conexão
});

// Teste de conexão (opcional)
pool.connect()
  .then(() => console.log('✅ Pool conectado ao PostgreSQL'))
  .catch(err => console.error('❌ Erro na conexão com o banco:', err));
