-- ============================================================
-- 황룡동/대협곡 분리 (2026-07-21)
--
-- 배경: 기존에는 attr_id='canyon' 하나로 황룡동(동굴)과 대협곡(유리다리)을
-- 묶어서 관리했는데, 실제로는 서로 약 27~30km(차로 40분~1시간) 떨어진
-- 별개의 관광지라 관리자·고객 모두 헷갈리는 문제가 있었습니다.
-- 이제 두 곳을 완전히 독립된 경관지(huanglongdong / canyon)로 분리합니다.
-- (canyon은 이제 "대협곡"만을 의미하며, 황룡동은 새 attr_id='huanglongdong'
--  으로 이동합니다)
--
-- guide_attractions 테이블(경관지 이름/보호 여부)은 관리자 페이지에서
-- 이미 직접 수정 완료된 상태입니다. 이 스크립트는 guide_spots 테이블의
-- attr_id 체크 제약(guide_spots_attr_id_check)이 'huanglongdong' 값을
-- 허용하도록 갱신하고, 기존 9개 스팟의 attr_id/zone_id를 재배정합니다.
--
-- Supabase SQL Editor에서 실행하세요 (재실행해도 안전합니다)
-- ============================================================

-- 1) guide_spots.attr_id 체크 제약을 새 attr_id 값을 포함하도록 갱신
DO $$
DECLARE
  con_name text;
BEGIN
  SELECT conname INTO con_name
  FROM pg_constraint
  WHERE conrelid = 'guide_spots'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) ILIKE '%attr_id%';

  IF con_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE guide_spots DROP CONSTRAINT %I', con_name);
  END IF;

  ALTER TABLE guide_spots
    ADD CONSTRAINT guide_spots_attr_id_check
    CHECK (attr_id IN ('forest','tianmen','huanglongdong','canyon'));
END $$;

-- (참고용, 있다면 함께 갱신: guide_attractions/guide_tips 등 다른 테이블에
--  attr_id 체크 제약이 걸려 있다면 아래에서 동일하게 처리)
DO $$
DECLARE
  con_name text;
BEGIN
  SELECT conname INTO con_name
  FROM pg_constraint
  WHERE conrelid = 'guide_tips'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) ILIKE '%attr_id%';

  IF con_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE guide_tips DROP CONSTRAINT %I', con_name);
    ALTER TABLE guide_tips
      ADD CONSTRAINT guide_tips_attr_id_check
      CHECK (attr_id IN ('forest','tianmen','huanglongdong','canyon'));
  END IF;
END $$;

-- 2) 기존 9개 스팟 재배정
--    황룡동 관련 3개: attr_id를 huanglongdong으로 이동, zone_id 제거
UPDATE guide_spots
SET attr_id = 'huanglongdong', zone_id = NULL
WHERE id IN ('canyon_hld_entrance','canyon_hld_boat','canyon_hld_viewpoint');

--    대협곡 관련 6개: attr_id는 canyon 유지, zone_id만 제거(더 이상 구역 불필요)
UPDATE guide_spots
SET zone_id = NULL
WHERE id IN ('canyon_bridge_entrance','canyon_glass_bridge','canyon_slide','canyon_boat','canyon_toilet','canyon_food');

-- 확인용:
-- SELECT id, attr_id, zone_id, name_ko FROM guide_spots WHERE attr_id IN ('huanglongdong','canyon') ORDER BY attr_id, id;
