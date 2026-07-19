-- =====================================================
-- 로투차 카테고리 관리 확장 (지역 / 업체 카테고리 / 경관지)
-- Supabase SQL Editor에서 실행하세요 (새 쿼리 탭에서)
-- =====================================================

-- 1) 지역 (현지 업체 필터용)
create table if not exists guide_regions (
  id uuid primary key default gen_random_uuid(),
  name_ko text not null,
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_regions enable row level security;
drop policy if exists "public read active regions" on guide_regions;
create policy "public read active regions" on guide_regions for select using (is_active = true);
drop policy if exists "authenticated manage regions" on guide_regions;
create policy "authenticated manage regions" on guide_regions for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

insert into guide_regions (name_ko, sort_order) values
('시내(융딩구)', 1),
('무릉원구', 2),
('천문산', 3),
('황룡동', 4),
('봉황고성', 5),
('부용진', 6),
('기타', 99)
on conflict do nothing;

-- 2) 업체 카테고리 (현지 업체 분류)
create table if not exists guide_place_categories (
  id uuid primary key default gen_random_uuid(),
  cat_key text unique not null,
  name_ko text not null,
  icon text default '📍',
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_place_categories enable row level security;
drop policy if exists "public read active place_categories" on guide_place_categories;
create policy "public read active place_categories" on guide_place_categories for select using (is_active = true);
drop policy if exists "authenticated manage place_categories" on guide_place_categories;
create policy "authenticated manage place_categories" on guide_place_categories for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

insert into guide_place_categories (cat_key, name_ko, icon, sort_order) values
('restaurant','식당','🍜',1),
('cafe','카페','☕',2),
('hotel','호텔/숙소','🏨',3),
('shop','쇼핑','🛍️',4),
('attraction','볼거리','🎭',5),
('transport','교통','🚕',6),
('etc','기타','✨',7)
on conflict (cat_key) do nothing;

-- 3) 경관지 (景区) — forest/tianmen/canyon은 지도·GPS·구역·일정 로직에 고정 연결되어
--    is_protected=true 로 삭제 방지. 새로 추가하는 항목은 태그/필터 용도로만 사용되며
--    지도 탭에 자동으로 반영되려면 별도 개발이 필요합니다.
create table if not exists guide_attractions (
  id uuid primary key default gen_random_uuid(),
  attr_key text unique not null,
  name_ko text not null,
  icon text default '📍',
  is_protected boolean default false,
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_attractions enable row level security;
drop policy if exists "public read active attractions" on guide_attractions;
create policy "public read active attractions" on guide_attractions for select using (is_active = true);
drop policy if exists "authenticated manage attractions" on guide_attractions;
create policy "authenticated manage attractions" on guide_attractions for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

insert into guide_attractions (attr_key, name_ko, icon, is_protected, sort_order) values
('forest','국가삼림공원','🌲', true, 1),
('tianmen','천문산','⛰️', true, 2),
('canyon','황룡동+대협곡','🌉', true, 3)
on conflict (attr_key) do nothing;

-- 보호된 경관지(is_protected=true)는 DB 레벨에서도 삭제 방지
create or replace function prevent_delete_protected_attraction()
returns trigger as $$
begin
  if old.is_protected then
    raise exception '보호된 경관지는 삭제할 수 없습니다: %', old.attr_key;
  end if;
  return old;
end;
$$ language plpgsql;

drop trigger if exists trg_prevent_delete_protected_attraction on guide_attractions;
create trigger trg_prevent_delete_protected_attraction
  before delete on guide_attractions
  for each row execute function prevent_delete_protected_attraction();
