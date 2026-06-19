-- ============================================================
-- 기존에 관리자 페이지로 등록한 상품이 "is_active"가 비어 있어
-- (admin이 status만 저장하고 is_active는 안 건드림) 메인 페이지에
-- 안 보이던 문제 일괄 수정
-- Supabase SQL Editor에서 1회만 실행하세요
-- ============================================================

UPDATE tour_products
SET is_active = (status = 'live')
WHERE is_active IS NULL;
