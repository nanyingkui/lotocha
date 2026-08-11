-- ============================================================
-- 여행 모듈 통합 테이블 (travel_modules) — 2026-08-11
--
-- 배경: 지금까지 "장소/景点" 정보가 guide_attractions(4개 대경구) /
-- guide_spots(지도 핀) / tour_attractions(맞춤투어에서 선택 가능한
-- 항목, 가격 포함) 세 곳에 나뉘어 있어서, 같은 장소를 두 군데에
-- 따로 입력해야 하고 서로 자동으로 반영되지 않는 문제가 있었습니다.
-- (예: "보봉호수"가 tour_attractions에는 있지만 guide.html 지도에는 없음)
--
-- 이 스크립트는 그 3곳을 대체할 새 테이블 travel_modules를 만들고,
-- 기존 3개 테이블의 데이터를 여기로 복사해 넣습니다.
--
-- ⚠️ 이 단계에서는 기존 guide_attractions / guide_spots /
-- tour_attractions 테이블을 전혀 건드리거나 삭제하지 않습니다.
-- 그래서 지금 이 SQL을 실행해도 현재 라이브 사이트(guide.html /
-- tour.html / admin.html)의 동작은 전혀 바뀌지 않습니다 — 새 표를
-- 만들고 데이터만 복사해 넣는 "준비 단계"입니다.
-- 관리자 페이지/향도 페이지/투어 페이지가 실제로 이 새 표를
-- 사용하도록 바꾸는 작업은 이 SQL을 실행한 뒤, 데이터를 확인하고
-- 나서 별도로 진행합니다.
--
-- Supabase SQL Editor에서 실행하세요 (재실행해도 안전합니다)
-- ============================================================

-- 1) 테이블 생성
CREATE TABLE IF NOT EXISTS travel_modules (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_key         text UNIQUE NOT NULL,        -- 시스템 내부 식별자 (자동 생성, 관리자가 직접 입력할 필요 없음)
  parent_id          uuid REFERENCES travel_modules(id) ON DELETE SET NULL,  -- 소속된 대경구 (독립 항목/대경구 자체는 NULL)

  name_ko            text NOT NULL,
  name_cn            text,
  icon               text DEFAULT '📍',
  images             jsonb,
  video_url          text,
  desc_ko            text,
  tip_ko             text,

  region_zone        text CHECK (region_zone IN ('city','wulingyuan','outside')),  -- 시내 / 무릉원 / 장가계 외
  zone_id            text,                         -- 대경구 내 구역 (예: south/yuanjia/tianzi/yangjiajie, 없으면 NULL)
  type               text,                         -- 지도 핀 종류 (기존 guide_spots.type 계승, 대경구 자체는 NULL)

  lat                double precision,
  lon                double precision,
  gaode_uri          text,

  hours              text,                          -- 개방시간 표시용 텍스트 (예: "08:30~17:00")
  price_note         text,                          -- 가격 표시용 텍스트 (예: "성인 100元, 소아 50元")
  tags               jsonb,

  slot_type          text CHECK (slot_type IN ('full_day','half_day','evening','pm_evening','pm_evening_nextam','free')),
                                                     -- 맞춤투어 일정 슬롯 타입. free = 자유활동(일정 없음). NULL = 예약/일정 불가(전시 전용)
  booking_price       integer DEFAULT 0,             -- 맞춤투어 견적 계산용 1인당 원가(정수, 위안)
  needs_reservation   boolean DEFAULT false,
  reservation_note    text,                          -- 예약 안내 자유 텍스트 (예: "성수기 1~3일 전 예약 권장")
  open_time_start     time,                          -- 예약 시간대 자동 분할용 (1시간 단위) — needs_reservation=true일 때만 의미
  open_time_end       time,
  notes               text,                          -- 자유 비고 (성수기 대기, 체력 요구 등 뭐든 기록 가능)

  show_on_guide       boolean DEFAULT true,           -- 향도(guide.html) 지도/스팟 탭에 표시할지
  bookable_in_tour     boolean DEFAULT false,          -- 맞춤투어(tour.html) 일정 빌더에서 선택 가능하게 할지
  is_protected        boolean DEFAULT false,          -- 핵심 대경구(국가삼림공원/천문산/황룡동/대협곡) 등 삭제 방지
  is_active           boolean DEFAULT true,
  status              text DEFAULT 'live',            -- live/draft/pending (기존 guide_spots.status 계승)
  sort_order          integer DEFAULT 0,

  created_at          timestamptz DEFAULT now(),
  updated_at          timestamptz DEFAULT now()
);

