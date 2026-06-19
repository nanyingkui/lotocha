-- ============================================================
-- tour_products 스키마 업데이트: 연령별 가격 + 옵션 컬럼 추가
-- Supabase SQL Editor에서 실행하세요
-- ============================================================

-- 1. 새 컬럼 추가
ALTER TABLE tour_products
  ADD COLUMN IF NOT EXISTS price_tiers jsonb DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS tour_options jsonb DEFAULT '[]'::jsonb;

-- 2. 황룡동 + 대협곡 데이투어 가격 업데이트
UPDATE tour_products
SET
  price_tiers = '[
    {"key":"adult","label":"성인 (만 14~64세)","price":250000,"counts_min":true},
    {"key":"senior","label":"경로 (만 65세이상)","price":230000,"counts_min":true},
    {"key":"child","label":"어린이 (만 13세이하)","price":230000,"counts_min":false},
    {"key":"infant","label":"영유아 (만 3세미만)","price":20000,"counts_min":false}
  ]'::jsonb,
  tour_options = '[
    {"key":"private_car","label":"장거리 전용차량","price":20000,"per":"pax"}
  ]'::jsonb
WHERE title_ko LIKE '%황룡동%';

-- 3. 천문산 데이투어 가격 업데이트
UPDATE tour_products
SET
  price_tiers = '[
    {"key":"adult","label":"일반 (만 14~69세)","price":210000,"counts_min":true},
    {"key":"senior","label":"70세 이상","price":190000,"counts_min":true},
    {"key":"child","label":"어린이 (만 14세이하)","price":170000,"counts_min":false},
    {"key":"infant","label":"영유아 (만 3세미만)","price":20000,"counts_min":false}
  ]'::jsonb,
  tour_options = '[
    {"key":"massage","label":"80분 전신+발마사지 (시내)","price":40000,"per":"pax"},
    {"key":"private_car","label":"로투차 전용차량","price":20000,"per":"pax"}
  ]'::jsonb
WHERE title_ko LIKE '%천문산%';

-- 4. 무릉원 국가삼림공원 데이투어 가격 업데이트
UPDATE tour_products
SET
  price_tiers = '[
    {"key":"adult","label":"성인 (만 18~65세)","price":280000,"counts_min":true},
    {"key":"teen","label":"청소년 (만 14~17세)","price":270000,"counts_min":true},
    {"key":"senior","label":"경로 (만 65세이상)","price":270000,"counts_min":true},
    {"key":"child","label":"어린이 (만 13세이하)","price":250000,"counts_min":false},
    {"key":"infant","label":"영유아 (만 3세미만)","price":20000,"counts_min":false}
  ]'::jsonb,
  tour_options = '[
    {"key":"sky_tram","label":"공중전원 (정동카 포함)","price":30000,"per":"pax"},
    {"key":"massage","label":"80분 전신+발마사지","price":40000,"per":"pax"}
  ]'::jsonb
WHERE title_ko LIKE '%무릉원%';
