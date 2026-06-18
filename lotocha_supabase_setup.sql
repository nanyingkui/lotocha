-- =====================================================
-- 로투차 (LocalTour China) — Supabase 전체 스키마
-- Supabase 대시보드 → SQL Editor에서 실행
-- Project: https://qbzoepglovwlarjssqjg.supabase.co
-- =====================================================

-- ─────────────────────────────────────────────
-- 1. 투어 상품 테이블 (tour_products)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tour_products (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  product_type  text NOT NULL CHECK (product_type IN ('day_tour', 'package')),
  title_ko      text NOT NULL,
  title_cn      text,
  subtitle_ko   text,
  description_ko text,
  price_krw     integer,
  price_cny     numeric(10,2),
  duration_days integer DEFAULT 1,
  highlights    jsonb DEFAULT '[]',
  includes      jsonb DEFAULT '[]',
  excludes      jsonb DEFAULT '[]',
  itinerary     jsonb DEFAULT '[]',
  images        jsonb DEFAULT '[]',
  max_pax       integer DEFAULT 10,
  min_pax       integer DEFAULT 1,
  is_active     boolean DEFAULT true,
  sort_order    integer DEFAULT 0,
  status        text DEFAULT 'live' CHECK (status IN ('draft', 'pending', 'live', 'archived')),
  created_by    uuid,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

-- ─────────────────────────────────────────────
-- 2. 가이드 스팟 테이블 (guide_spots)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guide_spots (
  id          text PRIMARY KEY,
  attr_id     text NOT NULL CHECK (attr_id IN ('forest', 'tianmen', 'canyon')),
  zone_id     text,
  name_ko     text NOT NULL,
  name_cn     text,
  type        text NOT NULL CHECK (type IN ('landmark','transport','viewpoint','toilet','food','rest','ticket','info','danger')),
  lat         numeric(10,7),
  lon         numeric(10,7),
  gaode_uri   text,
  images      jsonb DEFAULT '[]',
  desc_ko     text,
  tip_ko      text,
  hours       text,
  price       text,
  tags        jsonb DEFAULT '[]',
  is_active   boolean DEFAULT true,
  sort_order  integer DEFAULT 0,
  status      text DEFAULT 'live' CHECK (status IN ('draft', 'pending', 'live')),
  created_by  uuid,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ─────────────────────────────────────────────
-- 3. 사이트 콘텐츠 테이블 (site_content)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS site_content (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  page        text NOT NULL,
  section     text NOT NULL,
  title_ko    text,
  body_ko     text,
  body_cn     text,
  images      jsonb DEFAULT '[]',
  links       jsonb DEFAULT '[]',
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  status      text DEFAULT 'live' CHECK (status IN ('draft', 'pending', 'live')),
  created_by  uuid,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ─────────────────────────────────────────────
-- 4. 스팟 리뷰 테이블 (guide_reviews)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guide_reviews (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  spot_id     text NOT NULL,
  attr_id     text NOT NULL,
  nickname    text NOT NULL,
  rating      integer CHECK (rating BETWEEN 1 AND 5) NOT NULL,
  comment     text NOT NULL,
  created_at  timestamptz DEFAULT now(),
  approved    boolean DEFAULT false,
  ip_hash     text
);

-- ─────────────────────────────────────────────
-- 5. 방문 통계 테이블 (guide_stats)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guide_stats (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  page        text NOT NULL DEFAULT 'guide',
  attr_id     text,
  visited_at  timestamptz DEFAULT now(),
  user_agent  text
);

-- ─────────────────────────────────────────────
-- 6. 관리자 사용자 테이블 (admin_users)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_users (
  id           uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email        text NOT NULL,
  role         text NOT NULL DEFAULT 'editor' CHECK (role IN ('superadmin', 'admin', 'editor')),
  display_name text,
  approved     boolean DEFAULT false,
  approved_by  uuid,
  approved_at  timestamptz,
  created_at   timestamptz DEFAULT now()
);

-- ─────────────────────────────────────────────
-- 7. 관리자 변경 이력 테이블 (admin_changes)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_changes (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  table_name   text NOT NULL,
  record_id    text NOT NULL,
  action       text NOT NULL CHECK (action IN ('create', 'update', 'delete', 'approve', 'reject')),
  changed_by   uuid NOT NULL,
  changed_data jsonb,
  status       text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by  uuid,
  reviewed_at  timestamptz,
  created_at   timestamptz DEFAULT now()
);

-- ─────────────────────────────────────────────
-- RLS (Row Level Security) 설정
-- ─────────────────────────────────────────────

ALTER TABLE tour_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_spots ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_changes ENABLE ROW LEVEL SECURITY;

-- tour_products
CREATE POLICY "tour_products_public_read"
  ON tour_products FOR SELECT
  USING (status = 'live' AND is_active = true);

CREATE POLICY "tour_products_admin_all"
  ON tour_products FOR ALL
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true));

-- guide_spots
CREATE POLICY "guide_spots_public_read"
  ON guide_spots FOR SELECT
  USING (status = 'live' AND is_active = true);

CREATE POLICY "guide_spots_admin_all"
  ON guide_spots FOR ALL
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true));

