# AiCU Project

## 구조
- backend: `aicu-todo-api` (Nest + Prisma + PostgreSQL, PORT=4000)
- web: `aicu-todo-web` (Next.js, PORT=3000 or 3001)

## 빠른 실행
### Backend
```bash
cd aicu-todo-api
cp .env.example .env  # 없으면 아래 예시값 복사
npm i
npx prisma migrate dev
npm run start:dev
Swagger: http://localhost:4000/api

Web
bash
코드 복사
cd aicu-todo-web
echo "NEXT_PUBLIC_API_BASE=http://localhost:4000" > .env.local
npm i
npm run dev
기능
회원가입/로그인(JWT)

Todo CRUD(인증)

테스트 계정 (예시)
email: test@example.com

password: secret123

bash
코드 복사

**.env 예시(백엔드)** → `aicu-todo-api/.env.example` 파일로:
DATABASE_URL="postgresql://aicu:aicu123@localhost:5432/aicu_todo?schema=public"
JWT_SECRET="devsecret"
JWT_EXPIRES="1d"
PORT=4000

sql
코드 복사

커밋:
```bash
git add .
git commit -m "docs: add README and env examples"
git push
