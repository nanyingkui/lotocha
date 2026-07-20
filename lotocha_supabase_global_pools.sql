-- ============================================================
-- 맞춤투어 공용(전역) 데이터 풀 생성: 호텔 / 항공편 / 명소
-- - 기존에는 hotel_options·flight_options가 각 상품(tour_products)에
--   따로 박혀 있어서 패키지마다 중복 입력해야 했고, 명소 풀은
--   코드(ATTRACTION_POOL)에 하드코딩되어 관리자가 못 건드렸음
-- - 이제 3개 테이블로 분리해 "한 곳에서 추가/수정하면 모든
--   맞춤투어 상품에 공통으로 적용"되도록 변경
-- - 본 일정의 "인문" 항목은 기존 local_places(현지 업체)와 별도로
--   같이 선택 가능 (qiqilou 같은 명소는 tour_attractions, 실제
--   가게는 local_places에서 그대로 가져다 씀)
-- Supabase SQL Editor에서 1회만 실행하세요
-- ============================================================

-- ── 1. 호텔 (전역 공용) ──
CREATE TABLE IF NOT EXISTS tour_hotels (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  grade       text,
  desc_ko     text,
  image       text,
  price       integer DEFAULT 0,
  per         text DEFAULT 'pax',          -- pax/group
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ── 2. 항공편 (전역 공용) ──
CREATE TABLE IF NOT EXISTS tour_flights (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,                -- 노선명 (예: 인천→장가계 대한항공)
  location    text,                         -- 출발지역 (예: 인천)
  time_desc   text,                         -- 시간 설명 (예: 오전 출발·약 3시간30분)
  desc_ko     text,
  image       text,
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ── 3. 명소/景区 (전역 공용, 일정 직접 짜기에서 사용) ──
CREATE TABLE IF NOT EXISTS tour_attractions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key         text UNIQUE NOT NULL,         -- 코드에서 참조하는 고정 키 (영문)
  label       text NOT NULL,
  cat         text NOT NULL DEFAULT 'feature', -- large/feature/local
  desc_ko     text,
  image       text,
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ── RLS: 누구나 읽기(활성만) / 로그인한 관리자만 쓰기 (local_places와 동일 패턴) ──
ALTER TABLE tour_hotels      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tour_flights     ENABLE ROW LEVEL SECURITY;
ALTER TABLE tour_attractions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public read tour_hotels" ON tour_hotels;
DROP POLICY IF EXISTS "auth write tour_hotels"  ON tour_hotels;
CREATE POLICY "public read tour_hotels" ON tour_hotels FOR SELECT USING (is_active = true);
CREATE POLICY "auth write tour_hotels"  ON tour_hotels FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "public read tour_flights" ON tour_flights;
DROP POLICY IF EXISTS "auth write tour_flights"  ON tour_flights;
CREATE POLICY "public read tour_flights" ON tour_flights FOR SELECT USING (is_active = true);
CREATE POLICY "auth write tour_flights"  ON tour_flights FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "public read tour_attractions" ON tour_attractions;
DROP POLICY IF EXISTS "auth write tour_attractions"  ON tour_attractions;
CREATE POLICY "public read tour_attractions" ON tour_attractions FOR SELECT USING (is_active = true);
CREATE POLICY "auth write tour_attractions"  ON tour_attractions FOR ALL USING (auth.role() = 'authenticated');

CREATE INDEX IF NOT EXISTS idx_tour_hotels_order      ON tour_hotels(sort_order);
CREATE INDEX IF NOT EXISTS idx_tour_flights_order     ON tour_flights(sort_order);
CREATE INDEX IF NOT EXISTS idx_tour_attractions_order ON tour_attractions(sort_order);

-- ── 시드 데이터: 기존에 상품마다 중복 입력돼 있던 placeholder를 전역으로 1회만 ──
-- (재실행해도 안전하도록 테이블이 완전히 비어있을 때만 시드 삽입)
INSERT INTO tour_hotels (name, grade, desc_ko, price, per, sort_order)
SELECT * FROM (VALUES
  ('일반 숙소', '3성급 추천', '시내 또는 무릉원 인근 3성급 호텔', 0, 'pax', 1),
  ('고급 숙소 업그레이드', '4~5성급', '4~5성급 호텔로 업그레이드', 0, 'pax', 2)
) AS seed(name, grade, desc_ko, price, per, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM tour_hotels);

INSERT INTO tour_flights (name, location, time_desc, desc_ko, sort_order)
SELECT * FROM (VALUES
  ('인천 ↔ 장가계(허화공항)', '인천', '직항 약 3시간 30분 (정확한 시간표는 상담 시 안내)', '', 1),
  ('부산(김해) ↔ 장가계(허화공항)', '부산', '직항 (정확한 시간표는 상담 시 안내)', '', 2),
  ('대구 ↔ 장가계(허화공항)', '대구', '직항 (정확한 시간표는 상담 시 안내)', '', 3),
  ('청주 ↔ 장가계(허화공항)', '청주', '직항 (정확한 시간표는 상담 시 안내)', '', 4)
) AS seed(name, location, time_desc, desc_ko, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM tour_flights);

INSERT INTO tour_attractions (key, label, cat, sort_order) VALUES
  ('tianmen',      '천문산',                'large',   1),
  ('forest_east',  '국가삼림공원 (동문 A·B선)', 'large',   2),
  ('grand_canyon', '장가계대협곡',           'large',   3),
  ('furong',       '부용진',                'large',   4),
  ('fenghuang',    '봉황고성',               'large',   5),
  ('baofeng',      '보봉호',                'feature', 6),
  ('huanglong',    '황룡동',                'feature', 7),
  ('qixing',       '칠성산',                'feature', 8),
  ('tujia',        '토가족 풍정원',          'feature', 9),
  ('forest_south', '국가삼림공원 (남문-황석채)', 'feature', 10),
  ('jinbianxi',    '금편계 트레킹',          'feature', 11),
  ('qiqilou',      '72기루 (야간 관람 추천)', 'local',   12),
  ('supermarket',  '현지 대형마트 (일반)',    'local',   13),
  ('cafe',         '현지 특색 카페 (일반)',   'local',   14)
ON CONFLICT (key) DO NOTHING;

-- ⚠️ 참고: tour_products의 hotel_options / flight_options 컬럼은 더이상 코드에서
-- 쓰지 않습니다 (전역 테이블로 대체됨). 기존 컬럼은 안전을 위해 삭제하지 않고
-- 그냥 남겨둡니다 — 굳이 지우고 싶다면 직접 DROP COLUMN 하셔도 무방합니다.
