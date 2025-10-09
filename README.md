# 🚌 Gestão de Frotas

Um projeto full-stack criado com propósito: **aprender fazendo**.  
Aqui nasce um sistema completo de **gestão de frotas**, conectando backend, banco de dados e aplicativo mobile.  
Feito para impulsionar o estágio, fortalecer o portfólio e provar que teoria e prática podem rodar na mesma estrada. 🚦

> “Do tanque ao destino — dados que dirigem decisões.”

---

## 🧩 Stack Principal
| Camada | Tecnologia | Função |
|--------|-------------|--------|
| 🐘 Banco de Dados | **PostgreSQL** | Armazena informações de veículos, motoristas e manutenções |
| 💡 ORM | **Prisma** | Conecta Node.js ao PostgreSQL com segurança e tipagem |
| ⚡ Backend | **Node.js + Express** | Criação da API REST e autenticação JWT |
| 🧭 Frontend | **Flutter (Dart)** | Interface mobile para usuários e gestores |
| 🔐 Segurança | **JWT + bcrypt** | Autenticação e criptografia de senhas |
| ☁️ Deploy | **Render** | Hospedagem do backend e banco de dados |
| 🧪 Testes | **Jest / Supertest** | Garantia de qualidade no backend |

---

## 🗂️ Funcionalidades
- Cadastro e gerenciamento de **veículos**, **motoristas** e **rotas**
- Controle de **abastecimentos, manutenções e custos**
- **Autenticação JWT** e controle de acesso
- **Relatórios e histórico** com base no banco de dados
- Integração total entre **Flutter + API Node + PostgreSQL**

---

## ⚙️ Como rodar localmente

### 1️⃣ Backend
```bash
# Clonar repositório
git clone https://github.com/SEU-USUARIO/gestao_frotas.git
cd gestao_frotas/backend

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# edite .env com suas credenciais do PostgreSQL

# Criar tabelas e iniciar Prisma
npx prisma migrate dev --name init


## 🎯 Objetivo
Este projeto é parte do estágio em Engenharia de Software, com o objetivo de aplicar práticas reais de desenvolvimento full-stack, integração contínua e boas práticas de arquitetura.

## 👩‍💻 Autora
Maria Luiza Ribeiro Rocha (eu)
Engenharia de Software - UNIPAMPA
💬 “Construindo full-stack, uma rota por vez.”
📧 [contato.marialuizaribeiro@gmail.com]
🌐 https://www.linkedin.com/in/marialuizaribeirorocha/


