-- ============================================================
-- 1. guide_spots에 video_url 컬럼 추가
-- 2. Supabase Storage 버킷 생성 (이미지·영상 업로드)
-- Supabase SQL Editor에서 실행하세요
-- ============================================================

-- 1. video_url 컬럼
ALTER TABLE guide_spots
  ADD COLUMN IF NOT EXISTS video_url text;

-- 2. Storage 버킷 생성 (lotocha-media)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lotocha-media',
  'lotocha-media',
  true,                    -- 공개 접근 가능
  104857600,               -- 100MB 제한 (0으로 바꾸면 무제한)
  NULL                     -- 파일 형식 제한 없음
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 104857600,
  allowed_mime_types = NULL;

-- 3. Storage RLS 정책
DROP POLICY IF EXISTS "public read lotocha-media" ON storage.objects;
DROP POLICY IF EXISTS "auth upload lotocha-media" ON storage.objects;
DROP POLICY IF EXISTS "auth delete lotocha-media" ON storage.objects;

CREATE POLICY "public read lotocha-media"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'lotocha-media');

CREATE POLICY "auth upload lotocha-media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'lotocha-media' AND auth.role() = 'authenticated');

CREATE POLICY "auth delete lotocha-media"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'lotocha-media' AND auth.role() = 'authenticated');
