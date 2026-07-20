-- ============================================================
-- 맞춤투어 "가격 구성 로직 v2" (2026-07-20 확정) 반영 마이그레이션
-- - tour_attractions: 슬롯 타입(slot_type) + 1인당 입장료(price) 컬럼 추가,
--   문서에서 확정된 전체 명소 목록/단가로 upsert (재실행해도 안전)
-- - tour_pricing_settings: 차량/가이드/호텔/식사 등 원가 단가 — 전부
--   관리자 페이지에서 수정 가능해야 하는 값들
-- - tour_addon_services: 마사지 등 슬롯을 점유하지 않는 개인별 부가서비스
-- Supabase SQL Editor에서 실행하세요 (여러 번 실행해도 안전합니다)
-- ============================================================

-- ── 1. tour_attractions에 슬롯 타입 + 단가 컬럼 추가 ──
ALTER TABLE tour_attractions ADD COLUMN IF NOT EXISTS slot_type text NOT NULL DEFAULT 'half_day';
ALTER TABLE tour_attractions ADD COLUMN IF NOT EXISTS price integer DEFAULT 0;
-- slot_type 값: full_day(하루종일) / half_day(반나절) / evening(저녁·야간 전용) /
--              pm_evening(오후+저녁, 당일치기) / pm_evening_nextam(오후+저녁+익일오전)

-- ── 2. 확정된 명소 목록 + 단가로 upsert (key 기준, 재실행 안전) ──
INSERT INTO tour_attractions (key, label, cat, slot_type, price, sort_order, is_active) VALUES
  ('forest_park',        '국가삼림공원',              'large',   'full_day',           300, 1,  true),
  ('tianmen',            '천문산',                    'large',   'half_day',           260, 2,  true),
  ('grand_canyon',       '대협곡+유리다리',            'large',   'half_day',           200, 3,  true),
  ('baofeng_lake',       '보봉호수',                  'feature', 'half_day',           90,  4,  true),
  ('huanglong_cave',     '황룡동굴',                  'feature', 'half_day',           110, 5,  true),
  ('huangshi_village',   '황석채',                    'feature', 'half_day',           150, 6,  true),
  ('jinbian_trek',       '금편계 트래킹',              'feature', 'half_day',           0,   7,  true),
  ('yaozi_village',      '요자채',                    'feature', 'half_day',           150, 8,  true),
  ('citytour',           '장가계 시티투어 (전통시장·로컬마트+카페)', 'local', 'half_day', 50,  9,  true),
  ('qiqilou_inside',     '72기루 내부관광',            'local',   'evening',            90,  10, true),
  ('qiqilou_outside',    '72기루 외부 촬영 포인트',     'local',   'evening',            10,  11, true),
  ('dayong_ancient_city','대용고성 자유활동',          'local',   'evening',            10,  12, true),
  ('supermarket_night',  '대형 로컬마트 자유관광(야간)', 'local',  'evening',            0,   13, true),
  ('tianmen_fox_show',   '천문호선 공연',              'local',   'evening',            100, 14, true),
  ('xiangxi_show',       '매력상서쇼',                'local',   'evening',            100, 15, true),
  ('furong_town',        '부용진',                    'large',   'pm_evening',         300, 16, true),
  ('hongshi_forest',     '홍석림',                    'large',   'pm_evening',         300, 17, true),
  ('fenghuang',          '봉황고성',                  'large',   'pm_evening_nextam',  600, 18, true)
ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, cat = EXCLUDED.cat, slot_type = EXCLUDED.slot_type,
  price = EXCLUDED.price, sort_order = EXCLUDED.sort_order, is_active = EXCLUDED.is_active,
  updated_at = now();

-- 예전 시드 데이터 중 위 확정 목록에 없는 것들은 비활성화만 (삭제하지 않음 — 필요시 관리자가 직접 복구/삭제 가능)
UPDATE tour_attractions SET is_active = false
WHERE key IN ('qixing', 'tujia', 'forest_south', 'supermarket', 'cafe', 'forest_east');

-- ── 3. 원가 단가 설정 (차량/가이드/호텔/식사) — 관리자 페이지에서 수정 ──
CREATE TABLE IF NOT EXISTS tour_pricing_settings (
  key         text PRIMARY KEY,
  label       text NOT NULL,
  value       numeric,             -- null이면 "고객센터 문의"(고정 단가 없음)
  unit        text,                -- 예: 위안/일, 위안/박, 위안/끼
  note        text,
  sort_order  integer DEFAULT 0,
  updated_at  timestamptz DEFAULT now()
);
ALTER TABLE tour_pricing_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read tour_pricing_settings" ON tour_pricing_settings;
DROP POLICY IF EXISTS "auth write tour_pricing_settings"  ON tour_pricing_settings;
CREATE POLICY "public read tour_pricing_settings" ON tour_pricing_settings FOR SELECT USING (true);
CREATE POLICY "auth write tour_pricing_settings"  ON tour_pricing_settings FOR ALL USING (auth.role() = 'authenticated');

INSERT INTO tour_pricing_settings (key, label, value, unit, note, sort_order) VALUES
  ('car_7seat',   '7인승 차량', 500,  '위안/일', '1~4인 배정',  1),
  ('car_9seat',   '9인승 차량', 700,  '위안/일', '5~7인 배정',  2),
  ('car_14seat',  '14인승 차량', 1000, '위안/일', '8~12인 배정', 3),
  ('car_bus',     '대형버스',   NULL, '위안/일', '13인 이상 — 고정 단가 없음, 고객센터 문의', 4),
  ('guide_daily', '가이드',    800,  '위안/일', '인원 규모와 무관하게 공통', 5),
  ('hotel_night', '호텔 (평시, 2인 1실)', 280, '위안/박', '성수기(5/1~5/5,7~8월,10/1~10/7,구정기간)는 고객센터 문의', 6),
  ('meal_per',    '식사 (1인 1끼)', 70, '위안/끼', '박수 × 2끼로 계산', 7)
ON CONFLICT (key) DO NOTHING;

-- ── 4. 부가서비스 (마사지 등, 슬롯 점유 없음) ──
CREATE TABLE IF NOT EXISTS tour_addon_services (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  duration_min  integer,
  price         integer DEFAULT 0,   -- 1인당 요금 (차량·기사·가이드비 포함된 금액)
  note          text,
  sort_order    integer DEFAULT 0,
  is_active     boolean DEFAULT true,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);
ALTER TABLE tour_addon_services ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read tour_addon_services" ON tour_addon_services;
DROP POLICY IF EXISTS "auth write tour_addon_services"  ON tour_addon_services;
CREATE POLICY "public read tour_addon_services" ON tour_addon_services FOR SELECT USING (is_active = true);
CREATE POLICY "auth write tour_addon_services"  ON tour_addon_services FOR ALL USING (auth.role() = 'authenticated');
CREATE INDEX IF NOT EXISTS idx_tour_addon_services_order ON tour_addon_services(sort_order);

INSERT INTO tour_addon_services (name, duration_min, price, note, sort_order)
SELECT * FROM (VALUES
  ('발마사지 60분', 60, 100, '차량·기사·가이드비 포함', 1),
  ('발마사지 80분', 80, 140, '차량·기사·가이드비 포함', 2),
  ('아로마(전신) 마사지 100분', 100, 200, '차량·기사·가이드비 포함', 3)
) AS seed(name, duration_min, price, note, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM tour_addon_services);
