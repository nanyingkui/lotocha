-- ============================================================
-- 맞춤투어(3박4일 / 4박5일 / 5박6일) 신규 상품 3개 생성 (DRAFT)
-- - 일정: 일자별로 오전/오후(반나절씩, 대형 명소는 하루 1개)·저녁(인문, 중복 가능)
--   구조로 저장 → 고객 화면에서 명소를 직접 바꿔가며 자유롭게 재구성 가능
-- - 가격: 연령별 기본가(price_tiers) + 선택 옵션(tour_options) 추가요금
-- - 숙박: hotel_options에 호텔별로 라디오(단일선택) 처리, 명절 가격변동 안내는
--   고객 화면에 자동 표시됨
-- - status='draft', is_active=false 로 생성 → 관리자 페이지에서
--   실제 가격/호텔/일정을 채운 뒤 "라이브"로 전환해야 공개 페이지에 노출됩니다
-- Supabase SQL Editor에서 1회만 실행하세요
-- ============================================================

-- 0. hotel_options / flight_options 컬럼이 아직 없다면 추가 (없어서 에러난 경우 이 줄 때문에 해결됨)
ALTER TABLE tour_products ADD COLUMN IF NOT EXISTS hotel_options jsonb DEFAULT '[]'::jsonb;
ALTER TABLE tour_products ADD COLUMN IF NOT EXISTS flight_options jsonb DEFAULT '[]'::jsonb;

-- 한국 → 장가계(허화공항) 직항 노선 placeholder (인천/부산/대구/청주 출발 — 2026년 기준 실제 운항 중인 출발지역)
-- ⚠️ 정확한 항공사/시간표/요금은 시즌에 따라 바뀌므로 admin 페이지에서 최신 정보로 업데이트해 주세요
-- (참고: 인천-장가계 직항 약 3시간 30분 소요, 운항 항공사는 대한항공/중국동방항공/쓰촨항공 등)

-- ① 맞춤투어 3박4일
INSERT INTO tour_products (
  product_type, title_ko, title_cn, subtitle_ko, description_ko,
  price_krw, price_cny, duration_days,
  highlights, includes, excludes, itinerary,
  price_tiers, tour_options, hotel_options, flight_options,
  images, max_pax, min_pax, is_active, status, sort_order
) VALUES (
  'package',
  '맞춤투어 3박4일',
  '自定行程 3晚4天',
  '장가계 핵심 명소 위주로 일정을 맞춤 구성 — 세부 일정은 상담으로 확정',
  '장가계의 핵심 명소를 중심으로 3박4일 일정을 자유롭게 구성하는 맞춤투어입니다. 아래는 추천 일정 예시이며, 예약 화면에서 명소를 자유롭게 바꿀 수 있습니다. 실제 입장 가능 여부·정확한 견적은 카카오톡/WeChat 상담을 통해 확정됩니다.',
  NULL, NULL, 4,
  '["천문산·장가계대협곡 등 핵심 명소", "일자별 명소 자유 변경 가능", "전 일정 한국어 가이드 동행"]'::jsonb,
  '["전 일정 숙박", "조식 (숙박 포함시)", "차량 이동 (공항/터미널 픽업&센딩 포함)", "한국어 가이드 서비스"]'::jsonb,
  '["항공권/기차표", "여행자 보험", "가이드 일정 외 개인 경비·쇼핑"]'::jsonb,
  '[
    {"day":1,"am":null,"pm":null,"evening":[{"key":"qiqilou"}]},
    {"day":2,"am":{"key":"tianmen"},"pm":{"key":"huanglong"},"evening":[{"key":"cafe"}]},
    {"day":3,"am":{"key":"grand_canyon"},"pm":{"key":"jinbianxi"},"evening":[{"key":"supermarket"}]},
    {"day":4,"am":{"key":"forest_south"},"pm":null,"evening":[]}
  ]'::jsonb,
  '[{"key":"adult","label":"성인","price":0,"counts_min":true},{"key":"senior","label":"경로","price":0,"counts_min":true},{"key":"child","label":"어린이","price":0,"counts_min":false},{"key":"infant","label":"영유아","price":0,"counts_min":false}]'::jsonb,
  '[{"key":"massage","label":"전신 마사지","price":0,"per":"pax"},{"key":"private_car","label":"전용차량","price":0,"per":"pax"}]'::jsonb,
  '[{"key":"standard","name":"일반 숙소 (3성급 추천)","price":0,"per":"pax","desc":"시내 또는 무릉원 인근 3성급 호텔"},{"key":"deluxe","name":"고급 숙소 업그레이드 (4~5성급)","price":0,"per":"pax","desc":"4~5성급 호텔로 업그레이드"}]'::jsonb,
  '[{"key":"incheon","name":"인천 ↔ 장가계(허화공항)","location":"인천","time":"직항 약 3시간 30분 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"busan","name":"부산(김해) ↔ 장가계(허화공항)","location":"부산","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"daegu","name":"대구 ↔ 장가계(허화공항)","location":"대구","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"cheongju","name":"청주 ↔ 장가계(허화공항)","location":"청주","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""}]'::jsonb,
  '[]'::jsonb, 20, 2, false, 'draft', 4
);

