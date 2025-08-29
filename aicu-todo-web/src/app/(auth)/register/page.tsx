'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function RegisterPage() {
  const r = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [err, setErr] = useState('');

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault(); setErr('');
    if (!emailRegex.test(email)) { setErr('이메일 형식 확인'); return; }
    if (password.length < 6) { setErr('비밀번호는 6자 이상'); return; }

    try {
      await api('/auth/register', { method:'POST', body: JSON.stringify({ email, password }) });
      r.push('/todos');
    } catch (e: any) {
      setErr(e?.message || '회원가입 실패');
    }
  }

  return (
    <main className="container">
      <div className="card">
        <h1 style={{marginTop:0}}>회원가입</h1>
        <form onSubmit={onSubmit} className="stack">
          <input className="input" value={email} onChange={e=>setEmail(e.target.value)} placeholder="email" inputMode="email" />
          <input className="input" value={password} type="password" onChange={e=>setPassword(e.target.value)} placeholder="password (6+)" />
          <div className="row">
            <button className="btn" type="submit">가입</button>
            <a className="btn secondary" href="/login">로그인</a>
          </div>
          {err && <p className="muted" style={{color:'crimson'}}>{err}</p>}
        </form>
      </div>
    </main>
  );
}
