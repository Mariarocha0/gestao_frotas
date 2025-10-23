import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { pool } from "./src/config/db.js";
import authRouter from "./src/routes/authRoutes.js";

dotenv.config({ path: "./.env" });
const app = express();
app.use(cors());
app.use(express.json());

// Aqui conectamos o router
app.use("/auth", authRouter);

// Teste simples para ver se o servidor responde
app.get("/", (req, res) => {
  res.send("Servidor funcionando!");
});

// Teste de conexão com o banco ao iniciar o servidor
try {
  const result = await pool.query("SELECT table_name FROM information_schema.tables WHERE table_schema='public';");
  console.log("🔍 Tabelas encontradas no banco:", result.rows);
} catch (err) {
  console.error("Erro ao consultar tabelas:", err.message);
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, async () => {
  try {
    const result = await pool.query("SELECT NOW()");
    console.log("✅ Conectado ao PostgreSQL:", result.rows[0]);
    console.log(`✅ Servidor rodando na porta ${PORT}`);
  } catch (err) {
    console.error("Erro ao conectar ao banco:", err.message);
  }
});
