local RUN={}
getgenv().AF_BOT=RUN
local CFG={
KEEP=0.4,
KEEP_HOT=0.6,
KEEP_STRIKE=0.35,
KEEP_RIVAL=0.6,
EXPAND_MULTI=3,
ATTACK_MULTI=3,
OVERKILL=1.3,
TILE_CD=8,
MAX_DEFENSE=14,DEF_R=22,DEF_COOLDOWN=8,
DEF_CONTACTS=40,
CITY_CAP=16,SAM_CAP=5,
SAM_FIRST_INCOME_MULT=75,
CITY_CAP_RICH=40,
CITY_LV_CAP=24,
SILO_LV_MAX=6,
SILO_MIN_CITY=3,
UP_BATCH=4,
CITY_PER_TILES=2500,
CITY_SAFE_N=8,
EARLY_S=150,
EARLY_EXTRA=2,
EARLY_RATIO=0.15,
EARLY_MIN_FILL=0.30,
EARLY_MIN_FILL_BOT=0.12,
EARLY_KEEP_BOT=0.10,
EARLY_WAIT=0.5,
EARLY_ACTIVE=7,
MAX_ACTIVE=8,
STOP_FILL=0.2,
ATTACK_P=1.8,
HOLD_P=1.4,
WEAK_P=0.8,
WEAK_KEEP=0.6,
WEAK_STOP=0.5,
FRONT_COS=0.6,
FRONT_HOLD=20,
FRONT_RESEED=15,
DEF_ASSAULT_INC=0.25,
DEF_ASSAULT_LOSS=0.02,
DEF_ASSAULT_HOLD=45,
DEF_THREAT_MIN=0.25,
DEF_MIN_FRAC=0.2,
DEF_INWARD=0.4,
DEF_PROBE_FRAC=0.8,
BRUTAL_FRAC=0.05,
BRUTAL_MUL=2,
BRUTAL_HORIZON=30,
CONTESTED_EXTRA=2,
CONTESTED_RATIO=0.18,
SAVE_MAX_S=420,
SAVE_FORCE_AFTER_S=600,
SAVE_FORCE_MAX_S=900,
HOLE_MIN_FILL=0.4,
HOLE_SLOTS=3,
HOLE_RATIO=0.06,
RIVAL_RATIO=0.6,
RIVAL_CONTACTS=30,
RIVAL_FOCUS_BONUS=2.5,
ALLIANCE=false,
ALLY_CD=40,
ALLY_MIN_RATIO=0.6,
ATK_SAMPLE=40,
ATK_MARGIN=1.2,
ATK_MIN_RATIO=0.02,
ATK_MAX_RATIO=0.4,
ATK_TILES_MIN=15,
ATK_TILES_MAX=160,
MOM_P_BOOST=1.2,
MOM_SIZE=2.0,
MOM_SLOTS=2,
SPAWN_MAX_WAIT=4,
SPAWN_FRAC=0.5,
RESPAWN_MAX=3,
REPLAY_MAX=5,
EARLY_DEATH_S=90,
RESPAWN_CROWD=35,
ATK_MAX_COST_FRAC=0.5,
ATK_MIN_P=1.0,
COST_SCALE=1.0,
ATK_TILES=40,
COST_DEF_MULT=5.0,
DEF_SILO_MAX=0.35,
DEF_SILO_URGENT=0.7,
DEF_FRAC_BIG=0.4,
SILO_FIRST_GOLD=0.6,
REC_INTERVAL=10,
WATCH_INTERVAL=20,
COUNTER_MIN=1.1,
COUNTER_MIN_FRAC=0.02,
COUNTER_MAX=0.2,
COUNTER_FLOOR=0.4,
COUNTER_BUDGET=0.12,
COUNTER_WIN=30,
COUNTER_EXIST_FRAC=0.5,
COUNTER_EXIST_MAX=0.5,
LEADER_RESERVE=0.5,
LEADER_RESERVE_CAP=0.45,
BOAT_ATTACK_MAX=0.25,
BOAT_ATTACK_MIN_FILL=0.5,
INC_MIN_FRAC=0.03,
BOAT_REACH_MAX=4,
FOCUS_OVERKILL=1.25,
FOCUS_BOAT_FRAC=0.9,
FOCUS_BOAT_MAX_RATIO=0.25,
FOCUS_FAR_FRAC=0.2,
FLATTEN_RATIO=1.5,
FOCUS_SWITCH_MARGIN=1.0,
FOCUS_MIN_HOLD=15,
FOCUS_MIN_RATIO=0.8,
STRIKE_WINDOW=25,
STRIKE_OVERKILL_MUL=0.8,
STRIKE_EXTRA_SLOTS=2,
ANCHOR_HOLD=12,
ANCHOR_R=22,
PREDICT_S=8,
DENSITY_W=1.0,
RECLAIM_DROP=60,
RECLAIM_FRAC=0.02,
RECLAIM_WINDOW=25,
BLAST_R=24,
BLAST_R_MIRV=32,
SAM_R=56,
NUKE_ROI=1.0,
MIRV_ROI=1.0,
NUKE_RESERVE=100000,
NUKE_COOLDOWN=3,
NUKE_MAX_DIST=100000,
HBOMB_ROI=1.0,
TILE_VALUE=600,
OPENER_FILL=0.4,
INVADE_MIN_FILL=0.5,
INVADE_CANDS=12,
INVADE_DIRS=3,
INVADE_OWN_FRAC=0.06,
DISC_STEP=4,
BOAT_MULTI=2,
BOAT_SCAN_INTERVAL=8,
BOAT_RESERVE_FRAC=0.7,
BOAT_FLOOD_STEPS=25000,
BOAT_STARTS=24,
BOAT_CELL=12,
BOAT_CELL_CD=25,
BOAT_MAX_DIST=70,
WARSHIP_CAP=5,
BOT_RATIO_HI=2.3,
BOT_SEND_HI=0.4,
BOT_RATIO_MID=1.5,
BOT_SEND_MID=0.3,
BOT_MIN_P=1.5,
BOT_FLOOR=0.25,
HUMAN_MIN_P=3.0,
HUMAN_MAX_SEND=0.35,
HUMAN_FLOOR=0.5,
HUMAN_FOCUS_MIN=1.5,
HUMAN_NEAR_RATIO=0.5,
PUNISH_MIN_FILL=0.35,
RES_SAFETY_OK=0.6,
RES_SAFETY_WEAK=0.9,
RES_CAP=0.6,
ADJ_MIN_CONTACTS=3,
SEND_CAP_MULT=3.0,
DEF_MIN_CITY=3,
}
local CFG_BASE={}
for k,v in pairs(CFG)do CFG_BASE[k]=v end
local CFG_HARDCORE_OVR={
KEEP=0.35,KEEP_HOT=0.5,KEEP_RIVAL=0.45,KEEP_STRIKE=0.3,
LEADER_RESERVE=0.2,LEADER_RESERVE_CAP=0.2,
MAX_ACTIVE=8,EARLY_ACTIVE=8,
ATTACK_P=1.8,BOT_MIN_P=1.5,HUMAN_MIN_P=3.0,
MAX_DEFENSE=6,
SAM_CAP=7,
SILO_MIN_CITY=2,
NUKE_RESERVE=50000,PUNISH_P=3.0,PUNISH_P_MOM=2.0,
}
function RUN.setHardcore(v)
v=v and true or false
CFG.HARDCORE=v
for k,bv in pairs(CFG_BASE)do CFG[k]=bv end
if v then for k,hv in pairs(CFG_HARDCORE_OVR)do CFG[k]=hv end end
end
RUN.setHardcore(getgenv().AF_HARDCORE~=false)
RUN.cfg=CFG
RUN.paused=false
local EARLY=false
local DYN={stop=0}
local RS=game:GetService("ReplicatedStorage")
local Rules=require(RS.Airfront.Core.Rules)
local Defs=require(RS.Airfront.Core.Defs)
local KIND_TRIBE=1
if type(Defs)=="table"and type(Defs.KIND_TRIBE)=="number"then KIND_TRIBE=Defs.KIND_TRIBE end
local ctx
local W,H=1200,1200
local rd,ru=buffer.readi32,buffer.readu8
local DIRS4={1,-1,W,-W}
local function setMapSize(w,h)
W,H=w,h
DIRS4[3]=W
DIRS4[4]=-W
end
local function R()
local st=ctx and ctx.state
local r=st and st.rules
if type(r)=="table"and type(r.build_cost)=="function"then return r end
return Rules
end
local function defR()
local r=R().DEFENSE_RADIUS
if type(r)=="number"and r>0 then return r end
return CFG.DEF_R
end
local function probeLen()
return math.max(6,math.floor(defR()*CFG.DEF_PROBE_FRAC))
end
local NAMES={[0]="city","port","factory","defense","sam","silo","artillery","airfield","railgun","warship"}
local FALLBACK={
city=125000,port=125000,factory=125000,defense=50000,
sam=1500000,silo=1000000,atom=750000,hydrogen=5000000,
mirv=25000000,warship=250000,
}
local VALUE={city=250000,port=500000,factory=500000,defense=200000,
sam=1500000,silo=1000000}
local RATIOS={0.10,0.25,0.35,0.50,0.75}
local logs={}
getgenv().AF_LOGS=logs
local lastWrite,lastIdle=0,0
local LOGFILE="af_log_"..tostring(os.time())..".txt"
local function flushLogs()
local txt=table.concat(logs,"\n")
pcall(writefile,"af_log.txt",txt)
pcall(writefile,LOGFILE,txt)
end
local function log(s)
logs[#logs+1]=("[%.0f] %s"):format(os.clock(),s)
if#logs>8000 then table.remove(logs,1)end
if os.clock()-lastWrite>5 then
lastWrite=os.clock()
flushLogs()
end
end
getgenv().AF_COPY_LOG=function()
flushLogs()
local clip=setclipboard or toclipboard
if clip then pcall(clip,table.concat(logs,"\n"))end
end
local function findCtx()
for _,t in ipairs(getgc(true))do
if type(t)=="table"and rawget(t,"sent_log")and rawget(t,"state")and rawget(t,"borders")then return t end
end
end
local function findSender(c0)
local mt=getmetatable(c0);local idx=mt and mt.__index;local c={}
if type(idx)=="table"then
for k,f in pairs(idx)do
if type(f)=="function"and not iscclosure(f)then
local ok,cs=pcall(debug.getconstants,f)
if ok then for _,x in pairs(cs)do if x=="sent_log"then c[#c+1]={k,f}break end end end
end
end
end
return c
end
ctx=findCtx()
if not ctx then log("CTX tidak ketemu, jalankan di dalam match")return end
do
local st0=ctx.state
if type(st0.W)=="number"and type(st0.H)=="number"then
setMapSize(st0.W,st0.H)
log("ukuran map: "..W.."x"..H)
else
log("WARN: state.W/H tidak ada, pakai default "..W.."x"..H)
end
end
local cands,send=findSender(ctx),nil
local function trySend(intent)
for _,c in ipairs(cands)do
local before=#ctx.sent_log
if pcall(c[2],ctx,intent)and#ctx.sent_log>before then
send=function(i)return c[2](ctx,i)end
log("sender = "..tostring(c[1]))return true
end
end
return false
end
local lastSendWarn=0
local function fire(intent)
if send then return pcall(send,intent)end
local ok=trySend(intent)
if not ok and os.clock()-lastSendWarn>10 then
lastSendWarn=os.clock()
log("WARN: sender belum ketemu / intent nggak masuk sent_log (type="..tostring(intent.type)..")")
end
return ok
end
local flow={last=nil,lastT=0,spent=0,rate=nil}
local function noteSpend(x)flow.spent+=x end
local function flowTick(m,now)
local g=m.gold or 0
if not flow.last then
flow.last,flow.lastT,flow.spent=g,now,0
return
end
local dt=now-flow.lastT
if dt>=4 then
local earned=math.max(g-flow.last+flow.spent,0)
local r=earned/dt
flow.rate=flow.rate and(flow.rate*0.6+r*0.4)or r
flow.last,flow.lastT,flow.spent=g,now,0
end
end
local function incomeRate(m)
local r=flow.rate
if not r or r<1 then
r=(type(m.income)=="number"and m.income>0)and m.income or 1000
end
return math.max(r,1)
end
local NUKE_KINDS={}
local NAME_OF={}
local warnedPrice,lastKindSummary={},""
local ROI_BY_IDX={[0]=CFG.NUKE_ROI,[1]=CFG.HBOMB_ROI,[2]=CFG.MIRV_ROI}
local function resolveNames()
for idx=0,8 do
local nm=Defs.NUKE_NAMES and Defs.NUKE_NAMES[idx]
if type(nm)=="string"then NAME_OF[idx]=nm end
end
NAME_OF[0]=NAME_OF[0]or"atom"
NAME_OF[1]=NAME_OF[1]or"hydrogen"
NAME_OF[2]=NAME_OF[2]or"mirv"
end
local function unlocked(idx)
local bit=Defs.NUKE_UNLOCK and Defs.NUKE_UNLOCK[idx]or 0
if bit==0 then return true end
local ok,v=pcall(function()return ctx.state:has_unlock(ctx.state.local_owner,bit)end)
return(ok and v)and true or false
end
local function nukePriceByIdx(idx)
local r=R()
local nc=r.NUKE_COST
local base=type(nc)=="table"and nc[idx]
if type(base)~="number"or base<=0 then return nil end
if idx==2 then base+=(r.MIRV_COST_STEP or 0)*(ctx.state.mirvs_launched or 0)end
return base
end
local function nukePrice(name)
local ok,v=pcall(Rules.nuke_cost,name,ctx.state.mirvs_launched or 0)
if ok and type(v)=="number"and v>0 then return v end
for idx,nm in pairs(NAME_OF)do
if nm==name then
local p=nukePriceByIdx(idx)
if p then return p end
end
end
if not warnedPrice[name]then
warnedPrice[name]=true
log("harga bom '"..name.."' pakai tebakan!")
end
return FALLBACK[name]or 5000000
end
local function samR()return R().SAM_RADIUS or CFG.SAM_R end
local function buildNukeKinds()
local r=R()
local nc,nl,nr=r.NUKE_COST,r.NUKE_LAUNCHER,r.NUKE_RADIUS
if type(nc)~="table"then return end
resolveNames()
local fresh,locked={},{}
for idx=0,8 do
local price=nc[idx]
if type(price)=="number"and price>0 and type(nl)=="table"and nl[idx]==5 then
local nm=NAME_OF[idx]
if nm then
if unlocked(idx)then
local rad=type(nr)=="table"and nr[idx]or nil
if idx==2 then
local sp=r.MIRV_SPREAD
rad=(type(sp)=="number"and sp>0)and math.sqrt(sp)or CFG.BLAST_R_MIRV
elseif type(rad)~="number"or rad<=0 then
rad=CFG.BLAST_R_MIRV
end
fresh[nm]={r=rad,roi=ROI_BY_IDX[idx]or 1.0,idx=idx}
else
locked[#locked+1]=nm
end
end
end
end
NUKE_KINDS=fresh
local parts={}
for nm,kd in pairs(fresh)do parts[#parts+1]=("%s(r=%s)"):format(nm,tostring(kd.r))end
table.sort(parts)
local summary=table.concat(parts,",").." | terkunci: "..table.concat(locked,",")
if summary~=lastKindSummary then
lastKindSummary=summary
log("bom aktif: "..summary)
end
end
local function readyMissiles(st,S)
local rt=(R().RELOAD_TICKS or Rules.RELOAD_TICKS)
local reload=type(rt)=="table"and rt[5]or 90
local n=0
for _,s in ipairs(S.silos)do
local ok,v=pcall(st.ready_missiles,st,s,reload)
if ok and type(v)=="number"then n+=math.max(v,0)else n+=1 end
end
return n
end
local function NUKE_INTENT(tile,kind,amount)
local i={type="nuke",kind=kind or"atom",tile=tile}
if amount and amount>1 and(kind or"atom")=="atom"then i.amount=math.min(amount,50)end
return i
end
local function BOAT_INTENT(tile,ratio)return{type="boat",ratio=ratio,tile=tile}end
local function me(st)return st.owners[st.local_owner]end
function RUN.stats()
local st=ctx and ctx.state
local m=st and me(st)
if not m then return nil end
return{
tiles=m.tiles,troops=m.troops,maxTroops=m.max_troops,gold=m.gold,
income=incomeRate(m),alive=m.alive,spawned=m.spawned,
hardcore=CFG.HARDCORE,warship=RUN.getWarship(),paused=RUN.paused,
}
end
local function ownerAt(st,t)
if t<0 or t>=W*H then return-1 end
return rd(st.owner,t*4)
end
local function isLand(st,t)
if t<0 or t>=W*H then return false end
return ru(st.map.land,t)~=0
end
local function isFallout(st,t)
local f=st.flags
if not f then return false end
local ok,v=pcall(ru,f,t)
return ok and bit32.band(v,1)~=0
end
local function kindOf(s)return type(s.kind)=="number"and NAMES[s.kind]or s.kind end
local function homeCenter(m)
local tiles=math.max(m.tiles or 1,1)
return(m.cx or 0)/tiles,(m.cy or 0)/tiles
end
local function dist2(x1,y1,x2,y2)return(x1-x2)^2+(y1-y2)^2 end
local allyCache={}
local function allied(st,o)
local v=allyCache[o]
if v==nil then
v=false
pcall(function()v=st:are_allies(st.local_owner,o)and true or false end)
allyCache[o]=v
end
return v
end
local warnedCost={}
local function cost(kind,n)
local ok,v=pcall(R().build_cost,kind,n)
if ok and type(v)=="number"and v>0 then return v end
if not warnedCost[kind]then
warnedCost[kind]=true
log("harga '"..kind.."' pakai tebakan (build_cost gagal)")
end
return FALLBACK[kind]or 250000
end
local quoteSig
local function quote(real,tile)
local st=ctx.state
local r=R()
if type(r.placement)~="function"then return nil end
local tries={
function()return r.placement(st,st.local_owner,real,tile)end,
function()return r.placement(st,real,tile)end,
}
local order=quoteSig and{quoteSig}or{1,2}
for _,i in ipairs(order)do
local ok,res=pcall(tries[i])
if ok and type(res)=="table"then
if quoteSig==i then return res end
if type(res.cost)=="number"and res.cost>0 then
for n=0,14 do
local okc,v=pcall(Rules.build_cost,real,n)
if okc and v==res.cost then
quoteSig=i
log("placement signature #"..i.." cocok")
return res
end
end
end
end
end
end
local function wealthOf(m)
return(m.gold or 0)/math.max(nukePrice("atom"),1)
end
local function borderList(border,maxN)
local total=0
for _ in pairs(border)do total+=1 end
local p=total>maxN and(maxN/total)or 1
local out={}
for t in pairs(border)do
if p>=1 or math.random()<p then out[#out+1]=t end
end
return out
end
local function structSpacing()
local v=R().STRUCT_SPACING
return(type(v)=="number"and v>0)and math.ceil(v)or 9
end
local function spaced(st,t)
local x,y=t%W,t//W
local minD=structSpacing()
for _,s in pairs(st.structures)do
local sx,sy=s.tile%W,s.tile//W
if math.abs(sx-x)+math.abs(sy-y)<minD then return false end
end
return true
end
local function waterNear(st,t)
for _,d in ipairs({3,-3,3*W,-3*W,6,-6})do
local nt=t+d
if nt>0 and nt<W*H and not isLand(st,nt)then return true end
end
end
local function waterAdj(st,t)
for _,d in ipairs(DIRS4)do
local nt=t+d
if nt>0 and nt<W*H and not isLand(st,nt)then return true end
end
end
local function railMaxPath()
local v=R().RAIL_MAX_PATH
return(type(v)=="number"and v>0)and v or 92
end
local function nearestOwnStructDist(st,x,y)
local best=math.huge
for _,s in pairs(st.structures)do
if s.owner==st.local_owner then
local d=math.abs((s.tile%W)-x)+math.abs((s.tile//W)-y)
if d<best then best=d end
end
end
return best
end
local function sampleOwn(st,m,pred)
local tiles=math.max(m.tiles or 1,1)
local cx,cy=(m.cx or 0)/tiles,(m.cy or 0)/tiles
local Rr=math.max(20,math.sqrt(tiles)*0.9)
local rmp=railMaxPath()
local minD=structSpacing()
local railCands={}
for _=1,600 do
local x=math.floor(cx+(math.random()*2-1)*Rr)
local y=math.floor(cy+(math.random()*2-1)*Rr)
if x>8 and x<W-8 and y>8 and y<H-8 then
local t=y*W+x
if ownerAt(st,t)==st.local_owner and isLand(st,t)and spaced(st,t)and pred(t,x,y)then
local d=nearestOwnStructDist(st,x,y)
if d>=minD and d<=rmp then
railCands[#railCands+1]={t=t,d=d}
end
end
end
end
if#railCands>0 then
table.sort(railCands,function(a,b)return a.d<b.d end)
return railCands[1].t
end
for _=1,300 do
local x=math.floor(cx+(math.random()*2-1)*Rr)
local y=math.floor(cy+(math.random()*2-1)*Rr)
if x>8 and x<W-8 and y>8 and y<H-8 then
local t=y*W+x
if ownerAt(st,t)==st.local_owner and isLand(st,t)and spaced(st,t)and pred(t,x,y)then return t end
end
end
end
local function interior(st,t)
for _,d in ipairs({6,-6,6*W,-6*W})do
if ownerAt(st,t+d)~=st.local_owner then return false end
end
return true
end
local function discStats(st,cx,cy,r)
local mine=st.local_owner
local step=CFG.DISC_STEP
local foe,own,tot=0,0,0
local r2=r*r
for dy=-r,r,step do
for dx=-r,r,step do
if dx*dx+dy*dy<=r2 then
local x,y=cx+dx,cy+dy
if x>=0 and x<W and y>=0 and y<H then
local t=y*W+x
if isLand(st,t)then
tot+=1
local o=ownerAt(st,t)
if o==mine then
own+=1
elseif o>0 and not allied(st,o)then
foe+=1
end
end
end
end
end
end
return foe,own,tot
end
local spawnHist=getgenv().AF_SPAWN_HIST or{}
getgenv().AF_SPAWN_HIST=spawnHist
local function pickSpawn(st)
local taken={}
for y=20,H-20,14 do
for x=20,W-20,14 do
if ownerAt(st,y*W+x)>0 then taken[#taken+1]={x,y}end
end
end
local cx0,cy0=W/2,H/2
local maxC=math.sqrt(cx0*cx0+cy0*cy0)
local best,bestScore
for _=1,500 do
local x,y=math.random(60,W-60),math.random(60,H-60)
local t=y*W+x
if isLand(st,t)and ownerAt(st,t)==0 then
local clear=true
for dx=-25,25,12 do for dy=-25,25,12 do
if ownerAt(st,(y+dy)*W+(x+dx))~=0 then clear=false end
end end
if clear then
local dn=260
for _,p in ipairs(taken)do
local d=math.sqrt((p[1]-x)^2+(p[2]-y)^2)
if d<dn then dn=d end
end
local dc=math.sqrt((x-cx0)^2+(y-cy0)^2)/maxC
local foe,own,tot=discStats(st,x,y,45)
local openLand=tot>0 and(tot/((2*45/CFG.DISC_STEP+1)^2*0.785))or 0
local hist=0
for _,h in ipairs(spawnHist)do
if math.sqrt((h[1]-x)^2+(h[2]-y)^2)<120 then hist=hist+1 end
end
local sc=(dn/260)*2.0+dc*1.0+math.min(openLand,1)*1.2-hist*0.5+math.random()*0.15
if not bestScore or sc>bestScore then best,bestScore=t,sc end
end
end
end
if best then
spawnHist[#spawnHist+1]={best%W,best//W}
if#spawnHist>6 then table.remove(spawnHist,1)end
end
return best
end
local loggedUnknownKind={}
local function scan(st)
allyCache={}
local mine=st.local_owner
local S={
c={city=0,port=0,factory=0,defense=0,silo=0,sam=0,warship=0},
lv={city=0,port=0,factory=0,defense=0,silo=0,sam=0,warship=0},
defs={},own={},foes={},foeSam={},foeSilo=0,
fsum={},tiles={},silos={},
}
for _,s in pairs(st.structures)do
local k=kindOf(s)
if s.owner==mine then
if not k and type(s.kind)=="number"and not loggedUnknownKind[s.kind]then
loggedUnknownKind[s.kind]=true
log("kind numerik belum dikenal: "..s.kind.." -- cek & update NAMES kalau perlu")
end
S.own[#S.own+1]={tile=s.tile,kind=k}
if k and S.c[k]then
S.c[k]+=1
S.lv[k]+=(s.level or 1)
if k=="defense"then S.defs[#S.defs+1]=s end
if s.active~=false then
local l=S.tiles[k]
if not l then l={};S.tiles[k]=l end
l[#l+1]=s.tile
if k=="silo"then S.silos[#S.silos+1]=s end
end
end
elseif s.owner and s.owner~=0 then
local oi=st.owners[s.owner]
if oi and oi.alive and not allied(st,s.owner)then
local f={tile=s.tile,kind=k,owner=s.owner}
S.foes[#S.foes+1]=f
if k=="sam"then S.foeSam[#S.foeSam+1]=f end
if k=="silo"then S.foeSilo+=1 end
local fs=S.fsum[s.owner]
if not fs then fs={x=0,y=0,n=0};S.fsum[s.owner]=fs end
fs.x+=s.tile%W;fs.y+=s.tile//W;fs.n+=1
end
end
end
return S
end
local function analyse(st)
local mine=st.local_owner
local border=ctx.borders and ctx.borders.border
local nb,neutral,fallout,seen={},{},{},{}
if border then
for _,t in ipairs(borderList(border,4000))do
local x,y=t%W,t//W
if x>1 and x<W-2 and y>1 and y<H-2 then
for _,d in ipairs(DIRS4)do
local nt=t+d
local o=ownerAt(st,nt)
if o~=mine and o>=0 then
if o==0 then
if not seen[nt]and isLand(st,nt)then
seen[nt]=true
if isFallout(st,nt)then
fallout[#fallout+1]=nt
else
neutral[#neutral+1]=nt
end
end
else
local e=nb[o]
if e==nil then
local oi=st.owners[o]
if oi and oi.alive and not allied(st,o)then
e={o=o,troops=oi.troops or 0,contacts=0,tiles={},etiles={}}
else
e=false
end
nb[o]=e
end
if e then
e.contacts+=1
if#e.tiles<300 then e.tiles[#e.tiles+1]=t end
if#e.etiles<300 and not seen[nt]then
seen[nt]=true
e.etiles[#e.etiles+1]=nt
end
end
end
end
end
end
end
end
local myT=(st.owners[mine]and st.owners[mine].troops)or 0
if type(st.attacks)=="table"then
for _,a in pairs(st.attacks)do
if type(a)=="table"and a.target==mine and a.attacker~=mine and nb[a.attacker]
and(type(a.troops)~="number"or a.troops>=myT*CFG.INC_MIN_FRAC)then
nb[a.attacker].incoming=(nb[a.attacker].incoming or 0)+1
end
end
end
return nb,neutral,fallout
end
local function probeGaps(st,maxK)
local mine=st.local_owner
local border=ctx.borders and ctx.borders.border
local out={}
if not border then return out end
local total=W*H
for _,t in ipairs(borderList(border,260))do
if ownerAt(st,t)==mine then
local x=t%W
for i=1,4 do
local d=DIRS4[i]
local firstNeutral
for k=1,maxK do
local nt=t+d*k
if nt<0 or nt>=total then break end
if i==1 and x+k>=W then break end
if i==2 and x-k<0 then break end
local o=ownerAt(st,nt)
if o==mine then break end
if o>0 then
if not allied(st,o)then
local oi=st.owners[o]
if oi and oi.alive then
local e=out[o]
if not e then e={gap=k,n=0,pairs={},claims={}};out[o]=e end
e.n+=1
if k<e.gap then e.gap=k end
if#e.pairs<60 then e.pairs[#e.pairs+1]={b=t,e=nt,k=k}end
if firstNeutral and#e.claims<60 then e.claims[#e.claims+1]=firstNeutral end
end
end
break
elseif not isLand(st,nt)then
break
elseif not firstNeutral then
firstNeutral=nt
end
end
end
end
end
return out
end
local focus,focusHeldAt=nil,0
local boatStartsN=0
local reclaimBonus={}
local intel,myTrack={},{t=0,tiles=0,g=0,cur=0}
local function intelStep(st,m,now,nb,probe)
myTrack.cur=m.tiles or 0
if myTrack.t==0 then
myTrack.t,myTrack.tiles=now,myTrack.cur
elseif now-myTrack.t>=3 then
local g=(myTrack.cur-myTrack.tiles)/(now-myTrack.t)
myTrack.g=myTrack.g*0.5+g*0.5
myTrack.t,myTrack.tiles=now,myTrack.cur
end
local set={}
for o,e in pairs(nb)do if e then set[o]=true end end
for o in pairs(probe)do set[o]=true end
if focus then set[focus.o]=true end
for o in pairs(set)do
local oi=st.owners[o]
if oi and oi.alive then
local tiles,troops=oi.tiles or 0,oi.troops or 0
local it=intel[o]
if not it then
intel[o]={t=now,tiles=tiles,troops=troops,g=0,gT=0}
else
local dt=now-it.t
if dt>=3 then
it.g=it.g*0.5+((tiles-it.tiles)/dt)*0.5
it.gT=it.gT*0.5+((troops-it.troops)/dt)*0.5
it.t,it.tiles,it.troops=now,tiles,troops
end
end
end
end
end
local function isBrutal(o)
local it=intel[o]
if not it then return false end
local mine=math.max(myTrack.cur or 1,1)
local proj=it.g*CFG.BRUTAL_HORIZON
return proj>=mine*0.01 and
(proj>=mine*CFG.BRUTAL_FRAC or proj>=CFG.BRUTAL_MUL*math.max(myTrack.g*CFG.BRUTAL_HORIZON,1))
end
local function threat(st,m,nb,S,probe,maxK)
local info={incoming=false,danger=false,strong=false,strongest=0,
foeSilo=S.foeSilo,rival=nil,hostile={},brutalAny=false}
local mt=math.max(m.troops or 1,1)
local seen={}
for o,e in pairs(nb)do if e then seen[o]=true end end
for o in pairs(probe)do seen[o]=true end
for o in pairs(seen)do
local oi=st.owners[o]
local e,p=nb[o],probe[o]
if oi and oi.alive then
local troops=oi.troops or 0
local contacts=(e and e.contacts)or 0
local near=(p and p.n)or 0
local gap=contacts>0 and 1 or(p and p.gap)or(maxK+1)
local ratio=troops/mt
local wc=contacts+near
local inc=e and e.incoming
if inc then info.incoming=true end
if troops>info.strongest then info.strongest=troops end
if ratio>1.2 and(contacts>30 or gap<=4)then info.danger=true end
if ratio>0.35 and wc>=CFG.DEF_CONTACTS then info.strong=true end
if wc>=CFG.RIVAL_CONTACTS and ratio>=CFG.RIVAL_RATIO
and(not info.rival or troops>info.rival.troops)then
info.rival={o=o,troops=troops,contacts=wc}
end
local br=isBrutal(o)
if ratio>=CFG.DEF_THREAT_MIN or inc or br then
local prox=gap<=1 and 1 or math.max(0.15,1-(gap-1)/(maxK+1))
local w=math.min(ratio,3)*prox*(br and 1.5 or 1)+(inc and 1 or 0)
info.hostile[o]=math.max(w,0.2)
if br then info.brutalAny=true end
end
end
end
info.dominant=mt>info.strongest*1.6
return info
end
local counterCd,warnedCounter={},false
local counterSpent={}
local function counterStep(st,m,nb,now)
local out={}
if type(st.attacks)~="table"then return out end
local mine,mt=st.local_owner,m.troops or 0
if mt<1 then return out end
local floorT=(m.max_troops or 0)*math.max(CFG.STOP_FILL,CFG.COUNTER_FLOOR,DYN.stop)
local spent=0
for i=#counterSpent,1,-1 do
if now-counterSpent[i].t>CFG.COUNTER_WIN then table.remove(counterSpent,i)
else spent+=counterSpent[i].a end
end
local budget=(m.max_troops or 0)*CFG.COUNTER_BUDGET-spent
local inc={}
for _,a in pairs(st.attacks)do
if type(a)=="table"and not a.dead and a.target==mine and a.attacker~=mine then
if type(a.troops)=="number"then
inc[#inc+1]=a
elseif not warnedCounter then
warnedCounter=true
log("WARN: st.attacks nggak punya field .troops (angka), counter-attack nggak jalan")
end
end
end
table.sort(inc,function(x,y)return x.troops>y.troops end)
for _,a in ipairs(inc)do
if#out>=3 then break end
local e,T=nb[a.attacker],a.troops
if e and#e.etiles>0 and(counterCd[a.attacker]or 0)<=now
and mt>=T*CFG.COUNTER_MIN and T>=mt*CFG.COUNTER_MIN_FRAC then
local myAtk
for _,b in pairs(st.attacks)do
if type(b)=="table"and not b.dead and b.attacker==mine and b.target==a.attacker then myAtk=b break end
end
if not(myAtk and type(myAtk.troops)=="number"and myAtk.troops>=T*0.8)then
local existential=T>=mt*CFG.COUNTER_EXIST_FRAC
local maxRatio=existential and CFG.COUNTER_EXIST_MAX or CFG.COUNTER_MAX
local ratio=math.clamp(1.25*T/mt,0.05,maxRatio)
if mt-mt*ratio<floorT then
ratio=math.max((mt-floorT)/mt,0)
end
if not existential and mt*ratio>budget then ratio=math.max(budget,0)/mt end
if ratio>0.02 then
counterCd[a.attacker]=now+2.5
out[#out+1]={tile=e.etiles[math.random(#e.etiles)],ratio=ratio,owner=a.attacker,troops=T}
counterSpent[#counterSpent+1]={t=now,a=mt*ratio}
budget-=mt*ratio
mt=mt*(1-ratio)
end
end
end
end
return out
end
local allyCd={}
local function diplomacyStep(st,m,nb,fcs,now)
if not CFG.ALLIANCE then return end
local troops=m.troops or 0
local best
for o,e in pairs(nb)do
if e and not(fcs and fcs.o==o)and(allyCd[o]or 0)<=now
and e.contacts>=10 and e.troops>=troops*CFG.ALLY_MIN_RATIO then
if not best or e.troops>best.troops then best=e end
end
end
if best then
allyCd[best.o]=now+CFG.ALLY_CD
fire({type="ally_request",target=best.o})
log(("ALLY request -> owner %d (troops=%d kontak=%d)"):format(best.o,math.floor(best.troops),best.contacts))
end
end
local rec={last=0,tiles=nil,c=nil}
local function recorder(st,m,S,nb,info,now)
if now-rec.last<CFG.REC_INTERVAL then return end
rec.last=now
local mine=st.local_owner
local incN,incT=0,0
if type(st.attacks)=="table"then
for _,a in pairs(st.attacks)do
if type(a)=="table"and not a.dead and a.target==mine and a.attacker~=mine then
incN+=1
if type(a.troops)=="number"then incT+=a.troops end
end
end
end
local top,topT,topC=0,0,0
for o,e in pairs(nb)do
if e and e.troops>topT then top,topT,topC=o,e.troops,e.contacts end
end
local nk=0
if type(st.nukes)=="table"then for _ in pairs(st.nukes)do nk+=1 end end
local rv=info.rival and("owner "..info.rival.o)or"-"
local hn=0
for _ in pairs(info.hostile)do hn+=1 end
log(("REC troops=%d/%d gold=%d inc=%.0f/s tiles=%s city=%d(L%d) def=%d sam=%d silo=%d | serangan masuk=%d(%d troops) | tetangga terkuat=%d(%d, kontak %d) | rival=%s hostile=%d brutal=%s | nuke di udara=%d | foeSilo=%d"):format(
math.floor(m.troops or 0),math.floor(m.max_troops or 0),math.floor(m.gold or 0),incomeRate(m),tostring(m.tiles),
S.c.city,S.lv.city,S.c.defense,S.c.sam,S.c.silo,
incN,math.floor(incT),top,math.floor(topT),topC,rv,hn,tostring(info.brutalAny),nk,S.foeSilo))
if rec.tiles and(m.tiles or 0)<rec.tiles*0.9 then
log(("LOSS tanah %s -> %s dalam %ds"):format(tostring(rec.tiles),tostring(m.tiles),CFG.REC_INTERVAL))
end
if rec.c then
for k,v in pairs(S.c)do
if v<(rec.c[k]or 0)then log(("LOSS struktur %s %d -> %d"):format(k,rec.c[k],v))end
end
end
rec.tiles=m.tiles
rec.c={}
for k,v in pairs(S.c)do rec.c[k]=v end
end
local watch={last=0,leader=nil,snap=nil}
getgenv().AF_WATCH=watch
local function enemyWatch(st,S,now)
if now-watch.last<CFG.WATCH_INTERVAL then return end
watch.last=now
local mine=st.local_owner
local leader,leaderTiles=nil,-1
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=mine and o~=0 and type(oi)=="table"
and oi.alive and not allied(st,o)and(oi.tiles or 0)>leaderTiles then
leader,leaderTiles=o,oi.tiles or 0
end
end
if not leader then return end
local oi=st.owners[leader]
local c={city=0,port=0,factory=0,defense=0,sam=0,silo=0,warship=0}
for _,f in ipairs(S.foes)do
if f.owner==leader and f.kind and c[f.kind]~=nil then c[f.kind]+=1 end
end
local troops,tiles=oi.troops or 0,oi.tiles or 0
local sameLeader=watch.leader==leader
local prev=sameLeader and watch.snap or nil
local function d(cur,k)return prev and(cur-(prev[k]or cur))or 0 end
local function dc(k)return prev and(c[k]-(prev.c[k]or c[k]))or 0 end
if not sameLeader and watch.leader~=nil then
log(("WATCH leader ganti: owner %d -> owner %d"):format(watch.leader,leader))
end
log(("WATCH #1 land: owner=%d tiles=%d(%+d) troops=%d(%+d) | city=%d(%+d) port=%d(%+d) factory=%d(%+d) def=%d(%+d) sam=%d(%+d) silo=%d(%+d)%s"):format(
leader,tiles,d(tiles,"tiles"),troops,d(troops,"troops"),
c.city,dc("city"),c.port,dc("port"),c.factory,dc("factory"),
c.defense,dc("defense"),c.sam,dc("sam"),c.silo,dc("silo"),
prev and("  ["..math.floor(now-prev.at).."s]")or""))
watch.leader=leader
watch.snap={at=now,tiles=tiles,troops=troops,c=c}
end
local function foeCenter(S,o,oi)
if oi.cx~=nil and oi.cy~=nil and(oi.tiles or 0)>0 then
return oi.cx/oi.tiles,oi.cy/oi.tiles
end
local f=S.fsum[o]
if f and f.n>0 then return f.x/f.n,f.y/f.n end
end
local EXISTENTIAL_TILE_SHARE=0.25
local totalMapTiles=W*H
local function evalFocus(st,m,S,nb,now)
local troops=m.troops or 0
local myTiles=math.max(m.tiles or 1,1)
local myDens=troops/myTiles
local hx,hy=homeCenter(m)
local haveCoast=boatStartsN>0
local farMax=math.max(W,H)*CFG.FOCUS_FAR_FRAC
local totalLiveTiles=0
for o,oi in pairs(st.owners)do
if type(o)=="number"and type(oi)=="table"and oi.alive then
totalLiveTiles+=(oi.tiles or 0)
end
end
totalLiveTiles=math.max(totalLiveTiles,1)
local list={}
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=st.local_owner and o~=0 and type(oi)=="table"
and oi.alive and oi.spawned~=false and(oi.tiles==nil or oi.tiles>0)
and not allied(st,o)then
local e=nb[o]
local contact=(e and e.contacts>0)and true or false
local cx,cy=foeCenter(S,o,oi)
if not cx and e and#e.etiles>0 then cx,cy=e.etiles[1]%W,e.etiles[1]//W end
if cx then
local d=math.sqrt(dist2(cx,cy,hx,hy))
local tileShare=(oi.tiles or 0)/totalLiveTiles
local existential=tileShare>=EXISTENTIAL_TILE_SHARE
local isBot=(oi.kind==KIND_TRIBE)
local ratio0=troops/math.max(oi.troops or 1,1)
local skipHuman=(not isBot)and(not existential)and ratio0<CFG.HUMAN_FOCUS_MIN
if not skipHuman and(contact or existential or(haveCoast and d<=farMax))then
local ratio=troops/math.max(oi.troops or 1,1)
local isRival=e and e.contacts>=CFG.RIVAL_CONTACTS
and(oi.troops or 0)>=troops*CFG.RIVAL_RATIO
local theirDens=(oi.troops or 0)/math.max(oi.tiles or 1,1)
local dens=0
if myDens>0 and theirDens>0 then
dens=math.clamp(CFG.DENSITY_W*math.log(myDens/theirDens),-1,1.5)
end
local brutalBonus=(contact and isBrutal(o))and 1.5 or 0
local existentialPenalty=existential and math.min(tileShare*3,2.0)or 0
local score=math.min(ratio,6)+(contact and 1.5 or 0)-d/600
+(ratio>=CFG.FLATTEN_RATIO and 1.5 or 0)
+((reclaimBonus[o]or 0)>now and 2 or 0)
+((isRival and ratio>=1.1)and CFG.RIVAL_FOCUS_BONUS or 0)
+dens+brutalBonus
+((isBot and ratio>=CFG.BOT_RATIO_HI)and 1.0 or 0)
-existentialPenalty
list[#list+1]={o=o,ratio=ratio,contact=contact,cx=cx,cy=cy,
d=d,score=score,tiles=oi.tiles,
existential=existential,tileShare=tileShare}
end
end
end
end
local best,cur
for _,c in ipairs(list)do
if not best or c.score>best.score then best=c end
if focus and c.o==focus.o then cur=c end
end
local pick
local curMinRatio=(cur and cur.existential)and(CFG.FOCUS_MIN_RATIO*0.3)or(CFG.FOCUS_MIN_RATIO*0.75)
local bestMinRatio=(best and best.existential)and(CFG.FOCUS_MIN_RATIO*0.3)or CFG.FOCUS_MIN_RATIO
if cur and cur.ratio>=curMinRatio then
pick=cur
if best and best.o~=cur.o and best.ratio>=bestMinRatio
and best.score>cur.score+CFG.FOCUS_SWITCH_MARGIN
and now-focusHeldAt>CFG.FOCUS_MIN_HOLD then
pick=best
end
elseif best and best.ratio>=bestMinRatio then
pick=best
end
if pick then
if not focus or focus.o~=pick.o then
focusHeldAt=now
log(("FOCUS -> owner %d ratio=%.2f contact=%s jarak=%d skor=%.2f brutal=%s existential=%s(%.1f%%)"):format(
pick.o,pick.ratio,tostring(pick.contact),math.floor(pick.d),pick.score,
tostring(isBrutal(pick.o)),tostring(pick.existential),(pick.tileShare or 0)*100))
end
focus=pick
else
if focus then log("FOCUS dilepas (nggak ada musuh yang layak)")end
focus=nil
end
return focus
end
local function foeCoastTile(st,o,cx,cy,tiles,hx,hy)
local Rr=math.max(25,math.sqrt(math.max(tiles or 2500,1))*1.2)
local best,bestD
for _=1,600 do
local x=math.floor(cx+(math.random()*2-1)*Rr)
local y=math.floor(cy+(math.random()*2-1)*Rr)
if x>2 and x<W-3 and y>2 and y<H-3 then
local t=y*W+x
if ownerAt(st,t)==o and isLand(st,t)and waterAdj(st,t)then
local d=dist2(x,y,hx,hy)
if not bestD or d<bestD then best,bestD=t,d end
end
end
end
return best
end
local strike=nil
local function strikeFor(o,now)
return strike and strike.owner==o and strike.till>now
end
local trk={tiles=nil,otiles={}}
local reclaimFalloutUntil=0
local lastRebutLog=0
local function trackLoss(st,m,nb,now)
local cur=m.tiles or 0
local otNow={}
for o,oi in pairs(st.owners)do
if type(o)=="number"and type(oi)=="table"and o~=st.local_owner then
otNow[o]=oi.tiles or 0
end
end
local prev=trk.tiles
if prev then
local lost=prev-cur
if lost>=CFG.RECLAIM_DROP and lost>=prev*CFG.RECLAIM_FRAC then
local taker,gain=nil,0
for o,t in pairs(otNow)do
local g=t-(trk.otiles[o]or t)
if g>gain then taker,gain=o,g end
end
local quiet=now-lastRebutLog<4
if taker and gain>=lost*0.4 and nb[taker]and not allied(st,taker)then
strike={owner=taker,till=now+CFG.RECLAIM_WINDOW}
reclaimBonus[taker]=now+CFG.RECLAIM_WINDOW
if not quiet then
lastRebutLog=now
log(("REBUT: kehilangan %d tile, owner %d ngambil %d -> serang balik %ds"):format(
lost,taker,gain,CFG.RECLAIM_WINDOW))
end
end
if gain<lost*0.6 then
reclaimFalloutUntil=now+CFG.RECLAIM_WINDOW
if not quiet then
lastRebutLog=now
log(("REBUT: %d tile hilang jadi netral/fallout (kena nuke?) -> expand ulang %ds"):format(
lost,CFG.RECLAIM_WINDOW))
end
end
end
end
trk.tiles=cur
trk.otiles=otNow
end
local tileCd,cellCd,lastPurge={},{},0
local function ownNbCount(st,t)
local mine,n=st.local_owner,0
for _,d in ipairs(DIRS4)do
if ownerAt(st,t+d)==mine then n+=1 end
end
return n
end
local function holeStep(st,neutral,fallout,fill,now)
local out={}
if fill<CFG.HOLE_MIN_FILL then return out end
local cand={}
local function consider(list)
for i=1,math.min(#list,600)do
local t=list[i]
if(tileCd[t]or 0)<=now then
local n=ownNbCount(st,t)
if n>=2 then cand[#cand+1]={t=t,n=n,f=isFallout(st,t)}end
end
end
end
consider(fallout)
consider(neutral)
table.sort(cand,function(a,b)
if a.n~=b.n then return a.n>b.n end
if a.f~=b.f then return a.f end
return a.t<b.t
end)
for i=1,math.min(#cand,CFG.HOLE_SLOTS)do
local t=cand[i].t
tileCd[t]=now+CFG.TILE_CD
out[#out+1]={tile=t,kind="expand",ratio=CFG.HOLE_RATIO}
end
return out
end
local anchors={}
local function pickAnchor(st,S,e,hx,hy,now)
local a=anchors[e.o]
if a and now-a.at<CFG.ANCHOR_HOLD and ownerAt(st,a.tile)==e.o then return a.tile end
local gx,gy,bestS
for _,f in ipairs(S.foes)do
if f.owner==e.o and VALUE[f.kind]then
local d=math.sqrt(dist2(f.tile%W,f.tile//W,hx,hy))
local sc=VALUE[f.kind]/(1+d/40)
if not bestS or sc>bestS then
bestS=sc
gx,gy=f.tile%W,f.tile//W
end
end
end
if not gx then
local oi=st.owners[e.o]
if oi then gx,gy=foeCenter(S,e.o,oi)end
end
if not gx then return nil end
local bt,bd
for i=1,#e.etiles do
local t=e.etiles[i]
local d=dist2(t%W,t//W,gx,gy)
if not bd or d<bd then bt,bd=t,d end
end
if bt then anchors[e.o]={tile=bt,at=now}end
return bt
end
local FRONT=nil
local lastFrontLog=0
local function frontNorm(x,y)
local l=math.sqrt(x*x+y*y)
if l<1e-6 then return 1,0 end
return x/l,y/l
end
local function coneTiles(list,hx,hy,dx,dy)
local out={}
for i=1,#list do
local t=list[i]
local vx,vy=t%W-hx,t//W-hy
local l=math.sqrt(vx*vx+vy*vy)
if l<1 or(vx*dx+vy*dy)/l>=CFG.FRONT_COS then out[#out+1]=t end
end
return out
end
local momLog={}
local function momentumOf(st,m,o,e,now)
local it=intel[o]
local mom,why=0,{}
if it then
local T=math.max(e.troops or 1,1)
if it.gT<0 then
local v=math.clamp((-it.gT*8)/(T*0.15),0,1)*0.5
if v>0.05 then mom+=v;why[#why+1]="pasukan turun"end
end
local oi=st.owners[o]
local tl=math.max(oi and oi.tiles or 1,1)
if it.g<0 then
local v=math.clamp((-it.g*8)/(tl*0.01),0,1)*0.3
if v>0.05 then mom+=v;why[#why+1]="tanah turun"end
end
end
local Ta=0
if type(st.attacks)=="table"then
for _,a in pairs(st.attacks)do
if type(a)=="table"and not a.dead and a.target==o and a.attacker~=st.local_owner then
Ta+=(type(a.troops)=="number"and a.troops or 0)
end
end
end
if Ta>0 then
local v=math.clamp(Ta/math.max(e.troops or 1,1),0,1)*0.5
if v>0.05 then mom+=v;why[#why+1]="diserang pihak lain"end
end
mom=math.min(mom,1)
if mom>=0.4 and now-(momLog[o]or 0)>10 then
momLog[o]=now
log(("MOMENTUM owner %d mom=%.2f (%s) pasukan=%d"):format(o,mom,table.concat(why,", "),math.floor(e.troops or 0)))
end
return mom
end
local function frontStep(st,m,S,nb,now)
local troops=m.troops or 0
local hx,hy=homeCenter(m)
local best,cur
for o,e in pairs(nb)do
if e then
if#e.etiles>0 then
local it=intel[o]
local grow=it and math.max(it.gT,0)*CFG.PREDICT_S or 0
e.P=troops/math.max(e.troops+grow,1)
e.mom=momentumOf(st,m,o,e,now)
e.P=e.P*(1+CFG.MOM_P_BOOST*e.mom)
if FRONT and FRONT.o==o then cur=e end
if e.P>=CFG.ATTACK_P and(not best or e.P>best.P)then best=e end
end
end
end
local pick
if cur and cur.P>=CFG.HOLD_P then
pick=cur
if best and best.o~=cur.o and best.P>cur.P*1.5 and now-FRONT.at>CFG.FRONT_HOLD then pick=best end
else
pick=best
end
if not pick then
if FRONT then log("FRONT dilepas (P turun / musuh hilang)")end
FRONT=nil
return nil
end
if not FRONT or FRONT.o~=pick.o then
local seed=pickAnchor(st,S,pick,hx,hy,now)or pick.etiles[1]
local dx,dy=frontNorm(seed%W-hx,seed//W-hy)
FRONT={o=pick.o,at=now,seed=seed,dx=dx,dy=dy,reseed=now}
log(("FRONT -> owner %d P=%.2f arah=(%.2f,%.2f) pasukan musuh=%d"):format(
pick.o,pick.P,dx,dy,math.floor(pick.troops)))
end
local tiles=coneTiles(pick.etiles,hx,hy,FRONT.dx,FRONT.dy)
if#tiles==0 then
local seed=pickAnchor(st,S,pick,hx,hy,now)or pick.etiles[1]
FRONT.dx,FRONT.dy=frontNorm(seed%W-hx,seed//W-hy)
FRONT.seed,FRONT.reseed=seed,now
tiles=coneTiles(pick.etiles,hx,hy,FRONT.dx,FRONT.dy)
if#tiles==0 then tiles={seed}end
elseif now-FRONT.reseed>=CFG.FRONT_RESEED or ownerAt(st,FRONT.seed)~=FRONT.o then
local seed=pickAnchor(st,S,{o=pick.o,etiles=tiles},hx,hy,now)
if seed then
FRONT.seed=seed
local nx,ny=frontNorm(seed%W-hx,seed//W-hy)
FRONT.dx,FRONT.dy=frontNorm(FRONT.dx*0.7+nx*0.3,FRONT.dy*0.7+ny*0.3)
end
FRONT.reseed=now
end
FRONT.tiles,FRONT.P=tiles,pick.P
if now-lastFrontLog>10 then
lastFrontLog=now
log(("FRONT owner %d P=%.2f kerucut=%d tile, pasukan gw=%d musuh=%d"):format(
pick.o,pick.P,#tiles,math.floor(troops),math.floor(pick.troops)))
end
return FRONT
end
local function pickRatio(avail,need,maxR)
for _,r in ipairs(RATIOS)do
if maxR and r>maxR then break end
if r*avail>=need then return r end
end
end
local costLogN=0
local avgMagCache
local function avgMag(t)
if avgMagCache then return avgMagCache end
local sum,n=0,0
for _,v in pairs(t)do if type(v)=="number"then sum+=v;n+=1 end end
avgMagCache=n>0 and sum/n or 80
return avgMagCache
end
local function ltb(Rl,tiles,depth)
local f=Rl.large_territory_bonus
if type(f)=="function"then
local ok,v=pcall(f,tiles,depth)
if ok and type(v)=="number"then return v end
end
return 1
end
local function tileLoss(st,S,e,t,X)
local Rl=R()
local oi=st.owners[e.o]
local me=st.owners[st.local_owner]
local defT=math.max((oi and oi.troops)or e.troops or 0,1)
local defTiles=math.max((oi and oi.tiles)or 1000,1)
local myTiles=math.max((me and me.tiles)or 1,1)
local mag=80
local magT=Rl.ATTACK_MAG
if type(magT)=="table"then
local terr
local tb=st.map and st.map.terrain
if typeof(tb)=="buffer"then
local ok,v=pcall(buffer.readu8,tb,t)
if ok then terr=v end
end
mag=(terr and tonumber(magT[terr]))or avgMag(magT)
end
local tx,ty=t%W,t//W
local rr2=defR()^2
for _,f in ipairs(S.foes)do
if f.owner==e.o and f.kind=="defense"and dist2(f.tile%W,f.tile//W,tx,ty)<rr2 then
mag=mag*(tonumber(Rl.DEFENSE_POST_MAG)or CFG.COST_DEF_MULT)
break
end
end
if oi and oi.kind==KIND_TRIBE and me and me.kind~=KIND_TRIBE then
mag=mag*(tonumber(Rl.BOT_DEFENDER_LOSS_MULT)or 0.7)
end
local ratio=math.clamp(defT/math.max(X,1),0.6,2)
local base=(tonumber(Rl.ATTACKER_LOSS_BASE)or 0.463)*ltb(Rl,myTiles,Rl.LARGE_ATTACKER_DEPTH or 0.7)
*ltb(Rl,defTiles,Rl.LARGE_DEFENDER_DEPTH or 0.3)
+(tonumber(Rl.ATTACKER_LOSS_PER_DENSITY)or 0.0039)*(defT/defTiles)
return math.max(mag*ratio*base*CFG.COST_SCALE,0.01)
end
local function attackNeed(st,S,e,t,ref,Nopt)
local N=Nopt or CFG.ATK_TILES
local X=math.max(ref,1)
local L=tileLoss(st,S,e,t,X)
for _=1,3 do
X=math.max(L*N,1)
L=tileLoss(st,S,e,t,X)
end
return L,math.max(L*N,1)
end
local function dynTiles(e,fill,info,isFocus)
local N=CFG.ATK_TILES
N=N*(1+CFG.MOM_SIZE*(e.mom or 0))
if fill>0.9 then N=N*1.5 end
local P=e.P or 0
if P>=3 then N=N*1.4 elseif P>=2 then N=N*1.15 end
if isFocus then N=N*1.2 end
if info and info.incoming then N=N*0.5 end
return math.clamp(N,CFG.ATK_TILES_MIN,CFG.ATK_TILES_MAX)
end
local contestCache={at=-99,score={},de={}}
local function contestScan(st,neutral,now)
if now-contestCache.at<1.0 then return contestCache end
local mine=st.local_owner
local R_,CAP=45,9000
local dm,src={},{}
local q,qh,n={},1,0
for _,f in ipairs(neutral)do
if not dm[f]then dm[f]=1;src[f]=f;q[#q+1]=f;n+=1 end
end
local seeds,seedSeen={},{}
while qh<=#q and n<CAP do
local t=q[qh];qh+=1
local dt=dm[t]
local x=t%W
for i=1,4 do
local nt=t+DIRS4[i]
if not((i==1 and x+1>=W)or(i==2 and x-1<0))and nt>=0 and nt<W*H then
local o=ownerAt(st,nt)
if o==0 then
if dm[nt]==nil and dt<R_ and isLand(st,nt)then
dm[nt]=dt+1;src[nt]=src[t];q[#q+1]=nt;n+=1
end
elseif o>0 and o~=mine and not seedSeen[nt]and not allied(st,o)then
seedSeen[nt]=true;seeds[#seeds+1]=nt
end
end
end
end
local de={}
local q2,h2={},1
for _,e in ipairs(seeds)do
local x=e%W
for i=1,4 do
local nt=e+DIRS4[i]
if not((i==1 and x+1>=W)or(i==2 and x-1<0))and dm[nt]and not de[nt]then
de[nt]=1;q2[#q2+1]=nt
end
end
end
while h2<=#q2 do
local t=q2[h2];h2+=1
local dt=de[t]
if dt<R_ then
local x=t%W
for i=1,4 do
local nt=t+DIRS4[i]
if not((i==1 and x+1>=W)or(i==2 and x-1<0))and dm[nt]and not de[nt]then
de[nt]=dt+1;q2[#q2+1]=nt
end
end
end
end
local score={}
for v,d in pairs(dm)do
local e=de[v]
if e and e<=d+3 then
local w=1+(d-e<=0 and 1 or 0)
score[src[v]]=(score[src[v]]or 0)+w
end
end
contestCache={at=now,score=score,de=de}
return contestCache
end
local sizeLogN=0
local function planAttacks(st,m,S,nb,neutral,info,now,fcs,fallout,claimSet,contested,expandOnly)
if now-lastPurge>60 then
lastPurge=now
for t,v in pairs(tileCd)do if v<=now then tileCd[t]=nil end end
for t,v in pairs(cellCd)do if v<=now then cellCd[t]=nil end end
end
local out={}
local troops,maxT=m.troops or 0,math.max(m.max_troops or 1,1)
local fill=troops/maxT
local avail=info.incoming and troops*0.6 or troops
local hx,hy=homeCenter(m)
local activeN=0
if type(st.attacks)=="table"then
for _,a in pairs(st.attacks)do
if type(a)=="table"and not a.dead and a.attacker==st.local_owner then activeN+=1 end
end
end
local room=math.max((EARLY and CFG.EARLY_ACTIVE or CFG.MAX_ACTIVE)-activeN,0)
if fallout and#fallout>0 and reclaimFalloutUntil>now and fill>=0.4 and troops>(info and info.reserveT or 0)then
local n=0
for _=1,8 do
if n>=3 then break end
local t=fallout[math.random(#fallout)]
if(tileCd[t]or 0)<=now then
tileCd[t]=now+CFG.TILE_CD
out[#out+1]={tile=t,kind="expand",ratio=0.15}
avail=avail*0.85
n+=1
end
end
end
local peerT=0
for o,e in pairs(nb)do
if e and(e.contacts or 0)>=5 then
local oiP=st.owners[o]
if oiP and oiP.kind~=KIND_TRIBE and(oiP.troops or 0)>=(m.troops or 0)*CFG.HUMAN_NEAR_RATIO then
peerT=math.max(peerT,oiP.troops or 0)
end
end
end
local hot=info and info.punish and true or false
for _,e in pairs(nb)do
if e and#e.etiles>0 and e.P then
local oiH=st.owners[e.o]
local botH=(oiH~=nil and oiH.kind==KIND_TRIBE)
if e.P>=(botH and CFG.BOT_MIN_P or CFG.HUMAN_MIN_P)then hot=true break end
end
end
if#neutral>0 then
local ratio=EARLY and CFG.EARLY_RATIO or(fill>0.9 and 0.25 or(contested and CFG.CONTESTED_RATIO or 0.10))
local slots=CFG.EXPAND_MULTI+(contested and CFG.CONTESTED_EXTRA or 0)+(EARLY and CFG.EARLY_EXTRA or 0)
slots=math.min(slots,room)
if hot and not expandOnly then slots=math.min(slots,2,math.max(room-3,1))end
if peerT>0 and not EARLY then slots=math.min(slots,2)end
local resT=info and info.reserveT or 0
local weakAdj=(not EARLY)and info and(info.adjRatio or 99)<1.0
if weakAdj then slots=math.min(slots,1)end
if troops<=resT then slots=0 end
local scored={}
local cs=next(nb)~=nil or contested or next(claimSet)~=nil
local cc
if cs then
local okc,res=pcall(contestScan,st,neutral,now)
if okc then cc=res else log("ERR contest: "..tostring(res))end
end
local nBlock=0
for _,t in ipairs(neutral)do
local d=dist2(t%W,t//W,hx,hy)
local pr=cc and cc.score[t]or 0
if pr>0 then nBlock+=1 end
if pr>0 then d=-pr
elseif claimSet[t]then d=d*0.01 elseif ownNbCount(st,t)>=2 then d=d*0.3 end
scored[#scored+1]={t=t,d=d,blk=pr>0}
end
table.sort(scored,function(a,b)return a.d<b.d end)
if nBlock>0 then slots=math.min(slots+1,room)end
local got=0
for _,s in ipairs(scored)do
if got>=slots then break end
local t=s.t
if(tileCd[t]or 0)<=now then
tileCd[t]=now+CFG.TILE_CD
local rr=s.blk and math.max(ratio,CFG.CONTESTED_RATIO)or ratio
if peerT>0 and not EARLY then rr=math.min(rr,0.08)end
if weakAdj then rr=math.min(rr,0.08)end
if troops*(1-rr)<resT then break end
out[#out+1]={tile=t,kind="expand",ratio=rr}
avail=avail*(1-rr)
troops=troops*(1-rr)
got+=1
end
end
if(fill<0.75 and not hot)or expandOnly then return out,avail end
elseif fallout and#fallout>0 and fill>0.85 and reclaimFalloutUntil<=now then
local t=fallout[math.random(#fallout)]
if(tileCd[t]or 0)<=now then
tileCd[t]=now+CFG.TILE_CD
out[#out+1]={tile=t,kind="expand",ratio=0.15}
avail=avail*0.85
end
end
if expandOnly then return out,avail end
local list={}
for _,e in pairs(nb)do
if e and#e.etiles>0 then
local bestD=math.huge
for i=1,math.min(#e.etiles,40)do
local t=e.etiles[i]
local d=dist2(t%W,t//W,hx,hy)
if d<bestD then bestD=d end
end
e.nearDist=bestD
local isFocus=fcs and e.o==fcs.o
local oi=st.owners[e.o]
e.bot=(oi~=nil and oi.kind==KIND_TRIBE)
local minP=e.bot and CFG.BOT_MIN_P or CFG.HUMAN_MIN_P
local Pq=e.P or 0
if(e.bot and((FRONT and e.o==FRONT.o)or isFocus or Pq>=minP))
or((not e.bot)and Pq>=minP)or(info and info.punishE==e)then
list[#list+1]=e
end
end
end
table.sort(list,function(a,b)
local as,bs=strikeFor(a.o,now),strikeFor(b.o,now)
if as~=bs then return as end
local af,bf=fcs and a.o==fcs.o,fcs and b.o==fcs.o
if af~=bf then return af end
return a.nearDist<b.nearDist
end)
local humanThreat=peerT>0
local slots=math.min(CFG.ATTACK_MULTI,room)
if info and info.punish then slots=math.min(CFG.ATTACK_MULTI+2,room)end
for _,e in ipairs(list)do
if slots<=0 then break end
local isFocus=fcs and e.o==fcs.o
local mult=isFocus and CFG.FOCUS_OVERKILL or CFG.OVERKILL
local inStrike=strikeFor(e.o,now)
local dynN=dynTiles(e,fill,info,isFocus)
local costFrac=CFG.ATK_MAX_COST_FRAC+0.25*(e.mom or 0)
if(e.mom or 0)>=0.4 then
slots=math.max(slots,math.min(CFG.ATTACK_MULTI+CFG.MOM_SLOTS,room))
end
if inStrike then
mult=mult*CFG.STRIKE_OVERKILL_MUL
slots=math.max(slots,CFG.ATTACK_MULTI+CFG.STRIKE_EXTRA_SLOTS)
end
local pool=(FRONT and FRONT.o==e.o and FRONT.tiles)or e.etiles
local anchorTile
if inStrike and strike.tile then
local sx,sy=strike.tile%W,strike.tile//W
local rr2=((strike.r or CFG.BLAST_R)+12)^2
local near={}
for _,t in ipairs(pool)do
if dist2(t%W,t//W,sx,sy)<=rr2 then near[#near+1]=t end
end
if#near>0 then pool=near end
else
anchorTile=(FRONT and FRONT.seed and ownerAt(st,FRONT.seed)==e.o)and FRONT.seed
or pickAnchor(st,S,e,hx,hy,now)
if anchorTile then
local ax,ay=anchorTile%W,anchorTile//W
local rr2=CFG.ANCHOR_R^2
local near={}
for _,t in ipairs(pool)do
if dist2(t%W,t//W,ax,ay)<=rr2 then near[#near+1]=t end
end
if#near>0 then pool=near end
end
end
local cands,seenC={},{}
local function addC(t)
if t and not seenC[t]and(tileCd[t]or 0)<=now then
seenC[t]=true
cands[#cands+1]={t=t,c=tileLoss(st,S,e,t,math.max(avail*0.3,1))}
end
end
addC(anchorTile)
for _=1,CFG.ATK_SAMPLE*2 do
if#cands>=CFG.ATK_SAMPLE then break end
addC(pool[math.random(#pool)])
end
table.sort(cands,function(x,y)return x.c<y.c end)
local margin=math.max(CFG.ATK_MARGIN*(isFocus and 1.1 or 1)*(inStrike and CFG.STRIKE_OVERKILL_MUL or 1),1.05)
local floorT=maxT*math.max(CFG.STOP_FILL,DYN.stop)
if humanThreat then floorT=math.max(floorT,maxT*CFG.HUMAN_FLOOR,math.min(peerT*0.9,maxT*0.85))
elseif e.bot then floorT=math.max(CFG.STOP_FILL*maxT,math.min(floorT,maxT*CFG.BOT_FLOOR))end
if info and info.punishE==e then floorT=math.min(floorT,math.max(troops*0.2,maxT*0.03))end
floorT=math.max(floorT,(info and info.reserveT)or 0)
for _,cd in ipairs(cands)do
if slots<=0 then break end
local L,X=attackNeed(st,S,e,cd.t,avail*0.3,dynN)
local need=X*margin
if costLogN<8 then
costLogN+=1
log(("COST tile=%d loss/tile=%d x%d tile=%d kirim=%d pasukan=%d musuh=%d"):format(
cd.t,math.floor(L),CFG.ATK_TILES,math.floor(X),math.floor(need),math.floor(troops),math.floor(e.troops or 0)))
end
if need>avail or troops-need<floorT or need>troops*costFrac then break end
local ratio=math.clamp(need/math.max(troops,1),CFG.ATK_MIN_RATIO,CFG.ATK_MAX_RATIO)
local pushFloor=0
if fill>=0.3 and not(info and info.incoming)then
local P=e.P or 0
if P>=20 then pushFloor=0.35 elseif P>=8 then pushFloor=0.25
elseif P>=3 then pushFloor=0.15 elseif P>=1.8 then pushFloor=0.08 end
if(e.mom or 0)>=0.5 then pushFloor=pushFloor*1.3 end
if info and(info.danger or info.strong or info.rival)then pushFloor=pushFloor*0.5 end
end
ratio=math.min(math.max(ratio,pushFloor),CFG.ATK_MAX_RATIO)
local P0=e.P or 0
if e.bot then
if P0>=CFG.BOT_RATIO_HI then ratio=math.max(ratio,CFG.BOT_SEND_HI)
elseif P0>=CFG.BOT_RATIO_MID then ratio=math.max(ratio,CFG.BOT_SEND_MID)end
if info and info.incoming then ratio=math.min(ratio,CFG.BOT_SEND_MID)end
ratio=math.min(ratio,CFG.BOT_SEND_HI)
else
ratio=math.max(ratio,0.25)
if P0>=5 then ratio=math.max(ratio,0.5)end
ratio=math.min(ratio,CFG.HUMAN_MAX_SEND)
end
local capT=math.max(need*CFG.SEND_CAP_MULT,(e.troops or 0)*CFG.OVERKILL*1.5)
local capR=math.max(capT/math.max(troops,1),CFG.ATK_MIN_RATIO)
if ratio>capR then ratio=capR end
local sent=math.min(ratio*troops,math.max(troops-floorT,0))
ratio=sent/math.max(troops,1)
if ratio<CFG.ATK_MIN_RATIO then break end
if not e.bot and ratio<0.15 then break end
need=sent
tileCd[cd.t]=now+CFG.TILE_CD
out[#out+1]={tile=cd.t,kind="attack",ratio=ratio,owner=e.o}
if sizeLogN<25 then
sizeLogN+=1
log(("ATKSIZE owner %d N=%d ratio=%.2f mom=%.2f fill=%.2f P=%.2f"):format(e.o,dynN,ratio,e.mom or 0,fill,e.P or 0))
end
avail-=need
troops-=need
slots-=1
end
end
return out,avail
end
local boatTargets,lastBoatScan={},0
local boatReach=1
local function cellKey(t)
return((t//W)//CFG.BOAT_CELL)*1000+((t%W)//CFG.BOAT_CELL)
end
local function coastalStarts(st,mine,maxN)
local border=ctx.borders and ctx.borders.border
local out={}
if not border then return out end
for _,t in ipairs(borderList(border,4000))do
if ownerAt(st,t)==mine and isLand(st,t)and waterAdj(st,t)then
out[#out+1]=t
if#out>=maxN then break end
end
end
return out
end
local function floodWaterTargets(st,mine,starts)
local visited,dist,queue,out={},{},{},{}
local startSet={}
for _,t in ipairs(starts)do
if not visited[t]then
visited[t]=true;dist[t]=0;startSet[t]=true
queue[#queue+1]=t
end
end
local head,steps=1,0
while head<=#queue and steps<CFG.BOAT_FLOOD_STEPS*boatReach do
local t=queue[head];head+=1;steps+=1
local x=t%W
local dcur=dist[t]or 0
local fromStart=startSet[t]
for i=1,4 do
local nt=t+DIRS4[i]
if nt>0 and nt<W*H and not visited[nt]then
local nx=nt%W
if math.abs(nx-x)<=1 then
if isLand(st,nt)then
if not fromStart then
visited[nt]=true
dist[nt]=dcur+1
local o=ownerAt(st,nt)
if o~=mine then out[#out+1]={tile=nt,owner=o,dist=dcur+1}end
end
else
visited[nt]=true
dist[nt]=dcur+1
queue[#queue+1]=nt
end
end
end
end
end
table.sort(out,function(a,b)return a.dist<b.dist end)
return out
end
local function scanBoatTargets(st,m)
local mine=st.local_owner
local starts=coastalStarts(st,mine,CFG.BOAT_STARTS)
boatStartsN=#starts
if#starts==0 then boatTargets={};return end
local raw=floodWaterTargets(st,mine,starts)
local out={}
for _,r in ipairs(raw)do
if#out>=800 or r.dist>CFG.BOAT_MAX_DIST*boatReach then break end
if r.owner==0 then
if not isFallout(st,r.tile)then
out[#out+1]={tile=r.tile,kind="expand",dist=r.dist}
end
else
local oi=st.owners[r.owner]
if oi and oi.alive and not allied(st,r.owner)then
out[#out+1]={tile=r.tile,kind="attack",dist=r.dist}
end
end
end
boatTargets=out
log("boat scan: "..#out.." target (<="..(CFG.BOAT_MAX_DIST*boatReach).." langkah, reach x"..boatReach..") dari "..#starts.." titik pantai")
if#out==0 then
boatReach=math.min(boatReach+1,CFG.BOAT_REACH_MAX)
elseif#out>300 and boatReach>1 then
boatReach-=1
end
end
local function planBoats(st,m,info,now,availLeft,fcs,focusTile,landDone)
local out={}
local troops=m.troops or 0
local fillB=troops/math.max(m.max_troops or 1,1)
if(info.rival or info.brutalAny)and fillB<0.6 then
if now-(RUN.boatLogAt or 0)>15 then RUN.boatLogAt=now;log(("BOAT batal: fill=%.2f<0.6 (rival/brutal)"):format(fillB))end
return out end
local mine=st.local_owner
local frac=info.incoming and CFG.BOAT_RESERVE_FRAC*0.7 or CFG.BOAT_RESERVE_FRAC
local avail=math.min(availLeft or troops,troops*frac)
avail=math.min(avail,math.max(troops-(info.reserveT or 0),0))
local slots=CFG.BOAT_MULTI
if false and fcs and focusTile and fcs.ratio>=CFG.FLATTEN_RATIO and(tileCd[focusTile]or 0)<=now then
local oi=st.owners[fcs.o]
if oi and oi.alive and ownerAt(st,focusTile)==fcs.o then
local fa=troops*(info.incoming and 0.6 or CFG.FOCUS_BOAT_FRAC)
local mult=CFG.FOCUS_OVERKILL*(strikeFor(fcs.o,now)and CFG.STRIKE_OVERKILL_MUL or 1)
local r=pickRatio(fa,(oi.troops or 0)*mult)
if r and r<=CFG.FOCUS_BOAT_MAX_RATIO then
tileCd[focusTile]=now+CFG.TILE_CD
out[#out+1]={tile=focusTile,ratio=r,kind="focus"}
avail=math.max(avail-r*troops,0)
slots-=1
end
end
end
for pass=1,2 do
local want=pass==1 and"expand"or"attack"
if(want=="attack"and fillB>=CFG.BOAT_ATTACK_MIN_FILL)or(want=="expand"and landDone)then
for _,bt in ipairs(boatTargets)do
if slots<=0 then break end
if bt.kind==want and(tileCd[bt.tile]or 0)<=now and isLand(st,bt.tile)then
local ck=cellKey(bt.tile)
if(cellCd[ck]or 0)<=now then
local o=ownerAt(st,bt.tile)
local ratio
if o==mine or o<0 or(o~=0 and allied(st,o))then
ratio=nil
elseif o==0 then
if avail>0 then ratio=0.15 end
else
local oi=st.owners[o]
if oi and oi.alive then
ratio=pickRatio(avail,(oi.troops or 0)*CFG.OVERKILL,CFG.BOAT_ATTACK_MAX)
end
end
if ratio then
tileCd[bt.tile]=now+CFG.TILE_CD
cellCd[ck]=now+CFG.BOAT_CELL_CD
out[#out+1]={tile=bt.tile,ratio=ratio,kind=(o==0)and"expand"or"attack"}
avail=avail*(1-ratio)
slots-=1
end
end
end
end
end
end
return out
end
local function planDefense(st,m,probe,info,defs,maxK)
local Rd=defR()
local Rd2=Rd*Rd
local pts,totalW={},0
local byOwner={}
for o,w in pairs(info.hostile)do
local p=probe[o]
if p then
for _,pr in ipairs(p.pairs)do
local wk=w*(pr.k<=1 and 1 or math.max(0.2,1-(pr.k-1)/(maxK+2)))
pts[#pts+1]={x=pr.b%W,y=pr.b//W,ex=pr.e%W,ey=pr.e//W,w=wk,o=o}
totalW+=wk
byOwner[o]=(byOwner[o]or 0)+wk
end
end
end
if#pts==0 then return nil end
local unc,U={},0
for _,p in ipairs(pts)do
local cov=false
for _,s in ipairs(defs)do
local sx,sy=s.tile%W,s.tile//W
if(sx-p.x)^2+(sy-p.y)^2<Rd2 then cov=true break end
end
if not cov then unc[#unc+1]=p;U+=p.w end
end
if#unc==0 or U<totalW*CFG.DEF_MIN_FRAC then return nil end
table.sort(unc,function(a,b)return a.w>b.w end)
local minDist=(R().STRUCT_MIN_DIST or 11)+1
local found,seenT={},{}
for i=1,math.min(#unc,14)do
local p=unc[i]
local vx,vy=p.x-p.ex,p.y-p.ey
local len=math.max(math.sqrt(vx*vx+vy*vy),1)
vx,vy=vx/len,vy/len
for _,f in ipairs({0,0.25,CFG.DEF_INWARD,0.55})do
local cx=math.floor(p.x+vx*Rd*f+0.5)
local cy=math.floor(p.y+vy*Rd*f+0.5)
if cx>8 and cx<W-8 and cy>8 and cy<H-8 then
local ct=cy*W+cx
if not seenT[ct]and ownerAt(st,ct)==st.local_owner and isLand(st,ct)then
seenT[ct]=true
local free=true
for _,s in pairs(st.structures)do
local sx,sy=s.tile%W,s.tile//W
if math.abs(sx-cx)+math.abs(sy-cy)<minDist then free=false break end
end
if free then
local sc=0
for _,q in ipairs(unc)do
if(q.x-cx)^2+(q.y-cy)^2<Rd2 then sc+=q.w end
end
sc=sc*(1-0.05*math.abs(f-CFG.DEF_INWARD))
found[#found+1]={tile=ct,score=sc,owner=p.o}
end
end
end
end
end
if#found==0 then return nil end
table.sort(found,function(a,b)return a.score>b.score end)
local cs={}
for i=1,math.min(#found,5)do cs[i]=found[i]end
local urgent=info.incoming or info.danger or info.rival~=nil or info.brutalAny
return{cands=cs,urgent=urgent and true or false,frac=U/totalW,owner=cs[1].owner}
end
local lastNuke,nukePend,nukeFails,nukeOff,nukeOffAt=0,nil,0,false,0
local function blastValue(S,nb,center,radius,focusO,fill)
local cx,cy=center.tile%W,center.tile//W
local R2=radius*radius
local safe2=(radius+6)^2
for _,s in ipairs(S.own)do
local sx,sy=s.tile%W,s.tile//W
if(sx-cx)^2+(sy-cy)^2<=safe2 then return 0,0 end
end
local v=0
local Rd2=defR()^2
for _,f in ipairs(S.foes)do
local fx,fy=f.tile%W,f.tile//W
if(fx-cx)^2+(fy-cy)^2<=R2 then
local base=(VALUE[f.kind]or 100000)*(f.kind=="silo"and 1.5 or f.kind=="factory"and 1.6 or 1)
if f.kind=="defense"and waterNear(ctx.state,f.tile)then base=base*1.8 end
if focusO and f.owner==focusO and(f.kind=="sam"or f.kind=="defense")then
base=base*1.5
if f.kind=="defense"and nb[focusO]then
local n=0
for _,et in ipairs(nb[focusO].etiles)do
if(et%W-fx)^2+(et//W-fy)^2<Rd2 then n+=1 end
end
base=base+n*CFG.TILE_VALUE*2
end
if fill<CFG.OPENER_FILL then base=base*0.4 end
end
v+=base
end
end
if center.inv then
local foe,own,tot=discStats(ctx.state,cx,cy,radius)
if tot>0 and own/tot>CFG.INVADE_OWN_FRAC then return 0,0 end
v+=foe*(CFG.DISC_STEP^2)*CFG.TILE_VALUE
end
local sams=0
local sr=samR()
for _,sm in ipairs(S.foeSam)do
local sx,sy=sm.tile%W,sm.tile//W
if(sx-cx)^2+(sy-cy)^2<=sr^2 then sams+=1 end
end
v=v*(0.3^math.min(sams,3))
if nb[center.owner]then v=v*1.3 end
if focusO and center.owner==focusO then v=v*1.4 end
return v,sams
end
local DIRS8={{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,-1},{1,-1},{-1,1}}
local function invasionCands(st,nb,fcs)
local out={}
local rAtom,rMax=nil,0
for nm,kd in pairs(NUKE_KINDS)do
if kd.idx~=2 then
if nm=="atom"then rAtom=kd.r end
if kd.r>rMax then rMax=kd.r end
end
end
rAtom=rAtom or rMax
if not rAtom or rAtom<=0 then return out end
local depths={rAtom*0.9}
if rMax>rAtom*1.2 then depths[#depths+1]=rMax*0.9 end
local want={}
if fcs and nb[fcs.o]then
want[1]=nb[fcs.o]
else
for _,e in pairs(nb)do if e then want[#want+1]=e end end
end
if#want==0 then return out end
local per=math.max(1,math.ceil(CFG.INVADE_CANDS/#want))
local myT=(st.owners[st.local_owner]and st.owners[st.local_owner].troops)or 0
for _,e in ipairs(want)do
local eT=(st.owners[e.o]and st.owners[e.o].troops)or 0
if#e.etiles>0 and eT>=myT*0.05 then
for _=1,per do
local t=e.etiles[math.random(#e.etiles)]
local x,y=t%W,t//W
for _=1,CFG.INVADE_DIRS do
local d=DIRS8[math.random(#DIRS8)]
local k=(d[1]~=0 and d[2]~=0)and 0.7 or 1
for _,len in ipairs(depths)do
local cx=math.floor(x+d[1]*len*k)
local cy=math.floor(y+d[2]*len*k)
if cx>2 and cx<W-3 and cy>2 and cy<H-3 then
local ct=cy*W+cx
if ownerAt(st,ct)==e.o and isLand(st,ct)then
out[#out+1]={tile=ct,owner=e.o,inv=true}
end
end
end
end
end
end
end
return out
end
local function bestNukeChoice(S,nb,cs,hx,hy,roiMul,rangeMul,wealth,focusO,gold,res,fill,inc)
local md=CFG.NUKE_MAX_DIST*rangeMul
local maxD2=md*md
local lambda=wealth>=8 and 0 or wealth>=3 and 0.3 or 1
local best={}
local nowB=os.clock()
local bad=RUN.nukeBad or{}
for i=#bad,1,-1 do if bad[i].till<nowB then table.remove(bad,i)end end
for _,f in ipairs(cs)do
local d2=dist2(f.tile%W,f.tile//W,hx,hy)
local blocked=false
for _,bd in ipairs(bad)do
if dist2(f.tile%W,f.tile//W,bd.x,bd.y)<=22*22 then blocked=true break end
end
if d2<=maxD2 and not blocked then
for k,kd in pairs(NUKE_KINDS)do
local v,sams=blastValue(S,nb,f,kd.r,focusO,fill)
local b=best[k]
if v>0 and(not b or v>b.v or(v==b.v and d2<b.d2))then
best[k]={f=f,v=v,d2=d2,sams=sams}
end
end
end
end
local pick,hold
local hb=best.hydrogen
if hb and NUKE_KINDS.hydrogen then
local hp=nukePrice("hydrogen")
local needH=hp*1.05+res
local ab=best.atom
local an=ab and(ab.v-nukePrice("atom")*lambda)or 0
local hn=hb.v-hp*lambda
if gold<needH and hb.v/hp>=NUKE_KINDS.hydrogen.roi*roiMul and hn>math.max(an,1)*1.5
and(inc or 0)*45>=needH-gold then
return nil,needH
end
end
for k,b in pairs(best)do
local price=nukePrice(k)
if b.v/price>=NUKE_KINDS[k].roi*roiMul then
local need=price*1.05+res
if gold>=need then
local net=b.v-price*lambda
if not pick or net>pick.net then
pick={kind=k,f=b.f,v=b.v,price=price,net=net,sams=b.sams or 0}
end
elseif not hold or need<hold then
hold=need
end
end
end
return pick,hold
end
local function nukeStep(st,m,S,nb,fcs)
local now,gold=os.clock(),m.gold or 0
if nukeOff and now-nukeOffAt>120 then
nukeOff=false;nukeFails=0
log("nuke diaktifkan lagi (retry)")
end
if nukeOff or S.c.silo<1 then return 0 end
if nukePend and now-nukePend.at>3 then
local dtp=math.max(now-nukePend.at,0)
local spentReal=nukePend.gold-gold+incomeRate(m)*dtp*0.8
if spentReal>=nukePend.price*0.5 then
nukeFails=0
log(("BOM(%s) x%d kena tile=%d nilai~%d%s"):format(nukePend.kind,nukePend.n,nukePend.tile,
math.floor(nukePend.value),nukePend.inv and" [INVASI]"or""))
if nukePend.owner then
strike={owner=nukePend.owner,till=now+CFG.STRIKE_WINDOW,
tile=nukePend.tile,r=nukePend.r}
log("jendela serang ke owner "..nukePend.owner.." "..CFG.STRIKE_WINDOW.." detik (fokus zona ledak)")
end
else
nukeFails+=1
noteSpend(-nukePend.price)
log("bom gagal ("..nukeFails..") tile="..nukePend.tile)
RUN.nukeBad=RUN.nukeBad or{}
RUN.nukeBad[#RUN.nukeBad+1]={x=nukePend.tile%W,y=nukePend.tile//W,till=now+90}
if nukeFails>=4 then
nukeOff=true;nukeOffAt=now-90
log("nuke dimatikan 30 detik: 4x gagal beruntun")
end
end
nukePend=nil
end
if nukePend then return nukePend.price end
local wealth=wealthOf(m)
local roiMul=(wealth>=10 and 0.4 or wealth>=5 and 0.6 or wealth>=3 and 0.8 or 1)*(CFG.HARDCORE and 0.7 or 1)
local rangeMul=1
local res=CFG.NUKE_RESERVE*(wealth>=5 and 0.3 or 1)
local fill=(m.troops or 0)/math.max(m.max_troops or 1,1)
local cs=S.foes
if fcs and wealth<4 then
local fl={}
for _,f in ipairs(S.foes)do
if f.owner==fcs.o then fl[#fl+1]=f end
end
if#fl>0 then cs=fl end
end
if fill>=CFG.INVADE_MIN_FILL then
local ic=invasionCands(st,nb,fcs)
if#ic>0 then
local merged={}
for _,f in ipairs(cs)do merged[#merged+1]=f end
for _,f in ipairs(ic)do merged[#merged+1]=f end
cs=merged
end
end
local hx,hy=homeCenter(m)
local pick,hold=bestNukeChoice(S,nb,cs,hx,hy,roiMul,rangeMul,wealth,
fcs and fcs.o or nil,gold,res,fill,incomeRate(m))
if not pick and hold and hold>gold then
if now-(RUN.saveLogAt or 0)>10 then
RUN.saveLogAt=now
log(("NABUNG hydrogen: gold=%d butuh=%d (atom ditahan, target bernilai tinggi)"):format(gold,hold))
end
end
if not pick then return hold or 0 end
local want=pick.price*1.05+res
local ready=readyMissiles(st,S)
if ready<=0 or now-lastNuke<CFG.NUKE_COOLDOWN then return want end
local n=1
if pick.sams>0 then
local afford=math.max(1,math.floor((gold-res)/(pick.price*1.05)))
n=math.min(ready,pick.sams+1,afford)
end
if pick.kind=="atom"then
fire(NUKE_INTENT(pick.f.tile,"atom",n))
else
for _=1,n do fire(NUKE_INTENT(pick.f.tile,pick.kind))end
end
lastNuke=now
noteSpend(pick.price*n)
local kd=NUKE_KINDS[pick.kind]
nukePend={at=now,gold=gold,tile=pick.f.tile,value=pick.v,kind=pick.kind,
price=pick.price*n,owner=pick.f.owner,n=n,inv=pick.f.inv,
r=kd and kd.r or CFG.BLAST_R}
log(("BOM(%s) x%d tile=%d nilai~%d harga=%d wealth=%.1f ready=%d sam=%d owner=%s%s"):format(
pick.kind,n,pick.f.tile,pick.v,pick.price,wealth,ready,pick.sams,tostring(pick.f.owner),
pick.f.inv and" [INVASI]"or""))
return want
end
local POS={
HALF=90,
MIN_NEED=0.12,
URGENT=0.6,
EXISTENTIAL=0.9,
STR_LO=1.0,
STR_HI=2.6,
DOM_LO=1.5,
DOM_HI=4.0,
DOM_CUT=0.7,
DOM_CUT_BR=0.5,
LOSS_FULL=0.03,
LOSS_WIN=30,
RISE=0.6,
FALL=0.08,
}
local posture={need=0,hist={},logAt=0,logNeed=0,assault=false,assaultUntil=0,aggr=0,aggrAt=nil}
getgenv().AF_POSTURE=posture
local ledger={def=0,eco=0,at=nil}
local ECO_KEYS={city=true,port=true,factory=true}
local function ramp(x,lo,hi)
if hi<=lo then return x>=hi and 1 or 0 end
return math.clamp((x-lo)/(hi-lo),0,1)
end
local function ledgerTick(now)
if not ledger.at then ledger.at=now return end
local dt=now-ledger.at
if dt>0 then
local k=0.5^(dt/POS.HALF)
ledger.def*=k
ledger.eco*=k
ledger.at=now
end
end
local function ledgerAdd(real,amt)
if real=="defense"then
ledger.def=math.max(ledger.def+amt,0)
elseif ECO_KEYS[real]then
ledger.eco=math.max(ledger.eco+amt,0)
end
end
local function postureStep(st,m,nb,info,probe,maxK,now)
local mine=st.local_owner
local mt=math.max(m.troops or 1,1)
local incT=0
if type(st.attacks)=="table"then
for _,a in pairs(st.attacks)do
if type(a)=="table"and not a.dead and a.target==mine and a.attacker~=mine
and type(a.troops)=="number"then
incT+=a.troops
end
end
end
local nInc=ramp(incT/mt,0.05,0.5)
if info.incoming and nInc<0.4 then nInc=0.4 end
local nStr=0
for o,e in pairs(nb)do
if e then
local f=0.4+0.6*ramp(e.contacts or 0,3,40)
nStr=math.max(nStr,ramp((e.troops or 0)/mt,POS.STR_LO,POS.STR_HI)*f)
local it=intel[o]
if it and it.gT and it.gT>0 then
local projT=it.gT*CFG.BRUTAL_HORIZON
local growThreat=ramp(projT/mt,0.3,1.0)*f
nStr=math.max(nStr,growThreat)
end
end
end
for o,p in pairs(probe)do
if not nb[o]then
local oi=st.owners[o]
if oi and oi.alive then
local prox=math.clamp(1-(p.gap-1)/math.max(maxK,1),0,1)
nStr=math.max(nStr,ramp((oi.troops or 0)/mt,POS.STR_LO,POS.STR_HI)*0.5*prox)
end
end
end
if info.rival then nStr=math.max(nStr,0.4)end
local h=posture.hist
h[#h+1]={t=now,tiles=m.tiles or 0}
while#h>1 and now-h[2].t>=POS.LOSS_WIN do table.remove(h,1)end
local old=h[1].tiles
local lossFrac=old>0 and math.max(old-(m.tiles or 0),0)/old or 0
if incT/mt>=CFG.DEF_ASSAULT_INC or lossFrac>=CFG.DEF_ASSAULT_LOSS then
if not posture.assault then
log(("DEFENSE DIBLOK: lagi diserang (masuk=%.0f%% pasukan, tanah hilang=%.1f%%) %ds"):format(
incT/mt*100,lossFrac*100,CFG.DEF_ASSAULT_HOLD))
end
posture.assaultUntil=now+CFG.DEF_ASSAULT_HOLD
end
posture.assault=posture.assaultUntil>now
local taken=strike and not strike.tile and strike.till>now
local nLoss=ramp(lossFrac,0,POS.LOSS_FULL)*(taken and 1 or 0.35)
local nBr=info.brutalAny and 0.5 or 0
local strongest=info.strongest or 0
local dom=strongest<=0 and 1 or ramp(mt/strongest,POS.DOM_LO,POS.DOM_HI)
local dt=posture.aggrAt and math.max(now-posture.aggrAt,0)or 0
posture.aggrAt=now
posture.aggr=(posture.aggr or 0)*0.5^(dt/45)
if incT/mt>=0.02 or lossFrac>0 then posture.aggr=1 end
local aggrGate=0.35+0.65*posture.aggr
nStr=nStr*aggrGate
local raw=math.max(nInc,nLoss,nStr*(1-POS.DOM_CUT*dom),nBr*(1-POS.DOM_CUT_BR*dom))
local a=raw>posture.need and POS.RISE or POS.FALL
posture.need=posture.need+(raw-posture.need)*a
if now-posture.logAt>20 or math.abs(posture.need-posture.logNeed)>0.2 then
posture.logAt,posture.logNeed=now,posture.need
local share=ledger.def/math.max(ledger.def+ledger.eco,1)
log(("POSTURE need=%.2f [serang=%.2f loss=%.2f kuat=%.2f(gate=%.2f) brutal=%.2f] dom=%.2f | jatah defense=%.0f%% -> %s"):format(
posture.need,nInc,nLoss,nStr,aggrGate,nBr,dom,share*100,
posture.need>=POS.URGENT and"DEFENSE DULU"
or(posture.need>=POS.MIN_NEED and"SEIMBANG"or"FOKUS INCOME")))
end
return posture.need
end
local learnedDefCap,learnedDefAt=nil,0
local lastBuild,fails,pending={},{},nil
local warshipOff=false
function RUN.setWarship(v)warshipOff=not v end
function RUN.getWarship()return not warshipOff end
local lastQuoteLog=0
local playStart=nil
local REAL={def="defense",siloup="silo",samup="sam",cityup="city"}
local function samSpot(st,S)
local R2=samR()
local eco={}
local WT={city=2,factory=3,silo=3,port=1}
for _,o in ipairs(S.own)do
local w=WT[o.kind]
if w then eco[#eco+1]={x=o.tile%W,y=o.tile//W,w=w}end
end
if#eco==0 then return nil end
local sams={}
for _,t in ipairs(S.tiles.sam or{})do sams[#sams+1]={x=t%W,y=t//W}end
local cov2=(R2*0.85)^2
local unc={}
for _,a in ipairs(eco)do
local covered=false
for _,sm in ipairs(sams)do
if dist2(a.x,a.y,sm.x,sm.y)<cov2 then covered=true break end
end
if not covered then unc[#unc+1]=a end
end
if#unc==0 then return nil end
local best,bestV
for _,a in ipairs(unc)do
local v=0
for _,b in ipairs(unc)do
if dist2(a.x,a.y,b.x,b.y)<=(R2*0.8)^2 then v+=b.w end
end
if not bestV or v>bestV then best,bestV=a,v end
end
local sx,sy,sw=0,0,0
for _,b in ipairs(unc)do
if dist2(best.x,best.y,b.x,b.y)<=(R2*0.8)^2 then
sx+=b.x*b.w;sy+=b.y*b.w;sw+=b.w
end
end
local cx,cy=sx/sw,sy/sw
local bt,bs
for _=1,500 do
local x=math.floor(cx+(math.random()*2-1)*math.max(5,R2*0.25))
local y=math.floor(cy+(math.random()*2-1)*math.max(5,R2*0.25))
if x>8 and x<W-8 and y>8 and y<H-8 then
local t=y*W+x
if ownerAt(st,t)==st.local_owner and isLand(st,t)and spaced(st,t)then
local sc=-dist2(x,y,cx,cy)
if interior(st,t)then sc+=R2*R2*0.15 end
if not bs or sc>bs then bt,bs=t,sc end
end
end
end
return bt
end
local function upTileOf(S,k)
local l=S.tiles[k]
if l and#l>0 then return l[math.random(#l)]end
end
RUN.mix={at=0,list={},logAt=0}
function RUN.mimicList(st,m,c)
local now=os.clock()
local M=RUN.mix
if now-M.at<4 then return M.list end
M.at=now
M.list={}
local per={}
for _,sv in pairs(st.structures)do
local o=sv.owner
if o and o~=0 and o~=st.local_owner then
local k=kindOf(sv)
if k then
local t=per[o]
if not t then t={};per[o]=t end
t[k]=(t[k]or 0)+1
end
end
end
local rows={}
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=0 and o~=st.local_owner and type(oi)=="table"and oi.alive~=false and oi.spawned~=false and oi.kind~=KIND_TRIBE and type(oi.tiles)=="number"then
rows[#rows+1]={o=o,tiles=oi.tiles}
end
end
table.sort(rows,function(a,b)return a.tiles>b.tiles end)
local K=math.min(3,#rows)
if K<1 then return M.list end
local KEYS={"city","port","factory","silo","sam"}
local BIAS={silo=0.03,sam=0.02,factory=0.01,city=0,port=-0.01}
local avg,tl={},0
for i=1,K do
local r=rows[i]
tl+=r.tiles
local t=per[r.o]or{}
for _,k in ipairs(KEYS)do avg[k]=(avg[k]or 0)+(t[k]or 0)/K end
end
local ratio=math.clamp((m.tiles or 1)/math.max(tl/K,1),0.4,1.6)
local cand={}
for _,k in ipairs(KEYS)do
local tgt=math.floor((avg[k]or 0)*ratio+0.5)
local have=c[k]or 0
if tgt>have then cand[#cand+1]={k=k,f=(tgt-have)/tgt+BIAS[k],tgt=tgt,have=have}end
end
table.sort(cand,function(a,b)return a.f>b.f end)
for _,x in ipairs(cand)do M.list[#M.list+1]=x.k end
if now-M.logAt>20 then
M.logAt=now
local parts={}
for _,x in ipairs(cand)do parts[#parts+1]=("%s %d/%d"):format(x.k,x.have,x.tgt)end
log(("MIMIC ikut top%d (skala=%.2f) kurang: %s"):format(K,ratio,#parts>0 and table.concat(parts," ")or"-"))
end
return M.list
end
local function buildStep(st,m,S,nb,info,reserve,probe,maxK)
local c,lv,defs=S.c,S.lv,S.defs
local now=os.clock()
ledgerTick(now)
postureStep(st,m,nb,info,probe,maxK,now)
if learnedDefCap and now-learnedDefAt>180 then learnedDefCap=nil end
if pending and now-pending.at>2.5 then
local k=pending.kind
if(c[k]or 0)<=pending.before and(lv[k]or 0)<=pending.lvbefore then
fails[pending.key]=(fails[pending.key]or 0)+1
noteSpend(-(pending.need or 0))
ledgerAdd(pending.kind,-(pending.need or 0))
log(("build %s gagal (%d) tile=%d"):format(pending.key,fails[pending.key],pending.tile))
if pending.key=="def"and fails[pending.key]>=3 then
learnedDefCap=c.defense;learnedDefAt=now
log("defense kena limit di "..c.defense)
end
if fails[pending.key]>=5 then
lastBuild[pending.key]=now+40
fails[pending.key]=0
end
else
fails[pending.key]=0
local gained=(lv[k]or 0)-pending.lvbefore
log(("build %s OK, gold=%s level+%d (minta %d)"):format(pending.key,tostring(m.gold),math.max(gained,0),pending.amt or 1))
end
pending=nil
end
if pending then return end
local gold=m.gold or 0
local wealth=wealthOf(m)
local income=incomeRate(m)
local need=posture.need
local defUrgent=need>=POS.URGENT
local existentialAssault=need>=POS.EXISTENTIAL
local defShare=ledger.def/math.max(ledger.def+ledger.eco,1)
local defWanted=need>=(CFG.HARDCORE and 0.7 or POS.MIN_NEED)and(defUrgent or defShare<need)and(existentialAssault or not posture.assault)and not(info.dominant and not defUrgent)and c.city>=CFG.DEF_MIN_CITY
local pressure=need>=0.3 or info.incoming
local rsv=reserve*(wealth>=6 and 0 or wealth>=3 and 0.4 or 1)
if(CFG.HARDCORE and existentialAssault or(not CFG.HARDCORE and pressure))or lv.city<CFG.CITY_SAFE_N then rsv=0 end
local facCap=math.max(1,math.min(10,math.floor(lv.city*(c.port>=1 and 0.33 or 0.75))))
local portCap=math.min(6,math.floor(lv.city*0.75))
local siloCap=math.min(4,1+math.floor(wealth/3)+(c.city>=8 and 1 or 0))
local siloLv=math.min(CFG.SILO_LV_MAX,2+math.floor(wealth/3))
local samCap=math.min(14,CFG.SAM_CAP+math.floor(wealth/2)+math.floor(c.city/4))
local samLv=math.min(8,samCap+1+math.floor(wealth/3))
local cityCap=wealth>=2 and CFG.CITY_CAP_RICH
or math.min(CFG.CITY_CAP,3+math.floor((m.tiles or 0)/CFG.CITY_PER_TILES))
local defBase=2+c.city*2+(info.rival and 2 or 0)
local defCap=math.min(CFG.MAX_DEFENSE,learnedDefCap or 99,
math.max(1,math.floor(defBase*(0.4+0.6*need))))
local spot
if defWanted and next(info.hostile)~=nil and c.city>=1 and c.defense<defCap then
spot=planDefense(st,m,probe,info,defs,maxK)
if spot then spot.urgent=defUrgent end
end
local siloCost=cost("silo",lv.silo or 0)
local siloTarget=c.city>=CFG.SILO_MIN_CITY and(1+math.floor((c.city-CFG.SILO_MIN_CITY)/5))or 0
local siloWant=c.silo<math.min(siloTarget,siloCap)
local order={}
local function add(key,ess)order[#order+1]={key=key,ess=ess,pri=#order+1,seq=#order+1}end
if c.city<1 then add("city",true)end
if c.factory<1 and c.city>=1 then add("factory",true)end
if info.foeSilo>0 and c.sam<1 and c.city>=(CFG.HARDCORE and 4 or 3)then
add("sam",true)
elseif info.foeSilo>0 and c.city>=(CFG.HARDCORE and 4 or 6)and c.sam<math.min(CFG.HARDCORE and 4 or 10,1+math.floor(c.city/4)+(CFG.HARDCORE and math.floor(info.foeSilo/4)or 0))
and(CFG.HARDCORE or not existentialAssault)then
add("sam",true)
end
if c.city>=1 and c.city<(CFG.HARDCORE and 4 or 6)and not info.incoming then add("city",true)end
if spot and existentialAssault then add("def",true)end
if c.city<3 then add("city",true)end
if c.factory<1 and c.city>=2 then add("factory",true)end
if c.port<1 and c.city>=3 then add("port",false)end
if c.city<(CFG.HARDCORE and 4 or 6)then add("city",true)end
if c.factory<2 and c.city>=4 then add("factory",true)end
if CFG.HARDCORE and c.silo<1 and c.city>=4 then add("silo",true)end
if CFG.HARDCORE and c.city>=3 and c.factory>=1 then
for _,pk in ipairs(RUN.mimicList(st,m,c))do
if(lastBuild[pk]or 0)<=now then add(pk,true)break end
end
end
if c.silo<1 and c.city>=CFG.SILO_MIN_CITY and(CFG.HARDCORE and income*120>=siloCost or(#boatTargets==0 and income*60>=siloCost))then add("silo",true)end
if spot then add("def",false)end
if info.foeSilo>0 and c.sam<samCap and c.city>=3 then add("sam",false)end
if c.city<cityCap then add("city",false)end
if c.factory<facCap then add("factory",false)end
if c.port<portCap and c.city>=3 then add("port",false)end
if siloWant then add("silo",false)end
if c.silo>=1 and lv.silo<siloLv and c.city>=CFG.SILO_MIN_CITY then add("siloup",false)end
if info.foeSilo>0 and c.sam>=1 and lv.sam<samLv and c.city>=3 then add("samup",false)end
if not warshipOff and#boatTargets>0 and c.port>=1 and c.warship<CFG.WARSHIP_CAP then add("warship",false)end
if lv.city<CFG.CITY_LV_CAP and(c.city>=cityCap or(CFG.HARDCORE and c.city>=3 and gold>math.max(income*45,300000)))then add("cityup",false)end
table.sort(order,function(a,b)
if a.pri~=b.pri then return a.pri<b.pri end
return a.seq<b.seq
end)
local blockedEss=false
for _,o in ipairs(order)do
local key=o.key
local skip=blockedEss and(CFG.HARDCORE and not(key=="def"and existentialAssault)or(not CFG.HARDCORE and(key~="def"or not defUrgent)and key~="port"and key~="factory"and key~="warship"))
if not skip and(lastBuild[key]or 0)<=now then
local real=REAL[key]or key
local cnt=(real=="port"or real=="factory")and((lv.port or 0)+(lv.factory or 0))
or(lv[real]or c[real]or 0)
local need0=cost(real,cnt)
local avail=gold-(o.ess and 0 or key=="city"and 0 or rsv)
if avail>=need0*1.1 then
local t
if key=="sam"then
t=samSpot(st,S)
if not t and c.sam<1 then
t=sampleOwn(st,m,function(t)return interior(st,t)end)
or sampleOwn(st,m,function()return true end)
end
if not t then lastBuild[key]=now+8 end
elseif key=="city"or key=="factory"or key=="silo"then
t=sampleOwn(st,m,function(t)return interior(st,t)end)
or sampleOwn(st,m,function()return true end)
if not t then lastBuild[key]=now+5 end
elseif key=="port"or key=="warship"then
t=sampleOwn(st,m,function(t)return waterNear(st,t)end)
if not t then lastBuild[key]=now+30 end
elseif key=="siloup"or key=="samup"or key=="cityup"then
t=upTileOf(S,real)
if not t then lastBuild[key]=now+30 end
else
for _,cd in ipairs(spot.cands)do
local okOwn=ownerAt(st,cd.tile)==st.local_owner and isLand(st,cd.tile)and not isFallout(st,cd.tile)
if okOwn then
local q0=quote(real,cd.tile)
if not(q0 and q0.ok==false and type(q0.reason)=="string"and q0.reason~="")then
t=cd.tile
break
end
end
end
if not t then lastBuild[key]=now+4 end
end
if t then
local go=true
local q=quote(real,t)
if q then
if q.ok==false and type(q.reason)=="string"and q.reason~=""then
go=false
lastBuild[key]=now+3
if now-lastQuoteLog>5 then
lastQuoteLog=now
log(("placement ditolak %s tile=%d: %s"):format(key,t,q.reason))
end
elseif type(q.cost)=="number"and q.cost>0 then
need0=q.cost
if avail<need0*1.05 then go=false end
end
end
if go then
local amt
if key=="siloup"or key=="samup"or key=="cityup"then
local capLv=key=="siloup"and siloLv or key=="samup"and samLv or CFG.CITY_LV_CAP
local room=math.max(capLv-(lv[real]or 0),1)
local budget=avail-need0
local n=1
while n<math.min(CFG.UP_BATCH,room)do
local nc=cost(real,cnt+n)
if budget>=nc*1.1 then budget-=nc;n+=1 else break end
end
if n>1 then amt=n end
end
fire({type="build",kind=real,tile=t,amount=amt})
local spend=need0*(amt or 1)
noteSpend(spend)
ledgerAdd(real,spend)
pending={key=key,kind=real,tile=t,at=now,amt=amt,need=spend,
before=c[real]or 0,lvbefore=lv[real]or 0}
lastBuild[key]=now+((real=="defense")and CFG.DEF_COOLDOWN or 3)
local extra=""
if key=="def"then
extra=(" musuh=%s skor=%.1f tertutup=%.0f%% need=%.2f jatah=%.0f%%%s"):format(
tostring(spot.owner),spot.cands[1].score,(1-spot.frac)*100,
need,defShare*100,spot.urgent and" URGENT"or"")
end
log(("build %s tile=%d cost~%d gold=%d inc=%.0f/s wealth=%.1f amount=%s%s"):format(
key,t,need0,gold,income,wealth,tostring(amt or 1),extra))
return
end
end
elseif o.ess then
blockedEss=true
end
end
end
end
local LG={alive={},pairs={},atk={},nuke={},last=0,lb=0,clip=os.clock(),
sig=nil,sigAt=os.clock(),leaderWarn=0,inited=false,finished=nil}
local KINDS6={"city","port","factory","defense","sam","silo"}
local function nz(v)return type(v)=="number"and v or 0 end
local totalLand
local function shareOf(st,tiles)
local ok,v=pcall(function()
if not totalLand then
local n=0
for y=0,H-1,6 do
for x=0,W-1,6 do
if ru(st.map.land,y*W+x)~=0 then n+=1 end
end
end
totalLand=math.max(n*36,1)
end
return(tiles or 0)/totalLand*100
end)
return ok and v or 0
end
local function lgRows(st)
local out={}
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=0 and type(oi)=="table"and oi.spawned~=false then
out[#out+1]={o=o,oi=oi,tiles=nz(oi.tiles),alive=oi.alive~=false}
end
end
table.sort(out,function(a,b)return a.tiles>b.tiles end)
return out
end
local function lgCenter(oi)
local n=math.max(nz(oi.tiles),1)
return nz(oi.cx)/n,nz(oi.cy)/n
end
local function pairAllied(st,a,b)
local v=false
pcall(function()v=st:are_allies(a,b)and true or false end)
return v
end
local function lgStruct(st)
local per={}
for _,sv in pairs(st.structures)do
local o=sv.owner
if o and o~=0 then
local k=kindOf(sv)
if k then
local c=per[o]
if not c then c={};per[o]=c end
c[k]=(c[k]or 0)+1
end
end
end
return per
end
local function lgStructStr(c)
c=c or{}
local out={}
for _,k in ipairs(KINDS6)do out[#out+1]=k:sub(1,3).."="..(c[k]or 0)end
return table.concat(out," ")
end
local sw={prev={},noisy={},n={}}
local function watchState(st)
for k,v in pairs(st)do
local tv=type(v)
if type(k)=="string"and(tv=="number"or tv=="boolean"or tv=="string")then
local old=sw.prev[k]
if old~=nil and old~=v and not sw.noisy[k]then
sw.n[k]=(sw.n[k]or 0)+1
if tv=="number"and sw.n[k]>6 then
sw.noisy[k]=true
else
log(("STATE %s: %s -> %s"):format(k,tostring(old),tostring(v)))
end
end
sw.prev[k]=v
end
end
end
local function dumpTable(label,t,onlyKeys)
if type(t)~="table"then return end
local out={}
for k,v in pairs(t)do
if type(k)=="string"then
local lk=k:lower()
local hit=not onlyKeys or lk:find("win")or lk:find("victor")or lk:find("percent")or lk:find("team")
or lk:find("mode")or lk:find("ratio")or lk:find("limit")or lk:find("ally")or lk:find("end")or lk:find("time")
if hit then
local tv=type(v)
if tv=="number"or tv=="string"or tv=="boolean"then
out[#out+1]=k.."="..tostring(v)
elseif tv=="table"then
local n=0
for _ in pairs(v)do n+=1 end
out[#out+1]=k.."=table("..n..")"
end
end
end
end
table.sort(out)
log("RULES["..label.."] "..table.concat(out,", "))
end
local function dumpKeywords(label,t,words)
if type(t)~="table"then return end
local out={}
for k,v in pairs(t)do
if type(k)=="string"then
local lk=k:lower()
for _,w in ipairs(words)do
if lk:find(w,1,true)then
local tv=type(v)
if tv=="number"or tv=="string"or tv=="boolean"then
out[#out+1]=k.."="..tostring(v)
elseif tv=="table"then
local n=0
for _ in pairs(v)do n+=1 end
out[#out+1]=k.."=table("..n..")"
end
break
end
end
end
end
table.sort(out)
log("RULES["..label.."] "..table.concat(out,", "))
end
local function loggerInit(st,m)
local list=lgRows(st)
local mx,my=lgCenter(m)
log(("LG SPAWN gw (%d,%d) map %dx%d pemain=%d"):format(mx,my,W,H,#list))
local near={}
for _,r in ipairs(list)do
if r.o~=st.local_owner and r.alive and r.tiles>0 then
local ex,ey=lgCenter(r.oi)
near[#near+1]={o=r.o,d=math.sqrt((ex-mx)^2+(ey-my)^2)}
end
end
table.sort(near,function(a,b)return a.d<b.d end)
local parts={}
for i=1,math.min(6,#near)do parts[#parts+1]=("owner%d jarak %d"):format(near[i].o,near[i].d)end
log("LG TETANGGA: "..table.concat(parts,", "))
dumpTable("state",st,false)
dumpTable("me",m,false)
dumpTable("st.rules",st.rules,true)
dumpTable("Rules",Rules,true)
local KW={"rail","train","road","station","trade","connect","income","factory","gold","port","city","struct","dist","range","radius"}
dumpKeywords("Rules rail/income",Rules,KW)
dumpKeywords("st.rules rail/income",st.rules,KW)
local teams={}
for o,oi in pairs(st.owners)do
if type(o)=="number"and type(oi)=="table"then
local tm=oi.team or oi.team_id or oi.teamId or oi.alliance
if tm~=nil then teams[#teams+1]=o..":"..tostring(tm)end
end
end
log("LG TEAM/owner (kosong = nggak ada field team): "..table.concat(teams," "))
end
local function loggerFinal(st,m,why)
if LG.finished==why then return end
LG.finished=why
local list=lgRows(st)
log("===== SELESAI: "..why.." =====")
log(("LG tiles terakhir gw=%s (%.1f%%) troops=%s gold=%s"):format(tostring(m and m.tiles),shareOf(st,nz(m and m.tiles)),
tostring(m and m.troops),tostring(m and m.gold)))
for i=1,math.min(8,#list)do
local r=list[i]
log(("LG #%d owner%d %s tiles=%d(%.1f%%) troops=%d"):format(i,r.o,r.alive and"hidup"or"mati",
r.tiles,shareOf(st,r.tiles),nz(r.oi.troops)))
end
getgenv().AF_COPY_LOG()
warn("[AF_BOT] log disalin ke clipboard + af_log.txt")
end
local function loggerTick(st,m,now)
local mine=st.local_owner
if not LG.inited then
LG.inited=true
loggerInit(st,m)
end
pcall(watchState,st)
LG.t0=LG.t0 or now
if not LG.roadLog and now-LG.t0>=90 then
LG.roadLog=true
local nr,first=0,nil
if type(st.roads)=="table"then
for _,r in pairs(st.roads)do nr+=1;first=first or r end
end
local keys={}
if type(first)=="table"then
for k,v in pairs(first)do keys[#keys+1]=tostring(k).."="..tostring(v)end
end
table.sort(keys)
log(("LG ROADS jumlah=%d contoh: %s"):format(nr,table.concat(keys,",")))
local sk={}
for _,sv in pairs(st.structures)do
if sv.owner==mine and kindOf(sv)=="factory"then
for k,v in pairs(sv)do sk[#sk+1]=tostring(k).."="..tostring(v)end
break
end
end
table.sort(sk)
log("LG FACTORY field: "..table.concat(sk,","))
end
local seen={}
if type(st.attacks)=="table"then
for id,a in pairs(st.attacks)do
if type(a)=="table"and not a.dead then
seen[id]=true
if a.target==mine and a.attacker~=mine and not LG.atk[id]then
log(("LG SERANG MASUK dari owner%s troops=%d (pasukan gw %d)"):format(
tostring(a.attacker),nz(a.troops),nz(m.troops)))
end
end
end
end
LG.atk=seen
if type(st.nukes)=="table"then
local seenN={}
for id,n in pairs(st.nukes)do
seenN[id]=true
if not LG.nuke[id]and type(n)=="table"then
local who=n.owner or n.attacker or n.src_owner
log(("LG NUKE baru owner=%s kind=%s target=%s%s"):format(tostring(who),
tostring(n.kind or n.type or n.name),tostring(n.target or n.tile or n.dst),
who==mine and" (punya gw)"or""))
end
end
LG.nuke=seenN
end
local list=lgRows(st)
local lead=list[1]
if lead then
local sh=shareOf(st,lead.tiles)
if sh>=50 and now-LG.leaderWarn>20 then
LG.leaderWarn=now
log(("LG LEADER owner%d %.1f%% tanah (gw %.1f%%)"):format(lead.o,sh,shareOf(st,nz(m.tiles))))
end
end
local cur=table.concat({tostring(m.tiles),tostring(math.floor(nz(m.troops))),tostring(lead and lead.tiles),
tostring(lead and math.floor(nz(lead.oi.troops)))},"|")
if cur~=LG.sig then
LG.sig,LG.sigAt=cur,now
elseif now-LG.sigAt>40 and LG.finished~="beku"then
log("LG STATE BEKU 40 detik: tanah/pasukan nggak berubah -> match kemungkinan sudah selesai")
loggerFinal(st,m,"beku")
end
if now-LG.clip>=(tonumber(getgenv().AF_LOGGER_CLIP)or 20)then
LG.clip=now
getgenv().AF_COPY_LOG()
end
if now-LG.last<6 then return end
LG.last=now
local per=lgStruct(st)
local rank=0
for i,r in ipairs(list)do if r.o==mine then rank=i break end end
log(("LG ME rank=%d tiles=%d(%.1f%%) troops=%d/%d gold=%d | %s"):format(
rank,nz(m.tiles),shareOf(st,nz(m.tiles)),nz(m.troops),nz(m.max_troops),nz(m.gold),lgStructStr(per[mine])))
for _,r in ipairs(list)do
if LG.alive[r.o]==true and not r.alive then
log(("LG MATI owner%d (tiles terakhir %d)"):format(r.o,r.tiles))
end
LG.alive[r.o]=r.alive
end
local top={}
for i=1,math.min(10,#list)do if list[i].alive then top[#top+1]=list[i].o end end
for i=1,#top do
for j=i+1,#top do
local a,b=top[i],top[j]
local key=a<b and(a.."-"..b)or(b.."-"..a)
local al=pairAllied(st,a,b)
if LG.pairs[key]~=nil and LG.pairs[key]~=al then
log(("LG ALIANSI owner%d <-> owner%d %s%s"):format(a,b,al and"TERBENTUK"or"PUTUS",
(a==mine or b==mine)and" (ada gw)"or""))
end
LG.pairs[key]=al
end
end
if now-LG.lb>=30 then
LG.lb=now
local mx,my=lgCenter(m)
log("LG --- LEADERBOARD ---")
for i=1,math.min(8,#list)do
local r=list[i]
local ex,ey=lgCenter(r.oi)
local rel=(r.o==mine)and"GW"or(allied(st,r.o)and"ally"or"musuh")
log(("LG #%d owner%d [%s] %s tiles=%d(%.1f%%) troops=%d/%d gold=%d jarak=%d | %s"):format(
i,r.o,rel,r.alive and"hidup"or"mati",r.tiles,shareOf(st,r.tiles),
nz(r.oi.troops),nz(r.oi.max_troops),nz(r.oi.gold),
math.sqrt((ex-mx)^2+(ey-my)^2),lgStructStr(per[r.o])))
end
end
end
local dbgDone=false
local function dumpKeys(label,tbl)
if type(tbl)~="table"then
log("WARN: "..label.." bukan table ("..type(tbl)..")")
return
end
local _,a=next(tbl)
if type(a)=="table"then
local keys={}
for k in pairs(a)do keys[#keys+1]=tostring(k)end
log(label.." field: "..table.concat(keys,","))
end
end
local function debugOnce(st,m)
if dbgDone then return end
dbgDone=true
if m.cx==nil or m.cy==nil then
log("WARN: m.cx/m.cy nil -> 'terdekat' bakal ngitung dari (0,0). Cek nama field pusat wilayah.")
end
dumpKeys("st.attacks",st.attacks)
if st.nukes~=nil then dumpKeys("st.nukes",st.nukes)end
if st.flags==nil then log("WARN: st.flags nil -> deteksi fallout mati (expand bisa kena tile mahal)")end
end
buildNukeKinds()
local errAt={}
local function safe(name,f,fb,...)
local ok,a,b2=pcall(f,...)
if ok then return a,b2 end
local now=os.clock()
if now-(errAt[name]or-99)>10 then
errAt[name]=now
log("ERR modul "..name..": "..tostring(a))
end
return fb
end
task.spawn(function()
local lastSpawn,lastFind,lastKinds=0,0,0
local spawnWaitAt,respawnN,lastRe=nil,0,0
local replayN,lastReplay=0,0
local focusTile,focusTileAt,focusTileOwner=nil,0,nil
local fast,deadLogged=false,false
while getgenv().AF_BOT==RUN do
task.wait(EARLY and CFG.EARLY_WAIT or(fast and(0.4+math.random()*0.3)or(0.7+math.random()*0.5)))
if RUN.paused then goto continue end
local ok,err=pcall(function()
local st=ctx.state
local m=me(st)
if not m then return end
if type(st.W)=="number"and type(st.H)=="number"and(st.W~=W or st.H~=H)then
setMapSize(st.W,st.H)
tileCd,cellCd,boatTargets={},{},{}
focus,focusTile=nil,nil
log("ukuran map berubah: "..W.."x"..H)
end
if not m.spawned then
spawnWaitAt=spawnWaitAt or os.clock()
local tot,sp=0,0
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=0 and type(oi)=="table"and oi.alive~=false then
tot+=1
if oi.spawned then sp+=1 end
end
end
local waited=os.clock()-spawnWaitAt
local maxWait=tonumber(getgenv().AF_SPAWN_MAX)or CFG.SPAWN_MAX_WAIT
local ready=waited>=maxWait or(tot>0 and sp/tot>=CFG.SPAWN_FRAC and waited>=3)
if not ready then
if os.clock()-lastSpawn>4 then
lastSpawn=os.clock()
log(("nunggu spawn: %d/%d pemain sudah spawn (%.0fs/%ds)"):format(sp,tot,waited,maxWait))
end
return
end
if os.clock()-lastSpawn>3 then
lastSpawn=os.clock()
local t=pickSpawn(st)
if t then fire({type="spawn",tile=t});log("spawn "..t.." (pemain spawn "..sp.."/"..tot..")")end
end
return
end
if not m.alive then
if not deadLogged then
deadLogged=true
log(("MATI: tiles terakhir=%s troops=%s gold=%s"):format(tostring(m.tiles),tostring(m.troops),tostring(m.gold)))
if playStart and os.clock()-playStart<CFG.EARLY_DEATH_S then
log(("EARLY DEATH: mati %.0fs setelah match mulai -> coba main lagi"):format(os.clock()-playStart))
end
safe("loggerFinal",loggerFinal,nil,st,m,"gw mati")
pcall(writefile,"af_log.txt",table.concat(logs,"\n"))
getgenv().AF_COPY_LOG()
playStart,spawnWaitAt,respawnN=nil,nil,0
end
if replayN<CFG.REPLAY_MAX and os.clock()-lastReplay>6 then
lastReplay=os.clock()
replayN+=1
local pa=getgenv().AF_PLAY_AGAIN
if type(pa)=="function"then
local okp,errp=pcall(pa)
log(("REPLAY %d/%d: AF_PLAY_AGAIN %s"):format(replayN,CFG.REPLAY_MAX,okp and"dipanggil"or tostring(errp)))
end
local t=pickSpawn(st)
if t then
fire({type="spawn",tile=t})
log(("REPLAY %d/%d: coba spawn di %d"):format(replayN,CFG.REPLAY_MAX,t))
end
end
return
end
deadLogged=false
replayN=0
if st.phase~=1 then
if playStart then
safe("loggerFinal",loggerFinal,nil,st,m,"match selesai (phase "..tostring(st.phase)..")")
playStart,spawnWaitAt,respawnN=nil,nil,0
end
if st.phase==0 and respawnN<CFG.RESPAWN_MAX and os.clock()-lastRe>4 then
lastRe=os.clock()
local mx,my=homeCenter(m)
local near=math.huge
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=0 and o~=st.local_owner and type(oi)=="table"
and oi.spawned and(oi.tiles or 0)>0 then
local ex,ey=homeCenter(oi)
near=math.min(near,math.sqrt((ex-mx)^2+(ey-my)^2))
end
end
if near<CFG.RESPAWN_CROWD then
local t=pickSpawn(st)
if t then
respawnN+=1
fire({type="spawn",tile=t})
log(("RESPAWN: ada pemain %d tile dari gw -> coba pindah ke %d (%d/%d)"):format(near,t,respawnN,CFG.RESPAWN_MAX))
end
end
end
return
end
if not playStart then playStart=os.clock()end
debugOnce(st,m)
safe("logger",loggerTick,nil,st,m,os.clock())
local now=os.clock()
EARLY=(now-playStart)<CFG.EARLY_S
if now-lastKinds>30 then
lastKinds=now
buildNukeKinds()
end
local S=scan(st)
local nb,neutral,fallout=analyse(st)
local maxK=probeLen()
local probe=safe("probe",probeGaps,{},st,maxK)or{}
safe("flow",flowTick,nil,m,now)
safe("intel",intelStep,nil,st,m,now,nb,probe)
local info=safe("threat",threat,nil,st,m,nb,S,probe,maxK)
if not info then
info={incoming=false,danger=false,strong=false,strongest=0,foeSilo=S.foeSilo,
hostile={},brutalAny=false,dominant=false}
end
do
local adjT,adjO=0,nil
for o,e in pairs(nb)do
if e and(e.contacts or 0)>=CFG.ADJ_MIN_CONTACTS and(e.troops or 0)>adjT then adjT,adjO=e.troops or 0,o end
end
local mt0=math.max(m.troops or 1,1)
local safety=(mt0>=adjT)and CFG.RES_SAFETY_OK or CFG.RES_SAFETY_WEAK
info.adjT,info.adjO=adjT,adjO
info.adjRatio=adjT>0 and mt0/adjT or 99
info.reserveT=EARLY and 0 or math.min(safety*adjT,CFG.RES_CAP*math.max(m.max_troops or 1,1))
if adjT>0 and now-(RUN.resLog or 0)>10 then
RUN.resLog=now
log(("RESERVE tetangga terkuat=owner %s pasukan=%d gw=%d rasio=%.2f -> cadangan=%d spendable=%d"):format(
tostring(adjO),math.floor(adjT),math.floor(m.troops or 0),info.adjRatio,math.floor(info.reserveT),math.floor(math.max((m.troops or 0)-info.reserveT,0))))
end
end
fast=((info.incoming or info.rival~=nil or info.brutalAny)or EARLY)and true or false
local claimSet,contested={},false
for _,p in pairs(probe)do
for _,t in ipairs(p.claims)do claimSet[t]=true;contested=true end
end
contested=contested and(info.brutalAny or next(info.hostile)~=nil)
safe("trackLoss",trackLoss,nil,st,m,nb,now)
safe("recorder",recorder,nil,st,m,S,nb,info,now)
safe("watch",enemyWatch,nil,st,S,now)
if now-lastBoatScan>CFG.BOAT_SCAN_INTERVAL then
lastBoatScan=now
scanBoatTargets(st,m)
end
local fcs=safe("focus",evalFocus,nil,st,m,S,nb,now)
FRONT=safe("front",frontStep,nil,st,m,S,nb,now)
local weak=false
for _,e in pairs(nb)do
if e and e.P and e.P<CFG.WEAK_P and e.contacts>=5 then weak=true break end
end
safe("diplomacy",diplomacyStep,nil,st,m,nb,fcs,now)
if fcs and not fcs.contact then
if focusTileOwner~=fcs.o or not focusTile or now-focusTileAt>6
or ownerAt(st,focusTile)~=fcs.o then
local hx,hy=homeCenter(m)
focusTile=foeCoastTile(st,fcs.o,fcs.cx,fcs.cy,fcs.tiles,hx,hy)
focusTileAt=now
focusTileOwner=fcs.o
end
else
focusTile=nil
end
local reserve=safe("nuke",nukeStep,0,st,m,S,nb,fcs)or 0
safe("build",buildStep,nil,st,m,S,nb,info,reserve,probe,maxK)
local cs=safe("counter",counterStep,{},st,m,nb,now)or{}
if#cs>0 then
local parts={}
for _,c in ipairs(cs)do
fire({type="attack",ratio=c.ratio,tile=c.tile})
parts[#parts+1]=("owner %d serangan=%d ratio=%.2f"):format(c.owner,math.floor(c.troops),c.ratio)
end
log("COUNTER "..table.concat(parts," | "))
return
end
local fill=(m.troops or 0)/math.max(m.max_troops or 1,1)
local holes={}
if fill>=math.max(CFG.HOLE_MIN_FILL,(DYN.stop or 0)+0.15,(info.reserveT or 0)/math.max(m.max_troops or 1,1)+0.03)and now-(DYN.holeAt or-99)>=6 then
holes=safe("hole",holeStep,{},st,neutral,fallout,fill,now)or{}
if#holes>0 then DYN.holeAt=now end
end
if#holes>0 then
local hp={}
for _,h in ipairs(holes)do
fire({type="attack",ratio=h.ratio,tile=h.tile})
hp[#hp+1]=("%d@%.2f"):format(h.tile,h.ratio)
end
log(("LUBANG expand %s (fill=%.2f)"):format(table.concat(hp," "),fill))
end
info.punish=false;info.punishE=nil
if CFG.HARDCORE then
for o,e in pairs(nb)do
if e and e.P and e.etiles and#e.etiles>0 and not allied(st,o)then
local okp=e.P>=CFG.PUNISH_P or((e.mom or 0)>=0.4 and e.P>=CFG.PUNISH_P_MOM)
if okp and(not info.punishE or e.P>info.punishE.P)then info.punishE=e end
end
end
if info.punishE and(info.adjRatio or 99)<1.0 and info.punishE.o~=info.adjO then info.punishE=nil end
if info.punishE and fill<CFG.PUNISH_MIN_FILL then info.punishE=nil end
if info.punishE then
info.punish=true
fast=true
if now-(RUN.punLog or 0)>8 then
RUN.punLog=now
log(("PUNISH owner %d P=%.1f mom=%.2f pasukan musuh=%d gw=%d -> serang sekarang"):format(info.punishE.o,info.punishE.P,info.punishE.mom or 0,math.floor(info.punishE.troops or 0),math.floor(m.troops or 0)))
end
end
end
local keep=info.incoming and CFG.KEEP_HOT or CFG.KEEP
if info.rival then keep=math.max(keep,CFG.KEEP_RIVAL)end
if info.danger then keep=math.max(keep,CFG.KEEP_HOT)end
if info.strong then keep=math.max(keep,CFG.KEEP_RIVAL)end
if weak then keep=math.max(keep,CFG.WEAK_KEEP)end
if fcs and strikeFor(fcs.o,now)then keep=math.min(keep,CFG.KEEP_STRIKE)end
if strike and strike.till>now and not(fcs and fcs.o==strike.owner)then
keep=math.min(keep,CFG.KEEP_STRIKE)
end
local humanContact=false
for o,e in pairs(nb)do
if e and(e.contacts or 0)>=1 then
local oi2=st.owners[o]
if oi2 and oi2.kind~=KIND_TRIBE then humanContact=true break end
end
end
local earlyBotOnly=EARLY and not humanContact and not info.incoming
if earlyBotOnly then keep=math.min(keep,CFG.EARLY_KEEP_BOT)end
local lowTroops=(m.troops or 0)<(m.max_troops or 0)*keep
local stopFill=EARLY and(earlyBotOnly and CFG.EARLY_MIN_FILL_BOT or CFG.EARLY_MIN_FILL)or CFG.STOP_FILL
if weak and not earlyBotOnly then stopFill=math.max(stopFill,CFG.WEAK_STOP)end
local topFoe=0
for o,oi in pairs(st.owners)do
if type(o)=="number"and o~=0 and o~=st.local_owner and type(oi)=="table"
and oi.alive and oi.spawned~=false and not allied(st,o)then
local tr=oi.troops or 0
if tr>topFoe then topFoe=tr end
end
end
DYN.stop=EARLY and 0 or math.min(CFG.LEADER_RESERVE_CAP,topFoe*CFG.LEADER_RESERVE/math.max(m.max_troops or 1,1))
stopFill=math.max(stopFill,DYN.stop)
if lowTroops and not info.punish and(info.incoming or fill<stopFill or#neutral==0)then return end
if(EARLY or(weak and not earlyBotOnly))and fill<stopFill and not info.punish then return end
if not EARLY and fill<DYN.stop and not info.punish then return end
if posture.need>=POS.EXISTENTIAL and posture.assault then
if now-lastIdle>10 then
lastIdle=now
log(("COLLAPSE GUARD: nahan semua pasukan (need=%.2f) -- fokus defense/front, expand/attack dihentikan sementara"):format(posture.need))
end
return
end
local plan,availLeft=planAttacks(st,m,S,nb,neutral,info,now,fcs,fallout,claimSet,contested,lowTroops and not info.punish)
local boatPlan={}
if not lowTroops then
boatPlan=safe("boat",planBoats,{},st,m,info,now,availLeft,fcs,focusTile,#neutral==0)or{}
end
if#plan==0 and#boatPlan==0 then
if now-lastIdle>15 then
lastIdle=now
log("idle: nggak ada target layak (fokus="..(fcs and tostring(fcs.o)or"none")
.." boatTargets="..#boatTargets..")")
end
return
end
local parts={}
for _,a in ipairs(plan)do
fire({type="attack",ratio=a.ratio,tile=a.tile})
parts[#parts+1]=("%s:%d@%.2f"):format(a.kind=="expand"and"E"or"A",a.tile,a.ratio)
end
for _,b in ipairs(boatPlan)do
fire(BOAT_INTENT(b.tile,b.ratio))
log(("BOAT kirim kind=%s tile=%d owner=%s ratio=%.2f"):format(tostring(b.kind),b.tile,tostring(ownerAt(st,b.tile)),b.ratio))
parts[#parts+1]=("B%s:%d@%.2f"):format(b.kind=="focus"and"F"or"",b.tile,b.ratio)
end
log(("troops=%s %s"):format(tostring(m.troops),table.concat(parts," ")))
end)
if not ok then
log("ERR "..tostring(err))
if os.clock()-lastFind>5 then
lastFind=os.clock()
local c=findCtx()
if c then ctx=c;cands=findSender(ctx);send=nil end
end
end
::continue::
end
log("bot stop")
end)
log("bot v5.8 HARDCORE+MIMIC+PUNISH jalan [fix v5.8: GUI hooks ditambah -- RUN.cfg (tuning live dari GUI), RUN.setHardcore(bool), RUN.setWarship/getWarship(bool), RUN.paused (pause tanpa kill loop), RUN.stats() buat baca tiles/troops/gold/income cepat] [fix v5.7: warship diaktifin default (dulu off permanen) + gagal build warship cuma retry 40s bukan mati total + SAM_CAP naik (3/5->5/7) + samCap scaling dipercepat (wealth/2+city/4, max 14) + prioritas build sam non-essential digeser ke atas city/factory biar nggak starve pas ekonomi gede] [fix v5.6: deteksi bom gagal pakai kompensasi income + blacklist tile gagal + nabung hydrogen + SAM stronger discount + SAM coverage tertimbang + log BOAT]  (matiin: getgenv().AF_HARDCORE=false sebelum execute): [fix v5.5: CADANGAN PASUKAN = 0.6-0.9x pasukan tetangga terkuat (dicap 60% max) -- expand/attack/punish/boat/hole cuma boleh pakai pasukan DI ATAS cadangan itu; tetangga setara/unggul -> expand maks 1 slot ratio 0.08, nggak ada punish ke target lain; rasio serang maks 40% (bukan 75%), log RESERVE tiap 10 detik] [fix v5.4: PUNISH nggak jalan kalau pasukan <35% penuh + kirim pasukan dicap (3x kebutuhan / 1.5x pasukan musuh) biar nggak buang 75% pasukan ke musuh receh + threshold serang dinaikin (P 1.5->1.8, punish 3.0) + KEEP dinaikin + max serangan aktif 8 + defense baru boleh dibangun kalau city>=3 biar ekonomi nggak kesedot] [fix v4.16: planBoats nggak lagi blokir SEMUA invasi laut total cuma gara2 info.rival/brutalAny (flag global, bisa kepicu dari ancaman di tempat lain yang sama sekali nggak relevan ke target yang mau diserang) -- sekarang cuma diblokir kalau pasukan beneran menipis (fill<0.6); kalau pasukan udah penuh/surplus (yang notabene kondisi paling sering pas lead), invasi laut ke musuh lemah via boat tetap jalan. Ini akar dari 'idle: nggak ada target layak' padahal ratio 64x dan boatTargets 800] [fix v4.15: info.dominant (threat()) ambangnya diturunin 3x -> 1.6x troops vs musuh terkuat, diselaraskan sama DOM_LO=1.5 yang dipake postureStep -- sebelumnya dominant cuma nyala pas 3x lebih kuat, jadi defWanted (bar cuma need>=0.12, gampang kepenuhi) tetep ngalir ke defense walau kamu udah jelas lebih unggul dari musuh terdekat] [fix v4.14: def cuma boleh nyerobot antrian essential (motong city<6/factory<2/silo<1) kalau posture udah EXISTENTIAL(>=0.9) -- sebelumnya defUrgent(need>=0.6, status DEFENSE DULU yang sering banget nyala) bikin def selalu disisipin duluan dari city tiap tick walau cuma 'urgent' bukan beneran kritis, jadi city growth ketunda-tunda. Def tetep dibangun pas urgent-tapi-nggak-existential, tapi di prioritas rendah (gentian sama growth), nggak nyerobot antrian] [fix v4.13: POS.STR_LO/STR_HI dilonggarin 0.6/1.6 -> 1.0/2.6 (tetangga harus beneran jauh lebih gede baru dianggap 'kuat') + aggrGate: nStr('kuat') dikali 0.35-1.0 tergantung ada serangan/kehilangan tanah nyata belakangan ini (45s half-life) -- sebelumnya posture bisa full URGENT cuma gara2 tetangga ukurannya segede/lebih gede dikit walau nggak pernah nyerang, bikin gold kesedot ke defense padahal harusnya city/factory kayak kompetitor rank-1] [fix v4.12: SAM pertama TIDAK di-skip lagi pas existentialAssault (sebelumnya air-defense mati total justru pas paling rawan nuke finishing-blow) + kandidat tile defense divalidasi ulang ownerAt/isLand/isFallout sebelum fire, bukan cuma lewat quote() cost-check] [fix: factory duluan, REPLAY setelah mati/early death (hook AF_PLAY_AGAIN), RESPAWN maks 3x, timer EARLY ke-reset tiap match] [v4.11: bot=lahan/player=ancaman, attack-first, SAM di pusat ekonomi, peer-floor, hole dibatasi, city sebelum defense] [FIX v4.10] SAM pertama dipindah DI ATAS defense berulang (defUrgent) di urutan build -- sebelumnya starved terus selama defUrgent true (hampir sepanjang game kalau underdog), jadi sam=0 walau syarat affordable udah lama kepenuhi; [FIX v4.9] POSTURE deteksi growth-rate musuh snowball (bukan cuma ratio snapshot, ketangkep sebelum musuh keburu overtake) + COUNTER bypass budget cap buat invasi existential (>=50% pasukan gw sekali serang, masih dijaga floorT) + DEF_ASSAULT_HOLD dilewatin kalau posture udah existential (>=0.9, biar defense bisa dibangun ulang walau lagi digempur) + COLLAPSE GUARD: expand/attack full-stop pas existential assault biar semua pasukan kekonsentrasi ke defense/front; [FIX v4.8] spaced() pakai STRUCT_SPACING scaled dari rules (bukan hardcode 18) + sampleOwn rail-aware (prefer tile dalam RAIL_MAX_PATH dari struktur terdekat, fallback random) + evalFocus track existential enemy (tileShare>=25% selalu masuk kandidat, ratio cutoff 0.3x) + dominant flag inject ke score evalFocus; logger rel/kereta + boat attack dicap 0.25 + defense nggak nyerobot tabungan city + boat reach adaptif + serangan receh diabaikan + silo pas macet + defense skip kalau dominan; counter dibatasi (budget+floor) + cadangan pasukan vs musuh terkuat + warship off + SAM pertama prioritas + WATCH skip ally; map "..W.."x"..H..", POSTURE adaptif (jatah defense dari ancaman + dominasi) + build income dulu (city 3, factory, port, city 6, factory 2) + power P + satu front satu arah + serangan terorganisir + boat invade + logger WATCH + counter-attack floor + spawn nunggu pemain lain + expand nutup musuh + momentum + ukuran serangan dinamis + push besar kalau unggul + logger terintegrasi (leaderboard, aliansi, nuke, aturan game)")
