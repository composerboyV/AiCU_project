'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';

export default function LoginPage() {
  const r = useRouter();
  const [email, setEmail] = useState('demo@example.com');
  const [password, setPassword] = useState('secret123');
  const [err, setErr] = useState('');

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault(); setErr('');
    try {
      await api('/auth/login', { method:'POST', body: JSON.stringify({ email, password }) });
      r.push('/todos');
    } catch (e: any) {
      setErr(e?.message || '로그인 실패');
    }
  }

  return (
    <main className="container">
      <div className="card">
        <h1 style={{marginTop:0}}>로그인</h1>
        <form onSubmit={onSubmit} className="stack">
          <input className="input" value={email} onChange={e=>setEmail(e.target.value)} placeholder="email" autoComplete="email" />
          <input className="input" value={password} type="password" onChange={e=>setPassword(e.target.value)} placeholder="password" autoComplete="current-password" />
          <div className="row">
            <button className="btn" type="submit">로그인</button>
            <a className="btn secondary" href="/register">회원가입</a>
          </div>
          {err && <p className="muted" style={{color:'crimson'}}>{err}</p>}
        </form>
      </div>
    </main>
  );
}
