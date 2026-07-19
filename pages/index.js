import { useState, useEffect, useRef } from "react";

const C = {
  bg:"#F5F5F7", white:"#FFFFFF", primary:"#1A6B5A", primaryLight:"#E3F4EF",
  accent:"#FF6B35", text:"#1C1C1E", muted:"#8E8E93", border:"#E5E5EA",
};
const DAY_COLORS = ["#4A90D9","#E8622A","#7B5EA7","#2AAE6E","#D4A017"];

const POIS = {
  "천문산": { lat:29.1043, lng:110.4782, zh:"天门山",
    photos:["https://images.unsplash.com/photo-1537531383496-f4655f6f34d2?w=600"],
    desc:"해발 1518m. 세계 최장 케이블카(7.5km), 천문동굴, 유리잔도.", price:"258위안"},
  "국가삼림공원": { lat:29.3497, lng:110.5498, zh:"国家森林公园",
    photos:["https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600"],
    desc:"아바타 촬영지. 원가계·황석채·금편계곡 포함 세계자연유산.", price:"248위안"},
  "원가계": { lat:29.3703, lng:110.5234, zh:"袁家界",
    photos:["https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600"],
    desc:"아바타 할렐루야산 원형. 미혼대·천하제일교 전망대.", price:"삼림공원 포함"},
  "황룡동굴": { lat:29.3234, lng:110.5876, zh:"黄龙洞",
    photos:["https://images.unsplash.com/photo-1518002054494-3a6f94352e9d?w=600"],
    desc:"전장 7.5km 거대 석회암 동굴. 관람 약 2시간.", price:"100위안"},
  "대협곡유리다리": { lat:29.2456, lng:110.3891, zh:"大峡谷玻璃桥",
    photos:["https://images.unsplash.com/photo-1537531383496-f4655f6f34d2?w=600"],
    desc:"세계 최장 유리다리(430m, 높이 300m).", price:"100위안"},
  "바오펑호수": { lat:29.3156, lng:110.5567, zh:"宝峰湖",
    photos:["https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600"],
    desc:"에메랄드빛 산속 호수. 보트 투어 45분.", price:"82위안"},
  "천자산": { lat:29.3891, lng:110.5123, zh:"天子山",
    photos:["https://images.unsplash.com/photo-1537531383496-f4655f6f34d2?w=600"],
    desc:"해발 1250m 고원 전망대. 운해와 설경으로 유명.", price:"삼림공원 포함"},
  "토가족식당": { lat:29.3312, lng:110.5234, zh:"土家族餐厅",
    photos:["https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600"],
    desc:"현지 토가족 전통 요리. 훈제고기·고추볶음·산채 정식.", price:"60-80위안"},
};

const INSTRUCTIONS = `You are a Zhangjiajie travel expert for Korean tourists. Korean language. Return ONLY valid JSON, no other text.

Generate compact itinerary:
{"type":"itinerary","title":"제목","dest":"장가계","totalDays":3,"days":[{"day":1,"theme":"테마","items":[{"time":"09:00","name":"천문산","note":"메모"}]}],"tips":["팁"]}

Available places (use exact names): 천문산, 국가삼림공원, 원가계, 황룡동굴, 대협곡유리다리, 바오펑호수, 천자산, 토가족식당

Rules: max 3 items/day, max 1 tip, very short text, exact place names only.
Modifications: return full updated itinerary.
Other: {"type":"message","text":"답변"}`;

function distKm(a, b) {
  const R=6371, dLat=(b.lat-a.lat)*Math.PI/180, dLng=(b.lng-a.lng)*Math.PI/180;
  const x=Math.sin(dLat/2)**2+Math.cos(a.lat*Math.PI/180)*Math.cos(b.lat*Math.PI/180)*Math.sin(dLng/2)**2;
  return (R*2*Math.atan2(Math.sqrt(x),Math.sqrt(1-x))).toFixed(1);
}

function getSteps(input) {
  const s = ["🔍 장가계 정보 분석 중"];
  if (/수정|바꿔|변경/.test(input)) { s.push("✏️ 수정 사항 반영 중"); }
  else { s.push("🗺️ 최적 동선 계산 중"); s.push("📅 일정 배치 중"); }
  s.push("✅ 완성");
  return s;
}

