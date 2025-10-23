import jwt from "jsonwebtoken";
import dotenv from "dotenv";
dotenv.config();

export const verificarToken = (req, res, next) => {
  const token = req.headers["authorization"];

  if (!token) {
    return res.status(403).json({ message: "Acesso negado. Token não fornecido." });
  }

  try {
    // Remove o prefixo "Bearer " se estiver presente
    const tokenLimpo = token.replace("Bearer ", "");

    const decoded = jwt.verify(tokenLimpo, process.env.JWT_SECRET);
    req.user = decoded; // Armazena os dados do usuário (id, role, etc.) na requisição
    next();
  } catch (err) {
    return res.status(401).json({ message: "Token inválido ou expirado." });
  }
};
