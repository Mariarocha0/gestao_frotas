import express from "express";
import { verifyToken, requireRole } from "../middleware/authMiddleware.js";
import {
  listUsers,
  createUser,
  updateUser,
  deleteUser,
} from "../controllers/userController.js";

const router = express.Router();

// Todas as demais rotas exigem ADMIN
router.use(verifyToken, requireRole("admin"));

router.get("/", listUsers);        // GET /users
router.post("/", createUser);      // POST /users
router.put("/:id", updateUser);    // PUT /users/:id
router.delete("/:id", deleteUser); // DELETE /users/:id

export default router;