-- ② 맞춤투어 4박5일
INSERT INTO tour_products (
  product_type, title_ko, title_cn, subtitle_ko, description_ko,
  price_krw, price_cny, duration_days,
  highlights, includes, excludes, itinerary,
  price_tiers, tour_options, hotel_options, flight_options,
  images, max_pax, min_pax, is_active, status, sort_order
) VALUES (
  'package',
  '맞춤투어 4박5일',
  '自定行程 4晚5天',
  '장가계 핵심 명소 + 여유로운 일정 — 세부 일정은 상담으로 확정',
  '4박5일 동안 장가계 핵심 명소와 여유로운 일정을 함께 구성하는 맞춤투어입니다. 아래는 추천 일정 예시이며, 예약 화면에서 명소를 자유롭게 바꿀 수 있습니다. 실제 입장 가능 여부·정확한 견적은 카카오톡/WeChat 상담을 통해 확정됩니다.',
  NULL, NULL, 5,
  '["천문산·장가계대협곡·국가삼림공원 등 핵심+추가 명소", "일자별 명소 자유 변경 가능", "전 일정 한국어 가이드 동행"]'::jsonb,
  '["전 일정 숙박", "조식 (숙박 포함시)", "차량 이동 (공항/터미널 픽업&센딩 포함)", "한국어 가이드 서비스"]'::jsonb,
  '["항공권/기차표", "여행자 보험", "가이드 일정 외 개인 경비·쇼핑"]'::jsonb,
  '[
    {"day":1,"am":null,"pm":null,"evening":[{"key":"qiqilou"}]},
    {"day":2,"am":{"key":"tianmen"},"pm":{"key":"huanglong"},"evening":[{"key":"cafe"}]},
    {"day":3,"am":{"key":"grand_canyon"},"pm":{"key":"jinbianxi"},"evening":[{"key":"supermarket"}]},
    {"day":4,"am":{"key":"forest_east"},"pm":{"key":"baofeng"},"evening":[{"key":"cafe"}]},
    {"day":5,"am":{"key":"forest_south"},"pm":null,"evening":[]}
  ]'::jsonb,
  '[{"key":"adult","label":"성인","price":0,"counts_min":true},{"key":"senior","label":"경로","price":0,"counts_min":true},{"key":"child","label":"어린이","price":0,"counts_min":false},{"key":"infant","label":"영유아","price":0,"counts_min":false}]'::jsonb,
  '[{"key":"massage","label":"전신 마사지","price":0,"per":"pax"},{"key":"private_car","label":"전용차량","price":0,"per":"pax"}]'::jsonb,
  '[{"key":"standard","name":"일반 숙소 (3성급 추천)","price":0,"per":"pax","desc":"시내 또는 무릉원 인근 3성급 호텔"},{"key":"deluxe","name":"고급 숙소 업그레이드 (4~5성급)","price":0,"per":"pax","desc":"4~5성급 호텔로 업그레이드"}]'::jsonb,
  '[{"key":"incheon","name":"인천 ↔ 장가계(허화공항)","location":"인천","time":"직항 약 3시간 30분 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"busan","name":"부산(김해) ↔ 장가계(허화공항)","location":"부산","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"daegu","name":"대구 ↔ 장가계(허화공항)","location":"대구","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"cheongju","name":"청주 ↔ 장가계(허화공항)","location":"청주","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""}]'::jsonb,
  '[]'::jsonb, 20, 2, false, 'draft', 5
);