function MapView({ days, activeDay, onMarkerClick }) {
  const mapRef = useRef(null);
  const mapInstance = useRef(null);
  const markersRef = useRef([]);
  const linesRef = useRef([]);

  useEffect(() => {
    if (mapInstance.current || !mapRef.current) return;
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css";
    document.head.appendChild(link);
    const script = document.createElement("script");
    script.src = "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.js";
    document.body.appendChild(script);
    script.onload = () => {
      const L = window.L;
      const map = L.map(mapRef.current, { zoomControl:false, attributionControl:false })
        .setView([29.25, 110.52], 10);
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png").addTo(map);
      L.control.zoom({ position:"bottomright" }).addTo(map);
      mapInstance.current = map;
      if (days?.length) renderMarkers(days, activeDay);
    };
  }, []);

  useEffect(() => {
    if (!mapInstance.current || !window.L) return;
    renderMarkers(days, activeDay);
  }, [days, activeDay]);

  function renderMarkers(days, activeDay) {
    const L = window.L;
    const map = mapInstance.current;
    markersRef.current.forEach(m => m.remove());
    linesRef.current.forEach(l => l.remove());
    markersRef.current = []; linesRef.current = [];
    const bounds = [];
    (days||[]).forEach((day, di) => {
      if (activeDay !== null && activeDay !== di) return;
      const color = DAY_COLORS[di % DAY_COLORS.length];
      const pts = [];
      (day.items||[]).forEach((item, idx) => {
        const poi = POIS[item.name];
        if (!poi) return;
        bounds.push([poi.lat, poi.lng]);
        pts.push([poi.lat, poi.lng]);
        const icon = L.divIcon({
          html:`<div style="background:${color};color:#fff;border-radius:50%;width:30px;height:30px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:14px;border:2px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,0.3)">${idx+1}</div>`,
          iconSize:[30,30], iconAnchor:[15,15], className:""
        });
        const m = L.marker([poi.lat, poi.lng], {icon}).addTo(map)
          .on("click", () => onMarkerClick && onMarkerClick(item.name, di));
        markersRef.current.push(m);
      });
      if (pts.length > 1) {
        const l = L.polyline(pts, {color, weight:3, opacity:0.8}).addTo(map);
        linesRef.current.push(l);
      }
    });
    if (bounds.length) map.fitBounds(bounds, {padding:[30,30]});
  }

  return <div ref={mapRef} style={{width:"100%", height:"100%"}}/>;
}

function PoiDetail({ name, dayIndex, onClose }) {
  const poi = POIS[name];
  if (!poi) return null;
  const color = DAY_COLORS[dayIndex % DAY_COLORS.length];
  return (
    <div style={{position:"absolute", bottom:0, left:0, right:0, zIndex:1000,
      background:C.white, borderRadius:"20px 20px 0 0",
      boxShadow:"0 -4px 30px rgba(0,0,0,0.2)", maxHeight:"70%", overflowY:"auto"}}>
      <div style={{position:"relative", height:180}}>
        <img src={poi.photos[0]} alt={name}
          style={{width:"100%", height:"100%", objectFit:"cover"}}/>
        <button onClick={onClose} style={{position:"absolute", top:12, right:12,
          background:"rgba(0,0,0,0.5)", border:"none", borderRadius:15,
          color:"#fff", width:30, height:30, cursor:"pointer", fontSize:16}}>×</button>
      </div>
      <div style={{padding:"16px 18px 32px"}}>
        <div style={{display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:8}}>
          <div>
            <div style={{fontSize:18, fontWeight:800}}>{name}</div>
            <div style={{fontSize:12, color:C.muted}}>{poi.zh}</div>
          </div>
          <span style={{background:color, color:"#fff", fontSize:11, fontWeight:700,
            borderRadius:12, padding:"3px 10px"}}>DAY {dayIndex+1}</span>
        </div>
        {poi.price && (
          <div style={{background:C.primaryLight, borderRadius:8, padding:"6px 12px",
            fontSize:13, color:C.primary, fontWeight:600, marginBottom:12, display:"inline-block"}}>
            💰 {poi.price}
          </div>
        )}
        <p style={{fontSize:14, lineHeight:1.6, margin:"0 0 16px"}}>{poi.desc}</p>
        <div style={{display:"flex", gap:8}}>
          <button style={{flex:1, padding:10, borderRadius:10, background:C.primary,
            color:"#fff", border:"none", fontSize:13, fontWeight:700, cursor:"pointer"}}>
            🗺️ 지도에서 보기
          </button>
          <button style={{flex:1, padding:10, borderRadius:10, background:"#FFF0EB",
            color:C.accent, border:`1px solid ${C.accent}`, fontSize:13, fontWeight:700, cursor:"pointer"}}>
            🏢 로투차 예약
          </button>
        </div>
      </div>
    </div>
  );
}

