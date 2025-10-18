import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { pool } from "./src/config/db.js";

pool.query("SELECT NOW()", (err, res) => {
  if (err) console.error("❌ Erro na conexão:", err);
  else console.log("✅ Conectado ao PostgreSQL:", res.rows[0].now);
});


dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Rota de teste
app.get("/", (req, res) => {
  res.send("🚚 API Gestão de Frotas rodando com sucesso!");
});

// Porta do servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Servidor rodando na porta ${PORT}`));


