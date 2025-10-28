import { Router } from "express";
import { verifyToken, requireRole } from "../middleware/authMiddleware.js";

const router = Router();

// TODAS as rotas de vehicles exigem estar logado
router.use(verifyToken);

// GET /vehicles  (qualquer usuário autenticado)
router.get("/", async (req, res) => {
  return res.json({
    message: `Olá ${req.user.email}, você acessou /vehicles!`,
    user: req.user,
    items: [], 
  });
});

// POST /vehicles  (somente admin pode criar)
router.post("/", requireRole("admin"), async (req, res) => {
  return res.status(201).json({ message: "Veículo criado (exemplo)." });
});

export default router;
