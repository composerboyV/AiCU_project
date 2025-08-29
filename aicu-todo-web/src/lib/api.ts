export const API_BASE = process.env.NEXT_PUBLIC_API_BASE!;

/** 쿠키(HTTP-only) 자동 포함 + 에러 메시지 파싱 */
export async function api<T = any>(path: string, init: RequestInit = {}): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    credentials: 'include',
    ...init,
    headers: { 'Content-Type': 'application/json', ...(init.headers || {}) },
  });

  if (!res.ok) {
    let message = `HTTP ${res.status}`;
    try {
      const data = await res.clone().json();
      const m = Array.isArray(data?.message) ? data.message.join(', ') : (data?.message || data?.error || data?.detail);
      if (m) message = m;
    } catch {
      try { message = await res.text(); } catch {}
    }
    throw new Error(message);
  }

  if (res.status === 204) return undefined as T;
  const ct = res.headers.get('content-type') || '';
  return ct.includes('application/json') ? await res.json() : (await res.text() as any);
}