ALTER TABLE travel_modules ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read active travel_modules" ON travel_modules;
CREATE POLICY "public read active travel_modules" ON travel_modules FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "authenticated manage travel_modules" ON travel_modules;
CREATE POLICY "authenticated manage travel_modules" ON travel_modules FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- 보호된 모듈은 DB 레벨에서도 삭제 방지 (기존 guide_attractions 트리거와 동일 패턴)
CREATE OR REPLACE FUNCTION prevent_delete_protected_module()
RETURNS trigger AS $$
BEGIN
  IF old.is_protected THEN
    RAISE EXCEPTION '보호된 모듈은 삭제할 수 없습니다: %', old.name_ko;
  END IF;
  RETURN old;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_delete_protected_module ON travel_modules;
CREATE TRIGGER trg_prevent_delete_protected_module
  BEFORE DELETE ON travel_modules
  FOR EACH ROW EXECUTE FUNCTION prevent_delete_protected_module();

-- 안전장치: 혹시 이전 실행에서 테이블은 만들어졌는데(트랜잭션이 부분적으로만 반영된 경우)
-- images/tags 컬럼 타입이 잘못 남아있으면 여기서 바로잡음 (재실행해도 안전)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='travel_modules' AND column_name='images' AND data_type <> 'jsonb') THEN
    ALTER TABLE travel_modules ALTER COLUMN images TYPE jsonb USING images::text::jsonb;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='travel_modules' AND column_name='tags' AND data_type <> 'jsonb') THEN
    ALTER TABLE travel_modules ALTER COLUMN tags TYPE jsonb USING tags::text::jsonb;
  END IF;
END $$;


-- ============================================================
-- 2) 데이터 이관 (guide_attractions → travel_modules, 대경구 4개)
--    module_key는 기존 attr_key를 그대로 계승 (forest/tianmen/huanglongdong/canyon)
-- ============================================================
INSERT INTO travel_modules (module_key, name_ko, icon, region_zone, is_protected, is_active, sort_order, show_on_guide, bookable_in_tour)
SELECT
  attr_key,
  name_ko,
  icon,
  CASE attr_key WHEN 'tianmen' THEN 'city' ELSE 'wulingyuan' END,
  is_protected,
  is_active,
  sort_order,
  true,
  false   -- 대경구 자체는 조직용 상위 항목 — 실제 예약 가능한 옵션은 아래 3)에서 하위 항목으로 들어감
FROM guide_attractions
WHERE NOT EXISTS (SELECT 1 FROM travel_modules WHERE module_key = guide_attractions.attr_key);


-- ============================================================
-- 3) 데이터 이관 (guide_spots → travel_modules, 지도 핀)
--    module_key = 'spot_' + 기존 id (guide_spots.id는 이미 영문 식별자라 그대로 이어붙임)
--    parent_id = 해당 대경구(attr_id)의 travel_modules.id
-- ============================================================
INSERT INTO travel_modules (
  module_key, parent_id, name_ko, name_cn, images, video_url, desc_ko, tip_ko,
  region_zone, zone_id, type, lat, lon, gaode_uri, hours, price_note, tags,
  is_active, status, sort_order, show_on_guide, bookable_in_tour
)
SELECT
  'spot_' || gs.id,
  tm.id,
  gs.name_ko, gs.name_cn, gs.images, gs.video_url, gs.desc_ko, gs.tip_ko,
  tm.region_zone, gs.zone_id, gs.type, gs.lat, gs.lon, gs.gaode_uri, gs.hours, gs.price, gs.tags,
  gs.is_active, gs.status, gs.sort_order, true, false
FROM guide_spots gs
JOIN travel_modules tm ON tm.module_key = gs.attr_id
WHERE NOT EXISTS (SELECT 1 FROM travel_modules WHERE module_key = 'spot_' || gs.id);


