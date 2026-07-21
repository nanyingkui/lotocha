-- ============================================================
-- 가이드 페이지 "스팟" 탭 내 지도설정/추천일정/비오는날대안/
-- 마지막교통편/오는방법/구역·셔틀 을 전부 관리자 페이지에서
-- 편집 가능하도록 하는 신규 테이블 + 기존 lotocha_guide.html에
-- 하드코딩되어 있던 데이터를 그대로 시드 (2026-07-21)
-- Supabase SQL Editor에서 실행하세요 (재실행해도 안전)
-- ============================================================

CREATE TABLE IF NOT EXISTS guide_attr_map_config (
  attr_id text PRIMARY KEY,
  center_lat numeric, center_lng numeric, zoom int DEFAULT 13,
  gaode_search_url text, gaode_nav_url text,
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS guide_plan_steps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attr_id text NOT NULL,
  time_hhmm text NOT NULL,
  title text NOT NULL,
  desc_ko text, warn_ko text,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS guide_rain_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attr_id text NOT NULL,
  kind text NOT NULL CHECK (kind IN ('plan','avoid')),
  item_text text NOT NULL,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true
);

CREATE TABLE IF NOT EXISTS guide_last_transport (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attr_id text NOT NULL,
  name text NOT NULL,
  last_time text NOT NULL,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true
);

CREATE TABLE IF NOT EXISTS guide_transport_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attr_id text NOT NULL,
  origin text NOT NULL CHECK (origin IN ('wulingyuan','city','airport')),
  icon text DEFAULT '🚕',
  name text NOT NULL,
  detail text,
  price text,
  badge text DEFAULT 'b-green',
  badge_txt text,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true
);

CREATE TABLE IF NOT EXISTS guide_zones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attr_id text NOT NULL,
  zone_key text NOT NULL,
  name_ko text NOT NULL,
  icon text DEFAULT '📍',
  shuttle_info text,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  UNIQUE(attr_id, zone_key)
);

-- RLS: 다른 guide_* 테이블과 동일한 명명 규칙 사용 (읽기 공개, 쓰기 인증 필요)
ALTER TABLE guide_attr_map_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_plan_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_rain_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_last_transport ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_transport_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_zones ENABLE ROW LEVEL SECURITY;

