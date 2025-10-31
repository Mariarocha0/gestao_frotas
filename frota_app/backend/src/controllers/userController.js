import bcrypt from "bcrypt";
import { pool } from "../config/db.js";

/** CREATE */
export const createUser = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ message: "Todos os campos são obrigatórios." });
    }

    const existing = await pool.query("SELECT 1 FROM users WHERE email = $1", [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ message: "Email já cadastrado." });
    }

    const password_hash = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role, is_active, created_at`,
      [name, email, password_hash, role]
    );

    return res.status(201).json({
      message: "Usuário criado com sucesso!",
      user: result.rows[0],
    });
  } catch (error) {
    console.error("Erro ao criar usuário:", error);
    return res.status(500).json({ message: "Erro interno ao criar usuário." });
  }
};

/** LIST */
export const listUsers = async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, name, email, role, is_active, created_at FROM users ORDER BY id"
    );
    return res.json({ users: result.rows });
  } catch (error) {
    console.error("Erro ao listar usuários:", error);
    return res.status(500).json({ message: "Erro interno ao listar usuários." });
  }
};

/** UPDATE (parcial) */
export const updateUser = async (req, res) => {
  try {
    const { id } = req.params; // users/:id
    const { name, email, password, role, is_active } = req.body;

    // monta SET dinâmico
    const fields = [];
    const values = [];
    let idx = 1;

    if (name !== undefined) { fields.push(`name = $${idx++}`); values.push(name); }
    if (email !== undefined) { fields.push(`email = $${idx++}`); values.push(email); }
    if (role !== undefined) { fields.push(`role = $${idx++}`); values.push(role); }
    if (is_active !== undefined) { fields.push(`is_active = $${idx++}`); values.push(is_active); }

    if (password) {
      const hash = await bcrypt.hash(password, 10);
      fields.push(`password_hash = $${idx++}`);
      values.push(hash);
    }

    if (fields.length === 0) {
      return res.status(400).json({ message: "Nenhum campo para atualizar." });
    }

    values.push(id);
    const sql = `
      UPDATE users
      SET ${fields.join(", ")}
      WHERE id = $${idx}
      RETURNING id, name, email, role, is_active, created_at
    `;
    const result = await pool.query(sql, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Usuário não encontrado." });
    }

    return res.json({ message: "Usuário atualizado!", user: result.rows[0] });
  } catch (error) {
    console.error("Erro ao atualizar usuário:", error);
    return res.status(500).json({ message: "Erro interno ao atualizar usuário." });
  }
};

/** DELETE (hard delete) */
export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING id", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Usuário não encontrado." });
    }

    return res.json({ message: "Usuário removido com sucesso." });
  } catch (error) {
    console.error("Erro ao excluir usuário:", error);
    return res.status(500).json({ message: "Erro interno ao excluir usuário." });
  }
};