-- ③ 맞춤투어 5박6일
INSERT INTO tour_products (
  product_type, title_ko, title_cn, subtitle_ko, description_ko,
  price_krw, price_cny, duration_days,
  highlights, includes, excludes, itinerary,
  price_tiers, tour_options, hotel_options, flight_options,
  images, max_pax, min_pax, is_active, status, sort_order
) VALUES (
  'package',
  '맞춤투어 5박6일',
  '自定行程 5晚6天',
  '장가계 전 지역을 여유롭게 둘러보는 일정 — 세부 일정은 상담으로 확정',
  '5박6일 동안 장가계 전 지역의 명소를 여유롭게 둘러보는 맞춤투어입니다. 아래는 추천 일정 예시이며, 예약 화면에서 명소를 자유롭게 바꿀 수 있습니다. 실제 입장 가능 여부·정확한 견적은 카카오톡/WeChat 상담을 통해 확정됩니다.',
  NULL, NULL, 6,
  '["장가계 핵심 명소 + 부용진·토가족 풍정원 등 외곽 일정", "일자별 명소 자유 변경 가능", "전 일정 한국어 가이드 동행"]'::jsonb,
  '["전 일정 숙박", "조식 (숙박 포함시)", "차량 이동 (공항/터미널 픽업&센딩 포함)", "한국어 가이드 서비스"]'::jsonb,
  '["항공권/기차표", "여행자 보험", "가이드 일정 외 개인 경비·쇼핑"]'::jsonb,
  '[
    {"day":1,"am":null,"pm":null,"evening":[{"key":"qiqilou"}]},
    {"day":2,"am":{"key":"tianmen"},"pm":{"key":"huanglong"},"evening":[{"key":"cafe"}]},
    {"day":3,"am":{"key":"grand_canyon"},"pm":{"key":"jinbianxi"},"evening":[{"key":"supermarket"}]},
    {"day":4,"am":{"key":"forest_east"},"pm":{"key":"baofeng"},"evening":[{"key":"cafe"}]},
    {"day":5,"am":{"key":"furong"},"pm":{"key":"tujia"},"evening":[{"key":"supermarket"}]},
    {"day":6,"am":{"key":"qixing"},"pm":null,"evening":[]}
  ]'::jsonb,
  '[{"key":"adult","label":"성인","price":0,"counts_min":true},{"key":"senior","label":"경로","price":0,"counts_min":true},{"key":"child","label":"어린이","price":0,"counts_min":false},{"key":"infant","label":"영유아","price":0,"counts_min":false}]'::jsonb,
  '[{"key":"massage","label":"전신 마사지","price":0,"per":"pax"},{"key":"private_car","label":"전용차량","price":0,"per":"pax"}]'::jsonb,
  '[{"key":"standard","name":"일반 숙소 (3성급 추천)","price":0,"per":"pax","desc":"시내 또는 무릉원 인근 3성급 호텔"},{"key":"deluxe","name":"고급 숙소 업그레이드 (4~5성급)","price":0,"per":"pax","desc":"4~5성급 호텔로 업그레이드"}]'::jsonb,
  '[{"key":"incheon","name":"인천 ↔ 장가계(허화공항)","location":"인천","time":"직항 약 3시간 30분 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"busan","name":"부산(김해) ↔ 장가계(허화공항)","location":"부산","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"daegu","name":"대구 ↔ 장가계(허화공항)","location":"대구","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""},{"key":"cheongju","name":"청주 ↔ 장가계(허화공항)","location":"청주","time":"직항 (정확한 시간표는 상담 시 안내)","desc":"","image":""}]'::jsonb,
  '[]'::jsonb, 20, 2, false, 'draft', 6
);
