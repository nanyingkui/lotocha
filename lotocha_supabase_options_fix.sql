-- ============================================================
-- tour_options 수정
-- 1. 황룡동·천문산 → 전용차량 옵션 제거
-- 2. 무릉원 → 패스트트랙 2개 추가
-- ============================================================

-- 황룡동+대협곡: 전용차량 제거 (옵션 없음)
UPDATE tour_products
SET tour_options = '[]'::jsonb
WHERE title_ko LIKE '%황룡동%';

-- 천문산: 마사지만 유지, 전용차량 제거
UPDATE tour_products
SET tour_options = '[
  {"key":"massage","label":"80분 전신+발마사지 (시내)","price":40000,"per":"pax"}
]'::jsonb
WHERE title_ko LIKE '%천문산%';

-- 무릉원 국가삼림공원: 기존 옵션 유지 + 패스트트랙 2개 추가
-- (영유아 만 3세미만 제외, 나머지 모든 연령 동일 가격)
UPDATE tour_products
SET tour_options = '[
  {"key":"sky_tram","label":"공중전원 (정동카 포함)","price":30000,"per":"pax"},
  {"key":"massage","label":"80분 전신+발마사지","price":40000,"per":"pax"},
  {"key":"fast_baekryong","label":"백룡천梯 패스트트랙 (상행 또는 하행, 영유아 제외)","price":25000,"per":"pax"},
  {"key":"fast_cheonja","label":"천자산 케이블카 패스트트랙 (상행 또는 하행, 영유아 제외)","price":25000,"per":"pax"}
]'::jsonb
WHERE title_ko LIKE '%무릉원%';
