'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';

type Todo = { id:number; title:string; done:boolean };
type Me = { id:number; email:string };

export default function TodosPage() {
  const r = useRouter();
  const [me, setMe] = useState<Me | null>(null);
  const [todos, setTodos] = useState<Todo[]>([]);
  const [title, setTitle] = useState('');
  const [err, setErr] = useState('');

  async function ensureSession() {
    try {
      const who = await api<Me>('/auth/me', { method:'GET' });
      setMe(who);
      return true;
    } catch { r.replace('/login'); return false; }
  }
  async function fetchTodos() {
    setErr('');
    try { setTodos(await api<Todo[]>('/todos', { method:'GET' })); }
    catch { setErr('목록 조회 실패'); }
  }
  useEffect(() => { (async()=>{ if (await ensureSession()) await fetchTodos(); })(); }, []);

  async function addTodo() {
    if (!title.trim()) return;
    try {
      await api('/todos', { method:'POST', body: JSON.stringify({ title }) });
      setTitle(''); await fetchTodos();
    } catch { setErr('추가 실패'); }
  }
  async function toggle(todo: Todo) {
    try { await api(`/todos/${todo.id}`, { method:'PATCH', body: JSON.stringify({ done: !todo.done }) }); await fetchTodos(); }
    catch { setErr('토글 실패'); }
  }
  async function remove(id:number) {
    try { await api(`/todos/${id}`, { method:'DELETE' }); await fetchTodos(); }
    catch { setErr('삭제 실패'); }
  }
  async function logout() {
    try { await api('/auth/logout', { method:'POST' }); } finally { r.push('/login'); }
  }

  return (
    <main className="container">
      <div className="header">
        <h1>Todos</h1>
        {me && <span className="badge">{me.email}</span>}
        <div className="right">
          <button onClick={logout} className="btn ghost">로그아웃</button>
        </div>
      </div>

      <div className="card stack">
        <div className="row">
          <input className="input" value={title} onChange={e=>setTitle(e.target.value)} placeholder="할 일 입력" />
          <button onClick={addTodo} className="btn">추가</button>
        </div>
        {err && <p className="muted" style={{color:'crimson'}}>{err}</p>}
        <ul className="list">
          {todos.map(t => (
            <li key={t.id}>
              <input type="checkbox" checked={t.done} onChange={()=>toggle(t)} />
              <span className={`item-title ${t.done ? 'done' : ''}`}>{t.title}</span>
              <button onClick={()=>remove(t.id)} className="btn ghost">삭제</button>
            </li>
          ))}
          {!todos.length && <li className="center muted">아직 항목이 없습니다.</li>}
        </ul>
      </div>
    </main>
  );
}
