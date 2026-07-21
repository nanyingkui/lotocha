-- ============================================================
-- "지역(guide_regions)" 목록이 전부 2개씩 중복 표시되는 문제 수정 (2026-07-21)
--
-- 원인: lotocha_supabase_categories.sql의 guide_regions 시드가
--   INSERT ... ON CONFLICT DO NOTHING
-- 형태였는데, guide_regions 테이블에는 name_ko에 대한 유니크 제약이
-- 없었습니다. id는 매번 새 uuid로 생성되므로 "충돌" 자체가 발생하지
-- 않아 ON CONFLICT DO NOTHING이 사실상 아무 효과가 없었고, 그 SQL
-- 파일이 (실수로든 의도적으로든) 두 번 실행되며 7개 지역이 각각
-- 2행씩, 총 14행으로 중복 저장된 상태입니다.
--
-- 이 스크립트는:
--   1) 같은 name_ko끼리 중복된 행 중 1개만 남기고 나머지를 삭제
--   2) name_ko에 유니크 제약을 추가해 앞으로 재실행해도 중복이
--      다시 생기지 않도록 방지
-- Supabase SQL Editor에서 실행하세요 (재실행해도 안전)
-- ============================================================

-- 1) 중복 제거: 같은 name_ko 중 sort_order → created_at → id 순으로
--    가장 먼저 만들어진 1행만 남기고 나머지는 삭제
DELETE FROM guide_regions
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY name_ko ORDER BY sort_order, created_at, id) AS rn
    FROM guide_regions
  ) t
  WHERE t.rn > 1
);

-- 2) 재발 방지: name_ko 유니크 제약 추가 (이미 있으면 건너뜀)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'guide_regions_name_ko_key'
  ) THEN
    ALTER TABLE guide_regions ADD CONSTRAINT guide_regions_name_ko_key UNIQUE (name_ko);
  END IF;
END $$;

-- 확인용: 실행 후 아래 쿼리로 지역별 1행씩만 남았는지 확인할 수 있습니다.
-- SELECT name_ko, COUNT(*) FROM guide_regions GROUP BY name_ko ORDER BY name_ko;
