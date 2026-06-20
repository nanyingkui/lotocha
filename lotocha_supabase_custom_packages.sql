-- ============================================================
-- 맞춤투어(3박4일 / 4박5일 / 5박6일) 신규 상품 3개 생성 (DRAFT)
-- - 정의 방식: 참고 일정만 제공, 실제 세부 일정은 상담으로 확정
-- - 가격: 연령별 기본가(price_tiers) + 선택 옵션(tour_options) 추가요금
-- - 숙박 등급: tour_options에 group="lodging"으로 라디오(단일선택) 처리
-- - status='draft', is_active=false 로 생성 → 관리자 페이지에서
--   실제 가격/일정을 채운 뒤 "라이브"로 전환해야 공개 페이지에 노출됩니다
-- Supabase SQL Editor에서 1회만 실행하세요
-- ============================================================

-- ① 맞춤투어 3박4일
INSERT INTO tour_products (
  product_type, title_ko, title_cn, subtitle_ko, description_ko,
  price_krw, price_cny, duration_days,
  highlights, includes, excludes, itinerary,
  price_tiers, tour_options,
  images, max_pax, min_pax, is_active, status, sort_order
) VALUES (
  'package',
  '맞춤투어 3박4일',
  '自定行程 3晚4天',
  '장가계 핵심 명소 위주로 일정을 맞춤 구성 — 세부 일정은 상담으로 확정',
  '장가계의 핵심 명소를 중심으로 3박4일 일정을 자유롭게 구성하는 맞춤투어입니다. 아래 가격·옵션·일정은 예시이며, 실제 세부 일정과 견적은 카카오톡/WeChat 상담을 통해 손님의 취향에 맞춰 확정됩니다.',
  NULL, NULL, 4,
  '["장가계 핵심 명소 자유 구성", "숙박 등급 선택 가능", "전 일정 한국어 가이드 동행"]'::jsonb,
  '["전 일정 숙박", "조식 (숙박 포함시)", "차량 이동 (공항/터미널 픽업&센딩 포함)", "한국어 가이드 서비스"]'::jsonb,
  '["항공권/기차표", "여행자 보험", "가이드 일정 외 개인 경비·쇼핑"]'::jsonb,
  '[{"time":"1일차","desc":"(예시) 공항/터미널 도착 → 호텔 체크인 → 자유 일정"},{"time":"2일차","desc":"(예시) 핵심 명소 관광 → 호텔 숙박"},{"time":"3일차","desc":"(예시) 핵심 명소 관광 → 호텔 숙박"},{"time":"4일차","desc":"(예시) 마지막 일정 → 공항/터미널 센딩"}]'::jsonb,
  '[{"key":"adult","label":"성인","price":0,"counts_min":true},{"key":"senior","label":"경로","price":0,"counts_min":true},{"key":"child","label":"어린이","price":0,"counts_min":false},{"key":"infant","label":"영유아","price":0,"counts_min":false}]'::jsonb,
  '[{"key":"lodge_standard","label":"일반 숙소","price":0,"per":"pax","group":"lodging"},{"key":"lodge_deluxe","label":"고급 숙소 업그레이드","price":0,"per":"pax","group":"lodging"},{"key":"massage","label":"전신 마사지","price":0,"per":"pax"},{"key":"private_car","label":"전용차량","price":0,"per":"pax"}]'::jsonb,
  '[]'::jsonb, 20, 2, false, 'draft', 4
);

