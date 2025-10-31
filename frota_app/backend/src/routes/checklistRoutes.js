import express from "express";
import { verifyToken, requireRole } from "../middleware/authMiddleware.js";
import {
  createChecklist,
  listChecklists,
  updateChecklist,
  deleteChecklist
} from "../controllers/checklistController.js";

const router = express.Router();

// Oficina cria o checklist
router.post("/", verifyToken, requireRole("oficina"), createChecklist);

// Admin pode visualizar, editar e excluir
router.get("/", verifyToken, requireRole("admin"), listChecklists);
router.put("/:id", verifyToken, requireRole("admin"), updateChecklist);
router.delete("/:id", verifyToken, requireRole("admin"), deleteChecklist);

export default router;
