import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { pool } from "./src/config/db.js";
import authRouter from "./src/routes/authRoutes.js";
import vehiclesRouter from "./src/routes/vehiclesRoutes.js"; 

dotenv.config({ path: "./.env" });

const app = express();
app.use(cors());
app.use(express.json());

app.use("/auth", authRouter);

// rotas protegidas por middleware dentro do arquivo
app.use("/vehicles", vehiclesRouter);

// healthcheck
app.get("/", (_, res) => res.send("Servidor funcionando!"));

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