-- site_content
CREATE POLICY "site_content_public_read"
  ON site_content FOR SELECT
  USING (status = 'live' AND is_active = true);

CREATE POLICY "site_content_admin_all"
  ON site_content FOR ALL
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true));

-- guide_reviews
CREATE POLICY "approved_reviews_public_read"
  ON guide_reviews FOR SELECT
  USING (approved = true);

CREATE POLICY "anyone_can_write_review"
  ON guide_reviews FOR INSERT
  WITH CHECK (true);

CREATE POLICY "admin_manage_reviews"
  ON guide_reviews FOR ALL
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true));

-- guide_stats
CREATE POLICY "anyone_can_log_stat"
  ON guide_stats FOR INSERT
  WITH CHECK (true);

CREATE POLICY "stats_public_read"
  ON guide_stats FOR SELECT
  USING (true);

-- admin_users
CREATE POLICY "admin_users_self_read"
  ON admin_users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "superadmin_manage_users"
  ON admin_users FOR ALL
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE role = 'superadmin'));

-- admin_changes
CREATE POLICY "admin_changes_own_read"
  ON admin_changes FOR SELECT
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true));

CREATE POLICY "admin_changes_insert"
  ON admin_changes FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT id FROM admin_users WHERE approved = true));

CREATE POLICY "superadmin_review_changes"
  ON admin_changes FOR UPDATE
  USING (auth.uid() IN (SELECT id FROM admin_users WHERE role IN ('superadmin','admin')));

