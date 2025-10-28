import jwt from "jsonwebtoken";

/**
 * Extrai o token do header Authorization e valida a assinatura + expiração.
 * Se ok, coloca os dados do usuário em req.user e chama next().
 * Se falhar, responde 401/403.
 */
export function verifyToken(req, res, next) {
  try {
    const auth = req.headers.authorization || "";
    // Formato esperado: "Bearer <token>"
    const [scheme, token] = auth.split(" ");

    if (scheme !== "Bearer" || !token) {
      return res.status(403).json({ message: "Acesso negado. Token não fornecido." });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    return next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ message: "Token expirado. Faça login novamente." });
    }
    return res.status(401).json({ message: "Token inválido." });
  }
}

/**
 * Guarda de autorização por papel (role).
  * Verifica se req.user.role bate com o papel exigido.
  */
export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: "Não autenticado." });
    }
    if (req.user.role !== role) {
      return res.status(403).json({ message: "Acesso negado para este perfil." });
    }
    next();
  };
}