export default function Home() {
  const [view, setView] = useState("chat");
  const [messages, setMessages] = useState([{
    id:0, role:"ai",
    content:"안녕하세요! 장가계 여행 플래너 뤼지입니다 😊\n어디로, 몇 박 며칠 여행하고 싶으신가요?"
  }]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [thinkState, setThinkState] = useState(null);
  const [history, setHistory] = useState([]);
  const [itinerary, setItinerary] = useState(null);
  const [activeDay, setActiveDay] = useState(null);
  const [selectedPoi, setSelectedPoi] = useState(null);
  const timerRef = useRef(null);
  const bottomRef = useRef(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({behavior:"smooth"}); }, [messages, thinkState]);
  useEffect(() => () => clearInterval(timerRef.current), []);

  const callAI = async (userText) => {
    const newHistory = [...history, {
      role:"user",
      content: INSTRUCTIONS + (itinerary ? "\n\n현재일정:" + JSON.stringify(itinerary) : "") + "\n\n요청:" + userText
    }];
    const res = await fetch("/api/chat", {
      method:"POST",
      headers:{"Content-Type":"application/json"},
      body: JSON.stringify({ messages: newHistory })
    });
    const data = await res.json();
    if (data.error) throw new Error(JSON.stringify(data.error));
    const raw = data.content?.find(b=>b.type==="text")?.text || "";
    const match = raw.match(/\{[\s\S]*\}/);
    if (!match) throw new Error("JSON 없음: " + raw.slice(0,100));
    const result = JSON.parse(match[0]);
    setHistory([...newHistory, {role:"assistant", content:JSON.stringify(result)}]);
    return result;
  };

  const sendMessage = async (text) => {
    const userText = (text || input).trim();
    if (!userText || isLoading) return;
    setInput("");
    setMessages(prev => [...prev, {id:Date.now(), role:"user", content:userText}]);
    setIsLoading(true);
    const steps = getSteps(userText);
    let step = 0;
    setThinkState({steps, current:0});
    timerRef.current = setInterval(() => {
      step = Math.min(step+1, steps.length-2);
      setThinkState(prev => prev ? {...prev, current:step} : null);
    }, 700);
    try {
      const result = await callAI(userText);
      clearInterval(timerRef.current);
      setThinkState(prev => prev ? {...prev, current:steps.length-1} : null);
      await new Promise(r => setTimeout(r, 350));
      setThinkState(null);
      if (result.type === "itinerary") {
        setItinerary(result);
        setActiveDay(null);
        setView("map");
        setMessages(prev => [...prev, {id:Date.now(), role:"ai",
          content:`✅ ${result.title} 완성! 지도에서 확인해보세요.`}]);
      } else {
        setMessages(prev => [...prev, {id:Date.now(), role:"ai", content:result.text||"네!"}]);
      }
    } catch(e) {
      clearInterval(timerRef.current);
      setThinkState(null);
      setMessages(prev => [...prev, {id:Date.now(), role:"ai", content:"오류: "+e.message}]);
    } finally {
      setIsLoading(false);
    }
  };

  const CHIPS_INIT = ["장가계 3박4일 자연 위주","장가계 2박3일 핵심만","천문산+삼림공원 2일"];
  const CHIPS_MOD = ["첫날 바꿔줘","맛집 추가","더 여유롭게","하루 더 추가"];

  return (
    <div style={{height:"100vh", display:"flex", flexDirection:"column", background:C.bg,
      fontFamily:"'Noto Sans KR','Noto Sans',-apple-system,sans-serif",
      maxWidth:430, margin:"0 auto", overflow:"hidden"}}>

      {/* Header */}
      <div style={{background:C.white, borderBottom:`1px solid ${C.border}`,
        padding:"12px 16px", display:"flex", alignItems:"center",
        justifyContent:"space-between", flexShrink:0}}>
        <div style={{display:"flex", alignItems:"center", gap:8}}>
          <div style={{width:32, height:32, background:C.primary, borderRadius:9,
            display:"flex", alignItems:"center", justifyContent:"center", fontSize:17}}>🏔️</div>
          <div>
            <div style={{fontSize:15, fontWeight:900, color:C.primary, lineHeight:1}}>뤼지 AI</div>
            <div style={{fontSize:9, color:C.muted}}>장가계 여행 플래너</div>
          </div>
        </div>
        <div style={{display:"flex", background:C.bg, borderRadius:18, padding:3, gap:2}}>
          {[["chat","💬 채팅"],["map","🗺️ 지도"]].map(([v,l]) => (
            <button key={v} onClick={() => setView(v)}
              style={{padding:"5px 12px", borderRadius:15, fontSize:12, fontWeight:600,
                border:"none", cursor:"pointer",
                background:view===v?C.primary:"transparent",
                color:view===v?"#fff":C.muted}}>
              {l}
            </button>
          ))}
        </div>
      </div>

      {/* Chat view */}
      {view === "chat" && (
        <div style={{flex:1, display:"flex", flexDirection:"column", overflow:"hidden"}}>
          <div style={{flex:1, overflowY:"auto", padding:"12px 14px"}}>
            {messages.map(msg => (
              <div key={msg.id} style={{marginBottom:12, display:"flex",
                flexDirection:msg.role==="user"?"row-reverse":"row",
                alignItems:"flex-end", gap:6}}>
                {msg.role==="ai" && (
                  <div style={{width:28, height:28, borderRadius:14, background:C.primaryLight,
                    display:"flex", alignItems:"center", justifyContent:"center",
                    fontSize:14, flexShrink:0}}>🤖</div>
                )}
                <div style={{maxWidth:"82%",
                  background:msg.role==="user"?C.primary:C.white,
                  color:msg.role==="user"?"#fff":C.text,
                  borderRadius:msg.role==="user"?"14px 14px 4px 14px":"4px 14px 14px 14px",
                  padding:"10px 13px", fontSize:13, lineHeight:1.55,
                  boxShadow:"0 1px 4px rgba(0,0,0,0.08)",
                  whiteSpace:"pre-wrap"}}>
                  {msg.content}
                </div>
              </div>
            ))}
            {thinkState && (
              <div style={{display:"flex", alignItems:"flex-start", gap:6, marginBottom:12}}>
                <div style={{width:28, height:28, borderRadius:14, background:C.primaryLight,
                  display:"flex", alignItems:"center", justifyContent:"center", fontSize:14}}>🤖</div>
                <div style={{background:C.white, borderRadius:"4px 14px 14px 14px",
                  padding:"12px 14px", boxShadow:"0 1px 4px rgba(0,0,0,0.08)", minWidth:180}}>
                  {thinkState.steps.map((s,i) => {
                    if (i > thinkState.current) return null;
                    const done=i<thinkState.current, active=i===thinkState.current;
                    return (
                      <div key={i} style={{display:"flex", gap:6, alignItems:"center",
                        marginBottom:i<thinkState.steps.length-1?7:0,
                        fontSize:12, fontWeight:active?700:400,
                        color:done?"#aaa":active?C.primary:C.text, opacity:done?0.6:1}}>
                        <span style={{width:14, flexShrink:0, fontSize:11}}>
                          {done?"✓":active?"⟳":"○"}
                        </span>
                        <span>{s}</span>
                        {active && <span style={{animation:"blink 1s infinite"}}>...</span>}
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
            <div ref={bottomRef}/>
            <style>{`@keyframes blink{0%,100%{opacity:1}50%{opacity:0.2}} ::-webkit-scrollbar{width:3px} ::-webkit-scrollbar-thumb{background:#ddd;border-radius:2px}`}</style>
          </div>

          {messages.length<=1 && !isLoading && (
            <div style={{padding:"0 14px 6px", display:"flex", gap:6, overflowX:"auto", scrollbarWidth:"none"}}>
              {CHIPS_INIT.map((s,i) => (
                <button key={i} onClick={() => sendMessage(s)}
                  style={{padding:"7px 12px", borderRadius:16, fontSize:12, fontWeight:600,
                    background:C.white, border:`1px solid ${C.border}`, color:C.primary,
                    cursor:"pointer", whiteSpace:"nowrap", flexShrink:0}}>
                  {s}
                </button>
              ))}
            </div>
          )}
          {itinerary && !isLoading && !thinkState && (
            <div style={{padding:"0 14px 6px", display:"flex", gap:6, overflowX:"auto", scrollbarWidth:"none"}}>
              {CHIPS_MOD.map((s,i) => (
                <button key={i} onClick={() => sendMessage(s)}
                  style={{padding:"6px 12px", borderRadius:16, fontSize:11, fontWeight:600,
                    background:C.primaryLight, border:`1px solid ${C.primary}30`,
                    color:C.primary, cursor:"pointer", whiteSpace:"nowrap", flexShrink:0}}>
                  {s}
                </button>
              ))}
            </div>
          )}

          <div style={{background:C.white, borderTop:`1px solid ${C.border}`,
            padding:"8px 12px 20px", display:"flex", gap:8, alignItems:"flex-end", flexShrink:0}}>
            <textarea value={input} onChange={e=>setInput(e.target.value)}
              onKeyDown={e=>{if(e.key==="Enter"&&!e.shiftKey){e.preventDefault();sendMessage();}}}
              placeholder={itinerary?"수정 사항 입력...":"어디로, 몇 박 며칠?"}
              disabled={isLoading} rows={1}
              style={{flex:1, padding:"9px 12px", borderRadius:18, fontSize:13,
                border:`1.5px solid ${C.border}`, resize:"none", fontFamily:"inherit",
                lineHeight:1.4, maxHeight:80, outline:"none",
                background:isLoading?C.bg:C.white}}/>
            <button onClick={() => sendMessage()}
              disabled={!input.trim()||isLoading}
              style={{width:36, height:36, borderRadius:18, border:"none",
                background:input.trim()&&!isLoading?C.primary:C.border,
                color:"#fff", fontSize:16, cursor:input.trim()&&!isLoading?"pointer":"default",
                flexShrink:0, display:"flex", alignItems:"center", justifyContent:"center"}}>↑</button>
          </div>
        </div>
      )}

      {/* Map view */}
      {view === "map" && (
        <div style={{flex:1, display:"flex", flexDirection:"column", overflow:"hidden"}}>
          {itinerary ? (
            <>
              {/* Day tabs */}
              <div style={{display:"flex", gap:6, padding:"8px 16px", overflowX:"auto",
                background:C.white, borderBottom:`1px solid ${C.border}`, scrollbarWidth:"none", flexShrink:0}}>
                <button onClick={() => setActiveDay(null)}
                  style={{padding:"5px 14px", borderRadius:16, border:"none", fontSize:12, fontWeight:600,
                    background:activeDay===null?C.text:C.bg,
                    color:activeDay===null?"#fff":C.muted, cursor:"pointer", whiteSpace:"nowrap"}}>
                  전체
                </button>
                {itinerary.days.map((d,i) => (
                  <button key={i} onClick={() => setActiveDay(i)}
                    style={{padding:"5px 14px", borderRadius:16, border:"none", fontSize:12, fontWeight:600,
                      background:activeDay===i?DAY_COLORS[i%DAY_COLORS.length]:C.bg,
                      color:activeDay===i?"#fff":C.muted, cursor:"pointer", whiteSpace:"nowrap"}}>
                    DAY {d.day} · {d.theme}
                  </button>
                ))}
              </div>

              <div style={{flex:1, display:"flex", flexDirection:"column", overflow:"hidden", position:"relative"}}>
                {/* Map */}
                <div style={{height:"42%", flexShrink:0}}>
                  <MapView days={itinerary.days} activeDay={activeDay}
                    onMarkerClick={(name, dayIdx) => setSelectedPoi({name, dayIndex:dayIdx})}/>
                </div>
                {/* List */}
                <div style={{flex:1, overflowY:"auto", padding:"12px 16px"}}>
                  {(activeDay !== null ? [itinerary.days[activeDay]] : itinerary.days).map((day, di) => {
                    const realIdx = activeDay !== null ? activeDay : di;
                    const color = DAY_COLORS[realIdx % DAY_COLORS.length];
                    return (
                      <div key={di} style={{marginBottom:16}}>
                        <div style={{display:"flex", alignItems:"center", gap:8, marginBottom:10}}>
                          <div style={{width:4, height:20, background:color, borderRadius:2}}/>
                          <span style={{fontSize:13, fontWeight:800}}>DAY {day.day}</span>
                          <span style={{fontSize:12, color:C.muted}}>{day.theme}</span>
                        </div>
                        {(day.items||[]).map((item, idx) => {
                          const poi = POIS[item.name];
                          const next = day.items[idx+1];
                          const nextPoi = next ? POIS[next.name] : null;
                          const dist = poi && nextPoi ? distKm(poi, nextPoi) : null;
                          return (
                            <div key={idx}>
                              <button onClick={() => setSelectedPoi({name:item.name, dayIndex:realIdx})}
                                style={{width:"100%", textAlign:"left", background:C.white,
                                  border:`1px solid ${C.border}`, borderRadius:12,
                                  padding:"12px 14px", cursor:"pointer", display:"flex",
                                  gap:12, alignItems:"center", boxShadow:"0 1px 4px rgba(0,0,0,0.06)"}}>
                                <div style={{width:28, height:28, borderRadius:14, background:color,
                                  color:"#fff", display:"flex", alignItems:"center",
                                  justifyContent:"center", fontSize:13, fontWeight:800, flexShrink:0}}>
                                  {idx+1}
                                </div>
                                <div style={{flex:1}}>
                                  <div style={{fontSize:13, fontWeight:700}}>{item.name}</div>
                                  <div style={{fontSize:11, color:C.muted, marginTop:2}}>
                                    {item.time}{item.note ? ` · ${item.note}` : ""}
                                  </div>
                                </div>
                                {poi?.price && <span style={{fontSize:11, color:C.primary, fontWeight:600}}>{poi.price}</span>}
                                <span style={{fontSize:16, color:C.muted}}>›</span>
                              </button>
                              {dist && (
                                <div style={{textAlign:"center", fontSize:11, color:C.muted,
                                  padding:"4px 0", display:"flex", alignItems:"center", gap:4}}>
                                  <div style={{flex:1, height:1, background:C.border}}/>
                                  🚗 {dist}km
                                  <div style={{flex:1, height:1, background:C.border}}/>
                                </div>
                              )}
                            </div>
                          );
                        })}
                      </div>
                    );
                  })}
                  {/* Lotocha CTA */}
                  <div style={{background:"linear-gradient(135deg,#1A6B5A,#0F4A3D)",
                    borderRadius:14, padding:"14px 16px", marginTop:8,
                    display:"flex", justifyContent:"space-between", alignItems:"center"}}>
                    <div>
                      <div style={{fontSize:13, fontWeight:800, color:"#fff"}}>🏢 로투차 현지 서비스</div>
                      <div style={{fontSize:11, color:"rgba(255,255,255,0.65)", marginTop:2}}>
                        공항픽업 · 입장권 대행 · 한국어 가이드
                      </div>
                    </div>
                    <button style={{background:C.accent, border:"none", borderRadius:8,
                      padding:"8px 14px", color:"#fff", fontSize:12, fontWeight:700, cursor:"pointer"}}>
                      문의하기 →
                    </button>
                  </div>
                </div>

                {/* POI detail */}
                {selectedPoi && (
                  <div style={{position:"absolute", bottom:0, left:0, right:0, zIndex:100}}>
                    <PoiDetail name={selectedPoi.name} dayIndex={selectedPoi.dayIndex}
                      onClose={() => setSelectedPoi(null)}/>
                  </div>
                )}
              </div>
            </>
          ) : (
            <div style={{flex:1, display:"flex", flexDirection:"column",
              alignItems:"center", justifyContent:"center", gap:12, color:C.muted}}>
              <div style={{fontSize:48}}>🗺️</div>
              <div style={{fontSize:15, fontWeight:600}}>아직 일정이 없어요</div>
              <button onClick={() => setView("chat")}
                style={{padding:"10px 24px", borderRadius:20, background:C.primary,
                  color:"#fff", border:"none", fontSize:14, fontWeight:700, cursor:"pointer"}}>
                💬 채팅으로 일정 만들기
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
