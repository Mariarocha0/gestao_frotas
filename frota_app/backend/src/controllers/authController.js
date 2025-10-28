import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { pool } from "../config/db.js";

/**
 *   LOGIN
 * - Verifica se o usuário existe.
 * - Compara senha com hash do banco.
 * - Retorna um token JWT se for válido.
 */
export const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    console.time("loginTime");

    // 1️ Busca o usuário no banco
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    console.timeEnd("loginTime");

    if (result.rows.length === 0) {
      return res.status(400).json({ message: "Usuário não encontrado" });
    }

    const user = result.rows[0];

    // 2️ Compara a senha recebida com o hash do banco
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(400).json({ message: "Senha incorreta" });
    }

    // 3️ Gera o token JWT
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role, // importante para autenticação por cargo
      },
      process.env.JWT_SECRET, // segredo definido no .env
      { expiresIn: "1h" } // token expira em 1 hora
    );

    // 4 Retorna o token e dados básicos do usuário
    res.status(200).json({
      message: "Login bem-sucedido",
      token,
      user: {
        id: user.id,
        nome: user.nome,
        role: user.role,
      },
    });

  } catch (err) {
    // Se algo der errado no servidor
    console.error("Erro no login:", err);
    res.status(500).json({ message: "Erro no servidor", error: err.message });
  }
};


/**
 *   REGISTER USER (somente ADMIN)
 * - Apenas usuários com role "admin" podem cadastrar novos usuários.
 * - Verifica o token JWT antes de permitir o cadastro.
 */
export const registerUser = async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: "Token não fornecido" });
  }

  const token = authHeader.split(" ")[1]; // remove o "Bearer "
  try {
    // 1️ Verifica e decodifica o token JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 2️ Garante que o usuário seja ADMIN
    if (decoded.role !== "admin") {
      return res.status(403).json({ message: "Apenas administradores podem cadastrar usuários" });
    }

    // 3️ Recebe os dados do novo usuário
    const { nome, email, password, role } = req.body;

    // 4️ Criptografa a senha antes de salvar
    const hashedPassword = await bcrypt.hash(password, 10);

    // 5️ Insere no banco de dados
    await pool.query(
      "INSERT INTO users (nome, email, password, role) VALUES ($1, $2, $3, $4)",
      [nome, email, hashedPassword, role || "user"]
    );

    res.status(201).json({ message: "Usuário cadastrado com sucesso" });

  } catch (err) {
    console.error("Erro ao registrar usuário:", err);
    res.status(401).json({ message: "Token inválido ou expirado", error: err.message });
  }
};
