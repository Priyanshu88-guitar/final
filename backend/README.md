# VOLTERA BACKEND API — PHASE 1: FOUNDATION & DATABASE SETUP

Welcome to the backend architecture for the **VOLTERA** EV Charging Platform.

---

## 🚀 Tech Stack

- **Runtime**: Node.js (v20+)
- **Language**: TypeScript
- **Framework**: Express.js
- **Database & ORM**: Prisma ORM (SQLite for local development/testing; supports PostgreSQL/MySQL in production)
- **Validation**: Zod
- **Testing**: Vitest + Supertest

---

## 📁 Project Architecture

The backend follows a layered separation of concerns:

```
Route → Controller → Service → Repository → Database
```

```
backend/
├── prisma/
│   ├── schema.prisma      # Prisma ORM Database Schema
│   └── migrations/        # Database Migrations
├── src/
│   ├── config/            # Environment, Database & Logger setup
│   ├── controllers/       # Route request handlers
│   ├── database/          # Prisma client singleton instance
│   ├── middleware/         # Express middlewares (Error, Logger, Validation)
│   ├── models/            # Domain interfaces and type definitions
│   ├── repositories/      # Database access abstraction
│   ├── routes/            # Express route declarations
│   ├── services/          # Core business logic
│   ├── utils/             # AppError, Response formatters, Sanitizers
│   ├── validators/        # Request validation schemas
│   ├── app.ts             # Express app setup
│   └── server.ts          # Application entrypoint & lifecycle
├── tests/                 # Automated test suite (Vitest + Supertest)
├── .env.example           # Example environment variables template
└── README.md              # Backend documentation
```

---

## 🛠️ Prerequisites & Required Software

- **Node.js**: v20.0.0 or higher
- **npm**: v9.0.0 or higher

---

## ⚙️ Environment Variables

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `PORT` | `3000` | HTTP Server port |
| `APP_ENV` | `development` | Application environment (`development`, `test`, `production`) |
| `DATABASE_URL` | `"file:./dev.db"` | Database connection string (SQLite, PostgreSQL, or MySQL) |
| `LOG_LEVEL` | `info` | Logger verbosity (`debug`, `info`, `warn`, `error`) |
| `CORS_ORIGIN` | `*` | Allowed CORS origins |

---

## 📥 Installation Steps

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

---

## 🗄️ Database Setup & Migrations

1. Generate Prisma Client:
   ```bash
   npm run prisma:generate
   ```

2. Run database migrations:
   ```bash
   npm run prisma:migrate
   ```

3. (Optional) Inspect the database using Prisma Studio:
   ```bash
   npm run prisma:studio
   ```

---

## 🏃 Running the Application

### Development Server (with auto-reload):
```bash
npm run dev
```

### Build TypeScript:
```bash
npm run build
```

### Production Server:
```bash
npm start
```

---

## 🧪 Testing

Run the automated test suite:
```bash
npm test
```

---

## 🏥 Health Check Endpoint

- **URL**: `GET /health` or `GET /api/v1/health`
- **Method**: `GET`
- **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "VOLTERA backend is running",
  "data": {
    "status": "ok",
    "timestamp": "2026-10-02T04:53:24.424Z",
    "environment": "development",
    "database": {
      "connected": true,
      "latencyMs": 2
    }
  }
}
```
