import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { pool } from "./src/config/db.js";
import authRouter from "./src/routes/authRoutes.js";
import vehiclesRouter from "./src/routes/vehiclesRoutes.js";
import userRouter from "./src/routes/userRoutes.js";

dotenv.config({ path: "./.env" });

const app = express();
const PORT = process.env.PORT || 3000;

// 🔹 Middlewares
app.use(cors({ origin: "*" })); // permite acesso do app Flutter
app.use(express.json());

// 🔹 Rotas principais
app.use("/auth", authRouter);
app.use("/users", userRouter);
app.use("/vehicles", vehiclesRouter);

// 🔹 Healthcheck
app.get("/", (_, res) => {
  res.status(200).json({
    status: "ok",
    message: "🚍 Servidor de Gestão de Frotas funcionando!",
  });
});

// 🔹 Inicialização segura do servidor
const startServer = async () => {
  try {
    const result = await pool.query("SELECT NOW()");
    console.log("✅ Banco de dados conectado:", result.rows[0]);

    app.listen(PORT, () => {
      console.log(`🚀 Servidor rodando em http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("❌ Erro ao conectar ao banco:", err.message);
    process.exit(1); // encerra se falhar no banco
  }
};

startServer();

// 🔹 Captura erros inesperados
process.on("unhandledRejection", (err) => {
  console.error("⚠️ Erro não tratado:", err);
  process.exit(1);
});