drop policy if exists "public read map config" on guide_attr_map_config;
create policy "public read map config" on guide_attr_map_config for select using (true);
drop policy if exists "authenticated manage map config" on guide_attr_map_config;
create policy "authenticated manage map config" on guide_attr_map_config for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "public read active plan_steps" on guide_plan_steps;
create policy "public read active plan_steps" on guide_plan_steps for select using (is_active = true);
drop policy if exists "authenticated manage plan_steps" on guide_plan_steps;
create policy "authenticated manage plan_steps" on guide_plan_steps for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "public read active rain_items" on guide_rain_items;
create policy "public read active rain_items" on guide_rain_items for select using (is_active = true);
drop policy if exists "authenticated manage rain_items" on guide_rain_items;
create policy "authenticated manage rain_items" on guide_rain_items for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "public read active last_transport" on guide_last_transport;
create policy "public read active last_transport" on guide_last_transport for select using (is_active = true);
drop policy if exists "authenticated manage last_transport" on guide_last_transport;
create policy "authenticated manage last_transport" on guide_last_transport for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "public read active transport_options" on guide_transport_options;
create policy "public read active transport_options" on guide_transport_options for select using (is_active = true);
drop policy if exists "authenticated manage transport_options" on guide_transport_options;
create policy "authenticated manage transport_options" on guide_transport_options for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "public read active zones" on guide_zones;
create policy "public read active zones" on guide_zones for select using (is_active = true);
drop policy if exists "authenticated manage zones" on guide_zones;
create policy "authenticated manage zones" on guide_zones for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ── guide_attr_map_config 시드 ──
INSERT INTO guide_attr_map_config (attr_id, center_lat, center_lng, zoom, gaode_search_url, gaode_nav_url) VALUES ('forest', 29.3387, 110.5358, 13, 'https://uri.amap.com/search?keyword=张家界国家森林公园&city=张家界', 'https://uri.amap.com/navigation?to=110.5358,29.3387,张家界国家森林公园南门&mode=car&src=lotocha&coordinate=gaode&callnative=1') ON CONFLICT (attr_id) DO UPDATE SET center_lat=EXCLUDED.center_lat, center_lng=EXCLUDED.center_lng, zoom=EXCLUDED.zoom, gaode_search_url=EXCLUDED.gaode_search_url, gaode_nav_url=EXCLUDED.gaode_nav_url;
INSERT INTO guide_attr_map_config (attr_id, center_lat, center_lng, zoom, gaode_search_url, gaode_nav_url) VALUES ('tianmen', 29.128, 110.475, 13, 'https://uri.amap.com/search?keyword=天门山国家森林公园&city=张家界', 'https://uri.amap.com/navigation?to=110.4740,29.1180,天门山索道下站&mode=car&src=lotocha&coordinate=gaode&callnative=1') ON CONFLICT (attr_id) DO UPDATE SET center_lat=EXCLUDED.center_lat, center_lng=EXCLUDED.center_lng, zoom=EXCLUDED.zoom, gaode_search_url=EXCLUDED.gaode_search_url, gaode_nav_url=EXCLUDED.gaode_nav_url;
INSERT INTO guide_attr_map_config (attr_id, center_lat, center_lng, zoom, gaode_search_url, gaode_nav_url) VALUES ('canyon', 29.363, 110.27, 13, 'https://uri.amap.com/search?keyword=张家界大峡谷&city=张家界', 'https://uri.amap.com/navigation?to=110.2700,29.3640,张家界大峡谷&mode=car&src=lotocha&coordinate=gaode&callnative=1') ON CONFLICT (attr_id) DO UPDATE SET center_lat=EXCLUDED.center_lat, center_lng=EXCLUDED.center_lng, zoom=EXCLUDED.zoom, gaode_search_url=EXCLUDED.gaode_search_url, gaode_nav_url=EXCLUDED.gaode_nav_url;
INSERT INTO guide_attr_map_config (attr_id, center_lat, center_lng, zoom, gaode_search_url, gaode_nav_url) VALUES ('huanglongdong', 29.348, 110.478, 14, 'https://uri.amap.com/search?keyword=张家界黄龙洞&city=张家界', 'https://uri.amap.com/navigation?to=110.478,29.348,黄龙洞景区&mode=car&src=lotocha&coordinate=gaode&callnative=1') ON CONFLICT (attr_id) DO UPDATE SET center_lat=EXCLUDED.center_lat, center_lng=EXCLUDED.center_lng, zoom=EXCLUDED.zoom, gaode_search_url=EXCLUDED.gaode_search_url, gaode_nav_url=EXCLUDED.gaode_nav_url;

-- ── guide_plan_steps 시드 (기존 데이터 있으면 건너뜀) ──
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '08:30', '남문 입장·매표', '여권 지참.', NULL, 0 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '09:00', '십리화랑 모노레일', '¥76 왕복.', NULL, 1 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '10:00', '백룡엘리베이터', '2분 326m.', '성수기 대기 60분', 2 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '10:30', '원가계·아바타 산', '아바타 촬영지.', NULL, 3 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '12:30', '점심식사', '공원 내 식당.', NULL, 4 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '14:00', '양가계 환승 → 천자산', '셔틀 환승.', NULL, 5 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '15:00', '천자산 정상', '어필봉·전망대.', NULL, 6 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '16:30', '⚠️ 하산 시작', '케이블카 마지막 18:00.', '절대 놓치면 안 됨!', 7 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'forest', '17:30', '남문 출구·귀환', '숙소 귀환.', NULL, 8 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='forest');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '08:40', '가이드 미팅', '케이블카 하단.', NULL, 0 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '10:00', '사찰 관광', '백양사찰.', NULL, 1 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '11:30', '점심식사', '호남요리.', NULL, 2 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '13:00', '케이블카 탑승', '가는 편 왼쪽 추천.', '안개 시 시야 제한', 3 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '13:30', '유리잔도', '절벽 투명 산책로.', '강풍 시 폐쇄', 4 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '14:30', '천문동', '131m 아치형 동굴.', NULL, 5 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '15:30', '정상 전망대', '파노라마.', NULL, 6 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'tianmen', '16:30', '케이블카 하산', '17:00 전 탑승.', '마지막 17:30', 7 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='tianmen');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'canyon', '10:00', '픽업 후 이동', '무릉원 기준 약 1시간, 시내 기준 약 1시간30분.', NULL, 0 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='canyon');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'canyon', '11:00', '유리다리', '신발 커버 필수.', '비 오면 폐쇄', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='canyon');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'canyon', '12:00', '협곡 트레킹', '수직 절벽.', NULL, 2 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='canyon');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'canyon', '13:30', '점심식사', '대협곡 인근.', NULL, 3 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='canyon');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'canyon', '15:00', '출구·해산', '귀환 1~1.5시간.', NULL, 4 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='canyon');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'huanglongdong', '09:00', '무릉원 픽업·이동', '약 20~30분.', NULL, 0 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='huanglongdong');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'huanglongdong', '09:30', '황룡동 입장', '지하 유람선 포함, 약 1.5시간.', NULL, 1 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='huanglongdong');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'huanglongdong', '11:00', '점심식사', '황룡동 인근.', NULL, 2 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='huanglongdong');
INSERT INTO guide_plan_steps (attr_id, time_hhmm, title, desc_ko, warn_ko, sort_order) SELECT 'huanglongdong', '12:00', '출구·해산', '대협곡 이동 시 약 40분~1시간 추가.', NULL, 3 WHERE NOT EXISTS (SELECT 1 FROM guide_plan_steps WHERE attr_id='huanglongdong');

