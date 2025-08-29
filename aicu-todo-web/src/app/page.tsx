export default function Home() {
  return (
    <main className="container">
      <div className="card stack">
        <h1>AiCU Todo</h1>
        <p className="muted">쿠키 기반 인증 + Todo CRUD 예제</p>
        <div className="row">
          <a href="/login" className="btn">로그인</a>
          <a href="/register" className="btn secondary">회원가입</a>
        </div>
      </div>
    </main>
  );
}
