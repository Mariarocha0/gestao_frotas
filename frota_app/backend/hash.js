import bcrypt from "bcrypt";

const gerarHash = async () => {
  const hash = await bcrypt.hash("123456", 10);
  console.log("Hash gerado:", hash);
};

gerarHash();
