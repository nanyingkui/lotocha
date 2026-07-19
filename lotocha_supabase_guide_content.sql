-- =====================================================
-- 로투차 가이드 콘텐츠 CMS 확장
-- 도우미 탭의 정적 콘텐츠를 관리자 페이지에서 편집 가능하도록 테이블화
-- Supabase SQL Editor에서 실행하세요.
-- =====================================================

-- 1) 공연 · 입장권 (show / ticket)
create table if not exists guide_shows_tickets (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('show','ticket')),
  title_ko text not null,
  subtitle_ko text default '',
  time_info text default '',
  price_info text default '',
  links jsonb default '[]'::jsonb,   -- [{ "label": "Trip.com", "url": "https://..." }]
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_shows_tickets enable row level security;
create policy "public read active shows_tickets" on guide_shows_tickets for select using (is_active = true);
create policy "authenticated manage shows_tickets" on guide_shows_tickets for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- 2) 결제 방법
create table if not exists guide_payment_methods (
  id uuid primary key default gen_random_uuid(),
  method_key text unique not null,   -- 'kakao' | 'alipay' | 'wechat' | 'didi' | 'cash' 등
  name_ko text not null,
  subtitle_ko text default '',
  logo_emoji text default '💳',
  logo_bg text default '#f5f5f5',
  steps jsonb default '[]'::jsonb,   -- ["카카오톡 → 하단 <b>...</b>", "..."]
  note_html text default '',
  link_label text default '',
  link_url text default '',
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_payment_methods enable row level security;
create policy "public read active payment_methods" on guide_payment_methods for select using (is_active = true);
create policy "authenticated manage payment_methods" on guide_payment_methods for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- 3) 안전 · 응급 정보 (긴급전화 / 병원·영사관 / 인터넷·VPN)
create table if not exists guide_emergency_info (
  id uuid primary key default gen_random_uuid(),
  section text not null check (section in ('phone','hospital','connectivity')),
  label text not null,
  value text not null,
  extra jsonb default '{}'::jsonb,   -- phone: { "color": "var(--blue)" } 등
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_emergency_info enable row level security;
create policy "public read active emergency_info" on guide_emergency_info for select using (is_active = true);
create policy "authenticated manage emergency_info" on guide_emergency_info for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- 4) 현지 회화
create table if not exists guide_phrases (
  id uuid primary key default gen_random_uuid(),
  category text default '기본',
  phrase_cn text not null,
  pinyin text default '',
  phrase_ko text not null,
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_phrases enable row level security;
create policy "public read active phrases" on guide_phrases for select using (is_active = true);
create policy "authenticated manage phrases" on guide_phrases for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- 5) 여행 팁 (구역별 💡 여행 팁 카드)
create table if not exists guide_tips (
  id uuid primary key default gen_random_uuid(),
  attr_id text not null,  -- 'forest' | 'tianmen' | 'canyon'
  tip_text text not null,
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table guide_tips enable row level security;
create policy "public read active tips" on guide_tips for select using (is_active = true);
create policy "authenticated manage tips" on guide_tips for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- =====================================================
-- 기존 하드코딩 콘텐츠를 초기 데이터로 이전 (최초 1회)
-- =====================================================

insert into guide_shows_tickets (kind, title_ko, subtitle_ko, time_info, price_info, links, sort_order) values
('show', '매력상서 (魅力湘西)', '후난 토가족·묘족 전통 민속 공연.', '매일 19:30 (약 80분)', '¥160~280',
  '[{"label":"🎫 Trip.com","url":"https://kr.trip.com/attraction/buy/zhangjiajie-charming-xiangxi/"},{"label":"🎫 마이리얼트립","url":"https://experiences.myrealtrip.com/search?query=장가계+매력상서"}]', 1),
('show', '천문호선 (天门狐仙)', '천문산 절벽 야외 대형 공연.', '매일 20:00 (약 50분)', '¥180~380',
  '[{"label":"🎫 와그","url":"https://www.waug.com/ko/activities/143405"},{"label":"🎫 Trip.com","url":"https://kr.trip.com/moments/theme/poi-tianmen-fox-fairy-93422-attraction-993137/"}]', 2),
('ticket', '🌲 국가삼림공원', '여권 1개당 4일 재입장.', '', '¥236 (4일권)',
  '[{"label":"Trip.com","url":"https://kr.trip.com/travel-guide/attraction/zhangjiajie/zhangjiajie-national-forest-park/"}]', 3),
('ticket', '⛰️ 천문산 케이블카+입장', '온라인 예약 강력 추천.', '', '¥268',
  '[{"label":"마이리얼트립","url":"https://experiences.myrealtrip.com/products/3887183"}]', 4),
('ticket', '🌉 대협곡 유리다리', '1일 8,000명 제한. 사전 예약 필수.', '', '¥216',
  '[{"label":"Trip.com","url":"https://kr.trip.com/travel-guide/attraction/zhangjiajie/zhangjiajie-grand-canyon/"}]', 5)
on conflict do nothing;

insert into guide_payment_methods (method_key, name_ko, subtitle_ko, logo_emoji, logo_bg, steps, note_html, link_label, link_url, sort_order) values
('kakao', '카카오페이 × 알리페이플러스', '한국인 가장 간편', '💛', '#FEE500',
  '["카카오톡 → 하단 <b>···</b> → <b>카카오페이</b>","<b>결제</b> 탭 → <b>🌐 지구본</b> → <b>중국(China)</b>","QR코드 → 가맹점 스캔"]',
  '⚠️ 출발 전 카카오페이머니 잔고 확인.', '카카오페이 공식 →', 'https://pay.kakao.com', 1),
('alipay', '알리페이 (支付宝)', '여권 인증 + 한국 카드 등록', '🔵', '#1677ff',
  '["<b>한국에서 미리</b> Alipay 설치","국가코드 <b>+82</b> → SMS 인증","\"Tour Pass\" 검색 → 여권 업로드","Visa/Mastercard 한국 카드 등록"]',
  '⚠️ 인증 1~3일 소요. 출발 3일 전 완료 필수.', '알리페이 →', 'https://intl.alipay.com', 2),
('wechat', '위챗페이 (WeChat Pay)', '카드 등록 필요', '💚', '#07c160',
  '["WeChat 설치 → 한국 번호 가입","Me → Services → Wallet → Cards","해외 카드 등록 + 여권 인증"]',
  '⚠️ 외국인은 개인 간 송금 제한.', 'WeChat →', 'https://www.wechat.com', 3),
('didi', '디디택시 (DiDi)', '알리페이 앱에서 호출', '🚕', '#ff6400',
  '["알리페이 → 검색 <b>\"滴滴出行\"</b>","목적지 입력 (영문/중문)","Confirm → 배차 후 탑승"]',
  '💡 하차 시 알리페이 자동 결제.', '', '', 4),
('cash', '현금 & ATM', '최후 수단', '💴', '#f5f5f5',
  '["<b>중국은행</b> 또는 <b>공상은행</b> ATM","Visa/Mastercard. 1회 최대 2,000~3,000위안"]',
  '💡 경관지 매표소는 카드 단말기 대부분 구비.', '', '', 5)
on conflict (method_key) do nothing;

insert into guide_emergency_info (section, label, value, extra, sort_order) values
('phone', '경찰', '110', '{}', 1),
('phone', '구급차', '120', '{}', 2),
('phone', '소방', '119', '{}', 3),
('phone', '관광 불편', '12301', '{"color":"var(--blue)"}', 4),
('hospital', '시내 병원', '장가계시 인민병원 ☎ +86-744-8222120', '{}', 1),
('hospital', '무릉원', '무릉원구 인민병원 ☎ +86-744-5610120', '{}', 2),
('hospital', '🇰🇷 영사관', '주창사 한국총영사관 ☎ +86-731-8256-0525', '{}', 3),
('connectivity', 'VPN', '출국 전 설치 필수. ExpressVPN·Surfshark', '{}', 1),
('connectivity', 'SIM', '공항: 차이나유니콤 관광 SIM 30일 ¥100', '{}', 2)
on conflict do nothing;

insert into guide_phrases (category, phrase_cn, pinyin, phrase_ko, sort_order) values
('🚕 교통', '请带我去张家界国家森林公园南门', 'Qǐng dài wǒ qù... nán mén', '삼림공원 남문으로', 1),
('🚕 교통', '请带我去天门山索道下站', 'Qǐng dài wǒ qù tiānménshān suǒdào xià zhàn', '천문산 케이블카 하단', 2),
('🚕 교통', '请带我去张家界大峡谷', 'Qǐng dài wǒ qù zhāngjiājiè dàxiágǔ', '대협곡으로', 3),
('🚕 교통', '多少钱？', 'Duōshǎo qián?', '얼마예요?', 4),
('🚕 교통', '请打表', 'Qǐng dǎ biǎo', '미터기 켜주세요', 5),
('🎫 경관지', '最后一班缆车几点？', 'Zuìhòu yī bān lǎnchē jǐ diǎn?', '마지막 케이블카 몇 시?', 1),
('🎫 경관지', '厕所在哪里？', 'Cèsuǒ zài nǎlǐ?', '화장실 어디?', 2),
('🎫 경관지', '出口在哪里？', 'Chūkǒu zài nǎlǐ?', '출구 어디?', 3),
('🍜 식사', '不要太辣', 'Bù yào tài là', '너무 맵지 않게', 1),
('🍜 식사', '买单', 'Mǎi dān', '계산해주세요', 2),
('🍜 식사', 'WiFi密码是什么？', 'WiFi mìmǎ shì shénme?', '와이파이 비번?', 3),
('🚨 긴급', '我需要帮助！', 'Wǒ xūyào bāngzhù!', '도움이 필요해요!', 1),
('🚨 긴급', '请叫救护车', 'Qǐng jiào jiùhùchē', '구급차 불러주세요', 2),
('🚨 긴급', '我迷路了', 'Wǒ mí lù le', '길을 잃었어요', 3)
on conflict do nothing;

insert into guide_tips (attr_id, tip_text, sort_order) values
('forest', '👟 운동화 필수.', 1),
('forest', '⏰ 4일권.', 2),
('forest', '📱 오프라인 지도 다운로드.', 3),
('forest', '🌫️ 오전 안개는 10시 이후 걷힘.', 4),
('forest', '🔋 보조배터리 필수.', 5),
('tianmen', '🧥 정상 6°C 낮음. 겉옷 필수.', 1),
('tianmen', '📸 케이블카에서 항공 사진.', 2),
('tianmen', '⏰ 최소 4시간.', 3),
('canyon', '🚗 시내에서 130km.', 1),
('canyon', '📅 유리다리 8,000명 제한.', 2),
('canyon', '💧 물·간식 넉넉히.', 3)
on conflict do nothing;