-- ============================================================
-- 4) 데이터 이관 (tour_attractions → travel_modules, 맞춤투어 예약 가능 항목)
--    module_key = 'ta_' + 기존 key (기존 guide_attractions/guide_spots 키와 겹치지 않도록 접두사 부여)
--    parent_id: 아래 명시적으로 대경구가 확실한 것만 연결. 나머지는 독립 항목(NULL)으로 이관.
--    region_zone: 사용자가 직접 예시로 알려준 것만 채움. 확실치 않은 건 NULL로 남겨두고 관리자 페이지에서 검토 필요.
--    ⚠️ 아래 목록에 이름이 비슷한 항목(보봉호/보봉호수, 황룡동/황룡동굴, 부용진 2건, 금편계 2건 등)이
--       여러 개 보이는데, 기존 tour_attractions 데이터에 이미 있던 중복으로 보입니다.
--       실수로 지우면 안 되니 일단 전부 그대로 이관하고, 관리자 페이지에서 직접 확인 후 정리해주세요.
-- ============================================================
INSERT INTO travel_modules (
  module_key, parent_id, name_ko, region_zone, slot_type, booking_price,
  is_active, sort_order, show_on_guide, bookable_in_tour
)
SELECT
  'ta_' || ta.key,
  CASE ta.key
    WHEN 'forest_park'  THEN (SELECT id FROM travel_modules WHERE module_key='forest')
    WHEN 'forest_east'  THEN (SELECT id FROM travel_modules WHERE module_key='forest')
    WHEN 'forest_south' THEN (SELECT id FROM travel_modules WHERE module_key='forest')
    WHEN 'huangshi_village' THEN (SELECT id FROM travel_modules WHERE module_key='forest')
    WHEN 'jinbian_trek' THEN (SELECT id FROM travel_modules WHERE module_key='forest')
    WHEN 'jinbianxi'    THEN (SELECT id FROM travel_modules WHERE module_key='forest')
    WHEN 'tianmen'      THEN (SELECT id FROM travel_modules WHERE module_key='tianmen')
    WHEN 'grand_canyon' THEN (SELECT id FROM travel_modules WHERE module_key='canyon')
    WHEN 'huanglong'      THEN (SELECT id FROM travel_modules WHERE module_key='huanglongdong')
    WHEN 'huanglong_cave' THEN (SELECT id FROM travel_modules WHERE module_key='huanglongdong')
    ELSE NULL
  END,
  ta.label,
  CASE ta.key
    WHEN 'tianmen'          THEN 'city'
    WHEN 'qixing'            THEN 'city'
    WHEN 'dayong_ancient_city' THEN 'city'
    WHEN 'qiqilou'            THEN 'city'
    WHEN 'qiqilou_inside'     THEN 'city'
    WHEN 'qiqilou_outside'    THEN 'city'
    WHEN 'citytour'           THEN 'city'
    WHEN 'tianmen_fox_show'   THEN 'city'
    WHEN 'xiangxi_show'       THEN 'city'
    WHEN 'forest_park'  THEN 'wulingyuan'
    WHEN 'forest_east'  THEN 'wulingyuan'
    WHEN 'forest_south' THEN 'wulingyuan'
    WHEN 'huangshi_village' THEN 'wulingyuan'
    WHEN 'jinbian_trek' THEN 'wulingyuan'
    WHEN 'jinbianxi'    THEN 'wulingyuan'
    WHEN 'grand_canyon' THEN 'wulingyuan'
    WHEN 'huanglong'      THEN 'wulingyuan'
    WHEN 'huanglong_cave' THEN 'wulingyuan'
    WHEN 'baofeng'      THEN 'wulingyuan'
    WHEN 'baofeng_lake' THEN 'wulingyuan'
    WHEN 'furong'       THEN 'outside'
    WHEN 'furong_town'  THEN 'outside'
    WHEN 'hongshi_forest' THEN 'outside'
    WHEN 'fenghuang'      THEN 'outside'
    ELSE NULL  -- yaozi_village/tujia/supermarket/supermarket_night/cafe 등은 확실치 않아 비워둠 — 관리자 페이지에서 직접 지정 필요
  END,
  ta.slot_type,
  ta.price,
  ta.is_active,
  ta.sort_order,
  false,  -- 원래 guide.html 지도에는 없던 항목이므로 기본은 비노출. 지도에도 보이고 싶으면 관리자 페이지에서 켜면 됨
  true
FROM tour_attractions ta
WHERE NOT EXISTS (SELECT 1 FROM travel_modules WHERE module_key = 'ta_' || ta.key);

-- 확인용:
-- SELECT module_key, parent_id, name_ko, region_zone, slot_type, booking_price, bookable_in_tour, show_on_guide FROM travel_modules ORDER BY parent_id NULLS FIRST, sort_order;
