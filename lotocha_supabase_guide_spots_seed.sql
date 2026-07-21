-- ============================================================
-- 가이드 스팟(guide_spots) 초기 데이터 이관 (2026-07-21)
-- 문제: guide_spots 테이블이 비어있어 lotocha_guide.html이 정적 파일
--       lotocha_spots.json 으로 자동 폴백 중이었음 → 관리자 페이지
--       "가이드 스팟"에서는 그 내용이 안 보이고 수정도 불가능했음.
-- 이 스크립트는 lotocha_spots.json에 있던 42개 스팟을 guide_spots
-- 테이블에 그대로 넣어, 관리자 페이지에서 편집 가능하게 만듭니다.
-- Supabase SQL Editor에서 실행하세요 (재실행해도 안전 — id 기준 upsert)
-- ============================================================

INSERT INTO guide_spots (id, attr_id, zone_id, type, name_ko, name_cn, lat, lon, gaode_uri, images, desc_ko, tip_ko, hours, price, sort_order, status) VALUES
('forest_south_gate', 'forest', 'south', 'ticket', '🅿️ 남문 입구·여권 매표소', '国家森林公园南门售票处', 29.3387, 110.5358, 'https://uri.amap.com/search?keyword=张家界国家森林公园南门&city=张家界', '[]'::jsonb, '삼림공원 메인 입구. 여권 제시 후 입장권(4일권) 구매. 관광버스 하차 지점.', '외국인 매표 창구 별도 운영 (왼쪽 끝). 줄이 길면 오른쪽 자동발권기 이용.', '07:00-18:00', '¥236 (4일권)', 10, 'live'),
('forest_south_info', 'forest', 'south', 'info', 'ℹ️ 관광안내소', '旅游咨询服务中心', 29.3388, 110.5362, 'https://uri.amap.com/search?keyword=张家界国家森林公园游客中心&city=张家界', '[]'::jsonb, '지도·셔틀 시간표·분실물 신고 등 모든 관광 정보 제공. 영어 가능 직원 상주.', '무료 종이 지도를 여기서 받으세요. 핸드폰 배터리 충전소도 있음.', '07:30-18:00', NULL, 20, 'live'),
('forest_south_shuttle_stop', 'forest', 'south', 'transport', '🚌 남문 셔틀버스 정류장', '南门景区换乘巴士站', 29.339, 110.5355, 'https://uri.amap.com/search?keyword=张家界南门换乘站&city=张家界', '[]'::jsonb, '삼림공원 내 무료 셔틀버스 탑승장. 원가계·천자산·양가계 환승센터 방향 운행.', '셔틀은 입장권 포함. 10~20분 간격 운행. 마지막 셔틀 18:30.', '08:00-18:30', '입장권 포함', 30, 'live'),
('forest_south_monorail_start', 'forest', 'south', 'transport', '🚞 십리화랑 모노레일 탑승장', '十里画廊单轨列车起点站', 29.321, 110.524, 'https://uri.amap.com/search?keyword=十里画廊单轨列车&city=张家界', '[]'::jsonb, '계곡 따라 달리는 모노레일 시작점. 편도 또는 왕복 선택 가능.', '왕복 구매 후 중간 내려서 걷다 종점에서 탑승해도 됨. 타고 들어가 걸어 나오는 것이 최선.', '08:00-17:30', '¥76 왕복 / ¥50 편도 (별도 구매)', 40, 'live'),
('forest_south_monorail_end', 'forest', 'south', 'transport', '🚞 십리화랑 모노레일 종점', '十里画廊单轨列车终点站', 29.318, 110.52, 'https://uri.amap.com/search?keyword=十里画廊终点&city=张家界', '[]'::jsonb, '모노레일 종점. 여기서 걸어서 백룡엘리베이터 방향으로 이동 가능.', NULL, '08:00-17:30', NULL, 50, 'live'),
('forest_south_viewpoint1', 'forest', 'south', 'viewpoint', '🏔️ 십리화랑 메인 전망대', '十里画廊主要观景台', 29.3195, 110.5215, 'https://uri.amap.com/search?keyword=十里画廊观景台&city=张家界', '[]'::jsonb, '양쪽으로 솟은 사암 기둥들이 파노라마로 펼쳐지는 최고의 사진 스팟.', '오전 9시 안개가 걷힌 후 방문하면 맑은 뷰 가능.', NULL, NULL, 60, 'live'),
('forest_south_toilet1', 'forest', 'south', 'toilet', '🚻 남문 구역 화장실 (입구)', '南门区域公共厕所', 29.3386, 110.535, NULL, '[]'::jsonb, '남문 입구 우측에 위치. 무료. 화장지 없음 — 미리 준비하세요.', '공원 내 화장실은 전부 화장지 없음. 미니 화장지 챙기기!', '07:00-19:00', '무료', 70, 'live'),
('forest_south_food1', 'forest', 'south', 'food', '🍜 남문 구역 식당가', '南门景区餐饮区', 29.3392, 110.5368, 'https://uri.amap.com/search?keyword=张家界森林公园餐饮&city=张家界', '[]'::jsonb, '남문 입구 주변 식당. 면류·볶음밥·현지 간식 등.', '공원 내부보다 입구 밖 식당이 훨씬 저렴함. 점심 전 나와서 먹는 것 추천.', '08:00-19:00', '¥20~60/인', 80, 'live'),
('forest_yuanjia_balong_base', 'forest', 'yuanjia', 'transport', '🛗 백룡엘리베이터 하단 탑승장', '百龙天梯下乘梯处', 29.318, 110.505, 'https://uri.amap.com/search?keyword=百龙天梯下乘梯处&city=张家界', '[]'::jsonb, '세계 최고 야외 엘리베이터 하단 탑승장. 이 지점에서 줄을 서고 엘리베이터에 탑승.', '성수기 대기 30~60분. 07:30 개장 시 바로 탑승하면 줄 없음.', '07:30-18:00', '입장권 포함', 90, 'live'),
('forest_yuanjia_balong_top', 'forest', 'yuanjia', 'transport', '🛗 백룡엘리베이터 상단 도착장', '百龙天梯上乘梯处', 29.328, 110.503, 'https://uri.amap.com/search?keyword=百龙天梯上乘梯处&city=张家界', '[]'::jsonb, '엘리베이터 상단. 여기서 원가계 방향 산책로로 바로 연결됨.', NULL, '07:30-18:00', NULL, 100, 'live'),
('forest_yuanjia_avatar', 'forest', 'yuanjia', 'viewpoint', '🏔️ 원가계 전망대 (아바타 산)', '袁家界观景台(哈利路亚山)', 29.331, 110.502, 'https://uri.amap.com/search?keyword=袁家界哈利路亚山&city=张家界', '[]'::jsonb, '영화 아바타의 배경이 된 할렐루야 산(석영 모래암 기둥군). 새벽 운무와 함께 가장 아름다움.', '오전 8~10시 사이 안개가 낀 날 가장 몽환적. 맑은 날은 오후가 선명.', NULL, NULL, 110, 'live'),
('forest_yuanjia_mihuntai', 'forest', 'yuanjia', 'viewpoint', '🌉 미혼대 (절벽 전망대)', '迷魂台', 29.332, 110.5, 'https://uri.amap.com/search?keyword=迷魂台&city=张家界', '[]'::jsonb, '절벽 끝 전망대. ''혼을 잃는다''는 뜻처럼 경치가 압도적. 360도 기암괴석 조망.', '사람이 적은 이른 아침이 최고. 절벽 끝은 안전난간이 있지만 어지러움 주의.', NULL, NULL, 120, 'live'),
('forest_yuanjia_bridge', 'forest', 'yuanjia', 'landmark', '🌉 천하제일교', '天下第一桥', 29.329, 110.499, 'https://uri.amap.com/search?keyword=天下第一桥张家界&city=张家界', '[]'::jsonb, '두 산봉우리 사이를 잇는 자연 돌다리. 높이 350m, 너비 2m의 아찔한 구조.', '다리 위에서 아래를 내려다보면 아찔. 겁 많은 분도 도전해볼 만함.', NULL, NULL, 130, 'live'),
('forest_yuanjia_shuttle', 'forest', 'yuanjia', 'transport', '🚌 원가계 셔틀버스 승차장', '袁家界景区巴士站', 29.334, 110.501, NULL, '[]'::jsonb, '원가계에서 양가계 환승센터로 가는 셔틀버스 탑승 지점.', '이 버스 마지막 18:30. 절대 놓치지 마세요.', '08:00-18:30', '입장권 포함', 140, 'live'),
('forest_yuanjia_toilet', 'forest', 'yuanjia', 'toilet', '🚻 원가계 구역 화장실', '袁家界公共厕所', 29.3315, 110.5025, NULL, '[]'::jsonb, '원가계 전망대 인근 화장실. 무료. 화장지 없음.', '다음 화장실까지 거리가 멀 수 있음. 지나칠 때 미리 이용.', NULL, '무료', 150, 'live'),
('forest_tianzi_cable_base', 'forest', 'tianzi', 'transport', '🚡 천자산 케이블카 하단 탑승장', '天子山索道下站', 29.35, 110.462, 'https://uri.amap.com/search?keyword=天子山索道下站&city=张家界', '[]'::jsonb, '천자산 정상까지 올라가는 케이블카 하단 탑승장. 양가계 환승 후 여기서 탑승.', '마지막 케이블카 18:00. 17:30에는 이미 이 지점에 있어야 함.', '08:00-18:00', '입장권 포함', 160, 'live'),
('forest_tianzi_cable_top', 'forest', 'tianzi', 'transport', '🚡 천자산 케이블카 상단 도착장', '天子山索道上站', 29.361, 110.468, 'https://uri.amap.com/search?keyword=天子山索道上站&city=张家界', '[]'::jsonb, '케이블카 상단. 여기서 천자산 정상 산책로로 바로 연결.', NULL, NULL, NULL, 170, 'live'),
('forest_tianzi_yubifeng', 'forest', 'tianzi', 'viewpoint', '🌅 어필봉 전망대', '御笔峰观景台', 29.362, 110.47, 'https://uri.amap.com/search?keyword=御笔峰&city=张家界', '[]'::jsonb, '황제의 붓처럼 솟아오른 봉우리들. 일몰 전 황금빛으로 물드는 장면이 압권.', '15:30~17:00 사이 빛이 가장 드라마틱. 이 시간대에 맞춰 방문.', NULL, NULL, 180, 'live'),
('forest_tianzi_main_viewpoint', 'forest', 'tianzi', 'viewpoint', '🏔️ 천자산 메인 전망대', '天子山主要观景台', 29.363, 110.472, 'https://uri.amap.com/search?keyword=天子山观景台&city=张家界', '[]'::jsonb, '천자산 정상 파노라마. 어필생화·하룡공원 등 핵심 뷰포인트 모두 이곳에서 조망.', '정상 기온 계곡보다 6°C 낮음. 얇은 겉옷 꼭 챙기세요.', NULL, NULL, 190, 'live'),
('forest_tianzi_toilet', 'forest', 'tianzi', 'toilet', '🚻 천자산 구역 화장실', '天子山公共厕所', 29.3615, 110.469, NULL, '[]'::jsonb, '케이블카 상단 인근 화장실.', '화장지 없음. 산 정상이라 추울 수 있음.', NULL, '무료', 200, 'live'),
('forest_tianzi_food', 'forest', 'tianzi', 'food', '☕ 천자산 정상 카페·편의점', '天子山山顶便利店', 29.3618, 110.4685, NULL, '[]'::jsonb, '정상 인근 간이 매점. 음료·컵라면·간식 판매.', '아래보다 가격이 비쌈 (¥2~5 추가). 물은 꼭 아래서 사 올라오기.', '08:00-17:30', '¥5~30', 210, 'live'),
('forest_yang_transfer', 'forest', 'yangjiajie', 'transport', '🔄 양가계 환승센터', '杨家界核心换乘中心', 29.342, 110.485, 'https://uri.amap.com/search?keyword=杨家界换乘中心&city=张家界', '[]'::jsonb, '삼림공원 내 4개 구역을 연결하는 핵심 환승 허브. 여기서 모든 셔틀이 출발·도착.', '막차 18:30. 이 시간 놓치면 이후 교통수단 없음. 시간 여유 두기.', '08:00-18:30', '무료', 220, 'live'),
('forest_yang_nature', 'forest', 'yangjiajie', 'viewpoint', '🏯 양가계 자연경관구', '杨家界自然风景区', 29.344, 110.482, 'https://uri.amap.com/search?keyword=杨家界风景区&city=张家界', '[]'::jsonb, '관광객이 적어 한적하게 즐길 수 있는 숨은 명소. 도보 전용 코스.', '성수기에도 사람 적음. 조용한 사진 원하는 분께 강추.', NULL, '입장권 포함', 230, 'live'),
('tianmen_cable_base', 'tianmen', 'base', 'transport', '🚡 천문산 케이블카 하단 탑승장', '天门山索道下站(市区)', 29.118, 110.474, 'https://uri.amap.com/search?keyword=天门山索道下站&city=张家界', '[]'::jsonb, '세계 최장 산악 케이블카(7.5km) 시내 하단 탑승장. 30분간 시내 상공을 날아감.', '가는 편 왼쪽 좌석에 앉으면 천문동이 정면으로 보임.', '08:30-17:30', '¥268 왕복+입장', 10, 'live'),
('tianmen_ticket_office', 'tianmen', 'base', 'ticket', '🎫 천문산 매표소', '天门山售票处', 29.1178, 110.4742, 'https://uri.amap.com/search?keyword=天门山景区售票处&city=张家界', '[]'::jsonb, '케이블카 탑승 전 입장권 구매. 여권 필지.', 'Trip.com(트립닷컴)이나 마이리얼트립 사전 예약 시 줄 없이 바로 입장 가능.', '08:00-17:00', '¥268 (케이블카+입장)', 20, 'live'),
('tianmen_market', 'tianmen', 'base', 'food', '🛍️ 영정구 전통시장', '永定区传统市场', 29.12, 110.476, 'https://uri.amap.com/search?keyword=永定区市场&city=张家界', '[]'::jsonb, '장가계 시내 전통시장. 현지 간식·과일·잡화 구경.', '케이블카 탑승 전 30분 산책 추천. 현지 물가 저렴.', '07:00-20:00', NULL, 30, 'live'),
('tianmen_cafe', 'tianmen', 'base', 'rest', '☕ 로컬 카페 (케이블카 인근)', '天门山索道附近咖啡厅', 29.1185, 110.475, 'https://uri.amap.com/search?keyword=天门山附近咖啡&city=张家界', '[]'::jsonb, '케이블카 대기 전 커피 타임. 로투차 1일 투어 포함 항목.', '현지 산차(山茶)도 추천. 향이 독특하고 가격 저렴.', '08:00-18:00', '¥15~35', 40, 'live'),
('tianmen_cable_top', 'tianmen', 'summit', 'transport', '🚡 천문산 케이블카 상단 도착장', '天门山索道上站', 29.135, 110.505, 'https://uri.amap.com/search?keyword=天门山索道上站&city=张家界', '[]'::jsonb, '케이블카 상단. 여기서 유리잔도·에스컬레이터·정상 산책로로 연결.', '상단은 하단보다 6°C 낮음. 겉옷 필수.', '08:30-17:30', NULL, 50, 'live'),
('tianmen_glass_walkway', 'tianmen', 'summit', 'viewpoint', '🌉 유리잔도 (귀곡잔도)', '鬼谷栈道·玻璃栈道', 29.134, 110.504, 'https://uri.amap.com/search?keyword=天门山玻璃栈道&city=张家界', '[]'::jsonb, '절벽에 붙은 투명 유리바닥 산책로. 발아래 60m 절벽이 훤히 보임.', '신발 커버 무료 제공·필수 착용. 강풍 시 폐쇄. 비 오면 더 위험.', '08:30-17:30', '입장권 포함', 60, 'live'),
('tianmen_cave', 'tianmen', 'summit', 'landmark', '🏯 천문동 (천국의 문)', '天门洞(天国之门)', 29.131, 110.502, 'https://uri.amap.com/search?keyword=天门洞&city=张家界', '[]'::jsonb, '자연이 만든 131m 높이의 아치형 동굴. 에스컬레이터로 입구 도달 후 안을 걸어 통과.', '에스컬레이터 이동 약 15분. 동굴 앞 전망 사진 필수 촬영 포인트.', '08:30-17:00', '입장권 포함', 70, 'live'),
('tianmen_escalator', 'tianmen', 'summit', 'transport', '⬆️ 천문동 에스컬레이터', '天门洞自动扶梯', 29.1315, 110.5025, NULL, '[]'::jsonb, '정상에서 천문동 입구까지 이어지는 야외 에스컬레이터. 약 15분 소요.', NULL, '08:30-17:00', '입장권 포함', 80, 'live'),
('tianmen_summit_viewpoint', 'tianmen', 'summit', 'viewpoint', '🏔️ 정상 전망대', '天门山顶部观景台', 29.136, 110.506, 'https://uri.amap.com/search?keyword=天门山顶部观景台&city=张家界', '[]'::jsonb, '360도 파노라마. 맑은 날 100km 이상 조망 가능. 15:30~16:30이 황금 빛.', NULL, NULL, NULL, 90, 'live'),
('tianmen_toilet_summit', 'tianmen', 'summit', 'toilet', '🚻 정상 화장실', '山顶公共厕所', 29.1345, 110.5045, NULL, '[]'::jsonb, '케이블카 상단 인근 화장실. 무료.', '화장지 없음.', NULL, '무료', 100, 'live'),
('canyon_hld_entrance', 'canyon', 'huanglongdong', 'ticket', '🦎 황룡동 입구·매표소', '黄龙洞景区入口', 29.364, 110.27, 'https://uri.amap.com/search?keyword=黄龙洞&city=张家界', '[]'::jsonb, '지하 동굴 관광 입구. 별도 입장권 구매 필요.', '내부 15°C. 얇은 겉옷 필수. 비가 와도 관광 가능.', '08:00-17:30', '¥121 (별도)', 10, 'live'),
('canyon_hld_boat', 'canyon', 'huanglongdong', 'transport', '⛵ 황룡동 지하 유람선 탑승장', '黄龙洞地下河游船', 29.3635, 110.2705, NULL, '[]'::jsonb, '동굴 내부 지하 하천을 유람선으로 이동. 종유석 아래 배를 타는 신비로운 체험.', '구명조끼 착용 필수. 짐은 미리 보관.', '08:00-17:00', '입장권 포함', 20, 'live'),
('canyon_hld_viewpoint', 'canyon', 'huanglongdong', 'viewpoint', '🌊 황룡동 종유석 전망 포인트', '黄龙洞钟乳石观赏区', 29.3638, 110.2702, NULL, '[]'::jsonb, '수억 년 세월이 만든 종유석·석순의 군락. 조명이 더해져 환상적인 분위기.', '플래시 사진보다 야간 모드가 더 예쁘게 찍힘.', NULL, NULL, 30, 'live'),
('canyon_bridge_entrance', 'canyon', 'bridge', 'ticket', '🌉 대협곡 입구·셔틀 탑승장', '张家界大峡谷景区入口', 29.348, 110.295, 'https://uri.amap.com/search?keyword=张家界大峡谷景区&city=张家界', '[]'::jsonb, '대협곡 입구. 여기서 내부 무료 셔틀로 유리다리 방향 이동.', '여권 필수. 짐은 최소화 (협곡 내 도보 구간 많음).', '08:00-17:00', '¥216 (입장+유리다리)', 40, 'live'),
('canyon_glass_bridge', 'canyon', 'bridge', 'landmark', '🪟 유리다리 (세계 최장·430m)', '张家界大峡谷玻璃桥(430m)', 29.346, 110.297, 'https://uri.amap.com/search?keyword=张家界大峡谷玻璃桥&city=张家界', '[]'::jsonb, '세계에서 가장 길고 높은 유리바닥 다리. 430m, 높이 300m. 협곡 위를 걷는 경험.', '신발 커버 무료 제공·필수. 비 오면 즉시 폐쇄. 1일 8,000명 제한.', '08:30-17:00', '입장권 포함', 50, 'live'),
('canyon_slide', 'canyon', 'bridge', 'landmark', '🎢 협곡 대형 미끄럼틀 (1,080m)', '大峡谷高速滑道(1080m)', 29.345, 110.298, NULL, '[]'::jsonb, '협곡 아래까지 1,080m 슬라이드. 최대 속도 40km/h. 스릴 만점.', '발을 들면 더 빠름. 뒷주머니 물건 꼭 꺼내기. 완전 추천!', '09:00-16:30', '¥40 (별도 옵션)', 60, 'live'),
('canyon_boat', 'canyon', 'bridge', 'transport', '⛵ 협곡 유람선 탑승장', '大峡谷游船乘船处', 29.343, 110.299, NULL, '[]'::jsonb, '협곡 바닥 강물 위 유람선. 수직 절벽이 양쪽으로 솟아오르는 장관.', '구명조끼 착용 필수. 30분 소요.', '09:00-16:30', '¥30 (별도 옵션)', 70, 'live'),
('canyon_toilet', 'canyon', 'bridge', 'toilet', '🚻 대협곡 화장실', '大峡谷公共厕所', 29.3475, 110.2955, NULL, '[]'::jsonb, '대협곡 입구 인근 화장실. 내부에는 화장실 드묾 — 들어가기 전 이용 권장.', '화장지 없음. 물티슈 지참 권장.', NULL, '무료', 80, 'live'),
('canyon_food', 'canyon', 'bridge', 'food', '🍜 대협곡 입구 식당', '大峡谷景区外餐饮', 29.3488, 110.2945, NULL, '[]'::jsonb, '입구 밖 식당가. 현지 호남요리. 내부 매점보다 훨씬 저렴하고 맛있음.', '내부 매점은 드물고 비쌈. 입장 전 식사 강력 권장.', '08:00-19:00', '¥20~60/인', 90, 'live')
ON CONFLICT (id) DO UPDATE SET
  attr_id = EXCLUDED.attr_id, zone_id = EXCLUDED.zone_id, type = EXCLUDED.type,
  name_ko = EXCLUDED.name_ko, name_cn = EXCLUDED.name_cn, lat = EXCLUDED.lat, lon = EXCLUDED.lon,
  gaode_uri = EXCLUDED.gaode_uri, desc_ko = EXCLUDED.desc_ko, tip_ko = EXCLUDED.tip_ko,
  hours = EXCLUDED.hours, price = EXCLUDED.price, sort_order = EXCLUDED.sort_order,
  updated_at = now();

-- 실행 후: lotocha_guide.html은 이 데이터가 있으면 자동으로 Supabase를 사용하고,
-- lotocha_spots.json(정적 파일) 폴백은 더 이상 쓰이지 않습니다.
-- 관리자 페이지 "가이드 스팟"에서 바로 편집 가능합니다.
