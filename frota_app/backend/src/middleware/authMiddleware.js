import jwt from "jsonwebtoken";

/**
 * Middleware que valida o token JWT
 * Se válido, adiciona `req.user` e segue.
 */
export function verifyToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";
    const [scheme, token] = authHeader.split(" ");

    if (scheme !== "Bearer" || !token) {
      return res.status(403).json({ success: false, message: "Acesso negado. Token não fornecido." });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    console.log("✅ Token verificado:", decoded);
    return next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ success: false, message: "Token expirado. Faça login novamente." });
    }
    return res.status(401).json({ success: false, message: "Token inválido." });
  }
}

/**
 * Middleware para limitar acesso por papel (role)
 */
export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: "Não autenticado." });
    }
    if (req.user.role !== role) {
      return res.status(403).json({ success: false, message: "Acesso negado para este perfil." });
    }
    next();
  };
}