-- ② 맞춤투어 4박5일
INSERT INTO tour_products (
  product_type, title_ko, title_cn, subtitle_ko, description_ko,
  price_krw, price_cny, duration_days,
  highlights, includes, excludes, itinerary,
  price_tiers, tour_options,
  images, max_pax, min_pax, is_active, status, sort_order
) VALUES (
  'package',
  '맞춤투어 4박5일',
  '自定行程 4晚5天',
  '장가계 핵심 명소 + 여유로운 일정 — 세부 일정은 상담으로 확정',
  '4박5일 동안 장가계 핵심 명소와 여유로운 일정을 함께 구성하는 맞춤투어입니다. 아래 가격·옵션·일정은 예시이며, 실제 세부 일정과 견적은 카카오톡/WeChat 상담을 통해 손님의 취향에 맞춰 확정됩니다.',
  NULL, NULL, 5,
  '["장가계 핵심 명소 + 여유 일정", "숙박 등급 선택 가능", "전 일정 한국어 가이드 동행"]'::jsonb,
  '["전 일정 숙박", "조식 (숙박 포함시)", "차량 이동 (공항/터미널 픽업&센딩 포함)", "한국어 가이드 서비스"]'::jsonb,
  '["항공권/기차표", "여행자 보험", "가이드 일정 외 개인 경비·쇼핑"]'::jsonb,
  '[{"time":"1일차","desc":"(예시) 공항/터미널 도착 → 호텔 체크인 → 자유 일정"},{"time":"2일차","desc":"(예시) 핵심 명소 관광 → 호텔 숙박"},{"time":"3일차","desc":"(예시) 핵심 명소 관광 → 호텔 숙박"},{"time":"4일차","desc":"(예시) 추가 명소/체험 → 호텔 숙박"},{"time":"5일차","desc":"(예시) 마지막 일정 → 공항/터미널 센딩"}]'::jsonb,
  '[{"key":"adult","label":"성인","price":0,"counts_min":true},{"key":"senior","label":"경로","price":0,"counts_min":true},{"key":"child","label":"어린이","price":0,"counts_min":false},{"key":"infant","label":"영유아","price":0,"counts_min":false}]'::jsonb,
  '[{"key":"lodge_standard","label":"일반 숙소","price":0,"per":"pax","group":"lodging"},{"key":"lodge_deluxe","label":"고급 숙소 업그레이드","price":0,"per":"pax","group":"lodging"},{"key":"massage","label":"전신 마사지","price":0,"per":"pax"},{"key":"private_car","label":"전용차량","price":0,"per":"pax"}]'::jsonb,
  '[]'::jsonb, 20, 2, false, 'draft', 5
);

-- ③ 맞춤투어 5박6일
INSERT INTO tour_products (
  product_type, title_ko, title_cn, subtitle_ko, description_ko,
  price_krw, price_cny, duration_days,
  highlights, includes, excludes, itinerary,
  price_tiers, tour_options,
  images, max_pax, min_pax, is_active, status, sort_order
) VALUES (
  'package',
  '맞춤투어 5박6일',
  '自定行程 5晚6天',
  '장가계 전 지역을 여유롭게 둘러보는 일정 — 세부 일정은 상담으로 확정',
  '5박6일 동안 장가계 전 지역의 명소를 여유롭게 둘러보는 맞춤투어입니다. 아래 가격·옵션·일정은 예시이며, 실제 세부 일정과 견적은 카카오톡/WeChat 상담을 통해 손님의 취향에 맞춰 확정됩니다.',
  NULL, NULL, 6,
  '["장가계 전 지역 여유 일정", "숙박 등급 선택 가능", "전 일정 한국어 가이드 동행"]'::jsonb,
  '["전 일정 숙박", "조식 (숙박 포함시)", "차량 이동 (공항/터미널 픽업&센딩 포함)", "한국어 가이드 서비스"]'::jsonb,
  '["항공권/기차표", "여행자 보험", "가이드 일정 외 개인 경비·쇼핑"]'::jsonb,
  '[{"time":"1일차","desc":"(예시) 공항/터미널 도착 → 호텔 체크인 → 자유 일정"},{"time":"2일차","desc":"(예시) 핵심 명소 관광 → 호텔 숙박"},{"time":"3일차","desc":"(예시) 핵심 명소 관광 → 호텔 숙박"},{"time":"4일차","desc":"(예시) 추가 명소/체험 → 호텔 숙박"},{"time":"5일차","desc":"(예시) 추가 명소/체험 → 호텔 숙박"},{"time":"6일차","desc":"(예시) 마지막 일정 → 공항/터미널 센딩"}]'::jsonb,
  '[{"key":"adult","label":"성인","price":0,"counts_min":true},{"key":"senior","label":"경로","price":0,"counts_min":true},{"key":"child","label":"어린이","price":0,"counts_min":false},{"key":"infant","label":"영유아","price":0,"counts_min":false}]'::jsonb,
  '[{"key":"lodge_standard","label":"일반 숙소","price":0,"per":"pax","group":"lodging"},{"key":"lodge_deluxe","label":"고급 숙소 업그레이드","price":0,"per":"pax","group":"lodging"},{"key":"massage","label":"전신 마사지","price":0,"per":"pax"},{"key":"private_car","label":"전용차량","price":0,"per":"pax"}]'::jsonb,
  '[]'::jsonb, 20, 2, false, 'draft', 6
);