-- ── guide_rain_items 시드 ──
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'plan', '🌲 삼림공원 운무 경치', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'plan', '🦎 황룡동 동굴 — 실내', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'plan', '🛍️ 시내 탐방', 2 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'plan', '🍜 훠궈 식당', 3 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'avoid', '🌉 유리다리 — 비 폐쇄', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'avoid', '🌉 천문산 유리잔도', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'forest', 'avoid', '🚡 천문산 케이블카', 2 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='forest' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'tianmen', 'plan', '⛰️ 약한 비엔 운행', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='tianmen' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'tianmen', 'plan', '⚠️ 강풍 시 중단 — 확인 필수', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='tianmen' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'tianmen', 'plan', '🛍️ 시내 탐방', 2 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='tianmen' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'tianmen', 'avoid', '🌉 유리잔도 — 비 폐쇄', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='tianmen' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'tianmen', 'avoid', '🚡 케이블카 — 강풍 중단', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='tianmen' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'canyon', 'plan', '⚠️ 유리다리 — 비 폐쇄', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='canyon' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'canyon', 'plan', '🌲 삼림공원/황룡동 대안', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='canyon' AND kind='plan');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'canyon', 'avoid', '🪟 유리다리 — 비 폐쇄', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='canyon' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'canyon', 'avoid', '🎢 미끄럼틀 — 비 위험', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='canyon' AND kind='avoid');
INSERT INTO guide_rain_items (attr_id, kind, item_text, sort_order) SELECT 'huanglongdong', 'plan', '🦎 황룡동 — 실내 동굴이라 비 영향 적음', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_rain_items WHERE attr_id='huanglongdong' AND kind='plan');

-- ── guide_last_transport 시드 ──
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'forest', '백룡엘리베이터', '18:00', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='forest');
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'forest', '천자산 케이블카', '18:00', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='forest');
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'forest', '공원 내 셔틀버스', '18:30', 2 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='forest');
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'tianmen', '천문산 케이블카', '17:30', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='tianmen');
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'tianmen', '에스컬레이터 마감', '17:00', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='tianmen');
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'canyon', '유리다리 입장 마감', '17:00', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='canyon');
INSERT INTO guide_last_transport (attr_id, name, last_time, sort_order) SELECT 'huanglongdong', '황룡동 마지막 입장', '16:30', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_last_transport WHERE attr_id='huanglongdong');

