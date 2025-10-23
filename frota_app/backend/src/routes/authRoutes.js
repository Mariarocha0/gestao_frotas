import express from "express";
import { login, registerUser } from "../controllers/authController.js";

const router = express.Router();

router.post("/login", login);
router.post("/register", registerUser);

export default router;
console.log("✅ authRoutes carregado com sucesso");
