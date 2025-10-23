import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { pool } from "../config/db.js";

// LOGIN
export const login = async (req, res) => {
  const { email, password } = req.body;
  try {
    console.time("loginTime");
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    console.timeEnd("loginTime");
    if (result.rows.length === 0) return res.status(400).json({ message: "Usuário não encontrado" });

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(400).json({ message: "Senha incorreta" });

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.status(200).json({
      message: "Login bem-sucedido",
      token,
      user: { id: user.id, nome: user.nome, role: user.role },
    });
  } catch (err) {
    res.status(500).json({ message: "Erro no servidor", error: err.message });
  }
};

// REGISTER (somente admin)
export const registerUser = async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Token não fornecido" });

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // ⚠️ só permite se for admin
    if (decoded.role !== "admin") {
      return res.status(403).json({ message: "Apenas administradores podem cadastrar usuários" });
    }

    const { nome, email, password, role } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    await pool.query(
      "INSERT INTO users (nome, email, password, role) VALUES ($1, $2, $3, $4)",
      [nome, email, hashedPassword, role || "user"]
    );

    res.status(201).json({ message: "Usuário cadastrado com sucesso" });
  } catch (err) {
    res.status(401).json({ message: "Token inválido ou expirado", error: err.message });
  }
};
