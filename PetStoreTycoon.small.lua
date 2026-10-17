local a='Pet Store Tycoon'local b='v1.0'local c=
'https://www.youtube.com/@RansbloxScript'local d='https://ransblox.net'if _G.
PETSTORETYCOON_Unload then pcall(_G.PETSTORETYCOON_Unload)end pcall(function()
setclipboard(c)end)local e,f=pcall(function()return loadstring(game:HttpGet(
[[https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua]]
))()end)if not e or not f then return end local g={}local h=function(h,i)local j
=h:Connect(i)table.insert(g,j)return j end local i=game:GetService('Players')
local j=game:GetService('ReplicatedStorage')local k=game:GetService('RunService'
)local l=i.LocalPlayer local m=l:WaitForChild('PlayerGui')local n=function(n)f:
Notify({Title=a,Content=n,Icon='x',Duration=5})end local o=j:WaitForChild(
'Remotes',10)if not o then n(
[[Pet Store Tycoon not found. This script only works in Pet Store Tycoon.]])
return end local p=true local q={restockOn=false,buyOn=false,cashierStarting=
false,thiefNow=function()return false end}local r={}q.hold=function(s,t)r[s]=t
and true or nil end q.held=function()return next(r)~=nil end local s,t={},nil
local u=function(u,v)s[u]=v and true or nil local w=next(s)~=nil if w and not t
then t=k.Stepped:Connect(function()local x=l.Character if not x then return end
for y,z in ipairs(x:GetDescendants())do if z:IsA('BasePart')then z.CanCollide=
false end end end)elseif not w and t then t:Disconnect()t=nil end end local v={
teleport=false}function v.isTp()return v.teleport end function v.tp(w,x)local y=
l.Character local z=y and y:FindFirstChild('HumanoidRootPart')local A=y and y:
FindFirstChildOfClass('Humanoid')if not(z and w)then return false end if A and A
.Health<=0 then return false end local B=z.CFrame z.CFrame=CFrame.new(w.X,B.
Position.Y,w.Z)*(B-B.Position)z.AssemblyLinearVelocity=Vector3.zero if not x
then task.wait(0.15)end return true end local w,x,y={},0,os.clock()local z=
function(z,A,...)local B,C=table.pack(...),{}for D=1,B.n do C[D]=tostring(B[D])
end w[#w+1]=string.format('[%.2f] %s %s(%s)',os.clock()-y,z,tostring(A),table.
concat(C,', '))if#w>400 then table.remove(w,1)end x+=1 end task.spawn(function()
local A=0 while p do task.wait(2)if x~=A then A=x if writefile then pcall(
writefile,'petstore_tycoon_log.txt',table.concat(w,'\n'))end end end end)local A
=game:GetService('HttpService')local B=o:WaitForChild('Checkout',10)local C=B
and B:FindFirstChild('ScanCurrent')local D=B and B:FindFirstChild('BeginShift')
local E=B and B:FindFirstChild('EndShift')local F=false local G='Ready'local H=
function()end local I=function()return p and F and not q.thiefNow()end local J=
function(J,K,...)z('CASH:'..J,K,...)if J=='BOT'then H(tostring(K))end end local
K local L=function()local L=workspace:WaitForChild('Plots')for M,N in ipairs(L:
GetChildren())do if N:GetAttribute('OwnerUserId')==l.UserId then return N:
FindFirstChild('Checkout')end end local M=l.Character and l.Character:
FindFirstChild('HumanoidRootPart')local N,O for P,Q in ipairs(L:GetChildren())do
local R=Q:FindFirstChild('Checkout')local S=R and R:FindFirstChild('PlayerPoint'
)if S and M then local T=(S.Position-M.Position).Magnitude if not O or T<O then
N,O=R,T end end end return N end local M=function()if not K then return nil end
local M=K:GetAttribute('CheckoutDisplayPayload')if type(M)~='string'then return
nil end local N,O=pcall(A.JSONDecode,A,M)return N and O or nil end local N=
function()return(M()or{}).phase end local O,P,Q=false,0,0 local R=function()
local R=os.clock()if R-P<0.5 then return O end P=R local S=0 local T=K and K.
Parent local U=T and T:FindFirstChild('NPCs')for V,W in ipairs(U and U:
GetChildren()or{})do local X=W:GetAttribute('Phase')local Y=tostring(W:
GetAttribute('Status')or''):lower()if X=='Buy'or Y:find('pay')or Y:find('queue')
or Y:find('line')then S+=1 end end local V=M()if V and((V.totalCents or 0)>0 or#
(V.lines or{})>0)then S+=1 end O=S>0 if O then Q=R end return O end q.yield=
function()return F and R()end q.yieldTask=function()return false end q.
canLeaveDesk=function()if not F then return true end if R()then return false end
return os.clock()-Q>=((q.RCfg and q.RCfg.IdleBefore)or 0)end local S=false local
T=function()if not K then return end z('DUMP','register',K:GetFullName())for T,U
in ipairs(K:GetDescendants())do if U:IsA('ProximityPrompt')then z('DUMP',
'ProximityPrompt',U:GetFullName(),U.ActionText,U.HoldDuration,U.Enabled)elseif U
:IsA('ClickDetector')then z('DUMP','ClickDetector',U:GetFullName())elseif U:IsA(
'TouchTransmitter')then z('DUMP','TouchInterest',U.Parent:GetFullName())end end
end pcall(function()local U U=hookmetamethod(game,'__namecall',newcclosure(
function(V,...)if p and not checkcaller()then local W=getnamecallmethod()if(W==
'InvokeServer'or W=='FireServer')and(V==D or V==E or V.Name==
'AcceptPresentedPayment')then z('HOOK',V.Name..':'..W,...)end end return U(V,...
)end))end)local U=function()local U={}if K then for V,W in pairs(K:
GetAttributes())do if V~='CheckoutDisplayPayload'then U[#U+1]=V..'='..tostring(W
)end end end for V,W in pairs(l:GetAttributes())do U[#U+1]='lp.'..V..'='..
tostring(W)end table.sort(U)return table.concat(U,'|')end local V={function(V)
firesignal(V.Activated)end,function(V)firesignal(V.MouseButton1Click)end,
function(V)for W,X in ipairs(getconnections(V.Activated))do X:Fire()end end,
function(V)for W,X in ipairs(getconnections(V.MouseButton1Click))do X:Fire()end
end}local W=1 local aa=function(X,Y)local Z=Y()for _=0,#V-1 do local aa=((W-1+_)
%#V)+1 pcall(V[aa],X)local ab=os.clock()while os.clock()-ab<0.8 do task.wait(
0.03)if Y()~=Z then W=aa return true end end end J('BOT','Button press failed',X
:GetFullName())return false end local ab=function()local ab=m:FindFirstChild(
'UI2Checkout')local X=ab and ab:FindFirstChild('Frame')local Y=X and X:
FindFirstChild('Panel')return Y and Y:FindFirstChild('Panel')end local X=
function(X)local Y=os.clock()while os.clock()-Y<3 do local Z=ab()if Z and Z:
FindFirstChild(X,true)then return Z end task.wait(0.1)end end local Y,Z=0,nil
local ac=function(_)local ac={}for ad,ae in ipairs(_.lines or{})do ac[ae.
sourceIndex]=true end local ad,ae for af,ag in ipairs(K:GetChildren())do if ag.
Name=='ScanItem'then local ah=ag:GetAttribute('CheckoutItemIndex')if ah and not
ac[ah]and(not ae or ah<ae)then ad,ae=ag,ah end end end return ad end local ad=
function()local ad,ae=0,0 while I()do local af=M()if not af or af.phase~=
'Scanning'then return end local ag=ac(af)if not ag then ae+=1 if ae>30 then
return end task.wait(0.2)else ae=0 local ah=ag:GetAttribute(
'CheckoutTransactionId')if ah~=Z then Z=ah task.spawn(function()pcall(D.
InvokeServer,D,K)end)task.wait(0.5)end local _=af.scannedCount or 0 Y+=1 C:
FireServer(ag,ah,Y)local ai,aj=false,os.clock()while os.clock()-aj<1 do task.
wait(0.05)local ak=M()if not ak or ak.phase~='Scanning'or(ak.scannedCount or 0)>
_ then ai=true break end end if ai then ad=0 task.wait(0.15)else ad+=1 J('SCAN',
'Scan rejected',Y,ag:GetAttribute('CheckoutItemIndex'),ah)if ad>8 then J('BOT',
'Gave up scanning')return end end end end end local ae=1 local af=function(af)
local ag=K:FindFirstChild('CheckoutPayment')local ah=ag and ag:FindFirstChild(af
=='Card'and'Card'or'Band',true)local ai=B:FindFirstChild(
'AcceptPresentedPayment')if not ai then J('BOT',
'AcceptPresentedPayment remote not found')return end local aj={table.pack(K,Z),
table.pack(Z),table.pack(K),table.pack(ah),table.pack(),table.pack(K,Z,af),table
.pack(ah,Z)}for ak=0,#aj-1 do local _=((ae-1+ak)%#aj)+1 local al=aj[_]pcall(
function()ai:FireServer(table.unpack(al,1,al.n))end)local am=os.clock()while os.
clock()-am<1.2 do task.wait(0.05)if N()~='AwaitingPayment'then if ae~=_ then J(
'PAY','Accept argument shape worked',_)end ae=_ return end end end J('BOT',
'All payment accept shapes failed',tostring(Z))end local ag={{'Bills','bill100',
10000},{'Bills','bill50',5000},{'Bills','bill20',2000},{'Bills','bill10',1000},{
'Bills','bill5',500},{'Bills','bill1',100},{'Coins','coin50',50},{'Coins',
'coin25',25},{'Coins','coin10',10},{'Coins','coin5',5},{'Coins','coin1',1}}local
ah=function(ah)return math.floor((tonumber((ah:gsub(',','')))or 0)*100+0.5)end
local ai=function(ai)local aj,ak=ai.Text:match(
'Giving%s*%$([%d,%.]+)%s*of%s*%$([%d,%.]+)')return aj and ah(aj),ak and ah(ak)
end local aj=function()local aj=X('Giving')if not aj then J('BOT',
"Cash panel didn't appear")return end local ak=aj:FindFirstChild('Giving')local
al=function()return ak.Text end local am,_=ai(ak)if not _ then J('BOT',
"Couldn't read the cash target",ak.Text)return end local an,ao,ap=1,0,0 for aq=1
,160 do if not I()or N()~='CashChange'then return end local ar=(ai(ak))or 0 if
ar==_ then break end if ar>_ then ao+=1 if ao>4 then J('BOT',
'Gave up: overshot the cash target',ar,_)return end local as=aj:FindFirstChild(
'ClearAll')if as then aa(as,al)end continue end local as,at,au=_-ar,nil,nil for
av,aw in ipairs(ag)do if aw[3]*an<=as then local ax=aj:FindFirstChild(aw[2],true
)ax=ax and ax:FindFirstChild('Button')if ax then at,au=ax,aw break end end end
if not at then J('BOT','No matching bill or coin button',as,an)return end if not
aa(at,al)then return end task.wait(0.1)local av=(ai(ak))or ar local aw=math.
floor((av-ar)/au[3]+0.5)if ap<6 then ap+=1 J('DELTA',au[2],av-ar,aw,W)end if aw
>=1 then an=aw end end local aq=(ai(ak))or 0 if aq==_ then local ar=aj:
FindFirstChild('OK')if ar then aa(ar,N)end else J('BOT',
"Cash total doesn't match",aq,_)end end local ak=function()local ak=X('DueValue'
)if not ak then J('BOT',"Card panel didn't appear")return end local al=ak:
FindFirstChild('DueValue',true)local am=ak:FindFirstChild('Entered',true)local
an=string.format('%.2f',ah((al.Text:gsub('[^%d%.]','')))/100)local ao=function()
return am.Text end for ap in an:gmatch('.')do local aq=ap=='.'and'KeyDot'or(
'Key'..ap)local ar=ak:FindFirstChild(aq)if not ar or not aa(ar,ao)then J('BOT',
'Keypad press failed',aq)return end task.wait(0.03)end local ap=ak:
FindFirstChild('ConfirmKey')if ap then aa(ap,N)end end local al=false local am=
nil local an=nil local ao=function()local ao=K and K:FindFirstChild(
'PlayerPoint')return ao and ao.Position end local ap=function()local ap=l.
Character local aq=ap and ap:FindFirstChildOfClass('Humanoid')local ar=ap and ap
:FindFirstChild('HumanoidRootPart')local as=ao()if not(aq and ar and as)then
return false end if v.isTp()then return v.tp(as)end local at=os.clock()while I()
and not q.held()and os.clock()-at<20 do local au=ar.Position if Vector3.new(au.X
-as.X,0,au.Z-as.Z).Magnitude<=2 then aq:MoveTo(au)return true end aq:MoveTo(as)
task.wait(0.1)end return false end local aq,ar local as=function()local as=K and
K:FindFirstChild('PlayerPoint')if not as then return nil end local at,au=Vector3
.zero,0 for av,aw in ipairs(K:GetDescendants())do if aw:IsA('BasePart')and aw~=
as and(aw.Position-as.Position).Magnitude<12 then at+=aw.Position au+=1 end end
if au>0 then local av=at/au if Vector3.new(av.X-as.Position.X,0,av.Z-as.Position
.Z).Magnitude>0.5 then return av end end return as.Position+as.CFrame.LookVector
*5 end local at=function(at)if aq then aq:Disconnect()aq=nil end local au=l.
Character and l.Character:FindFirstChildOfClass('Humanoid')if au then au.
AutoRotate=not at end if at then aq=k.Heartbeat:Connect(function()local av=l.
Character and l.Character:FindFirstChild('HumanoidRootPart')if av and ar then
local aw=av.Position local ax=Vector3.new(ar.X,aw.Y,ar.Z)if(ax-aw).Magnitude>0.1
then av.CFrame=CFrame.lookAt(aw,ax)end end end)end end local au=game:GetService(
'VirtualInputManager')local av=function()if K:IsA('Model')then return K:
GetPivot().Position end return ao()end local aw=function()local aw=l.Character
local ax=aw and aw:FindFirstChild('HumanoidRootPart')local _=aw and aw:
FindFirstChildOfClass('Humanoid')local ay=workspace.CurrentCamera if ax then ax.
Anchored=false end if ay then ay.CameraType=Enum.CameraType.Custom if _ then ay.
CameraSubject=_ end end end local ax=function()local ax=l.Character local ay=ax
and ax:FindFirstChild('HumanoidRootPart')local _=workspace.CurrentCamera local
az=av()if not(ay and _ and az)then return false end ay.Anchored=true _.
CameraType=Enum.CameraType.Scriptable local aA=Vector3.new(ay.Position.X-az.X,0,
ay.Position.Z-az.Z)aA=aA.Magnitude>0.1 and aA.Unit or Vector3.new(0,0,1)_.CFrame
=CFrame.lookAt(az+Vector3.new(0,10,0)+aA*3,az)task.wait(0.3)local aB,aC=_:
WorldToViewportPoint(az)z('CASH:SHIFT','tap at',math.floor(aB.X),math.floor(aB.Y
),aC)local aD,aE=pcall(function()au:SendTouchEvent(1,0,aB.X,aB.Y)task.wait(0.08)
au:SendTouchEvent(1,2,aB.X,aB.Y)end)z('CASH:SHIFT','touch sent',aD,tostring(aE))
task.wait(0.8)aw()return true end local ay=function()if not K then return false
end local ay=l.Character and l.Character:FindFirstChild('HumanoidRootPart')if ay
and not an then an=ay.Position end H('Walking to the register...')u('cashier',
true)if not ap()then u('cashier',false)H(
"Couldn't reach the register, retrying...")return false end if q.held()or not I(
)then u('cashier',false)return false end ar=as()at(true)task.wait(0.6)if q.held(
)or not I()then at(false)u('cashier',false)return false end H(
'Tapping the register...')local az=U()local aA=ax()u('cashier',false)z(
'CASH:SHIFT','tap',aA,az~=U()and'state changed'or'no visible change')al=aA if al
then am=nil H('Shift started')else at(false)H('Tap failed, retrying...')end
return al end local az=function()at(false)if E then pcall(function()E:
FireServer()end)end al=false an=nil z('CASH:SHIFT','end')end local aA=function(
aA)local aB=l.Character local aC=aB and aB:FindFirstChildOfClass('Humanoid')
local aD=aB and aB:FindFirstChild('HumanoidRootPart')if not(aC and aD and aA)
then return'none'end if v.isTp()then v.tp(aA)return'home'end u('cashier',true)
local aE,_='timeout',os.clock()while os.clock()-_<15 do if not I()or q.held()
then aE='other'break end if R()then aE='customer'break end local aF=aD.Position
if Vector3.new(aF.X-aA.X,0,aF.Z-aA.Z).Magnitude<=2 then aE='home'break end aC:
MoveTo(aA)task.wait(0.1)end u('cashier',false)aC:MoveTo(aD.Position)return aE
end local aB=function()local aB=an az()if not aB then am='waiting'H(
'Waiting for a customer...')return end H('Walking back to where you were...')
local aC=aA(aB)if aC=='customer'then an=aB elseif I()then am='waiting'H(
'Waiting for a customer...')end end local aC=function()q.cashierStarting=true
local aC,aD=pcall(ay)q.cashierStarting=false u('cashier',false)aw()if not aC
then error(aD,0)end if al and(not I()or q.held())then az()end return aD end q.
pauseCashier=function()if not al then return end local aD=os.clock()while R()and
os.clock()-aD<8 do task.wait(0.2)end az()end local aD,aE=false,{}local aF=
function(aF,_)if aD or os.clock()-(aE[aF]or 0)<0.6 then return end aD,aE[aF]=
true,os.clock()task.spawn(function()local aG,aH=pcall(_)if not aG then J('ERR',
aF,aH)end aD=false end)end local aG={Scanning='Scanning items...',
AwaitingPayment='Accepting payment...',CashChange='Giving change...',CardEntry=
'Entering card amount...'}local aH=1 local aI=function(_,aI)if am~=_ then am=_
H(aI)end end local aJ=function()if not(B and C and D)then H(
'Checkout remotes not found')return end if not K then K=L()if not K then H(
'Register not found')return end end if not S then S=true T()end if not al then
if not R()then aI('waiting','Waiting for a customer...')elseif q.held()then an=
nil aI('held','Waiting for restock to finish...')else am=nil aF('shift',aC)end
return end local _=ao()local aJ=l.Character and l.Character:FindFirstChild(
'HumanoidRootPart')local aK=false if _ and aJ then local aL=aJ.Position aK=
Vector3.new(aL.X-_.X,0,aL.Z-_.Z).Magnitude>6 end if aK then if q.held()then aI(
'held','Waiting for restock to finish...')else az()end return end local aL=M()if
not aD and not R()and os.clock()-Q>=aH and not(aL and aG[aL.phase])then aF(
'leave',aB)return end if not aL then aI('idle',
'Waiting for the next customer...')return end if aL.phase~=am then am=aL.phase
H(aG[aL.phase]or('Phase: '..tostring(aL.phase)))end if aL.phase=='Scanning'then
aF('scan',ad)elseif aL.phase=='AwaitingPayment'then aF('open',function()af(aL.
paymentMethod)end)elseif aL.phase=='CashChange'then aF('cash',aj)elseif aL.phase
=='CardEntry'then aF('card',ak)end end task.spawn(function()while p do task.
wait(0.2)if F then pcall(aJ)end end end)local aK=nil do local aL=j:
FindFirstChild('Modules')if aL then local _,aM=pcall(function()return{AP=
require(aL.ActivePlot),GC=require(aL.GoodsCatalogue),SR=require(aL.ShelfRules),
GR=require(aL.ShelfGuideRules),GCO=require(aL.GoodsCommitOutcome),PDC=require(aL
.PlayerDataClient),LC=require(aL.LevelConfig)}end)if _ then aK=aM end end end
local aL=o:FindFirstChild('Goods')local aM={PickDist=3,PickRetries=4,StandDist=
2.5,FireFrom=6,UseEmptySlots=true,Reassign=false,MaxFail=2,MaxLoops=300,DoGoods=
true,FishRestock=true,EnclosureTry=6,IdleBefore=0,RunGap=0,FullRun=true,FillMax=
180,FillWait=8}local _={BuyDelay=0.4,Cooldown=6,Safety=15,LevelCheck=5}q.ready=(
aK~=nil and aL~=nil)q.RCfg=aM q.BCfg=_ q.getOptions=function()return{}end q.
getLevel=function()return 1 end q.setSelected=function()end q.setNoclip=function
()end q.clearSkip=function()end q.buyWake=function()end q.buyReset=function()end
q.fishRoom=nil q.getPlot=function()return nil end q.fillSet,q.fillStart={},nil q
.fillEnd=function(aN)if next(q.fillSet)~=nil then z('FILL','end',tostring(aN))
end q.fillQuota,q.fillOrdered={},{}q.fillSet,q.fillStart={},nil q.buyWake()end q
.fillQuota,q.fillOrdered={},{}q.fillActive=function()if not(aM.FullRun and q.
restockOn and aM.DoGoods and next(q.fillSet)~=nil)then return false end if os.
clock()-(q.fillStart or 0)>aM.FillMax+30 then q.fillEnd('stale')return false end
return true end q.fillStep=function()return 0,true,false end local aN=function()
end local aO=function()end local aP=function()end if q.ready then local aQ,aR,aS
,aT,aU,aV,aW=aK.AP,aK.GC,aK.SR,aK.GR,aK.GCO,aK.PDC,aK.LC local aX,aY={},{}local
aZ local a_=function(a_)if a_~=aZ then aZ=a_ aN(a_)end end local a0=false local
a1=function()if not(p and q.restockOn)then return false end if q.thiefNow()then
a0=true return false end return true end local a2={}local a3=0 local a4=function
(a4)if a4 then if os.clock()-a3<2 then return end a3=os.clock()local a5=aQ.
getPlot()local a6=a5 and a5:FindFirstChild('Items')for a7,a8 in ipairs(a6 and a6
:GetChildren()or{})do if a8:IsA('Model')and aS.isShelf(a8)then for a9,ba in
ipairs(a8:GetDescendants())do if ba:IsA('BasePart')and a2[ba]==nil then a2[ba]=
ba.CanCollide ba.CanCollide=false end end end end else for a5,a6 in pairs(a2)do
if a5.Parent then a5.CanCollide=a6 end a2[a5]=nil end a3=0 end end local a5=
function(a5)u('restock',a5)pcall(a4,a5)end q.setNoclip=a5 local a6=function(a6)
if a6:IsA('Model')then return a6:GetPivot().Position end if a6:IsA('BasePart')
then return a6.Position end end local a7=function(a7,a8,a9)local ba=l.Character
local bb=ba and ba:FindFirstChildOfClass('Humanoid')local bc=ba and ba:
FindFirstChild('HumanoidRootPart')if not(bb and bc)then return false end a5(true
)local bd=os.clock()if v.isTp()then local be=a7()if not be then return false end
return v.tp(be)end while a1()and os.clock()-bd<(a9 or 20)do local be=a7()if not
be then return false end if(bc.Position-be).Magnitude<=a8 then bb:MoveTo(bc.
Position)return true end bb:MoveTo(be)task.wait(0.1)end return false end local
a8=function(a8,a9,ba,bb,bc)local bd={}local be=aQ.getPlot()local bf=be and be:
FindFirstChild('Items')local bg=l.Character and l.Character:FindFirstChild(
'HumanoidRootPart')if not(bf and bg)then return bd end local bh=aV.getGoods()
local bi=typeof(bh)=='table'and bh.Shelves or{}for bj,bk in ipairs(bf:
GetChildren())do local bl=bk:IsA('Model')and bk:GetAttribute('ItemId')if bl and(
not bc or bl==bc)and aS.isShelf(bk)and aS.acceptsGood(bk,a8)then local bm=bi[bl]
for bn,bo in ipairs(aS.slotModels(bk))do local bp=bo:GetAttribute('SlotIndex')
local bq=aS.goodsPartOf(bo)if bp and bq and not(bb and bb[bl..':'..bp])then
local br=typeof(bm)=='table'and bm[tostring(bp)]or nil local bs=typeof(br)==
'table'and typeof(br.Good)=='string'and br.Good or nil local bt=typeof(br)==
'table'and typeof(br.Qty)=='number'and br.Qty or 0 if aT.targetable({good=bs,qty
=bt},a9,ba)then local bu if bs==a9 and bt>0 then bu=1 elseif bs==a9 then bu=2
elseif bs==nil and aM.UseEmptySlots then bu=3 elseif aM.Reassign then bu=4 end
local bv=bq.CFrame.LookVector local bw=Vector3.new(bv.X,0,bv.Z)if bu and bw.
Magnitude>0.1 then local bx=Vector3.new(bq.Position.X,bg.Position.Y,bq.Position.
Z)+bw.Unit*aM.StandDist local by=(bq.Position-bg.Position).Magnitude table.
insert(bd,{pri=bu,dist=by,itemId=bl,index=bp,stand=bx,qty=bt})end end end end
end end return bd end local a9=function(a9,ba,bb,bc,bd)local be for bf,bg in
ipairs(a8(a9,ba,bb,bc,bd))do if not be or bg.pri<be.pri or(bg.pri==be.pri and bg
.dist<be.dist)then be=bg end end return be end local ba=function(ba)local bb,bc=
ba:GetAttribute('Category'),ba:GetAttribute('GoodName')local bd=aR.find(bb,bc)if
not bd then return end return bd,aR.keyOf(bb,bc),aS.boxQuantityOf(bd)end local
bb=function(bb,bc)local bd,be,bf,bg=pcall(ba,bb)if not bd or not be then return
0 end return#a8(be,bf,bg,nil,bc)end local bc=function()local bc=aQ.getPlot()
local bd=bc and bc:FindFirstChild('Boxes')return bd and bd:GetChildren()or{}end
local bd=function(bd)return bd:GetAttribute('BoxKey')or bd.Name end local be=
function()for be,bf in ipairs(bc())do if bf:GetAttribute('Carrier')==l.UserId
then return bf end end end local bf=function(bf)if not aM.DoGoods then return
end local bg=l.Character and l.Character:FindFirstChild('HumanoidRootPart')if
not bg then return end local bh,bi for bj,bk in ipairs(bc())do if bk:
GetAttribute('Carrier')==nil and not aX[bd(bk)]and bb(bk,bf)>0 then local bl=(
a6(bk)-bg.Position).Magnitude if not bi or bl<bi then bh,bi=bk,bl end end end
return bh end local bg=o:FindFirstChild('Pets')local bh=function(bh)local bi,bj=
pcall(ba,bh)return bi and bj~=nil end local bi=function(bi)return bi:
GetAttribute('Kind')=='Pet'or bi:GetAttribute('PetName')~=nil or not bh(bi)end
local bj=function()local bj=be()if not bj then return end if bi(bj)then if aM.
FishRestock then return bj end elseif aM.DoGoods then return bj end end local bk
=function(bk)return tostring(bk:GetAttribute('GoodName')or bk:GetAttribute(
'PetName')or bk:GetAttribute('Pet')or bk:GetAttribute('PetKey')or bk.Name)end
local bl=function()local bl=aQ.getPlot()local bm=bl and bl:FindFirstChild(
'Items')if not bm then return'No plot found yet'end local bn=aV.getGoods()local
bo=typeof(bn)=='table'and bn.Shelves or{}local bp,bq,br,bs=0,0,0,0 for bt,bu in
ipairs(bm:GetChildren())do local bv=bu:IsA('Model')and bu:GetAttribute('ItemId')
if bv and aS.isShelf(bu)then bp+=1 local bw=typeof(bo)=='table'and bo[bv]or nil
for bx,by in ipairs(aS.slotModels(bu))do local bz=by:GetAttribute('SlotIndex')if
bz then bq+=1 local bA=typeof(bw)=='table'and bw[tostring(bz)]or nil local bB=
typeof(bA)=='table'and typeof(bA.Good)=='string'and bA.Good or nil local bC=
typeof(bA)=='table'and typeof(bA.Qty)=='number'and bA.Qty or 0 if not bB or bC<=
0 then br+=1 else bs+=1 end end end end end local bt=0 for bu,bv in ipairs(bc())
do if bv:GetAttribute('Carrier')==nil then bt+=1 end end return(
[[Shelves: %d  |  Slots in use: %d/%d  |  Empty slots: %d  |  Boxes waiting: %d]]
):format(bp,bs,bq,br,bt)end local bm=function(bm,bn)if bg and bi(bm)then local
bo=bg:FindFirstChild(bn)if bo then return bo end end return aL[bn]end local bn=j
:FindFirstChild('Modules')local bo,bp=pcall(function()return require(bn.
EnclosureRules)end)if not bo then bp=nil end local bq,br=pcall(function()return
require(bn.PetCatalogue)end)if not bq then br=nil end local bs={}local bt=
function(bt,bu)local bv=tostring(bt)..'/'..tostring(bu)if bs[bv]then return bs[
bv]end local bw=1 if br then local bx,by=pcall(br.find,bt,bu)if bx and typeof(by
)=='Instance'then local bz=tonumber(by:GetAttribute((bp and bp.SPACE_ATTRIBUTE)
or'Space'))if bz and bz>0 then bw=bz end end end bs[bv]=bw return bw end local
bu=function()local bu={}local bv,bw=pcall(aV.getPets)if bv and typeof(bw)==
'table'then for bx,by in pairs(bw)do if typeof(by)=='table'and by.State==
'Enclosure'and by.Enclosure then bu[by.Enclosure]=(bu[by.Enclosure]or 0)+bt(by.
Type,by.Name)end end end return bu end local bv=function(bv,bw)bw=bw or bu()
local bx=aQ.getPlot()local by=bx and bx:FindFirstChild('Items')local bz=l.
Character and l.Character:FindFirstChild('HumanoidRootPart')local bA={}if not(by
and bz)then return bA end local bB=bv:GetAttribute('PetType')local bC=bt(bB,bv:
GetAttribute('PetName'))for bD,bE in ipairs(by:GetChildren())do local bF=bE:IsA(
'Model')and bE:GetAttribute('ItemId')local bG=bE:IsA('Model')and tonumber(bE:
GetAttribute('Capacity'))local bH=bE:GetAttribute('AcceptsType')if bF and bG and
(bH==nil or bH==bB)and(bw[bF]or 0)+bC<=bG then bA[#bA+1]={id=bF,model=bE,dist=(
bE:GetPivot().Position-bz.Position).Magnitude}end end table.sort(bA,function(bD,
bE)return bD.dist<bE.dist end)return bA end q.getPlot=function()local bw,bx=
pcall(aQ.getPlot)return bw and typeof(bx)=='Instance'and bx or nil end q.
fishRoom=function(bw,bx)local by=bu()local bz=aQ.getPlot()local bA=bz and bz:
FindFirstChild('Items')local bB=bt(bw,bx)local bC,bD=0,0 for bE,bF in ipairs(bA
and bA:GetChildren()or{})do local bG=bF:IsA('Model')and bF:GetAttribute('ItemId'
)local bH=bF:IsA('Model')and tonumber(bF:GetAttribute('Capacity'))local bI=bF:
GetAttribute('AcceptsType')if bG and bH and(bI==nil or bI==bw)then bD+=1 bC+=
math.max(math.floor((bH-(by[bG]or 0))/bB),0)end end local bE=0 for bF,bG in
ipairs(bc())do if bi(bG)and bG:GetAttribute('PetType')==bw and bG:GetAttribute(
'PetName')==bx then bE+=1 end end return bC,bE,bD end q.fishSpace=bt q.fishPool=
function(bw,bx)local by=bu()local bz=aQ.getPlot()local bA=bz and bz:
FindFirstChild('Items')local bB,bC,bD=0,0,0 for bE,bF in ipairs(bA and bA:
GetChildren()or{})do local bG=bF:IsA('Model')and bF:GetAttribute('ItemId')local
bH=bF:IsA('Model')and tonumber(bF:GetAttribute('Capacity'))local bI=bF:
GetAttribute('AcceptsType')if bG and bH and(bI==nil or bI==bw)then bB+=1 local
bJ=by[bG]or 0 bD+=math.max(bH-bJ,0)if bJ==0 then bC+=bH end end end local bE=0
for bF,bG in ipairs(bc())do if bi(bG)and bG:GetAttribute('PetType')==bw then bE
+=bt(bw,bG:GetAttribute('PetName'))end end local bF=(bx=='Always')and bD or bC
return math.max(bF-bE,0),bB end local bw=function()if not(aM.FishRestock and bg
and bg:FindFirstChild('PlacePetFromBox'))then return end local bw=l.Character
and l.Character:FindFirstChild('HumanoidRootPart')if not bw then return end
local bx=bu()local by={}local bz,bA for bB,bC in ipairs(bc())do if bC:
GetAttribute('Carrier')==nil and not aX[bd(bC)]and bi(bC)then local bD=tostring(
bC:GetAttribute('PetType'))..'/'..tostring(bC:GetAttribute('PetName'))if by[bD]
==nil then by[bD]=#bv(bC,bx)>0 end if by[bD]then local bE=(a6(bC)-bw.Position).
Magnitude if not bA or bE<bA then bz,bA=bC,bE end end end end return bz end
local bx={}local by local bz=function()if by then return by end local bz,bA={},{
}local bB,bC=pcall(aR.categoryFolders)if bB and typeof(bC)=='table'then for bD,
bE in ipairs(bC)do bA[#bA+1]=typeof(bE)=='Instance'and bE.Name or tostring(bE)
end end if#bA==0 then bA={'Food','Toys','Habitat','Equipment'}end for bD,bE in
ipairs(bA)do local bF,bG=pcall(aR.allOf,bE)if bF and typeof(bG)=='table'then for
bH,bI in ipairs(bG)do local bJ=typeof(bI)=='Instance'and bI.Name or tostring(bI)
local bK,bL=pcall(aR.find,bE,bJ)bz[#bz+1]=(bK and bL)or bI end end end by=bz
return bz end local bA=function(bA)return typeof(bA)=='Instance'and bA:
GetAttribute('SizeClass')or nil end local bB=function(bB)local bC,bD={},{}for bE
,bF in ipairs(bz())do local bG=bA(bF)if bG and not bC[bG]then local bH,bI=pcall(
aS.acceptsGood,bB,bF)if bH and bI then bC[bG]=true end end end for bE in pairs(
bC)do bD[#bD+1]=bE end table.sort(bD)return#bD>0 and table.concat(bD,'/')or'?'
end local bC=function(bC)local bD=aQ.getPlot()local bE=bD and bD:FindFirstChild(
'Items')local bF,bG,bH,bI,bJ=0,0,{},{},{}for bK,bL in ipairs(bE and bE:
GetChildren()or{})do if bL:IsA('Model')and bL:GetAttribute('ItemId')and aS.
isShelf(bL)then bF+=1 local bM=aS.acceptsGood(bL,bC)and true or false if bM then
bG+=1 end bJ[bL.Name]=bJ[bL.Name]or bB(bL)local bN=bL.Name..' ('..bJ[bL.Name]..
')'if not bH[bN]then bH[bN]=0 bI[#bI+1]=bN end bH[bN]+=1 z('NOSHELF','shelf',bL.
Name,bL:GetAttribute('ItemId'),#aS.slotModels(bL)..' slots',bM and'accepts'or
'rejects')end end local bK={}for bL,bM in ipairs(bI)do bK[#bK+1]=bH[bM]>1 and(bH
[bM]..'x '..bM)or bM end return bF,bG,table.concat(bK,', ')end local bD local bE
=function(bE)if not bD then bD={}local bF={}for bG,bH in ipairs(j:
GetDescendants())do if bH:IsA('Model')and not bF[bH.Name]then local bI=bH.Name:
lower()if bI:find('shelf')or bI:find('rack')then bF[bH.Name]=true bD[#bD+1]=bH
end end end end local bF={}for bG,bH in ipairs(bD)do local bI,bJ=pcall(aS.
acceptsGood,bH,bE)if bI and bJ then bF[#bF+1]=bH.Name end if#bF>=3 then break
end end return table.concat(bF,', ')end local bF=function()for bF,bG in ipairs(
bc())do if bG:GetAttribute('Carrier')==nil and not aX[bd(bG)]then local bH,bI,bJ
=pcall(ba,bG)if bH and bI and(bx[bJ]or 0)<os.clock()and bb(bG)==0 then local bK=
tostring(bG:GetAttribute('GoodName'))local bL=(typeof(bI)=='Instance'and bI:
GetAttribute('Label'))or bK local bM=bA(bI)or'?'local bN,bO,bP=bC(bI)local bQ if
bN==0 then bQ=bL..' ('..bM..
' good): you have no shelves yet. Place a shelf that holds '..bM..' goods.'
elseif bO==0 then local bR=bE(bI)bQ=bL..' is a '..bM..
' good, so it needs a shelf that holds '..bM..' goods. Your shelves: '..bP..'.'
..(bR~=''and(' Try: '..bR..'.')or'')else bQ=bL..': the '..bO..
' shelf(s) that hold '..bM..' goods are full or taken by other goods.'end z(
'NOSHELF',bK,bM,bN,bP,bO)f:Notify({Title=a,Content=bQ,Icon='info',Duration=8})bx
[bJ]=os.clock()+(bO==0 and 90 or 300)end end end end local bG=function(bG)local
bH=bd(bG)local bI=l.Character local bJ=bI and bI:FindFirstChildOfClass(
'Humanoid')local bK=bI and bI:FindFirstChild('HumanoidRootPart')if not(bJ and bK
)then return false,'no character'end a5(true)if v.isTp()then for bL=0,aM.
PickRetries do if not a1()then return false,'stopped'end if bG:GetAttribute(
'Carrier')==l.UserId then return true end if not bG.Parent then return false,
'box vanished'end local bM=a6(bG)local bN=CFrame.Angles(0,math.rad(90*bL),0):
VectorToWorldSpace(Vector3.new(aM.PickDist,0,0))v.tp(Vector3.new(bM.X+bN.X,0,bM.
Z+bN.Z))local bO=os.clock()while a1()and os.clock()-bO<1.2 do bm(bG,'PickUpBox')
:FireServer(bH)task.wait(0.25)if bG:GetAttribute('Carrier')==l.UserId then
return true end if not bG.Parent then return false,'box vanished'end end end
return false,'pickup not confirmed'end local bL,bM,bN=os.clock(),0,0 local bO,bP
,bQ=0,nil,nil local bR=function(bR)if not bQ then local bS=Vector3.new(bK.
Position.X-bR.X,0,bK.Position.Z-bR.Z)bQ=bS.Magnitude>0.5 and bS.Unit or Vector3.
new(0,0,1)end local bS=CFrame.Angles(0,math.rad(90*bO),0):VectorToWorldSpace(bQ)
local bT=bO%2==0 and aM.PickDist or(aM.PickDist+1)return Vector3.new(bR.X,bK.
Position.Y,bR.Z)+bS*bT end local bS=function(bS)bO+=1 bP=nil bN=os.clock()z(
'RESTOCK','pickup reposition',bO,bS)end while a1()and os.clock()-bL<25 do if bG:
GetAttribute('Carrier')==l.UserId then bJ:MoveTo(bK.Position)return true end if
not bG.Parent then return false,'box vanished'end if bO>aM.PickRetries then
return false,'pickup not confirmed'end local bT=a6(bG)local bU=bK.Position local
bV=(Vector3.new(bU.X,0,bU.Z)-Vector3.new(bT.X,0,bT.Z)).Magnitude local bW=bR(bT)
local bX=(Vector3.new(bU.X,0,bU.Z)-Vector3.new(bW.X,0,bW.Z)).Magnitude local bY=
os.clock()if(bU-bT).Magnitude<=aM.FireFrom and bY-bM>0.25 then bM=bY bm(bG,
'PickUpBox'):FireServer(bH)end if bV<1.5 and bY-bN>0.6 then bS('on top of box')
elseif bX<=1.2 then bP=bP or bY if bY-bP>1.5 then bS('no confirmation')end else
bP=nil end bJ:MoveTo(bW)task.wait(0.05)end return false,'pickup timeout'end
local bH=function(bH)bm(bH,'DropBox'):FireServer()local bI=os.clock()while os.
clock()-bI<2 do if bH.Parent==nil or bH:GetAttribute('Carrier')~=l.UserId then
return true end task.wait(0.1)end return false end local bI=function(bI,bJ)local
bK=bd(bI)local bL,bM,bN=ba(bI)if not bL then return false,
'item not in catalogue',false end local bO={}for bP=1,15 do if not a1()then
return false,'stopped',false end if bI:GetAttribute('Carrier')~=l.UserId then
return false,'box no longer carried',false end local bQ=a9(bL,bM,bN,bO,bJ)or(bJ
and a9(bL,bM,bN,bO))if not bQ then local bR=bH(bI)z('RESTOCK',
'shelves full, box dropped',bR)return false,'shelves full / no matching slot',
true end bO[bQ.itemId..':'..bQ.index]=true if a7(function()return bQ.stand end,
1.5,15)then local bR,bS=pcall(function()return aL.PlaceGoods:InvokeServer(bK,bQ.
itemId,bQ.index)end)local bT=aU.classify(bR,bS)z('RESTOCK','PlaceGoods',bQ.
itemId,bQ.index,bT.kind,tostring(bT.reason or bT.remainder or''))if bT.kind==
'consumed'then return true,'box emptied',false,bQ.itemId end if aU.nextAction(bT
)=='stop'then return false,bT.reason or bT.kind,false end task.wait(0.3)end end
return false,'too many attempts',false end local bJ=0 local bK=function(bK)local
bL=bd(bK)local bM=bg and bg:FindFirstChild('PlacePetFromBox')if not bM then
return false,'PlacePetFromBox remote not found',false end local bN=bv(bK)for bO,
bP in ipairs(bN)do if not a1()then return false,'stopped',false end if bK:
GetAttribute('Carrier')~=l.UserId then return bK.Parent==nil,
'box no longer carried',false end if bO>aM.EnclosureTry then break end local bQ=
l.Character and l.Character:FindFirstChild('HumanoidRootPart')if not bQ then
return false,'no character',false end local bR=bP.model:GetPivot().Position
local bS=bP.model:GetExtentsSize()local bT=math.max(bS.X,bS.Z)/2+2 local bU=
Vector3.new(bQ.Position.X-bR.X,0,bQ.Position.Z-bR.Z)local bV=bU.Magnitude>0.5
and bU.Unit or Vector3.new(0,0,1)local bW=Vector3.new(bR.X,bQ.Position.Y,bR.Z)+
bV*bT if a7(function()return bW end,2,15)then pcall(function()bM:FireServer({
boxKey=bL,enclosureKey=bP.id})end)local bX=os.clock()while os.clock()-bX<2 do
task.wait(0.1)if bK.Parent==nil or bK:GetAttribute('Carrier')~=l.UserId then z(
'RESTOCK','PlacePetFromBox ok',bL,bP.id,bP.model.Name)return true,'box emptied',
false end end z('RESTOCK','PlacePetFromBox no effect',bL,bP.id,bP.model.Name)end
end if a0 then return false,'stopped',false end aX[bL]=true local bO=bH(bK)z(
'RESTOCK','tanks full, box dropped',bL,#bN,bO)if#bN>0 and os.clock()>bJ then bJ=
os.clock()+120 f:Notify({Title=a,Content="Couldn't place "..bk(bK)..
' in any tank.',Icon='info',Duration=8})end return false,
'no tank accepted the box',true end local bL=function(bL,bM)local bN=bd(bL)aY[bN
]=(aY[bN]or 0)+1 z('RESTOCK','fail',bL.Name,aY[bN],tostring(bM))if aY[bN]>=aM.
MaxFail then aX[bN]=true z('RESTOCK','box skipped',bL.Name)end end local bM=
function()if not q.fillActive()then return end if os.clock()-(q.fillStart or os.
clock())>aM.FillMax then q.fillEnd('timeout')return end a_(
'Full restock: ordering more boxes...')local bM,bN,bO=q.fillStep()if bO then q.
fillEnd('blocked (cash / refused)')return end if bM<=0 then q.fillEnd(bN and
'all shelves full'or'nothing left to order')return end local bP=os.clock()while
a1()and os.clock()-bP<aM.FillWait do local bQ=bf()or bw()if bQ then return bQ
end task.wait(0.2)end q.fillEnd('boxes did not show up')end local bN=function()
local bN,bO,bP=0,0,0 local bQ=nil local bR=false a0=false for bS=1,aM.MaxLoops
do if not a1()then break end local bT=bj()if bT and aX[bd(bT)]then bH(bT)bT=nil
end if not bT and bR and aM.Priority=='Customers first'and q.yield()then a0=true
a_('Customer waiting, restock paused')break end if not bT then local bU=bQ and
bf(bQ)or nil if not bU then bQ=nil if bR and q.yieldTask()then a0=true a_(
'Interrupted, stepping aside')break end bU=bf()or bw()end bT=bU if not bT and q.
fillActive()then bT=bM()end if not bT then break end bR=true a_('Picking up '..
bk(bT))local bV,bW=bG(bT)if not bV then bP+=1 if not a0 then bL(bT,bW)end
continue end end bR=true local bU=bi(bT)a_((bU and'Placing fish 'or'Shelving ')
..bk(bT))local bV,bW,bX,bY if bU then bV,bW,bX=bK(bT)bQ=nil else bV,bW,bX,bY=bI(
bT,bQ)if bV and bY then bQ=bY else bQ=nil end end if bV then bN+=1 elseif bX
then bO+=1 else bP+=1 if not a0 then bL(bT,bW)end if bT.Parent and bT:
GetAttribute('Carrier')==l.UserId then bH(bT)end end task.wait(0.3)end z(
'RESTOCK','summary',bN,bO,bP)if a0 and not q.thiefNow()then a_(
'Customer waiting, restock paused')end return bN,bO,bP end q.clearSkip=function(
)for bO in pairs(aX)do aX[bO]=nil end for bO in pairs(aY)do aY[bO]=nil end end
task.spawn(function()local bO=false local bP=os.clock()local bQ=0 local bR,bS=0,
''while p do task.wait(0.3)if(q.restockOn or q.buyOn)and os.clock()-bR>1.5 then
bR=os.clock()local bT,bU=pcall(bl)if bT then aP(bU..(bS~=''and('  |  '..bS)or'')
)end end if q.restockOn and not bO then if aM.DoGoods and os.clock()-bQ>5 then
bQ=os.clock()pcall(bF)end if os.clock()-bP>120 then q.clearSkip()bP=os.clock()
end local bT,bU=pcall(function()return bj()~=nil or bf()~=nil or bw()~=nil end)
local bV=q.canLeaveDesk()if not bV and q.fillActive()and not q.thiefNow()and not
r.care and not r.clean and aM.Priority~='Customers first'then bV=true end if bT
and bU and not bV then a_(q.yield()and'Customer waiting, restock paused'or
'Waiting for a quiet moment...')elseif bT and bU then bO=true q.hold('restock',
true)local bW=os.clock()while q.cashierStarting and os.clock()-bW<15 do task.
wait(0.1)end if q.pauseCashier then pcall(q.pauseCashier)end local bX,bY,bZ,b_=
pcall(bN)if not bX then z('ERR','restock',bY)else bS=(
'Last run: %d placed, %d failed%s'):format(bY or 0,b_ or 0,a0 and
' (paused for customers)'or'')end bO=false q.hold('restock',false)a5(false)if q.
restockOn then a_('Waiting for boxes...')end elseif q.restockOn then a_((aM.
DoGoods or aM.FishRestock)and'Waiting for boxes...'or'No restock type selected')
end end end end)local bO,bP={},{}local bQ local bR=function()if not(bQ and bQ.
Parent)then bQ=nil for bR,bS in ipairs(m:GetDescendants())do if bS:IsA(
'TextLabel')and bS.Name=='Level'and bS.Text:upper():match('^LV%s*%d+')then bQ=bS
break end end end if bQ then local bR=tonumber(bQ.Text:match('%d+'))if bR then
return bR end end local bR=l:GetAttribute('Exp')if bR and aW.levelForXp then
local bS,bT=pcall(aW.levelForXp,bR)if bS and typeof(bT)=='number'then return
math.floor(bT)end end return 1 end q.getLevel=bR local bS=function()local bS={}
local bT,bU=pcall(aR.categoryFolders)if bT and typeof(bU)=='table'then for bV,bW
in ipairs(bU)do bS[#bS+1]=typeof(bW)=='Instance'and bW.Name or tostring(bW)end
end if#bS==0 then bS={'Food','Toys','Habitat','Equipment'}end return bS end q.
getOptions=function()local bT=bR()local bU={}for bV,bW in ipairs(bS())do local
bX,bY=pcall(aR.allOf,bW)if bX and typeof(bY)=='table'then for bZ,b_ in ipairs(bY
)do local b0=typeof(b_)=='Instance'and b_.Name or tostring(b_)local b1,b2=pcall(
aW.unlockLevelForGood,b_)b2=b1 and tonumber(b2)or 1 if b2<=bT then local b3=
typeof(b_)=='Instance'and b_:GetAttribute('SizeClass')table.insert(bU,{label=bW
..'/'..b0..(b3 and(' ['..b3..']')or''),cat=bW,name=b0,lv=b2})end end end end
table.sort(bU,function(bV,bW)if bV.lv~=bW.lv then return bV.lv<bW.lv end return
bV.label<bW.label end)local bV={}bP={}for bW,bX in ipairs(bU)do bV[#bV+1]=bX.
label bP[bX.label]=bX end return bV end q.setSelected=function(bT)bO={}for bU,bV
in ipairs(bT)do bO[bV]=true end q.buyWake()end local bT=function(bT,bU)local bV=
0 for bW,bX in ipairs(bc())do if bX:GetAttribute('Category')==bT and bX:
GetAttribute('GoodName')==bU then bV=bV+1 end end return bV end local bU=
function(bU,bV)local bW,bX=pcall(function()return aL.PurchaseGood:InvokeServer(
bU,bV)end)return bW and bX==true end local bV local bW=function(bW)if bW~=bV
then bV=bW aO(bW)end end local bX=function()return p and q.buyOn end local bY,bZ
={},{}local b_=false q.buyReset=function()bY,bZ={},{}bV=nil end local b0=
function(b0)if not(l.Character and l.Character:FindFirstChild('HumanoidRootPart'
))then return nil end local b1=aR.find(b0.cat,b0.name)if not b1 then return nil
end local b2=aR.keyOf(b0.cat,b0.name)local b3=aS.boxQuantityOf(b1)local b4,b5=0,
0 for b6,b7 in ipairs(a8(b1,b2,b3))do if b7.pri<=2 then b4+=1 else b5+=1 end end
local b6=0 local b7=aV.getGoods()local b8=typeof(b7)=='table'and b7.Shelves or
nil if typeof(b8)=='table'then for b9,ca in pairs(b8)do if typeof(ca)=='table'
then for cb,cc in pairs(ca)do if typeof(cc)=='table'and cc.Good==b2 and typeof(
cc.Qty)=='number'then b6+=cc.Qty end end end end end return b4,b6,b5,b1,b2 end
local b1=function(b1)local b2=aQ.getPlot()local b3=b2 and b2:FindFirstChild(
'Items')if not b3 then return 0 end local b4=aR.find(b1.cat,b1.name)if not b4
then return 0 end local b5=aR.keyOf(b1.cat,b1.name)local b6=aS.boxQuantityOf(b4)
local b7=aV.getGoods()local b8=typeof(b7)=='table'and b7.Shelves or{}local b9,ca
=0,0 for cb,cc in ipairs(b3:GetChildren())do local cd=cc:IsA('Model')and cc:
GetAttribute('ItemId')if cd and aS.isShelf(cc)and aS.acceptsGood(cc,b4)then
local ce=typeof(b8)=='table'and b8[cd]or nil for cf,cg in ipairs(aS.slotModels(
cc))do local ch=cg:GetAttribute('SlotIndex')if ch and aS.goodsPartOf(cg)then
local ci=typeof(ce)=='table'and ce[tostring(ch)]or nil local cj=typeof(ci)==
'table'and typeof(ci.Good)=='string'and ci.Good or nil local ck=typeof(ci)==
'table'and typeof(ci.Qty)=='number'and ci.Qty or 0 if cj==b5 or cj==nil then b9
+=1 if cj==b5 and ck>0 and not aT.targetable({good=cj,qty=ck},b5,b6)then ca+=1
end end end end end end return b9>0 and(ca/b9*100)or 0 end local b2=function(b2)
local b3,b4,b5,b6,b7=b0(b2)if not b3 then return 0 end local b8=bT(b2.cat,b2.
name)if b3==0 and b4==0 and b5==0 then return 0,b8==0,b6,b7 end local b9 local
ca=aM.FullRun and b5 or 0 if b3==0 and b4==0 then b9=b5 else b9=b3+((b4==0)and
ca or 0)end return math.max(b9-b8,0),false,b6,b7,b9 end local b3=function(b3,b4,
b5)if(bx[b5]or 0)>=os.clock()then return end local b6=(typeof(b4)=='Instance'and
b4:GetAttribute('Label'))or b3.name local b7=bA(b4)or'?'local b8,b9,ca=bC(b4)
local cb if b8==0 then cb=b6..' ('..b7..
' good): you have no shelves yet. Place a shelf that holds '..b7..
' goods. Not buying.'elseif b9==0 then local cc=bE(b4)cb=b6..' is a '..b7..
' good, so it needs a shelf that holds '..b7..' goods. Your shelves: '..ca..'.'
..(cc~=''and(' Try: '..cc..'.')or'')..' Not buying.'else cb=b6..': the '..b9..
' shelf(s) that hold '..b7..
' goods are full or taken by other goods. Not buying.'end z('NOSHELF',b3.name,b7
,b8,ca,b9)bW('Shelves full: '..b6)f:Notify({Title=a,Content=cb,Icon='info',
Duration=8})bx[b5]=os.clock()+(b9==0 and 90 or 300)end q.fillStep=function()
local b4=os.clock()while b_ and os.clock()-b4<15 do task.wait(0.2)end b_=true
local b5,b6,b7=0,true,false local b8,b9=pcall(function()for b8,b9 in pairs(q.
fillSet)do if not bX()then b7=true return end local ca=bP[b9]if not ca then q.
fillSet[b8]=nil else local cb,cc,cd=b0(ca)if not cb then b6=false else local ce=
cb+cd if ce<=0 then q.fillSet[b8]=nil else b6=false local cf=(q.fillQuota[b8]or
math.huge)-(q.fillOrdered[b8]or 0)if cf<=0 then q.fillSet[b8]=nil end local cg=
math.min(ce-bT(ca.cat,ca.name),cf)for ch=1,cg do if not bX()then b7=true return
end if bU(ca.cat,ca.name)then b5+=1 bW(('Full restock: buying %s (%d/%d)'):
format(b9,ch,cg))q.fillOrdered[b8]=(q.fillOrdered[b8]or 0)+1 task.wait(_.
BuyDelay)else b7=true bZ[b8]=true bW('Purchase refused (not enough cash?): '..b9
)z('BUY','refused (full restock)',b9)break end end end end end end end)b_=false
if not b8 then z('ERR','fillStep',b9)b7=true end return b5,b6,b7 end local b4=0
local b5=function()if(q.restockOn and aM.DoGoods)or os.clock()<b4 then return
end b4=os.clock()+120 f:Notify({Title=a,Content=
[[Auto Buy only orders goods. Turn on Auto Restock with "Shelves (goods)" picked (Stock tab) so the boxes get shelved.]]
,Icon='info',Duration=6})end local b6=function()local b6,b7,b8,b9=false,0,false,
false for ca in pairs(bO)do if not bX()then return end local cb=bP[ca]if cb then
b6=true local cc=cb.cat..'/'..cb.name if(bY[cc]or 0)<os.clock()and not bZ[cc]
then local cd,ce,cf,cg,ch=b2(cb)if not ce and(ch or 0)>0 and not q.fillSet[cc]
and b1(cb)>=(_.Threshold or 70)then cd,ch=0,0 end if(ch or 0)>0 and not ce and
aM.FullRun and q.restockOn and aM.DoGoods then if next(q.fillSet)==nil then q.
fillStart=os.clock()end if not q.fillSet[cc]then local ci,cj,ck=b0(cb)q.
fillQuota[cc]=math.max((ci or 0)+(ck or 0)-bT(cb.cat,cb.name),0)q.fillOrdered[cc
]=0 z('FILL','target',ca,q.fillQuota[cc])end q.fillSet[cc]=ca end if q.fillSet[
cc]then cd=math.min(cd,(q.fillQuota[cc]or cd)-(q.fillOrdered[cc]or 0))end if ce
then b9=true b3(cb,cf,cg)elseif cd>0 then for ci=1,cd do if not bX()then return
end if bU(cb.cat,cb.name)then b7+=1 bW(('Buying %s (%d/%d)'):format(ca,ci,cd))if
q.fillSet[cc]then q.fillOrdered[cc]=(q.fillOrdered[cc]or 0)+1 end task.wait(_.
BuyDelay)else b8=true bZ[cc]=true bW('Purchase refused (not enough cash?): '..ca
)z('BUY','refused',ca)break end end bY[cc]=os.clock()+_.Cooldown end end end end
if not b6 then bW('Pick items in the dropdown')elseif b7>0 then b5()elseif not
b8 and not b9 and next(bZ)==nil then bW('Shelves stocked, waiting...')end end
local b7=Instance.new('BindableEvent')local b8=false q.buyWake=function()if q.
buyOn then b8=true b7:Fire()end end local b9,ca=nil,{}local cb=function()local
cb,cc=pcall(aQ.getPlot)if not cb or typeof(cc)~='Instance'or cc==b9 then return
end b9=cc for cd,ce in ipairs(ca)do pcall(function()ce:Disconnect()end)end ca={}
local cd,ce=cc:FindFirstChild('Boxes'),cc:FindFirstChild('NPCs')if cd then ca[#
ca+1]=h(cd.ChildAdded,function()q.buyWake()end)ca[#ca+1]=h(cd.ChildRemoved,
function()q.buyWake()end)end if ce then ca[#ca+1]=h(ce.ChildRemoved,function()q.
buyWake()end)end end local cc,cd=l:GetAttribute('Cash')or 0,0 h(l:
GetAttributeChangedSignal('Cash'),function()local ce=l:GetAttribute('Cash')or 0
local cf=ce>cc cc=ce if cf and q.buyOn and next(bZ)~=nil and os.clock()-cd>=10
then cd=os.clock()for cg in pairs(bZ)do bZ[cg]=nil end q.buyWake()end end)task.
spawn(function()while p do b7.Event:Wait()while p and b8 do task.wait(0.6)b8=
false if q.buyOn then pcall(cb)if q.fillActive()or b_ then elseif not q.
canLeaveDesk()then bW('Customer waiting, buying paused')task.delay(2,q.buyWake)
else b_=true local ce,cf=pcall(b6)b_=false if not ce then z('ERR','buy',cf)end
end end end end end)task.spawn(function()while p do task.wait(_.Safety)pcall(cb)
q.buyWake()end end)end local aQ={on=false,ready=false}local aR={Types={'Fish'},
Mode='Tank empty',CashReserve=500,BuyDelay=0.4,Cooldown=6,Safety=15}aQ.FCfg=aR
aQ.getOptions=function()return{}end aQ.getLevel=function()return 1 end aQ.
setSelected=function()end aQ.setEnabled=function()end aQ.wake=function()end
local aS=function()end do local aT,aU=pcall(function()local aT=j:WaitForChild(
'Modules',10)local aU=o:WaitForChild('Pets',10)return{PC=require(aT.PetCatalogue
),LC=require(aT.LevelConfig),Purchase=aU:WaitForChild('PurchaseCrate',10)}end)if
aT and aU and aU.PC and aU.LC and aU.Purchase and q.fishRoom then aQ.ready=true
local aV,aW,aX=aU.PC,aU.LC,aU.Purchase local aY,aZ={},{}local a_,a0={},{}local
a1=Instance.new('BindableEvent')local a2=false aQ.wake=function()if aQ.on then
a2=true a1:Fire()end end local a3 local a4=function(a4)if a4~=a3 then a3=a4 aS(
a4)end end local a5=function()local a5,a6=pcall(aW.levelForXp,l:GetAttribute(
'Exp')or 0)return a5 and tonumber(a6)and math.floor(a6)or 1 end aQ.getLevel=a5
local a6=function(a6)local a7={}for a8,a9 in ipairs(aR.Types or aW.TYPE_ORDER)do
local ba,bb=pcall(aW.typeUnlockLevel,a9)local bc,bd=pcall(aW.typeRequirement,a9)
if ba and(tonumber(bb)or 1)<=a6 and not(bc and bd)then a7[#a7+1]=a9 end end
return a7 end aQ.getOptions=function()local a7=a5()local a8={}for a9,ba in
ipairs(a6(a7))do local bb,bc=pcall(aV.allOf,ba)for bd,be in ipairs(bb and bc or{
})do local bf=false for bg,bh in pairs(be:GetAttributes())do bg=bg:lower()if(bg:
find('level')or bg:find('unlock'))and type(bh)=='number'and bh>a7 then bf=true
end end if not bf and not be:GetAttribute('OffSale')then local bg=be:
GetAttribute('Rarity')local bh=tonumber(be:GetAttribute('Price'))or 0 a8[#a8+1]=
{label=ba..'/'..be.Name..(bg and(' ['..bg..']')or''),type=ba,name=be.Name,price=
bh}end end end table.sort(a8,function(a9,ba)if a9.price~=ba.price then return a9
.price<ba.price end return a9.label<ba.label end)local a9={}aZ={}for ba,bb in
ipairs(a8)do a9[#a9+1]=bb.label aZ[bb.label]=bb end return a9 end aQ.setSelected
=function(a7)aY={}for a8,a9 in ipairs(a7)do aY[a9]=true end aQ.wake()end aQ.
setEnabled=function(a7)aQ.on=a7 and true or false if aQ.on then a_,a0={},{}a3=
nil if not next(aZ)then aQ.getOptions()end end a4(aQ.on and'Running...'or
'Stopped')aQ.wake()end local a7=function(a7)local a8=l:GetAttribute('Cash')or 0
local a9,ba=pcall(aX.InvokeServer,aX,a7.type,a7.name)task.wait(0.15)local bb=l:
GetAttribute('Cash')or 0 return a9 and(ba==true or bb<a8)end local a8={}local a9
=function(a9,ba)local bb=a9.type..'/'..a9.name local bc=a9.type..'/'..a9.name
local bd,be,bf=0,false,false for bg=1,ba do if not(p and aQ.on)then return bd,be
,bf,true end local bh=l:GetAttribute('Cash')or 0 if bh-a9.price<aR.CashReserve
then bf=true a0[bb]=true break end if a7(a9)then bd+=1 a4(('Buying %s (%d/%d)'):
format(a9.name,bg,ba))task.wait(aR.BuyDelay)else be=true a0[bb]=true a4(
'Purchase refused (not enough cash?): '..a9.name)z('FISH','refused',bc)break end
end a_[bb]=os.clock()+aR.Cooldown return bd,be,bf,false end local ba=function()
local ba,bb,bc,bd,be=false,0,false,false,false local bf={}for bg in pairs(aY)do
local bh=aZ[bg]if bh then ba=true bf[bh.type]=bf[bh.type]or{}table.insert(bf[bh.
type],bh)end end for bg,bh in pairs(bf)do table.sort(bh,function(bi,bj)if bi.
price~=bj.price then return bi.price<bj.price end return bi.name<bj.name end)
local bi,bj,bk=pcall(q.fishPool,bg,aR.Mode)if bi then if bk==0 then be=true a4(
'No tank accepts '..bg)if(a8[bg]or 0)<os.clock()then a8[bg]=os.clock()+120 z(
'FISH','no tank',bg)f:Notify({Title=a,Content='You have no '..bg..
' tank to put them in. Not buying.',Icon='info',Duration=8})end else local bl,bm
,bn={},bj,true while bn do bn=false for bo,bp in ipairs(bh)do local bq=bp.type..
'/'..bp.name if(a_[bq]or 0)<os.clock()and not a0[bq]then local br=q.fishSpace(bp
.type,bp.name)if br<=bm then bm-=br bl[bq]=(bl[bq]or 0)+1 bn=true end end end
end for bo,bp in ipairs(bh)do local bq=bl[bp.type..'/'..bp.name]or 0 if bq>0
then local br,bs,bt,bu=a9(bp,bq)if bu then return end bb+=br bc=bc or bs bd=bd
or bt end end end end end if not ba then a4('Pick fish in the dropdown')elseif
bd and bb==0 then a4('Not enough cash')elseif bb==0 and not bc and not be and
not bd and next(a0)==nil then a4('Tanks full, waiting...')end end local bb,bc=
nil,{}local bd=function()local bd=q.getPlot()if not bd or bd==bb then return end
bb=bd for be,bf in ipairs(bc)do pcall(function()bf:Disconnect()end)end bc={}
local be,bf=bd:FindFirstChild('Boxes'),bd:FindFirstChild('Items')if be then bc[#
bc+1]=h(be.ChildAdded,function()aQ.wake()end)bc[#bc+1]=h(be.ChildRemoved,
function()aQ.wake()end)end if bf then bc[#bc+1]=h(bf.ChildAdded,function()aQ.
wake()end)bc[#bc+1]=h(bf.ChildRemoved,function()aQ.wake()end)end end local be,bf
=l:GetAttribute('Cash')or 0,0 h(l:GetAttributeChangedSignal('Cash'),function()
local bg=l:GetAttribute('Cash')or 0 local bh=bg>be be=bg if bh and aQ.on and
next(a0)~=nil and os.clock()-bf>=10 then bf=os.clock()for bi in pairs(a0)do a0[
bi]=nil end aQ.wake()end end)task.spawn(function()while p do a1.Event:Wait()
while p and a2 do task.wait(0.6)a2=false if aQ.on then pcall(bd)if not q.
canLeaveDesk()then a4('Customer waiting, buying paused')task.delay(2,aQ.wake)
else local bg,bh=pcall(ba)if not bg then z('ERR','fish',bh)end end end end end
end)task.spawn(function()while p do task.wait(aR.Safety)pcall(bd)aQ.wake()end
end)end end local aT=function(...)for aT,aU in ipairs({...})do local aV,aW=
pcall(f.Creator.Icon,aU)if aV and aW then return aU end end return'info'end f:
AddTheme({Name='RansBlox',Accent=Color3.fromHex('#FF8200'),Background=Color3.
fromHex('#0B0B0D'),BackgroundTransparency=0.02,Text=Color3.fromHex('#F5F5F5'),
Outline=Color3.fromHex('#27272A'),Placeholder=Color3.fromHex('#FFB066'),Button=
Color3.fromHex('#EA6F00'),Icon=Color3.fromHex('#FF8200'),Hover=Color3.fromHex(
'#1F1F23'),WindowBackground=f:Gradient({['0']={Color=Color3.fromHex('#1C1006'),
Transparency=0},['100']={Color=Color3.fromHex('#0B0B0D'),Transparency=0}},{
Rotation=135}),WindowShadow=Color3.fromHex('#000000'),WindowTopbarTitle=Color3.
fromHex('#FFFFFF'),WindowTopbarAuthor=Color3.fromHex('#FF9F40'),WindowTopbarIcon
=Color3.fromHex('#FF8200'),WindowTopbarButtonIcon=Color3.fromHex('#FF8200'),
TabBackground=Color3.fromHex('#18181B'),TabTitle=Color3.fromHex('#F5F5F5'),
TabIcon=Color3.fromHex('#FF8200'),ElementBackground=Color3.fromHex('#161618'),
ElementTitle=Color3.fromHex('#F5F5F5'),ElementDesc=Color3.fromHex('#A8A29E'),
ElementIcon=Color3.fromHex('#FF8200'),Toggle=Color3.fromHex('#FF8200'),ToggleBar
=Color3.fromHex('#2A2A2E'),Slider=Color3.fromHex('#FF8200'),SliderThumb=Color3.
fromHex('#FFFFFF')})local aU=f:CreateWindow({Title=a,Author='Ransblox Scripts',
Icon='youtube',Theme='RansBlox',NewElements=true,Folder=a,Size=UDim2.fromOffset(
560,360),Radius=20,ElementsRadius=16,ShadowTransparency=0.6,User={Enabled=true},
Topbar={Height=44,ButtonsType='Mac'},HideSearchBar=false,OpenButton={Title=a,
CornerRadius=UDim.new(1,0),StrokeThickness=3,Enabled=true,Draggable=true,
OnlyMobile=false,Scale=0.5,Color=ColorSequence.new(Color3.fromHex('#FF9A1F'),
Color3.fromHex('#FF6A00'))},ToggleKey=Enum.KeyCode.RightControl})aU:Tag({Title=b
,Icon='youtube',Color=Color3.fromHex('#FF8200'),Border=true})aU:Tag({Title=
'FREE',Icon='badge-check',Color=Color3.fromHex('#22C55E'),Border=true})local aV=
{}aV.Home=aU:Tab({Title='Home',Icon=aT('house','home'),IconColor=Color3.fromHex(
'#FF8200'),IconShape='Circle'})aV.Cashier=aU:Tab({Title='Cashier',Icon=aT(
'banknote','house'),IconColor=Color3.fromHex('#FF8200'),IconShape='Circle'})aV.
Stock=aU:Tab({Title='Stock',Icon=aT('package','shopping-cart'),IconColor=Color3.
fromHex('#FF8200'),IconShape='Circle'})aV.Fish=aU:Tab({Title='Fish Tank',Icon=
aT('fish','paw-print'),IconColor=Color3.fromHex('#FF8200'),IconShape='Circle'})
aV.Security=aU:Tab({Title='Security',Icon=aT('shield','shield-check','info'),
IconColor=Color3.fromHex('#FF8200'),IconShape='Circle'})aV.Movement=aU:Tab({
Title='Movement',Icon=aT('footprints','move','navigation'),IconColor=Color3.
fromHex('#FF8200'),IconShape='Circle'})aV.Misc=aU:Tab({Title='Misc',Icon=aT(
'info'),IconColor=Color3.fromHex('#FF8200'),IconShape='Circle'})local aW=
function(aW,aX,aY)return aW:Section({Title=aX,Icon=aT(aY),Box=true,BoxBorder=
true,Opened=false})end local aX=function(aX,aY,aZ)return aX:Section({Title=aY,
Icon=aT(aZ),Box=true,BoxBorder=true,Opened=true})end local aY=function(aY)if
type(aY)=='table'then aY=aY.Title or aY.Name or aY[1]end return tostring(aY)end
local aZ=function(aZ,a_)pcall(function()setclipboard(a_)end)f:Notify({Title=aZ,
Content='Link copied to clipboard!',Icon='check',Duration=2})end local a_=aX(aV.
Home,'Ransblox Scripts','user')a_:Paragraph({Title='Welcome!',Desc=
[[I make Roblox script showcases on YouTube and run a free script hub. ]]..
[[New scripts drop on the channel and the website, so subscribe to catch them first.]]
})local a0=aX(aV.Home,'100% Free Script','shield-check')a0:Paragraph({Title=
'This script is free',Desc=
[[No key system, no payments, no subscription. It was never sold and it never will be.]]
})a0:Paragraph({Title="Found a version with a key? It's a scam",Desc=
[[If someone is asking you for a key, money, or to complete tasks to use this script, ]]
..[[you're looking at a fake copy. Don't pay, don't enter your info. ]]..
'Only trust the official links below.'})local a1=aX(aV.Home,'Developer Note',
'message-square')a1:Paragraph({Title='Initial release (v1.0)',Desc=
[[This script was built in a single day, so you may run into bugs or rough edges. ]]
..'Thanks for your understanding while it gets polished.'})a1:Paragraph({Title=
'Is it worth continuing?',Desc=
[[Whether this script gets future updates depends on community feedback. ]]..
[[If it's been useful to you, please like the video and leave a comment. ]]..
[[Your engagement is the signal I use to decide if it's worth maintaining. ]]..
[[Bug reports and feature requests in the comments are welcome.]]})local a2=aX(
aV.Home,'Official Links','link')local a3=a2:Group()a3:Button({Title='YouTube',
Desc='Ransblox Scripts - subscribe for more scripts',Icon='youtube',Color='Red',
Callback=function()aZ('YouTube',c)end})a3:Button({Title='Website',Desc=
'ransblox.net - script hub & request page',Icon='globe',Callback=function()aZ(
'Website',d)end})local a4=aX(aV.Cashier,'Auto Cashier','banknote')a4:Toggle({
Title='Auto Cashier',Desc='Serves customers at the register for you.',Value=
false,Callback=function(a5)F=a5 if a5 then aE={}am='waiting'al=false an=nil H(
'Waiting for a customer...')else az()H('Stopped')end end})local a5=a4:Paragraph(
{Title='Status',Desc=G})H=function(a6)G=a6 pcall(function()a5:SetDesc(a6)end)end
local a6=aX(aV.Stock,'Auto Restock','package')a6:Toggle({Title='Auto Restock',
Desc='Picks up boxes and stocks them on shelves or in fish tanks.',Value=false,
Callback=function(a7)if a7 and not q.ready then n(
"Game modules not found, Auto Restock can't run.")return end q.restockOn=a7 if
a7 then q.clearSkip()else q.setNoclip(false)q.fillEnd('restock off')end aN(a7
and'Running...'or'Stopped')end})a6:Dropdown({Title='Restock what',Desc=
[[Choose whether Auto Restock handles shelves, fish tanks, or both.]],Flag=
'RestockTypes',Values={'Shelves (goods)','Fish tanks'},Value={'Shelves (goods)',
'Fish tanks'},Multi=true,AllowNone=true,Callback=function(a7)local a8={}if type(
a7)=='table'then for a9,ba in ipairs(a7)do a8[#a8+1]=aY(ba)end elseif a7~=nil
then a8[1]=aY(a7)end local a9,ba=false,false for bb,bc in ipairs(a8)do if bc==
'Shelves (goods)'then a9=true elseif bc=='Fish tanks'then ba=true end end q.RCfg
.DoGoods=a9 q.RCfg.FishRestock=ba end})a6:Toggle({Title=
'Full restock (finish before cashier)',Desc=
[[Keeps restocking until everything's full before letting the cashier take over.]]
,Value=true,Flag='FullRestock',Callback=function(a7)q.RCfg.FullRun=a7 if not a7
then q.fillEnd('full restock off')end end})a6:Toggle({Title=
'Reuse empty slots of other goods',Desc=
[[Allows restock to use empty slots that belong to another good.]],Value=false,
Callback=function(a7)q.RCfg.Reassign=a7 end})a6:Dropdown({Title='Priority',Desc=
[[Finish restock first: completes the whole restock before serving customers. Serve customers first: pauses restocking to serve waiting customers.]]
,Flag='RestockPriority',Values={'Finish restock first','Serve customers first'},
Value='Finish restock first',Callback=function(a7)q.RCfg.Priority=aY(a7):find(
'customers')and'Customers first'or'Restock first'end})local a7=a6:Paragraph({
Title='Status',Desc='Ready'})aN=function(a8)pcall(function()a7:SetDesc(a8)end)
end local a8=aX(aV.Stock,'Auto Buy','shopping-cart')a8:Toggle({Title='Auto Buy',
Desc=
[[Orders the goods you picked when your shelves need them. Turn on Auto Restock too so the boxes get shelved.]]
,Value=false,Callback=function(a9)if a9 and not q.ready then n(
"Game modules not found, Auto Buy can't run.")return end q.buyOn=a9 if a9 then q
.buyReset()else q.fillEnd('buy off')end aO(a9 and'Running...'or'Stopped')if a9
then q.buyWake()end end})local a9=a8:Dropdown({Title='Goods to buy',Desc=
[[Pick which goods Auto Buy orders. List grows as you level up.]],Flag=
'BuyItems',Values=q.getOptions(),Value={},Multi=true,AllowNone=true,Callback=
function(a9)local ba={}if type(a9)=='table'then for bb,bc in ipairs(a9)do ba[#ba
+1]=aY(bc)end elseif a9~=nil then ba[1]=aY(a9)end q.setSelected(ba)end})a8:
Slider({Title='Refill when shelves below (%)',Desc=
[[Orders more once shelf stock drops below this percent. 100 = refill the moment anything's missing.]]
,Flag='BuyThreshold',Step=5,Value={Min=10,Max=100,Default=70},Callback=function(
ba)q.BCfg.Threshold=ba q.buyWake()end})local ba=a8:Paragraph({Title='Status',
Desc='Ready'})aO=function(bb)pcall(function()ba:SetDesc(bb)end)end task.spawn(
function()local bb=q.getLevel()while p do task.wait(q.BCfg.LevelCheck)local bc=q
.getLevel()if bc~=bb then bb=bc local bd=q.getOptions()pcall(function()a9:
Refresh(bd)end)f:Notify({Title=a,Content='Level '..bc..': goods list updated ('
..#bd..' goods)',Icon='check',Duration=3})end end end)aV.Fish:Paragraph({Title=
'Restocking fish boxes?',Desc=
[[That lives in Stock > Auto Restock. Pick "Fish tanks" in Restock what.]]})
local bb=aX(aV.Fish,'Auto Buy Fish','fish')bb:Toggle({Title='Auto Buy Fish',Desc
=
[[Orders the fish you picked based on your tanks. Turn on Auto Restock with "Fish tanks" picked so the boxes get placed.]]
,Value=false,Callback=function(bc)if bc and not aQ.ready then n(
"Fish modules not found, Auto Buy Fish can't run.")return end aQ.setEnabled(bc)
end})local bc=bb:Dropdown({Title='Fish to buy',Desc=
[[Pick which fish Auto Buy Fish orders. List grows as you level up.]],Flag=
'FishItems',Values=aQ.getOptions(),Value={},Multi=true,AllowNone=true,Callback=
function(bc)local bd={}if type(bc)=='table'then for be,bf in ipairs(bc)do bd[#bd
+1]=aY(bf)end elseif bc~=nil then bd[1]=aY(bc)end aQ.setSelected(bd)end})bb:
Dropdown({Title='Buy when',Desc=
[[Tank empty: only refills tanks with no fish left. Always: fills any open spot right away.]]
,Flag='FishBuyWhen',Values={'Tank empty','Always'},Value='Tank empty',Callback=
function(bd)aQ.FCfg.Mode=aY(bd)aQ.wake()end})local bd=bb:Paragraph({Title=
'Status',Desc='Ready'})aS=function(be)pcall(function()bd:SetDesc(be)end)end task
.spawn(function()local be=aQ.getLevel()while p do task.wait(5)local bf=aQ.
getLevel()if bf~=be then be=bf pcall(function()bc:Refresh(aQ.getOptions())end)
end end end)do local be={on=false}local bf={Threshold=60,Feats={Food=true,Glass=
true,Filter=true},Wait=4,Interval=1,RunGap=0,Backoff=60}local bg={}local bh,bi
local bj=function(bj)if bj~=bi then bi=bj pcall(function()bh:SetDesc(bj)end)end
end local bk=function(bk,bl,bm)f:Notify({Title='Auto Care',Content=bk,Icon=bl or
aT('heart','info'),Duration=bm or 4})end local bl={{label='Feed (Food)',feat=
'Food',verb='feeding'},{label='Clean (Glass)',feat='Glass',verb=
'cleaning the glass'},{label='Replace (Filter)',feat='Filter',verb=
'replacing the filter'}}local bm,bn={},{}for bo,bp in ipairs(bl)do bm[bp.label]=
bp.feat bn[bp.feat]=bp.verb end local bo=o:FindFirstChild('Enclosures')local bp=
bo and bo:FindFirstChild('BeginCare')local bq=bo and bo:FindFirstChild(
'CompleteCare')local br=bo and bo:FindFirstChild('CancelCare')local bs=(bp and
bq and br)and true or false local bt=function()return p and be.on and not q.
thiefNow()end local bu=q.canLeaveDesk q.canLeaveDesk=function()if r.care then
return false end return bu()end local bv=function()if aK and aK.AP then local bv
,bw=pcall(aK.AP.getPlot)if bv and typeof(bw)=='Instance'then return bw end end
local bv=workspace:FindFirstChild('Plots')for bw,bx in ipairs(bv and bv:
GetChildren()or{})do if bx:GetAttribute('OwnerUserId')==l.UserId then return bx
end end end local bw=function()local bw=bv()local bx=bw and bw:FindFirstChild(
'Items')local by=l.Character and l.Character:FindFirstChild('HumanoidRootPart')
local bz={}if not(bx and by)then return bz end for bA,bB in ipairs(bx:
GetChildren())do local bC=bB:IsA('Model')and bB:GetAttribute('ItemId')local bD=
bB:IsA('Model')and bB:GetAttribute('MaintenanceFeatures')if bC and bD and bB:
GetAttribute('AcceptsType')=='Fish'then local bE={}for bF in tostring(bD):
gmatch('[^,]+')do local bG=tonumber(bB:GetAttribute('MaintenanceCondition_'..bF)
)if bf.Feats[bF]and bG and bG<bf.Threshold and(bg[bC..':'..bF]or 0)<os.clock()
then bE[#bE+1]={feat=bF,cond=bG}end end if#bE>0 then bz[#bz+1]={id=bC,model=bB,
need=bE,dist=(bB:GetPivot().Position-by.Position).Magnitude}end end end table.
sort(bz,function(bA,bB)return bA.dist<bB.dist end)return bz end local bx=
function(bx,by)local bz=l.Character local bA=bz and bz:FindFirstChildOfClass(
'Humanoid')local bB=bz and bz:FindFirstChild('HumanoidRootPart')if not(bA and bB
)then return false end local bC=bx:GetPivot().Position local bD=bx:
GetExtentsSize()local bE=math.max(bD.X,bD.Z)/2+by local bF=bB.Position local bG=
Vector3.new(bF.X-bC.X,0,bF.Z-bC.Z)if bG.Magnitude<=bE+0.5 then return true end
local bH=bG.Magnitude>0.5 and bG.Unit or Vector3.new(0,0,1)local bI=Vector3.new(
bC.X,bF.Y,bC.Z)+bH*bE u('care',true)if v.isTp()then u('care',false)return v.tp(
bI)end local bJ,bK,bL=os.clock(),bF,os.clock()while bt()and os.clock()-bJ<30 do
local bM=bB.Position if Vector3.new(bM.X-bI.X,0,bM.Z-bI.Z).Magnitude<=1.5 then
bA:MoveTo(bM)u('care',false)return true end bA:MoveTo(bI)if(bM-bK).Magnitude>1
then bK,bL=bM,os.clock()elseif os.clock()-bL>2 then bA.Jump=true bL=os.clock()
end task.wait(0.1)end u('care',false)return false end local by=function(by,bz)
local bA,bB=pcall(function()return bp:InvokeServer({itemKey=by,feature=bz})end)
if not(bA and type(bB)=='table'and bB.ok and bB.token)then return false,'begin'
end local bC=os.clock()while bt()and os.clock()-bC<bf.Wait do task.wait(0.1)end
if not bt()then pcall(function()br:FireServer(bB.token)end)return false,
'stopped'end local bD,bE=pcall(function()return bq:InvokeServer({itemKey=by,
token=bB.token,quiet=true,feature=bz})end)if bD and type(bE)=='table'and bE.ok
then return true end pcall(function()br:FireServer(bB.token)end)return false,
'complete'end local bz=function(bz)local bA,bB,bC=0,0,0 for bD,bE in ipairs(bz)
do if not bt()then break end if q.yieldTask()then bj(
'Interrupted, stepping aside')break end local bF={}for bG,bH in ipairs(bE.need)
do bF[#bF+1]=bn[bH.feat]or bH.feat end bj('Walking to tank '..bE.id)bk((
'Tank %d/%d: heading there for %s'):format(bD,#bz,table.concat(bF,', ')))if bx(
bE.model,2)then local bG=0 for bH,bI in ipairs(bE.need)do if not bt()or q.
yieldTask()then break end bj(('Care %s on %s (%d)'):format(bI.feat,bE.id,bI.cond
))local bJ,bK=by(bE.id,bI.feat)if not bJ and bK=='begin'and bx(bE.model,0)then
bJ,bK=by(bE.id,bI.feat)end if bJ then bG+=1 bA+=1 z('CARE','ok',bE.id,bI.feat)
elseif bK~='stopped'then bC+=1 bg[bE.id..':'..bI.feat]=os.clock()+bf.Backoff z(
'CARE','fail',bE.id,bI.feat,bK)end task.wait(0.4)end if bG>0 then bB+=1 end
elseif bt()then for bG,bH in ipairs(bE.need)do bC+=1 bg[bE.id..':'..bH.feat]=os.
clock()+bf.Backoff end z('CARE','walk failed',bE.id)end end return bA,bB,bC end
task.spawn(function()local bA,bB=false,-1e9 while p do task.wait(bf.Interval)if
be.on and not bA then if next(bf.Feats)==nil then bj('No care type selected')
else local bC=bw()if#bC==0 then bj('All tanks above threshold')elseif r.restock
or r.buy or r.thief or r.clean then bj('Waiting for restock/buy to finish...')
elseif q.thiefNow()or(F and os.clock()-bB<bf.RunGap)then bj(q.thiefNow()and
'Thief on the plot, waiting...'or'Waiting between runs...')else bA=true q.hold(
'care',true)local bD=os.clock()while q.cashierStarting and os.clock()-bD<15 do
task.wait(0.1)end if q.pauseCashier then pcall(q.pauseCashier)end local bE,bF,bG
,bH=pcall(bz,bC)if not bE then z('ERR','care',bF)elseif bt()then if bF>0 then
bk(('Done: %d action(s) on %d tank(s)'):format(bF,bG),aT('check','info'))end if
bH>0 then bk(('%d action(s) failed, retrying in %ds'):format(bH,bf.Backoff),aT(
'x','info'))end end q.hold('care',false)u('care',false)bB=os.clock()bA=false if
be.on then bj('Waiting for tanks to need care...')end end end end end end)local
bA=aX(aV.Fish,'Auto Care','heart')bA:Toggle({Title='Auto Care',Desc=
[[Feeds, cleans and maintains your fish tanks for you. Don't open the tank panel while it runs.]]
,Value=false,Callback=function(bB)if bB and not bs then n(
"Care remotes not found, Auto Care can't run.")return end be.on=bB if bB then bg
={}end bj(bB and'Running...'or'Stopped')if bB then if next(bf.Feats)==nil then
bk('Pick at least one care type first.',aT('info'))else bk(
'Enabled. Watching your tanks below '..bf.Threshold..'.',aT('check','info'))end
else bk('Disabled.',aT('x','info'),3)end end})local bB,bC={},{}for bD,bE in
ipairs(bl)do bB[#bB+1]=bE.label bC[#bC+1]=bE.label end bA:Dropdown({Title=
'Care types',Desc='Pick which care tasks Auto Care performs.',Flag='CareTypes',
Values=bB,Value=bC,Multi=true,AllowNone=true,Callback=function(bD)local bE,bF={}
,{}if type(bD)=='table'then for bG,bH in ipairs(bD)do bE[#bE+1]=aY(bH)end elseif
bD~=nil then bE[1]=aY(bD)end for bG,bH in ipairs(bE)do local bI=bm[bH]if bI then
bF[bI]=true end end bf.Feats=bF if be.on and next(bF)==nil then bj(
'No care type selected')end end})bA:Slider({Title='Care threshold',Desc=
"Care kicks in once a tank's bar drops below this percent.",Flag='CareThreshold'
,Step=5,Value={Min=10,Max=100,Default=bf.Threshold},Callback=function(bD)bf.
Threshold=bD end})bh=bA:Paragraph({Title='Status',Desc='Ready'})end do local be=
{on=false}local bf={Range=5.5,SwingGap=0.9,Charge=1,GiveUp=25,GrabRange=6,Speed=
32}local bg=o:FindFirstChild('Bat')local bh=bg and bg:FindFirstChild('Grab')
local bi=bg and bg:FindFirstChild('Drop')local bj=bg and bg:FindFirstChild(
'Swing')local bk=bg and bg:FindFirstChild('Swung')local bl=(bh and bi and bj)and
true or false local bm,bn local bo=function(bo)if bo~=bn then bn=bo pcall(
function()bm:SetDesc(bo)end)end end local bp=function(bp,bq,br)f:Notify({Title=
'Anti-Thief',Content=bp,Icon=bq or aT('shield','info'),Duration=br or 4})end
local bq={}local br=setmetatable({},{__mode='k'})local bs=function()local bs=0
for bt in pairs(bq)do if bt.Parent and bt:GetAttribute('Shoplifter')==true and
not br[bt]then bs+=1 else bq[bt]=nil end end return bs end local bt=q.yield q.
yield=function()return bt()or(be.on and bs()>0)end q.yieldTask=function()return(
be.on and bs()>0)and true or false end local bu=q.canLeaveDesk q.canLeaveDesk=
function()if be.on and(r.thief or bs()>0)then return false end return bu()end
local bv=Instance.new('BindableEvent')local bw=false local bx=function()if be.on
then bw=true bv:Fire()end end local by=function(by)local bz={}for bA,bB in
pairs(by:GetAttributes())do bz[#bz+1]=bA..'='..tostring(bB)end table.sort(bz)
return table.concat(bz,'|')end local bz=function(bz)if not bz:IsA('Model')then
return end local bA=function()if bz:GetAttribute('Shoplifter')==true then if not
bq[bz]then bq[bz]=true z('THIEF','detected',bz.Name,by(bz))bx()end else bq[bz]=
nil end end h(bz:GetAttributeChangedSignal('Shoplifter'),bA)bA()end local bA=
function()if q.getPlot then local bA=q.getPlot()if bA then return bA end end
local bA=workspace:FindFirstChild('Plots')for bB,bC in ipairs(bA and bA:
GetChildren()or{})do if bC:GetAttribute('OwnerUserId')==l.UserId then return bC
end end end local bB local bC=function()local bC=bA()local bD=bC and bC:
FindFirstChild('NPCs')if not bD or bD==bB then return end bB=bD for bE,bF in
ipairs(bD:GetChildren())do bz(bF)end h(bD.ChildAdded,bz)end task.spawn(function(
)while p do pcall(bC)task.wait(3)end end)local bD=function()return l.Character
and l.Character:FindFirstChild('HumanoidRootPart')end local bE=function()return
l.Character and l.Character:FindFirstChildOfClass('Humanoid')end local bF=
function()return l:GetAttribute('HoldingBat')==true end local bG,bH local bI=
function(bI)if bI then if bG then return end local bJ=bE()bH=bJ and bJ.WalkSpeed
or nil bG=k.Heartbeat:Connect(function()local bK=bE()if bK then bK.WalkSpeed=bf.
Speed end end)else if bG then bG:Disconnect()bG=nil end local bJ=bE()if bJ and
bH then bJ.WalkSpeed=bH end bH=nil end end local bJ=o:FindFirstChild('Goods')
local bK=o:FindFirstChild('Pets')local bL=function()local bL=bA()local bM=bL and
bL:FindFirstChild('Boxes')for bN,bO in ipairs(bM and bM:GetChildren()or{})do if
bO:GetAttribute('Carrier')==l.UserId then for bP,bQ in ipairs({bJ,bK})do local
bR=bQ and bQ:FindFirstChild('DropBox')if bR then pcall(function()bR:FireServer()
end)end end z('THIEF','dropped carried box',bO.Name)task.wait(0.2)return end end
end local bM=function(bM)local bN=bM:FindFirstChild('HumanoidRootPart')or bM.
PrimaryPart return bN and bN.Position or bM:GetPivot().Position end local bN=
function()if bF()then return true end local bN=bA()local bO,bP=os.clock(),0
while be.on and p and os.clock()-bO<12 do if bF()then return true end local bQ=
bN and bN:FindFirstChild('Bat')if not(bQ and bQ:IsA('BasePart'))then return
false,'bat not found on your plot'end if bQ:GetAttribute('HeldBy')~=nil then
return false,'someone else is holding the bat'end local bR,bS=bD(),bE()if not(bR
and bS)then return false,'no character'end if(bQ.Position-bR.Position).Magnitude
>bf.GrabRange then if v.isTp()then v.tp(bQ.Position)else bS:MoveTo(bQ.Position)
end else bS:MoveTo(bR.Position)if os.clock()-bP>0.4 then bP=os.clock()bh:
FireServer()end end task.wait(0.1)end return bF(),"couldn't grab the bat"end if
bk then h(bk.OnClientEvent,function(bO,bP,bQ,bR,bS)if bO==l then z('THIEF',
'swung',tostring(bR),tostring(bQ),tostring(bS),typeof(bP)=='table'and#bP or'-')
end end)end local bO=function(bO)local bP,bQ,bR=os.clock(),0,0 while be.on and p
and os.clock()-bP<bf.GiveUp do if not bO.Parent or bO:GetAttribute('Shoplifter')
~=true then return true,'caught'end local bS,bT=bD(),bE()if not(bS and bT)then
return false,'no character'end if not bF()then return false,'lost the bat'end if
aq then pcall(at,false)end if bS.Anchored then bS.Anchored=false end local bU=
bM(bO)local bV=Vector3.new(bU.X-bS.Position.X,0,bU.Z-bS.Position.Z)if bV.
Magnitude>bf.Range then if v.isTp()then v.tp(bU-bV.Unit*3,true)else bT:MoveTo(bU
)end task.wait(0.1)else bT:MoveTo(bS.Position)bS.CFrame=CFrame.lookAt(bS.
Position,Vector3.new(bU.X,bS.Position.Y,bU.Z))if os.clock()-bQ>=bf.SwingGap then
task.wait(0.08)bQ=os.clock()bR+=1 bj:FireServer(bf.Charge)z('THIEF','swing',bR,
bO.Name,by(bO))end task.wait(0.05)end end return false,'timeout'end local bP=
function()if bi and bF()then pcall(function()bi:FireServer()end)end end local bQ
=function()q.hold('thief',true)u('thief',true)bI(true)pcall(at,false)pcall(aw)if
al then pcall(az)end bL()bo('Thief spotted!')bp(
'Thief spotted! Grabbing the bat.',aT('shield','info'))local bQ,bR=bN()if not bQ
then bo("Can't get the bat: "..tostring(bR))z('THIEF','no bat',tostring(bR))for
bS in pairs(bq)do br[bS]=true end else while be.on and p and bs()>0 do local bS,
bT local bU=bD()for bV in pairs(bq)do if bV.Parent and not br[bV]and bU then
local bW=(bM(bV)-bU.Position).Magnitude if not bT or bW<bT then bS,bT=bV,bW end
end end if not bS then break end bo('Chasing the thief...')local bV,bW=bO(bS)if
bV then bp('Thief caught!',aT('check','info'))z('THIEF','caught',bS.Name)else br
[bS]=true bo('Gave up: '..tostring(bW))z('THIEF','gave up',bS.Name,tostring(bW),
by(bS))end task.wait(0.2)end bP()end bI(false)u('thief',false)q.hold('thief',
false)if be.on then bo('Watching for thieves...')end end task.spawn(function()
while p do bv.Event:Wait()while p and bw do task.wait(0.15)bw=false if be.on and
bs()>0 then local bR,bS=pcall(bQ)if not bR then z('ERR','thief',bS)bI(false)u(
'thief',false)q.hold('thief',false)end end end end end)task.spawn(function()
while p do task.wait(10)bx()end end)q.thiefStop=function()be.on=false pcall(bP)q
.hold('thief',false)bI(false)u('thief',false)end q.thiefNow=function()return(be.
on and(r.thief or bs()>0))and true or false end local bR=aX(aV.Security,
'Auto Anti-Thief','shield')bR:Toggle({Title='Auto Anti-Thief',Desc=
[[Chases down shoplifters and deals with them automatically. Other features pause until it's done.]]
,Value=false,Callback=function(bS)if bS and not bl then n(
"Bat remotes not found, Auto Anti-Thief can't run.")return end be.on=bS if bS
then for bT in pairs(br)do br[bT]=nil end bo('Watching for thieves...')bx()else
task.spawn(bP)bo('Stopped')end end})bR:Slider({Title='Give up after (seconds)',
Desc='Stop chasing a thief after this long.',Flag='ThiefGiveUp',Step=5,Value={
Min=10,Max=60,Default=bf.GiveUp},Callback=function(bS)bf.GiveUp=bS end})bR:
Slider({Title='Chase speed',Desc='How fast you move while chasing a thief.',Flag
='ThiefSpeed',Step=2,Value={Min=16,Max=60,Default=bf.Speed},Callback=function(bS
)bf.Speed=bS end})bm=bR:Paragraph({Title='Status',Desc='Ready'})end do local be=
{on=false}local bf={Reach=4,Delay=0.4,WalkTimeout=15,Retries=3,Backoff=30,
MaxLoops=200,Safety=10}local bg,bh local bi=function(bi)if bi~=bh then bh=bi
pcall(function()bg:SetDesc(bi)end)end end local bj=function()local bj=o:
FindFirstChild('Mess')return bj and bj:FindFirstChild('Clean')end local bk=
function()return p and be.on and not q.thiefNow()end local bl={}local bm=
function()local bm={}local bn=workspace:FindFirstChild('Plots')for bo,bp in
ipairs(bn and bn:GetChildren()or{})do local bq=bp:FindFirstChild('Messes')for br
,bs in ipairs(bq and bq:GetChildren()or{})do local bt=bs:GetAttribute('MessId')
if bt and bs:GetAttribute('OwnerUserId')==l.UserId and(bl[bt]or 0)<os.clock()
then bm[#bm+1]=bs end end end return bm end local bn=function()local bn=l.
Character and l.Character:FindFirstChild('HumanoidRootPart')local bo,bp for bq,
br in ipairs(bm())do local bs,bt=pcall(function()return br:GetPivot().Position
end)if bs then local bu=bn and(bt-bn.Position).Magnitude or 0 if not bp or bu<bp
then bo,bp=br,bu end end end return bo end local bo=function(bo)local bp=l.
Character local bq=bp and bp:FindFirstChildOfClass('Humanoid')local br=bp and bp
:FindFirstChild('HumanoidRootPart')if not(bq and br)then return false end if v.
isTp()then local bs,bt=pcall(function()return bo:GetPivot().Position end)return
bs and bo.Parent~=nil and v.tp(bt)end local bs,bt,bu=os.clock(),br.Position,os.
clock()while bk()and bo.Parent and os.clock()-bs<bf.WalkTimeout do local bv,bw=
pcall(function()return bo:GetPivot().Position end)if not bv then return false
end local bx=br.Position if Vector3.new(bx.X-bw.X,0,bx.Z-bw.Z).Magnitude<=bf.
Reach then bq:MoveTo(bx)return true end bq:MoveTo(bw)if(bx-bt).Magnitude>1 then
bt,bu=bx,os.clock()elseif os.clock()-bu>2 then bq.Jump=true bu=os.clock()end
task.wait(0.1)end return false end local bp=function(bp)local bq=bp:
GetAttribute('MessId')if not bq then return false end local br=tostring(bp:
GetAttribute('MessKind')or'mess')if not bo(bp)then if bp.Parent and bk()then bl[
bq]=os.clock()+bf.Backoff z('CLEAN','walk failed',bq,br)end return false end
task.wait(bf.Delay)for bs=1,bf.Retries do if not(bk()and bp.Parent)then break
end local bt=bj()if not bt then return false end pcall(function()bt:FireServer({
messId=bq})end)local bu=os.clock()while os.clock()-bu<1.2 and bp.Parent do task.
wait(0.1)end if not bp.Parent then z('CLEAN','ok',bq,br)return true end end if
bp.Parent and bk()then bl[bq]=os.clock()+bf.Backoff z('CLEAN','not cleaned',bq,
br)end return not bp.Parent end local bq=function()local bq,br=0,0 for bs=1,bf.
MaxLoops do if not bk()then break end local bt=bn()if not bt then break end bi((
'Cleaning %s (%d done)'):format(tostring(bt:GetAttribute('MessKind')or'mess'),bq
))if bp(bt)then bq+=1 else br+=1 end task.wait(0.2)end return bq,br end local br
=q.canLeaveDesk q.canLeaveDesk=function()if r.clean then return false end return
br()end local bs=Instance.new('BindableEvent')local bt=false local bu=function()
if be.on then bt=true bs:Fire()end end local bv=setmetatable({},{__mode='k'})
local bw=function()local bw=workspace:FindFirstChild('Plots')for bx,by in
ipairs(bw and bw:GetChildren()or{})do local bz=by:FindFirstChild('Messes')if bz
and not bv[bz]then bv[bz]=true h(bz.ChildAdded,function()bu()end)end end end
task.spawn(function()while p do bs.Event:Wait()while p and bt do task.wait(0.6)
bt=false if be.on then pcall(bw)if#bm()==0 then bi('Store is clean')elseif q.
thiefNow()then bi('Running...')task.delay(2,bu)elseif r.restock or r.care or r.
openclose then bi('Running...')task.delay(2,bu)elseif not q.canLeaveDesk()then
bi('Running...')task.delay(2,bu)else q.hold('clean',true)local bx=os.clock()
while q.cashierStarting and os.clock()-bx<15 do task.wait(0.1)end if q.
pauseCashier then pcall(q.pauseCashier)end pcall(at,false)pcall(aw)u('clean',
true)local by,bz,bA=pcall(bq)u('clean',false)q.hold('clean',false)if not by then
z('ERR','clean',bz)elseif be.on then bi(#bm()==0 and'Store is clean'or
'Running...')if#bm()>0 then task.delay(2,bu)end end end end end end end)task.
spawn(function()while p do task.wait(bf.Safety)pcall(bw)bu()end end)q.cleanStop=
function()be.on=false q.hold('clean',false)u('clean',false)end local bx=aX(aV.
Cashier,'Auto Clean',aT('sparkles','brush','trash-2'))bx:Toggle({Title=
'Auto Clean',Desc='Sweeps up the mess customers leave behind.',Value=false,Flag=
'AutoClean',Callback=function(by)if by and not bj()then n(
"Mess.Clean remote not found, Auto Clean can't run.")return end if by then bl={}
be.on=true bi('Running...')bu()else q.cleanStop()bi('Stopped')end end})bg=bx:
Paragraph({Title='Status',Desc='Ready'})end local be=aX(aV.Movement,
'Movement Mode','footprints')be:Dropdown({Title='Movement mode',Desc=
[[Walk (legit): moves naturally, safest. Teleport (fast): jumps straight to each spot. Applies to every feature.]]
,Flag='MoveMode',Values={'Walk (legit)','Teleport (fast)'},Value='Walk (legit)',
Callback=function(bf)v.teleport=aY(bf):find('Teleport')~=nil end})local bf=aW(aV
.Misc,'Interface','palette')bf:Toggle({Title='Glass Mode',Desc=
'Makes the window slightly transparent',Value=false,Callback=function(bg)aU:
ToggleTransparency(bg)end})bf:Slider({Title='UI Scale',Desc=
'Lower it if the GUI is too big on mobile',Step=0.05,Value={Min=0.7,Max=1.2,
Default=1},Callback=function(bg)aU:SetUIScale(bg)end})bf:Keybind({Title=
'Toggle GUI',Desc='Key to show/hide the window',Value='RightControl',Callback=
function(bg)local bh,bi=pcall(function()return Enum.KeyCode[bg]end)if bh and bi
then aU:Toggle()end end})local bg=aW(aV.Misc,'Config','save')local bh=bg:
Paragraph({Title='Auto-save',Desc=
[[Your settings save automatically and load back next time you join.]]})local bi
=bg:Group()bi:Button({Title='Save Now',Desc='Save your current settings',Icon=
'save',Callback=function()if aU.CurrentConfig then local bj=pcall(function()aU.
CurrentConfig:Save()end)if bj then f:Notify({Title='Config',Content=
'Settings saved!',Icon='check',Duration=2})pcall(function()bh:SetDesc(
'Last saved just now.')end)else f:Notify({Title='Config',Content=
"Couldn't save settings.",Icon='x',Duration=3})end end end})bi:Button({Title=
'Load Saved',Desc='Load your last saved settings',Icon='upload',Callback=
function()if aU.CurrentConfig then local bj=pcall(function()aU.CurrentConfig:
Load()end)if bj then f:Notify({Title='Config',Content='Settings loaded!',Icon=
'check',Duration=2})else f:Notify({Title='Config',Content=
'No saved settings found.',Icon='x',Duration=3})end end end})do local bj={on=
false,closeHour=17}local bk,bl local bm=function(bm)if bm==bl then return end bl
=bm pcall(function()bk:SetDesc(bm)end)end local bn=function()local bn=workspace:
FindFirstChild('Plots')for bo,bp in ipairs(bn and bn:GetChildren()or{})do if bp:
GetAttribute('OwnerUserId')==l.UserId then return bp end end end local bo=
function()local bo=l.PlayerGui:FindFirstChild('TopbarStandard')if not bo then
return end for bp,bq in ipairs(bo:GetDescendants())do if bq.Name=='StatusBadge'
then return bq end end end local bp=function()local bp=l.PlayerGui:
FindFirstChild('TopbarStandard')if not bp then return end for bq,br in ipairs(bp
:GetDescendants())do if br:IsA('TextLabel')and br.Name=='Time'then local bs,bt,
bu=br.Text:match('(%d+):(%d+)%s*(%a+)')if bs then bs=tonumber(bs)%12 if bu:
upper()=='PM'then bs+=12 end return bs+tonumber(bt)/60 end end end end local bq=
function()local bq=bo()if not bq then return false end for br,bs in ipairs(bq:
GetDescendants())do if bs:IsA('GuiButton')then for bt,bu in ipairs({'Activated',
'MouseButton1Click','MouseButton1Down','MouseButton1Up'})do pcall(function()
firesignal(bs[bu])end)end return true end end return false end local br=function
(br)local bs=o:FindFirstChild('Plot')return bs and bs:FindFirstChild(br)end
local bs=1.6 local bt=8 pcall(function()bt=require(j.Modules.StoreDayConfig).
SIGN_REACH_STUDS or bt end)local bu=math.max(2,bt-2)local bv=function(bv,bw)
local bx=bv:FindFirstChild('OpenSign',true)local by=l.Character local bz=by and
by:FindFirstChild('HumanoidRootPart')local bA=by and by:FindFirstChildOfClass(
'Humanoid')local bB,bC=br('OpenStore'),br('ToggleDoors')if not bx then bm(
'OpenSign not found, retrying...')return false end local bD=(bw=='open')and bB
or bC if not bD then bm((bw=='open'and'OpenStore'or'ToggleDoors')..
' remote not found, retrying...')z('OPENCLOSE','remote missing',bw)return false
end if not(bz and bA)or bA.Health<=0 then bm('Character not ready, retrying...')
return false end q.hold('openclose',true)if al then pcall(q.pauseCashier)end
local bE=os.clock()while q.cashierStarting and os.clock()-bE<15 do task.wait(0.1
)end u('openclose',true)local bF=(bw=='open')and math.max(2,bu-2)or bu if v.
isTp()and(bz.Position-bx:GetPivot().Position).Magnitude>bF then v.tp(bx:
GetPivot().Position)end local bG,bH=false,os.clock()while p and bj.on and os.
clock()-bH<15 do if q.thiefNow()then break end local bI=bx:GetPivot().Position
if(bz.Position-bI).Magnitude<=bF then bG=true break end bA:MoveTo(bI)task.wait(
0.1)end local bI=false if not bG then bm(
"Couldn't reach the sign in 15s, retrying...")z('OPENCLOSE','sign not reached',
bw)end if bG then bA:MoveTo(bz.Position)if bw=='open'then task.wait(0.2)if p and
bj.on and not q.thiefNow()and bv:GetAttribute('StoreOpen')~=true and bv:
GetAttribute('DoorsLocked')~=true then bB:FireServer()bI=true end else task.
wait(bs)if p and bj.on and not q.thiefNow()and bv:GetAttribute('StoreOpen')==
true and bv:GetAttribute('DoorsLocked')~=true then bC:FireServer()bI=true end
end task.wait(0.3)end u('openclose',false)q.hold('openclose',false)return bI end
local bw,bx=nil,0 local by={'Activated','MouseButton1Click','MouseButton1Down',
'MouseButton1Up'}local bz=function(bz)return(bz:IsA('TextLabel')or bz:IsA(
'TextButton'))and type(bz.Text)=='string'and string.match(bz.Text:lower(),
'^%s*continue')~=nil end local bA=function(bA)local bB=bA while bB and bB~=l.
PlayerGui do if bB:IsA('GuiObject')and not bB.Visible then return false end if
bB:IsA('ScreenGui')and not bB.Enabled then return false end bB=bB.Parent end
return bA.AbsoluteSize.X>0 end table.insert(g,l.PlayerGui.DescendantAdded:
Connect(function(bB)if bB:IsA('TextLabel')or bB:IsA('TextButton')then task.
defer(function()if bz(bB)then bw=bB end end)end end))local bB=function()return
bw~=nil and bw:IsDescendantOf(game)and bA(bw)end local bC=function(bC)if bw and
not bw:IsDescendantOf(game)then bw=nil end if bw and bA(bw)then return bw end if
not bC or os.clock()-bx<4 then return nil end bx=os.clock()local bD=0 for bE,bF
in ipairs(l.PlayerGui:GetDescendants())do bD+=1 if bD%800==0 then task.wait()end
if bz(bF)and bA(bF)then bw=bF return bF end end end local bD=function(bD)local
bE=bD for bF=1,4 do if not bE or bE==l.PlayerGui then break end if bE:IsA(
'GuiButton')then return bE end for bG,bH in ipairs(bE:GetChildren())do if bH:
IsA('GuiButton')then return bH end end bE=bE.Parent end end task.spawn(function(
)local bE,bF=nil,0 while p do if bj.on and not q.thiefNow()then local bG=bn()
local bH=bp()local bI=bG and(bG:GetAttribute('StoreOpen')~=true or bG:
GetAttribute('DoorsLocked')==true or(bH~=nil and bH>=bj.closeHour))local bJ=bC(
bI and true or false)if bJ then bE=bE or os.clock()if os.clock()-bE>=0.5 then
local bK=bD(bJ)if bK then local bL=by[(bF%#by)+1]bF+=1 pcall(function()
firesignal(bK[bL])end)bm('Day summary: pressed Continue')if bF==1 or bF==5 then
z('OPENCLOSE','continue pressed',bK:GetFullName(),bL,bF)end else bm(
'Continue button not found')if bF==0 then z('OPENCLOSE',
'continue label, no button',bJ:GetFullName())end bF+=1 end task.wait(0.8)end
else bE,bF=nil,0 end else bE,bF=nil,0 end task.wait(0.25)end end)task.spawn(
function()local bE,bF=0,nil local bG,bH=nil,0 while p do if bj.on then local bI=
bn()local bJ=bp()local bK=(bJ==nil)if bK then bJ=0 end if not bI then bm(
'Waiting for the plot...')elseif q.thiefNow()then bm(
'Thief on the plot, waiting...')elseif bB()then bm(
'Day summary, pressing Continue...')else local bL=bI:GetAttribute('StoreOpen')==
true local bM=(bI:GetAttribute('CustomersInside')or 0)+(bI:GetAttribute(
'CustomersPending')or 0)local bN=(not bK)and bJ>=bj.closeHour local bO=bI:
GetAttribute('DoorsLocked')==true local bP=os.clock()if bL then if bN then bF=bF
or bP if bO then bm('Closing, waiting for the store to finish...')elseif(bM==0
or bP-bF>45)and bP-bE>=15 then bE=bP bm('Walking to the sign to close...')local
bQ=bv(bI,'close')z('OPENCLOSE','close',string.format('hour %.2f inside %d',bJ,bM
),tostring(bQ))elseif bM>0 then bm(
'Closing time, waiting for customers to leave ('..bM..')')end else bF=nil bm(
string.format('Store open, closing at %02d:00',bj.closeHour))end else bF=nil if
bN then if bP-bE>=8 then bE=bP local bQ=bI:GetAttribute('StoreDay')if bQ~=bG
then bG,bH=bQ,0 end if bH>=2 and not bO then bm('Walking to the sign to open...'
)local bR=bv(bI,'open')z('OPENCLOSE','open (fallback)',string.format('hour %.2f'
,bJ),tostring(bR))else bH+=1 bm('Day over, starting next day...')local bR=br(
'StartNextDay')local bS,bT=pcall(function()if bR then bR:FireServer()end end)z(
'OPENCLOSE','next day',tostring(bS),tostring(bT),'day',tostring(bQ))end end
elseif bO then bm('Doors locked, waiting...')elseif bP-bE>=8 then bE=bP bm(
'Walking to the sign to open...')local bQ=bv(bI,'open')z('OPENCLOSE','open',
string.format('hour %.2f',bJ),tostring(bQ),bK and'(clock not found)'or'')end end
end end task.wait(1)end end)local bE=aX(aV.Cashier,'Auto Open / Close Store',
'house')bE:Toggle({Title='Auto Open / Close Store',Desc=
[[Opens and closes the store on schedule, then starts the next day.]],Value=
false,Callback=function(bF)bj.on=bF bm(bF and'Watching the store...'or'Stopped')
end})bk=bE:Paragraph({Title='Status',Desc='Ready'})end do local bj={on=true}
local bk,bl local bm local bn=0 local bo=0 local bp=function(bp)if bp==bl then
return end bl=bp pcall(function()bk:SetDesc(bp)end)end local bq=function(bq)
return(bq:IsA('TextLabel')or bq:IsA('TextButton'))and type(bq.Text)=='string'and
bq.Text:lower():gsub('%s+',' ')=='set price'end local br=function()bn=os.clock()
local br=0 for bs,bt in ipairs(l.PlayerGui:GetDescendants())do br+=1 if br%800==
0 then task.wait()end if bq(bt)then return bt end end end local bs=function(bs)
local bt=bs while bt and bt~=l.PlayerGui do if bt:IsA('GuiObject')and not bt.
Visible then return false end if bt:IsA('ScreenGui')and not bt.Enabled then
return false end bt=bt.Parent end return bs.AbsoluteSize.X>0 end local bt=
function(bt)local bu=bt:FindFirstAncestorWhichIsA('ScreenGui')or l.PlayerGui for
bv,bw in ipairs(bu:GetDescendants())do if(bw:IsA('TextLabel')or bw:IsA(
'TextButton'))and bw.Text=='Confirm'then if bw:IsA('GuiButton')then return bw
end local bx=bw:FindFirstAncestorWhichIsA('GuiButton')if bx then return bx end
return bw end end end local bu=function(bu)if bu:IsA('GuiButton')then for bv,bw
in ipairs({'Activated','MouseButton1Click','MouseButton1Down','MouseButton1Up'})
do pcall(function()firesignal(bu[bw])end)end return true end return false end
table.insert(g,l.PlayerGui.DescendantAdded:Connect(function(bv)if not bm and(bv:
IsA('TextLabel')or bv:IsA('TextButton'))then task.defer(function()if bq(bv)then
bm=bv end end)end end))task.spawn(function()local bv,bw=nil,0 while p do if bj.
on and q.restockOn then if bm and not bm:IsDescendantOf(game)then bm=nil end if
not bm and os.clock()-bn>5 then bm=br()end if bm and bs(bm)then bv=bv or os.
clock()if os.clock()-bv>=0.3 then local bx=bt(bm)if bx and bu(bx)then bw+=1 if
bw==1 then bo+=1 z('PRICE','confirm pressed',bx:GetFullName())bp(
'Confirmed price window ('..bo..')')elseif bw==4 then z('PRICE',
'window still open after 4 presses')bp("Price window won't close")end else bp(
'Price window open, Confirm button not found')end task.wait(0.6)end else bv,bw=
nil,0 if bo==0 then bp('Watching for the price window...')end end else bv,bw=nil
,0 end task.wait(0.25)end end)local bv=aX(aV.Stock,'Auto Confirm Price','check')
bv:Toggle({Title='Auto Confirm Price',Desc=
[[Auto-presses Confirm on the Set Price popup so restock doesn't get stuck.]],
Value=true,Flag='AutoConfirmPrice',Callback=function(bw)bj.on=bw bp(bw and
'Watching for the price window...'or'Off')end})bk=bv:Paragraph({Title='Status',
Desc='Ready'})end local bj=function()if _G.PETSTORETYCOON_Unloaded==aU then
return end _G.PETSTORETYCOON_Unloaded=aU if al then pcall(az)end pcall(at,false)
pcall(aw)pcall(u,'cashier',false)pcall(u,'care',false)if q.thiefStop then pcall(
q.thiefStop)end if q.cleanStop then pcall(q.cleanStop)end p=false F=false q.
restockOn=false q.buyOn=false aQ.on=false pcall(q.setNoclip,false)for bj,bk in
ipairs(g)do pcall(function()bk:Disconnect()end)end pcall(function()aU:Destroy()
end)_G.PETSTORETYCOON_Unload=nil end _G.PETSTORETYCOON_Unload=bj local bk=aW(aV.
Misc,'Script','power')bk:Button({Title='Unload Script',Desc=
'Removes the GUI and stops everything',Icon='x',Callback=bj})aV.Misc:Paragraph({
Title=a,Desc='Made by Ransblox Scripts \u{2022} '..b})if aU.Folder and aU.
ConfigManager then aU.ConfigManager:CreateConfig('default',true)end