
풀스택 연습용 모노레포입니다.  
**Backend:** Nest.js + Prisma + PostgreSQL (JWT, 쿠키 기반 인증)  
**Frontend:** Next.js (TypeScript, HTTP-only 쿠키 세션)  
**Mobile:** Flutter (추가 예정)

## 폴더 구조
- `aicu-todo-api/` — Nest.js 백엔드 (Swagger: `/api`)
- `aicu-todo-web/` — Next.js 프론트엔드 (쿠키 기반 인증)
- `docs/` — 스크린샷/기타 문서(선택)

## 빠른 실행

### 1) Backend (Nest.js)
1. 환경 변수
cp aicu-todo-api/.env.example aicu-todo-api/.env

arduino
코드 복사
2. 설치/마이그레이션/실행
```bash
cd aicu-todo-api
npm i
npx prisma generate
npx prisma migrate dev
npm run start:dev
확인

Swagger: http://localhost:4000/api

루트 / → /api로 리다이렉트

2) Frontend (Next.js)
환경 변수

bash
코드 복사
cd aicu-todo-web
echo "NEXT_PUBLIC_API_BASE=http://localhost:4000" > .env.local
설치/실행

bash
코드 복사
npm i
npm run dev
확인

http://localhost:3000 (이미 점유면 자동으로 3001)

페이지: /login, /register, /todos

환경 변수
Backend (aicu-todo-api/.env)
DATABASE_URL = postgresql://aicu:aicu123@localhost:5432/aicu_todo?schema=public

JWT_SECRET = devsecret

JWT_EXPIRES = 1d

PORT = 4000

Frontend (aicu-todo-web/.env.local)
NEXT_PUBLIC_API_BASE = http://localhost:4000

API 명세(요약)
Auth

POST /auth/register — 바디: {email, password}

성공 시 HTTP-only 쿠키(access_token) 설정 + 바디로 access_token 반환

POST /auth/login — 바디: {email, password}

성공 시 HTTP-only 쿠키 설정 + 바디로 access_token 반환

POST /auth/logout — 쿠키 삭제

GET /auth/me — 인증 필요(쿠키 또는 Bearer) → { id, email } 반환

Todos (인증 필요)

GET /todos — 사용자별 Todo 목록

POST /todos — 바디: { title }

PATCH /todos/:id — 바디: { title?, done? }

DELETE /todos/:id

전체 스펙: Swagger /api 참고

구현 기능 목록
회원가입/로그인(JWT) + 쿠키 기반(HTTP-only) 세션

로그인한 사용자 조회(/auth/me)

Todo 생성/조회/수정/삭제 (사용자별)

Swagger 문서화

(프론트) 로그인/회원가입/투두 화면, 세션 유지, 로그아웃

실행 스크린샷(예시)
docs/swagger.png — Swagger /api

docs/web-login.png — /login

docs/web-todos.png — /todos(추가/토글/삭제)

트러블슈팅 메모
CORS: 백엔드 main.ts에서 origin: ['http://localhost:3000','http://localhost:3001'], credentials:true

쿠키: cookie-parser 적용 및 credentials:'include' 로 호출

포트 충돌: lsof -iTCP:<port> -sTCP:LISTEN -n -P → kill -9 <PID>

라이선스
MIT (또는 조직 정책에 맞게 변경)
MD

백엔드 .env 예시 파일도 없으면 생성(이미 있으면 건너뜀)
mkdir -p aicu-todo-api
cat > aicu-todo-api/.env.example <<'ENV'
DATABASE_URL="postgresql://aicu:aicu123@localhost:5432/aicu_todo?schema=public"
JWT_SECRET="devsecret"
JWT_EXPIRES="1d"
PORT=4000
ENV
