import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { pool } from "../config/db.js";

/**
 * 🔐 LOGIN
 */
export const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (result.rows.length === 0) {
      return res.status(400).json({ message: "Usuário não encontrado" });
    }

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.password_hash);

    if (!validPassword) {
      return res.status(400).json({ message: "Senha incorreta" });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    return res.status(200).json({
      message: "Login bem-sucedido",
      token,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
      },
    });
  } catch (err) {
    console.error("Erro no login:", err);
    return res.status(500).json({ message: "Erro no servidor", error: err.message });
  }
};

/**
 * 🧑‍💼 REGISTER (somente admin)
 */
export const registerUser = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    await pool.query(
      "INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, $4)",
      [name, email, hashedPassword, role || "oficina"]
    );

    return res.status(201).json({ message: "Usuário cadastrado com sucesso!" });
  } catch (err) {
    console.error("Erro ao registrar usuário:", err);
    return res.status(500).json({ message: "Erro no servidor", error: err.message });
  }
};

/**
 * 🧭 ROTA /auth/me — retorna dados do usuário autenticado
 */
export const getCurrentUser = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ message: "Token não fornecido" });
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const result = await pool.query(
      "SELECT id, name, email, role, is_active, created_at FROM users WHERE id = $1",
      [decoded.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Usuário não encontrado" });
    }

    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error("Erro ao buscar usuário:", error);
    return res.status(500).json({ message: "Erro no servidor", error: error.message });
  }
};
