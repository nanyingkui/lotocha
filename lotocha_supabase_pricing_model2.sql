-- ============================================================
-- 가격 구성 확장 v2 (2026-07-20 추가) — 환율 / 이윤 / 연령 할인 / 자연손모
-- lotocha_supabase_pricing_model.sql 다음에 실행하세요 (재실행해도 안전)
-- ============================================================

-- ── 1. 환율 (위안 → 원) — 기존 가격 설정 테이블에 항목만 추가 ──
INSERT INTO tour_pricing_settings (key, label, value, unit, note, sort_order) VALUES
  ('exchange_rate', '환율 (위안→원)', 190, '원/위안', '실제 환율에 맞게 수시로 수정 필요', 8)
ON CONFLICT (key) DO NOTHING;

-- ── 2. 이윤 설정 (인당 고정액 또는 주문당 고정액/비율 중 선택) ──
CREATE TABLE IF NOT EXISTS tour_margin_settings (
  id          integer PRIMARY KEY DEFAULT 1,
  mode        text NOT NULL DEFAULT 'per_person',   -- per_person(인당) / per_order(주문당)
  value_type  text NOT NULL DEFAULT 'amount',        -- amount(고정 금액,원) / percent(비율,%)
  value       numeric NOT NULL DEFAULT 0,
  updated_at  timestamptz DEFAULT now(),
  CONSTRAINT single_row CHECK (id = 1)
);
ALTER TABLE tour_margin_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read tour_margin_settings" ON tour_margin_settings;
DROP POLICY IF EXISTS "auth write tour_margin_settings"  ON tour_margin_settings;
CREATE POLICY "public read tour_margin_settings" ON tour_margin_settings FOR SELECT USING (true);
CREATE POLICY "auth write tour_margin_settings"  ON tour_margin_settings FOR ALL USING (auth.role() = 'authenticated');
INSERT INTO tour_margin_settings (id, mode, value_type, value) VALUES (1, 'per_person', 'amount', 0)
ON CONFLICT (id) DO NOTHING;

-- ── 3. 연령별 할인 (장가계 관광지 경로할인 등, 원화 고정 할인액) ──
CREATE TABLE IF NOT EXISTS tour_age_discounts (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label        text NOT NULL,          -- 예: 만 60세 이상
  min_age      integer,                -- null이면 하한 없음
  max_age      integer,                -- null이면 상한 없음
  discount_krw integer NOT NULL DEFAULT 0,  -- 1인당 원화 고정 할인액
  sort_order   integer DEFAULT 0,
  is_active    boolean DEFAULT true,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);
ALTER TABLE tour_age_discounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read tour_age_discounts" ON tour_age_discounts;
DROP POLICY IF EXISTS "auth write tour_age_discounts"  ON tour_age_discounts;
CREATE POLICY "public read tour_age_discounts" ON tour_age_discounts FOR SELECT USING (is_active = true);
CREATE POLICY "auth write tour_age_discounts"  ON tour_age_discounts FOR ALL USING (auth.role() = 'authenticated');
CREATE INDEX IF NOT EXISTS idx_tour_age_discounts_order ON tour_age_discounts(sort_order);

INSERT INTO tour_age_discounts (label, min_age, max_age, discount_krw, sort_order)
SELECT * FROM (VALUES
  ('만 60세 이상', 60, NULL, 50000, 1),
  ('만 70세 이상', 70, NULL, 80000, 2),
  ('만 12세 이하', NULL, 12, 80000, 3)
) AS seed(label, min_age, max_age, discount_krw, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM tour_age_discounts);

-- ── 4. 자연손모 등 기타 원가 항목 (금액·항목명 자유 설정) ──
CREATE TABLE IF NOT EXISTS tour_cost_buffers (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,           -- 예: 자연손모, 우천 예비비 등
  amount      numeric NOT NULL DEFAULT 0,
  currency    text NOT NULL DEFAULT 'CNY',  -- CNY 또는 KRW
  per_unit    text NOT NULL DEFAULT 'order', -- order(주문당) / pax(인당)
  note        text,
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);
ALTER TABLE tour_cost_buffers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read tour_cost_buffers" ON tour_cost_buffers;
DROP POLICY IF EXISTS "auth write tour_cost_buffers"  ON tour_cost_buffers;
CREATE POLICY "public read tour_cost_buffers" ON tour_cost_buffers FOR SELECT USING (is_active = true);
CREATE POLICY "auth write tour_cost_buffers"  ON tour_cost_buffers FOR ALL USING (auth.role() = 'authenticated');
CREATE INDEX IF NOT EXISTS idx_tour_cost_buffers_order ON tour_cost_buffers(sort_order);