-- ─────────────────────────────────────────────
-- 초기 투어 상품 데이터 삽입
-- ─────────────────────────────────────────────
INSERT INTO tour_products (product_type, title_ko, title_cn, subtitle_ko, description_ko, price_krw, price_cny, duration_days, highlights, includes, sort_order, status) VALUES
(
  'day_tour',
  '장가계 국가삼림공원 1일투어',
  '张家界国家森林公园一日游',
  '원가계 + 천자산 핵심 코스',
  '세계자연유산 장가계 국가삼림공원의 하이라이트를 하루에 완주하는 코스입니다. 원가계의 압도적인 석영사암 기둥군과 천자산 전망대에서 바라보는 파노라마 뷰를 경험하세요.',
  89000, 480, 1,
  '["원가계 기둥군 트레킹", "천자산 케이블카 탑승", "미혼대 전망대", "황룡동 입장 선택"]',
  '["왕복 셔틀버스", "현지 가이드(한국어)", "입장권", "점심식사"]',
  1, 'live'
),
(
  'day_tour',
  '천문산 1일투어',
  '天门山一日游',
  '천문동 + 유리잔도 스릴 체험',
  '세계 최고 높이의 산악 케이블카를 타고 천문산 정상에 오릅니다. 천문동(天門洞)을 통과하는 99굽이 하늘길과 유리잔도에서 스릴 넘치는 경험을 즐기세요.',
  79000, 420, 1,
  '["세계 최장 케이블카 탑승", "천문동(天門洞) 통과", "유리잔도 체험", "하늘문 계단 999계단"]',
  '["왕복 케이블카", "현지 가이드(한국어)", "입장권"]',
  2, 'live'
),
(
  'day_tour',
  '황룡동 + 보봉호 1일투어',
  '黄龙洞+宝峰湖一日游',
  '동굴 탐험과 호수 유람의 조합',
  '아시아 최대 규모의 종유석 동굴 황룡동과 에메랄드빛 보봉호를 함께 즐기는 코스입니다. 보트를 타고 호수를 감상하며 현지 민속 공연도 관람할 수 있습니다.',
  69000, 380, 1,
  '["황룡동 종유석 동굴", "보봉호 보트 유람", "토가족 민속 공연", "현지 전통 점심"]',
  '["왕복 셔틀버스", "현지 가이드(한국어)", "입장권", "보트비", "점심식사"]',
  3, 'live'
),
(
  'package',
  '장가계 3박4일 핵심 패키지',
  '张家界3晚4天精华套餐',
  '삼림공원 + 천문산 + 황룡동 완전정복',
  '장가계의 모든 핵심 관광지를 여유롭게 즐기는 3박4일 패키지입니다.',
  320000, 1680, 4,
  '["장가계 국가삼림공원 2일", "천문산 + 유리잔도", "황룡동 + 보봉호", "매력상서 공연 관람"]',
  '["왕복 고속철(선택)", "3박 숙박(3성급)", "전일정 한국어 가이드", "모든 입장권", "조식 포함"]',
  4, 'live'
),
(
  'package',
  '장가계 4박5일 프리미엄 패키지',
  '张家界4晚5天高端套餐',
  '자유시간 포함 여유로운 일정',
  '장가계를 느긋하게 즐기고 싶은 분들을 위한 프리미엄 패키지입니다.',
  420000, 2180, 5,
  '["국가삼림공원 2일 완전 탐방", "천문산 전체 코스", "황룡동 + 보봉호", "매력상서 + 천문호선 공연", "자유 탐방 반나절"]',
  '["왕복 고속철", "4박 숙박(4성급)", "전일정 한국어 가이드", "모든 입장권", "조식+석식 포함", "공항/역 픽업"]',
  5, 'live'
),
(
  'package',
  '장가계 2박3일 위크엔드 패키지',
  '张家界2晚3天周末套餐',
  '짧은 일정으로 즐기는 알찬 구성',
  '주말을 이용해 장가계를 방문하는 분들을 위한 2박3일 패키지입니다.',
  220000, 1180, 3,
  '["원가계 + 천자산 하이라이트", "천문산 케이블카 + 천문동", "황룡동 or 보봉호 선택"]',
  '["2박 숙박(3성급)", "전일정 한국어 가이드", "모든 입장권", "셔틀버스"]',
  6, 'live'
);

-- ─────────────────────────────────────────────
-- 슈퍼어드민 등록 (스키마 실행 후 별도 실행)
-- nanyingkui@gmail.com 계정으로 Supabase Auth에 가입 후:
-- ─────────────────────────────────────────────
-- INSERT INTO admin_users (id, email, role, display_name, approved)
-- SELECT id, email, 'superadmin', '남영규', true
-- FROM auth.users WHERE email = 'nanyingkui@gmail.com'
-- ON CONFLICT (id) DO UPDATE SET role = 'superadmin', approved = true;

-- ─────────────────────────────────────────────
-- 유용한 관리자 쿼리
-- ─────────────────────────────────────────────
-- 미승인 리뷰: SELECT * FROM guide_reviews WHERE approved = false ORDER BY created_at DESC;
-- 리뷰 승인:   UPDATE guide_reviews SET approved = true WHERE id = '...';
-- 방문자 수:   SELECT page, COUNT(*) FROM guide_stats GROUP BY page;
-- =====================================================
