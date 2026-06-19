-- ============================================================
-- local_places 테이블 생성
-- 현지 업체 (식당·카페·호텔·쇼핑 등) 관리
-- Supabase SQL Editor에서 실행하세요
-- ============================================================

CREATE TABLE IF NOT EXISTS local_places (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category     text NOT NULL DEFAULT 'restaurant',   -- restaurant/cafe/hotel/shop/attraction/transport/etc
  area         text,                                  -- 시내/무릉원/천문산/황룡동 등
  name_ko      text NOT NULL,
  name_cn      text,
  address      text,
  phone        text,
  wechat       text,
  hours        text,
  price_range  text,
  lat          double precision,
  lon          double precision,
  gaode_uri    text,
  images       jsonb DEFAULT '[]'::jsonb,
  desc_ko      text,
  tags         jsonb DEFAULT '[]'::jsonb,             -- ["한국어메뉴","카드가능"]
  sort_order   integer DEFAULT 0,
  is_active    boolean DEFAULT true,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

-- RLS (Row Level Security) 설정
ALTER TABLE local_places ENABLE ROW LEVEL SECURITY;

-- 누구나 읽기 가능 (웹 프론트에서 fetch)
DROP POLICY IF EXISTS "public read local_places" ON local_places;
DROP POLICY IF EXISTS "auth write local_places" ON local_places;

CREATE POLICY "public read local_places"
  ON local_places FOR SELECT USING (is_active = true);

-- 관리자만 쓰기 (anon 키로는 INSERT/UPDATE/DELETE 불가)
CREATE POLICY "auth write local_places"
  ON local_places FOR ALL
  USING (auth.role() = 'authenticated');

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_local_places_category ON local_places(category);
CREATE INDEX IF NOT EXISTS idx_local_places_area     ON local_places(area);
CREATE INDEX IF NOT EXISTS idx_local_places_order    ON local_places(sort_order);
