import { Router } from "express";
import { login, registerUser, getCurrentUser } from "../controllers/authController.js";
import { verifyToken } from "../middleware/authMiddleware.js";

const router = Router();

router.post("/login", login);
router.post("/register", verifyToken, registerUser);
router.get("/me", verifyToken, getCurrentUser); 

export default router;
