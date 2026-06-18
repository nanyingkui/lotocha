// =====================================================
// 로투차 (LocalTour China) — Supabase 공유 설정
// 모든 HTML 파일에서 이 파일을 import하여 사용
// =====================================================

const LOTOCHA_CONFIG = {
  supabase: {
    url: 'https://qbzoepglovwlarjssqjg.supabase.co',
    anonKey: 'sb_publishable_oxeR92SfBDMzYAvcNitbPw_Vf0u1y0K',
  },
  site: {
    name: '로투차 (LocalTour China)',
    superAdminEmail: 'nanyingkui@gmail.com',
    githubPages: 'https://nanyingkui.github.io/lotocha',
  }
};

// Supabase 클라이언트 초기화 헬퍼
// 사용법: const sb = await initSupabase();
async function initSupabase() {
  if (window._supabaseClient) return window._supabaseClient;
  // supabase-js v2 CDN이 로드되어 있어야 함
  if (typeof window.supabase === 'undefined') {
    console.error('supabase-js not loaded');
    return null;
  }
  window._supabaseClient = window.supabase.createClient(
    LOTOCHA_CONFIG.supabase.url,
    LOTOCHA_CONFIG.supabase.anonKey
  );
  return window._supabaseClient;
}