-- ── guide_transport_options 시드 ──
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'forest', 'wulingyuan', '🚶', '도보', '무릉원 숙소 → 남문. 15~25분.', '무료', 'b-green', '가까움', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='forest' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'forest', 'wulingyuan', '🚕', '택시', '5~10분.', '¥10~15', 'b-green', '빠름', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='forest' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'tianmen', 'wulingyuan', '🚕', '택시', '약 45분.', '¥100~130', 'b-gold', '추천', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='tianmen' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'tianmen', 'wulingyuan', '🚌', '버스+환승', '1시간 20분.', '¥25', 'b-green', '저렴', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='tianmen' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'huanglongdong', 'wulingyuan', '🚕', '로투차 전용 차량', '약 20~30분.', '투어 포함', 'b-green', '추천', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='huanglongdong' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'huanglongdong', 'wulingyuan', '🚕', '택시', '약 30분.', '¥30~50', 'b-green', '가까움', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='huanglongdong' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'canyon', 'wulingyuan', '🚕', '로투차 전용 차량', '약 1시간.', '투어 포함', 'b-green', '추천', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='canyon' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'canyon', 'wulingyuan', '🚕', '택시 개인', '왕복 예약 필수.', '¥120~160', 'b-gold', '왕복 필요', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='canyon' AND origin='wulingyuan');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'forest', 'city', '🚌', '108번 버스', '약 1시간 30분.', '¥12', 'b-green', '저렴', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='forest' AND origin='city');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'forest', 'city', '🚕', '택시', '약 50분.', '¥100~130', 'b-gold', '편리', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='forest' AND origin='city');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'tianmen', 'city', '🚕', '택시', '15~20분.', '¥25~35', 'b-green', '가까움', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='tianmen' AND origin='city');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'huanglongdong', 'city', '🚕', '택시', '약 40~50분.', '¥60~80', 'b-green', '가까움', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='huanglongdong' AND origin='city');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'canyon', 'city', '🚕', '로투차 전용 차량', '약 1시간 30분.', '투어 포함', 'b-green', '추천', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='canyon' AND origin='city');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'canyon', 'city', '🚕', '택시 개인', '왕복 예약 필수.', '¥250~320', 'b-red', '비쌈', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='canyon' AND origin='city');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'forest', 'airport', '🚕', '공항 → 무릉원', '약 1시간.', '¥130~160', 'b-gold', '1단계', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='forest' AND origin='airport');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'tianmen', 'airport', '🚕', '공항 → 시내', '약 20분.', '¥30~50', 'b-green', '가까움', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='tianmen' AND origin='airport');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'huanglongdong', 'airport', '🚕', '공항 → 황룡동', '약 1시간.', '¥130~160', 'b-gold', '가까움', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='huanglongdong' AND origin='airport');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'huanglongdong', 'airport', '🚕', '로투차 공항 픽업', '투어 예약 시 포함.', '투어 포함', 'b-green', '추천', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='huanglongdong' AND origin='airport');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'canyon', 'airport', '🚕', '공항 → 대협곡 직행', '약 1시간 20분.', '¥180~220', 'b-gold', '직행', 0 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='canyon' AND origin='airport');
INSERT INTO guide_transport_options (attr_id, origin, icon, name, detail, price, badge, badge_txt, sort_order) SELECT 'canyon', 'airport', '🚕', '로투차 공항 픽업', '투어 예약 시 포함.', '투어 포함', 'b-green', '추천', 1 WHERE NOT EXISTS (SELECT 1 FROM guide_transport_options WHERE attr_id='canyon' AND origin='airport');

-- ── guide_zones 시드 (현재는 forest만 구역 있음) ──
INSERT INTO guide_zones (attr_id, zone_key, name_ko, icon, shuttle_info, sort_order) VALUES ('forest', 'south', '남문·화랑', '🅿️', '🚌 <b>셔틀:</b> 양가계 환승센터 10~15분 | <b>막차 18:30</b>', 0) ON CONFLICT (attr_id, zone_key) DO UPDATE SET name_ko=EXCLUDED.name_ko, icon=EXCLUDED.icon, shuttle_info=EXCLUDED.shuttle_info, sort_order=EXCLUDED.sort_order;
INSERT INTO guide_zones (attr_id, zone_key, name_ko, icon, shuttle_info, sort_order) VALUES ('forest', 'yuanjia', '원가계', '🏔️', '🛗 <b>백룡엘리베이터</b> | <b>막차 18:00</b>', 1) ON CONFLICT (attr_id, zone_key) DO UPDATE SET name_ko=EXCLUDED.name_ko, icon=EXCLUDED.icon, shuttle_info=EXCLUDED.shuttle_info, sort_order=EXCLUDED.sort_order;
INSERT INTO guide_zones (attr_id, zone_key, name_ko, icon, shuttle_info, sort_order) VALUES ('forest', 'tianzi', '천자산', '🌅', '🚡 <b>천자산 케이블카</b> | <b>막차 18:00</b>', 2) ON CONFLICT (attr_id, zone_key) DO UPDATE SET name_ko=EXCLUDED.name_ko, icon=EXCLUDED.icon, shuttle_info=EXCLUDED.shuttle_info, sort_order=EXCLUDED.sort_order;
INSERT INTO guide_zones (attr_id, zone_key, name_ko, icon, shuttle_info, sort_order) VALUES ('forest', 'yangjiajie', '양가계', '🔄', '🔄 <b>환승 허브</b> | 막차 <b>18:30</b>', 3) ON CONFLICT (attr_id, zone_key) DO UPDATE SET name_ko=EXCLUDED.name_ko, icon=EXCLUDED.icon, shuttle_info=EXCLUDED.shuttle_info, sort_order=EXCLUDED.sort_order;
