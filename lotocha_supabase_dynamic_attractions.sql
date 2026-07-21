-- ============================================================
-- 경관지(attraction) 개수 제한 완전 해제 (2026-07-21)
--
-- 배경: guide_spots.attr_id 는 지금까지 'forest'/'tianmen'/'huanglongdong'/
-- 'canyon' 같은 고정된 값만 허용하는 CHECK 제약이 걸려 있었습니다. 그래서
-- 관리자 페이지에서 새 경관지(景区)를 추가할 때마다 매번 이런 SQL 파일을
-- 새로 실행해서 제약을 갱신해야 했습니다.
--
-- 이 스크립트는 그 고정 CHECK 제약을 완전히 제거하고, 대신
-- guide_attractions(attr_key) 를 참조하는 FOREIGN KEY로 교체합니다.
-- 이렇게 하면 앞으로는 관리자 페이지("경관지" 패널 또는 "景区详情设置" 패널)
-- 에서 새 경관지를 추가하기만 하면 향도지점(guide_spots)에서 바로 그
-- attr_id를 사용할 수 있고, SQL을 다시 실행할 필요가 없습니다.
--
-- Supabase SQL Editor에서 실행하세요 (재실행해도 안전합니다)
-- ============================================================

-- 1) guide_spots: 고정 CHECK 제약 제거 → guide_attractions(attr_key) FK로 교체
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

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'guide_spots'::regclass
      AND contype = 'f'
      AND conname = 'guide_spots_attr_id_fkey'
  ) THEN
    ALTER TABLE guide_spots
      ADD CONSTRAINT guide_spots_attr_id_fkey
      FOREIGN KEY (attr_id) REFERENCES guide_attractions(attr_key);
  END IF;
END $$;

-- 2) guide_tips: 동일한 방식(있는 경우에만)
DO $$
DECLARE
  con_name text;
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'guide_tips') THEN
    SELECT conname INTO con_name
    FROM pg_constraint
    WHERE conrelid = 'guide_tips'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%attr_id%';

    IF con_name IS NOT NULL THEN
      EXECUTE format('ALTER TABLE guide_tips DROP CONSTRAINT %I', con_name);
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
      WHERE conrelid = 'guide_tips'::regclass
        AND contype = 'f'
        AND conname = 'guide_tips_attr_id_fkey'
    ) THEN
      ALTER TABLE guide_tips
        ADD CONSTRAINT guide_tips_attr_id_fkey
        FOREIGN KEY (attr_id) REFERENCES guide_attractions(attr_key);
    END IF;
  END IF;
END $$;

-- 3) 景区详情设置 6개 테이블(guide_attr_map_config / guide_plan_steps /
--    guide_rain_items / guide_last_transport / guide_transport_options /
--    guide_zones)도 동일하게 attr_id → guide_attractions(attr_key) FK를
--    걸어 데이터 무결성을 보장합니다. (이 테이블들이 아직 없다면 즉,
--    lotocha_supabase_guide_attr_details.sql을 아직 실행하지 않았다면
--    이 블록은 자동으로 건너뜁니다)
DO $$
DECLARE
  t text;
  tables text[] := ARRAY['guide_attr_map_config','guide_plan_steps','guide_rain_items','guide_last_transport','guide_transport_options','guide_zones'];
  con_name text;
BEGIN
  FOREACH t IN ARRAY tables LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t) THEN
      con_name := t || '_attr_id_fkey';
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = t::regclass AND contype = 'f' AND conname = con_name
      ) THEN
        EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (attr_id) REFERENCES guide_attractions(attr_key)', t, con_name);
      END IF;
    END IF;
  END LOOP;
END $$;

-- 확인용:
-- SELECT conname, conrelid::regclass FROM pg_constraint WHERE conname LIKE '%attr_id%';
