[10086] ukuran map: 1265x1265
[10086] bom aktif: atom(r=20.760398864746094),hydrogen(r=69.20132446289062),mirv(r=32.218007387174026) | terkunci: mega,scatter
[10086] bot v4.11+fix jalan: [fix: factory duluan, REPLAY setelah mati/early death (hook AF_PLAY_AGAIN), RESPAWN maks 3x, timer EARLY ke-reset tiap match] [v4.11: bot=lahan/player=ancaman, attack-first, SAM di pusat ekonomi, peer-floor, hole dibatasi, city sebelum defense] [FIX v4.10] SAM pertama dipindah DI ATAS defense berulang (defUrgent) di urutan build -- sebelumnya starved terus selama defUrgent true (hampir sepanjang game kalau underdog), jadi sam=0 walau syarat affordable udah lama kepenuhi; [FIX v4.9] POSTURE deteksi growth-rate musuh snowball (bukan cuma ratio snapshot, ketangkep sebelum musuh keburu overtake) + COUNTER bypass budget cap buat invasi existential (>=50% pasukan gw sekali serang, masih dijaga floorT) + DEF_ASSAULT_HOLD dilewatin kalau posture udah existential (>=0.9, biar defense bisa dibangun ulang walau lagi digempur) + COLLAPSE GUARD: expand/attack full-stop pas existential assault biar semua pasukan kekonsentrasi ke defense/front; [FIX v4.8] spaced() pakai STRUCT_SPACING scaled dari rules (bukan hardcode 18) + sampleOwn rail-aware (prefer tile dalam RAIL_MAX_PATH dari struktur terdekat, fallback random) + evalFocus track existential enemy (tileShare>=25% selalu masuk kandidat, ratio cutoff 0.3x) + dominant flag inject ke score evalFocus; logger rel/kereta + boat attack dicap 0.25 + defense nggak nyerobot tabungan city + boat reach adaptif + serangan receh diabaikan + silo pas macet + defense skip kalau dominan; counter dibatasi (budget+floor) + cadangan pasukan vs musuh terkuat + warship off + SAM pertama prioritas + WATCH skip ally; map 1265x1265, POSTURE adaptif (jatah defense dari ancaman + dominasi) + build income dulu (city 3, factory, port, city 6, factory 2) + power P + satu front satu arah + serangan terorganisir + boat invade + logger WATCH + counter-attack floor + spawn nunggu pemain lain + expand nutup musuh + momentum + ukuran serangan dinamis + push besar kalau unggul + logger terintegrasi (leaderboard, aliansi, nuke, aturan game)
[10088] sender = send
[10088] RESPAWN: ada pemain 25 tile dari gw -> coba pindah ke 1400277 (1/3)
[10092] RESPAWN: ada pemain 31 tile dari gw -> coba pindah ke 327177 (2/3)
[10097] RESPAWN: ada pemain 14 tile dari gw -> coba pindah ke 1143489 (3/3)
[10100] st.attacks field: anchor_tile,retreating,target,aid,attacker,troops
[10100] LG SPAWN gw (1193,902) map 1265x1265 pemain=287
[10100] LG TETANGGA: owner189 jarak 9, owner188 jarak 35, owner19 jarak 40, owner25 jarak 51, owner71 jarak 57, owner184 jarak 71
[10100] RULES[state] H=1265, N=1600225, W=1265, _ally_seq=table(0), _removed_now=table(0), _req_last=table(0), _seq=0, _tiles_old=table(76), alliance_changed=table(3), alliance_expires=table(0), alliance_ext=table(0), alliance_extension=table(3), alliance_request_closed=table(3), alliance_requested=table(3), alliances=table(0), attack_ended=table(3), attack_started=table(3), attack_updated=table(3), attacks=table(26), bonus=table(3), built=table(0), conquest=table(3), cosmetics=table(31), cosmetics_changed=table(3), fallout_count=0, flags_changed=table(3), game_over=table(3), loaded=true, local_owner=271, map=table(31), map_id=arctic@80, message=table(3), mirvs_launched=0, nuke_detonated=table(3), nuke_launched=table(3), nukes=table(0), over_reason=-1, owner_added=table(3), owner_eliminated=table(3), owner_spawned=table(3), owners=table(287), phase=1, phase_changed=table(3), phase_ticks_left=0, playing_since=200, reinforce_ready=table(0), reinforced=table(3), render_tick=205.48538664166222, requests=table(0), road_added=table(3), road_removed=table(3), roads=table(0), rules=table(231), sam_launched=table(3), sam_missiles=table(0), shell_fired=table(3), shell_impact=table(3), shells=table(0), snapshot_loaded=table(3), stats_changed=table(3), structure_added=table(3), structure_changed=table(3), structure_leveled=table(3), structure_removed=table(3), structures=table(0), team_names=table(3), tick=206, ticked=table(3), tiles_changed=table(3), time_limit_ticks=24200, traitor_marked=table(3), unit_added=table(3), unit_hp_changed=table(3), unit_moved=table(3), unit_removed=table(3), unit_state_changed=table(3), unit_veterancy_changed=table(3), units=table(0), winner=0, winner_team=0
[10100] RULES[me] alive=true, cx=28644, cy=21660, cz=0, gold=500, id=271, income=1000, killer=0, kind=2, label_tile=1143489, max_troops=120942, name=RansbloxScripts, rgba=4291106047, spawn_tile=1143489, spawned=true, team=3, tiles=24, traitor_until=0, troops=26665
[10100] RULES[st.rules] ALLIANCE_EXTEND_WINDOW_TICKS=300, ALLY_REQUEST_COOLDOWN_TICKS=300, ALLY_REQUEST_TICKS=200, BOT_DEFENDER_LOSS_MULT=0.7, CAPITULATE_RATIO=8, DEFAULT_ATTACK_RATIO=0.2, LARGE_DEFENDER_DEPTH=0.3, WIN_SHARE=0.8
[10100] RULES[Rules] ALLIANCE_EXTEND_WINDOW_TICKS=300, ALLY_REQUEST_COOLDOWN_TICKS=300, ALLY_REQUEST_TICKS=200, BOT_DEFENDER_LOSS_MULT=0.7, CAPITULATE_RATIO=8, DEFAULT_ATTACK_RATIO=0.2, LARGE_DEFENDER_DEPTH=0.3, WIN_SHARE=0.8
[10100] RULES[Rules rail/income] AIRFIELD_RANGE_OF=156, ARTILLERY_RANGE_OF=45, BUILD_SNAP_RADIUS=15, CITY_TROOPS=250000, DEFENSE_RADIUS=30, DEFENSE_RANGE_OF=30, GOLD_PER_TICK=100, NUKE_RADIUS=table(9), PORT_SPAWN_MANHATTAN=20, RAIL_CELL_OF=4, RAIL_HEURISTIC_W=2, RAIL_LINK_HOPS=4, RAIL_MAX_PATH=155.56199999999998, RAIL_MINIMAP=2, RAIL_SNAP_OF=3, RAIL_TURN_PENALTY=3, RAIL_WATER_PENALTY=5, ROAD_MAX_TILES=110, ROAD_MIN_TILES=15, SAM_MAX_RANGE_OF=150, SAM_RADIUS=70, SHORE_PROBE_DIST=5, SPAWN_RADIUS=4, SPAWN_RADIUS_AI=4, SPAWN_RADIUS_HUMAN=4, START_GOLD=0, STRUCT_HP=table(9), STRUCT_MIN_DIST=15, STRUCT_SPACING=15, TRADE_SHORT_RANGE_OF=300, TRADE_TPT_X100=100, TRAIN_COOLDOWN_TICKS=10, TRAIN_UNITS=6, TRANSPORT_TPT_X100=100, TRIBE_GOLD_PER_TICK=50, TRIBE_SPAWN_MIN_DIST=30, TRUCKS_PER_FACTORY=6, WARSHIP_PATROL_RADIUS=100, WARSHIP_PORT_HEAL_PER_LEVEL=5, WARSHIP_PORT_SWITCH=0.75, WARSHIP_RANGE=130, WARSHIP_RANGE_OF=130, WARSHIP_VET_TRADES=25, WARSHIP_VET_TRANSPORTS=10
[10100] RULES[st.rules rail/income] AIRFIELD_RANGE_OF=156, ARTILLERY_RANGE_OF=45, BUILD_SNAP_RADIUS=10.380199037567639, CITY_TROOPS=250000, DEFENSE_RADIUS=21, DEFENSE_RANGE_OF=30, GOLD_PER_TICK=100, NUKE_RADIUS=table(9), PORT_SPAWN_MANHATTAN=13.84026538342352, RAIL_CELL_OF=4, RAIL_HEURISTIC_W=2, RAIL_LINK_HOPS=4, RAIL_MAX_PATH=107.65096817880647, RAIL_MINIMAP=2, RAIL_SNAP_OF=3, RAIL_TURN_PENALTY=3, RAIL_WATER_PENALTY=5, ROAD_MAX_TILES=76.12145960882935, ROAD_MIN_TILES=10.380199037567639, SAM_MAX_RANGE_OF=150, SAM_RADIUS=49, SHORE_PROBE_DIST=3, SPAWN_RADIUS=2.768053076684704, SPAWN_RADIUS_AI=2.768053076684704, SPAWN_RADIUS_HUMAN=2.768053076684704, START_GOLD=0, STRUCT_HP=table(9), STRUCT_MIN_DIST=10.380199037567639, STRUCT_SPACING=11, TRADE_SHORT_RANGE_OF=300, TRADE_TPT_X100=144, TRAIN_COOLDOWN_TICKS=10, TRAIN_UNITS=6, TRANSPORT_TPT_X100=144, TRIBE_GOLD_PER_TICK=50, TRIBE_SPAWN_MIN_DIST=20.760398075135278, TRUCKS_PER_FACTORY=6, WARSHIP_PATROL_RADIUS=69, WARSHIP_PORT_HEAL_PER_LEVEL=5, WARSHIP_PORT_SWITCH=0.75, WARSHIP_RANGE=89, WARSHIP_RANGE_OF=130, WARSHIP_VET_TRADES=25, WARSHIP_VET_TRANSPORTS=10
[10100] LG TEAM/owner (kosong = nggak ada field team): 1:0 2:0 3:0 4:0 5:0 6:0 7:0 8:0 9:0 10:0 11:0 12:0 13:0 14:0 15:0 16:0 17:0 18:0 19:0 20:0 21:0 22:0 23:0 24:0 25:0 26:0 27:0 28:0 29:0 30:0 31:0 32:0 33:0 34:0 35:0 36:0 37:0 38:0 39:0 40:0 41:0 42:0 43:0 44:0 45:0 46:0 47:0 48:0 49:0 50:0 51:0 52:0 53:0 54:0 55:0 56:0 57:0 58:0 59:0 60:0 61:0 62:0 63:0 64:0 65:0 66:0 67:0 68:0 69:0 70:0 71:0 72:0 73:0 74:0 75:0 76:0 77:0 78:0 79:0 80:0 81:0 82:0 83:0 84:0 85:0 86:0 87:0 88:0 89:0 90:0 91:0 92:0 93:0 94:0 95:0 96:0 97:0 98:0 99:0 100:0 101:0 102:0 103:0 104:0 105:0 106:0 107:0 108:0 109:0 110:0 111:0 112:0 113:0 114:0 115:0 116:0 117:0 118:0 119:0 120:0 121:0 122:0 123:0 124:0 125:0 126:0 127:0 128:0 129:0 130:0 131:0 132:0 133:0 134:0 135:0 136:0 137:0 138:0 139:0 140:0 141:0 142:0 143:0 144:0 145:0 146:0 147:0 148:0 149:0 150:0 151:0 152:0 153:0 154:0 155:0 156:0 157:0 158:0 159:0 160:0 161:0 162:0 163:0 164:0 165:0 166:0 167:0 168:0 169:0 170:0 171:0 172:0 173:0 174:0 175:0 176:0 177:0 178:0 179:0 180:0 181:0 182:0 183:0 184:0 185:0 186:0 187:0 188:0 189:0 190:0 191:0 192:0 193:0 194:0 195:0 196:0 197:0 198:0 199:0 200:0 201:0 202:0 203:0 204:0 205:0 206:0 207:0 208:0 209:0 210:0 211:0 212:0 213:0 214:0 215:0 216:0 217:0 218:0 219:0 220:0 221:0 222:0 223:0 224:0 225:0 226:0 227:0 228:0 229:0 230:0 231:0 232:0 233:0 234:0 235:0 236:0 237:0 238:0 239:0 240:0 241:0 242:0 243:0 244:0 245:0 246:0 247:0 248:0 249:0 250:0 251:0 252:0 253:0 254:0 255:0 256:0 257:2 258:3 259:1 260:2 261:1 262:3 263:1 264:2 265:2 266:1 267:3 268:2 269:1 270:2 271:3 272:1 273:2 274:3 275:3 276:1 277:2 278:3 279:3 280:1 281:1 282:2 283:3 284:1 285:3 286:2 287:1
[10100] LG ME rank=111 tiles=24(0.0%) troops=26665/120942 gold=500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG --- LEADERBOARD ---
[10100] LG #1 owner286 [musuh] hidup tiles=56(0.0%) troops=13603/128877 gold=500 jarak=610 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #2 owner285 [ally] hidup tiles=56(0.0%) troops=13603/128877 gold=500 jarak=772 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #3 owner284 [musuh] hidup tiles=52(0.0%) troops=6862/64226 gold=500 jarak=266 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #4 owner229 [musuh] hidup tiles=42(0.0%) troops=4190/41783 gold=250 jarak=686 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #5 owner254 [musuh] hidup tiles=37(0.0%) troops=4546/40990 gold=250 jarak=1220 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #6 owner156 [musuh] hidup tiles=37(0.0%) troops=7134/41472 gold=250 jarak=215 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #7 owner48 [musuh] hidup tiles=34(0.0%) troops=4084/40314 gold=250 jarak=237 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] LG #8 owner230 [musuh] hidup tiles=34(0.0%) troops=7472/40990 gold=250 jarak=581 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10100] REC troops=26665/120942 gold=500 inc=1000/s tiles=24 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=0(0, kontak 0) | rival=- hostile=0 brutal=false | nuke di udara=0 | foeSilo=0
[10100] WATCH #1 land: owner=286 tiles=56(+0) troops=13603(+0) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10100] POSTURE need=0.00 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.00] dom=1.00 | jatah defense=0% -> FOKUS INCOME
[10100] troops=26665 E:1144751@0.15 E:1139695@0.15 E:1146020@0.15 E:1139692@0.15 E:1140956@0.15
[10101] STATE tick: 206 -> 211
[10101] STATE render_tick: 205.48538664166222 -> 210.87617531374525
[10101] STATE tick: 211 -> 216
[10101] STATE render_tick: 210.87617531374525 -> 215.98478443905546
[10102] STATE tick: 216 -> 222
[10102] STATE render_tick: 215.98478443905546 -> 221.20363487881642
[10102] FOCUS -> owner 189 ratio=1.29 contact=true jarak=9 skor=1.78 brutal=false existential=false(0.2%)
[10102] STATE tick: 222 -> 227
[10102] STATE render_tick: 221.20363487881642 -> 226.35440010170237
[10103] STATE tick: 227 -> 232
[10103] STATE render_tick: 226.35440010170237 -> 231.49191835254268
[10103] STATE tick: 232 -> 237
[10103] STATE render_tick: 231.49191835254268 -> 236.64710946870014
[10105] FRONT -> owner 189 P=3.31 arah=(0.92,0.40) pasukan musuh=4601
[10105] FRONT owner 189 P=3.31 kerucut=10 tile, pasukan gw=26300 musuh=4601
[10106] COST tile=1148557 loss/tile=69 x40 tile=4670 kirim=6164 pasukan=28233 musuh=4887
[10106] troops=28233 E:1157411@0.18 E:1154862@0.18 E:1130826@0.18
[10107] LG ME rank=12 tiles=509(0.1%) troops=30247/226683 gold=6500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10107] COST tile=1148557 loss/tile=74 x40 tile=5003 kirim=6604 pasukan=30247 musuh=5186
[10107] troops=30247 E:1140970@0.18 E:1147271@0.18 E:1151066@0.18
[10107] MOMENTUM owner 189 mom=0.50 (pasukan turun) pasukan=4547
[10107] POSTURE need=0.34 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.50] dom=0.15 | jatah defense=0% -> SEIMBANG
[10111] REC troops=28159/283401 gold=11000 inc=963/s tiles=893 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=189(5328, kontak 45) | rival=- hostile=3 brutal=true | nuke di udara=0 | foeSilo=0
[10112] COST tile=1153620 loss/tile=42 x40 tile=5729 kirim=7563 pasukan=34640 musuh=6352
[10112] troops=34640 E:1127057@0.18 E:1163714@0.18 E:1127028@0.18
[10113] LG ME rank=14 tiles=935(0.1%) troops=20458/283401 gold=13000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10116] FRONT owner 189 P=3.30 kerucut=41 tile, pasukan gw=32152 musuh=9178
[10118] COST tile=1153620 loss/tile=58 x40 tile=3958 kirim=5224 pasukan=41878 musuh=8500
[10118] COST tile=1171314 loss/tile=61 x40 tile=2836 kirim=3403 pasukan=41878 musuh=15192
[10118] troops=41878 E:1123226@0.18 E:1129593@0.18 E:1170036@0.18
[10118] COST tile=1166260 loss/tile=59 x40 tile=3985 kirim=5260 pasukan=44548 musuh=8936
[10118] COST tile=1140934 loss/tile=56 x40 tile=2607 kirim=3129 pasukan=44548 musuh=9879
[10118] COST tile=1171314 loss/tile=61 x40 tile=2845 kirim=3414 pasukan=44548 musuh=15793
[10118] troops=44548 E:1118202@0.18 E:1154852@0.18 E:1167505@0.18
[10119] LG ME rank=6 tiles=1595(0.2%) troops=26422/348341 gold=19000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10119] POSTURE need=0.56 [serang=0.00 loss=0.00 kuat=0.65 brutal=0.50] dom=0.04 | jatah defense=0% -> SEIMBANG
[10121] WATCH leader ganti: owner 286 -> owner 269
[10121] WATCH #1 land: owner=269 tiles=2094(+0) troops=22878(+0) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10121] REC troops=35193/379941 gold=21000 inc=979/s tiles=1823 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=188(15271, kontak 16) | rival=- hostile=5 brutal=true | nuke di udara=0 | foeSilo=0
[10123] FOCUS -> owner 19 ratio=4.59 contact=true jarak=35 skor=10.94 brutal=true existential=false(0.4%)
[10123] MOMENTUM owner 19 mom=0.49 (pasukan turun) pasukan=9942
[10123] troops=48451 E:1127065@0.18 E:1172562@0.18 E:1116900@0.18
[10125] LG ME rank=4 tiles=2244(0.3%) troops=35303/416569 gold=25500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10125] LG MATI owner238 (tiles terakhir 0)
[10125] LG MATI owner202 (tiles terakhir 0)
[10126] MOMENTUM owner 71 mom=0.46 (pasukan turun) pasukan=13812
[10126] FRONT owner 189 P=3.73 kerucut=50 tile, pasukan gw=40371 musuh=10819
[10128] STATE _seq: 0 -> 1
[10129] FRONT -> owner 19 P=7.15 arah=(-0.96,0.27) pasukan musuh=10924
[10129] troops=54952 E:1127070@0.18 E:1177615@0.18 E:1101721@0.18
[10131] LG ME rank=4 tiles=2877(0.4%) troops=42130/465396 gold=31500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG MATI owner30 (tiles terakhir 0)
[10131] LG --- LEADERBOARD ---
[10131] LG #1 owner276 [musuh] hidup tiles=3397(0.4%) troops=14806/508836 gold=31200 jarak=961 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #2 owner273 [musuh] hidup tiles=3316(0.4%) troops=7152/493627 gold=31500 jarak=476 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #3 owner265 [musuh] hidup tiles=2966(0.4%) troops=23706/474581 gold=44150 jarak=477 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #4 owner271 [GW] hidup tiles=2877(0.4%) troops=42130/465396 gold=31500 jarak=0 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #5 owner260 [musuh] hidup tiles=2875(0.4%) troops=3791/469892 gold=31500 jarak=633 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #6 owner269 [musuh] hidup tiles=2819(0.4%) troops=33287/463057 gold=31500 jarak=954 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #7 owner286 [musuh] hidup tiles=2701(0.3%) troops=68188/453515 gold=31500 jarak=605 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] LG #8 owner282 [musuh] hidup tiles=2594(0.3%) troops=68634/446951 gold=30800 jarak=276 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10131] REC troops=42130/465396 gold=31500 inc=998/s tiles=2877 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=25(22447, kontak 21) | rival=- hostile=7 brutal=true | nuke di udara=0 | foeSilo=0
[10133] boat scan: 113 target (<=70 langkah, reach x1) dari 24 titik pantai
[10133] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=15918
[10135] troops=60604 E:1123281@0.18 E:1182654@0.18 E:1167474@0.18
[10135] troops=64087 E:1101706@0.18 E:1177594@0.18 E:1178859@0.18
[10137] FRONT owner 19 P=4.17 kerucut=72 tile, pasukan gw=45833 musuh=14332
[10138] LG ME rank=3 tiles=3505(0.4%) troops=51879/515730 gold=38000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10138] LG MATI owner210 (tiles terakhir 0)
[10138] LG MATI owner191 (tiles terakhir 0)
[10139] POSTURE need=0.46 [serang=0.00 loss=0.00 kuat=0.27 brutal=0.50] dom=0.25 | jatah defense=0% -> SEIMBANG
[10140] troops=65404 E:1167454@0.18 E:1127084@0.18 E:1200354@0.18
[10141] WATCH leader ganti: owner 269 -> owner 282
[10141] WATCH #1 land: owner=282 tiles=4118(+0) troops=64508(+0) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10142] REC troops=67236/544288 gold=42000 inc=1000/s tiles=3919 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=25(33553, kontak 65) | rival=- hostile=8 brutal=true | nuke di udara=0 | foeSilo=0
[10142] boat scan: 88 target (<=70 langkah, reach x1) dari 24 titik pantai
[10142] troops=67236 E:1158592@0.18 E:1127088@0.18 E:1125823@0.18
[10144] LG ME rank=3 tiles=4099(0.5%) troops=68933/555736 gold=44000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10144] LG MATI owner174 (tiles terakhir 0)
[10144] LG MATI owner42 (tiles terakhir 0)
[10144] LG MATI owner12 (tiles terakhir 0)
[10144] LG MATI owner161 (tiles terakhir 0)
[10144] FOCUS -> owner 189 ratio=5.33 contact=true jarak=46 skor=11.39 brutal=true existential=false(0.3%)
[10144] troops=68933 E:1150993@0.18 E:1128356@0.18 E:1125825@0.18
[10144] troops=72753 E:1127091@0.18 E:1147204@0.15 E:1125826@0.15
[10145] troops=76693 E:1147194@0.18 E:1129623@0.18 E:1144673@0.18
[10146] MOMENTUM owner 71 mom=0.47 (pasukan turun) pasukan=16819
[10146] POSTURE need=0.80 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=0% -> DEFENSE DULU
[10147] FRONT owner 19 P=1.88 kerucut=82 tile, pasukan gw=48121 musuh=21147
[10150] LG ME rank=4 tiles=4795(0.6%) troops=72390/602073 gold=50500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10150] LG MATI owner152 (tiles terakhir 0)
[10150] boat scan: 88 target (<=70 langkah, reach x1) dari 24 titik pantai
[10150] troops=72390 E:1158562@0.18 E:1126940@0.18 E:1124416@0.18
[10151] FRONT -> owner 189 P=4.64 arah=(0.97,0.22) pasukan musuh=14741
[10152] REC troops=61635/615307 gold=52500 inc=1020/s tiles=5013 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=25(54717, kontak 65) | rival=owner 25 hostile=8 brutal=true | nuke di udara=0 | foeSilo=0
[10154] ATKSIZE owner 189 N=55 ratio=0.07 mom=0.00 fill=0.21 P=2.95
[10154] troops=133667 A:1152358@0.07
[10155] ATKSIZE owner 189 N=55 ratio=0.04 mom=0.00 fill=0.21 P=2.81
[10155] troops=129596 A:1167527@0.04
[10155] ATKSIZE owner 189 N=55 ratio=0.04 mom=0.00 fill=0.21 P=2.79
[10155] troops=129699 A:1152359@0.04
[10156] ATKSIZE owner 189 N=55 ratio=0.04 mom=0.00 fill=0.21 P=2.78
[10156] troops=130059 A:1134652@0.04
[10156] LG ME rank=8 tiles=5243(0.7%) troops=135501/628682 gold=56500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10156] LG MATI owner148 (tiles terakhir 0)
[10156] LG MATI owner140 (tiles terakhir 0)
[10156] LG MATI owner56 (tiles terakhir 0)
[10156] LG MATI owner211 (tiles terakhir 0)
[10156] LG MATI owner162 (tiles terakhir 0)
[10156] LG MATI owner260 (tiles terakhir 0)
[10156] ATKSIZE owner 189 N=55 ratio=0.07 mom=0.00 fill=0.22 P=2.88
[10156] troops=135501 A:1170056@0.07
[10157] ATKSIZE owner 189 N=107 ratio=0.07 mom=0.30 fill=0.22 P=4.34
[10157] troops=135949 A:1153625@0.07
[10157] FRONT owner 189 P=4.20 kerucut=71 tile, pasukan gw=131486 musuh=30782
[10157] ATKSIZE owner 19 N=46 ratio=0.04 mom=0.00 fill=0.21 P=2.48
[10157] troops=131486 A:1166208@0.04
[10158] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=18017
[10158] idle: nggak ada target layak (fokus=189 boatTargets=88)
[10159] boat scan: 149 target (<=70 langkah, reach x1) dari 24 titik pantai
[10159] FOCUS -> owner 71 ratio=6.84 contact=true jarak=91 skor=12.65 brutal=true existential=false(0.4%)
[10159] ATKSIZE owner 19 N=46 ratio=0.04 mom=0.00 fill=0.21 P=2.40
[10159] troops=133409 A:1167466@0.04
[10160] ATKSIZE owner 71 N=134 ratio=0.07 mom=0.50 fill=0.22 P=10.97
[10160] troops=138952 A:1127093@0.07
[10160] ATKSIZE owner 71 N=134 ratio=0.07 mom=0.50 fill=0.22 P=10.60
[10160] troops=139551 A:1129627@0.07
[10161] ATKSIZE owner 25 N=40 ratio=0.04 mom=0.00 fill=0.21 P=1.56
[10161] troops=134862 A:1183926@0.04
[10161] WATCH leader ganti: owner 282 -> owner 286
[10161] WATCH #1 land: owner=286 tiles=7363(+0) troops=118486(+0) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10161] ATKSIZE owner 71 N=55 ratio=0.07 mom=0.00 fill=0.22 P=2.96
[10161] troops=140642 A:1127095@0.07
[10162] LG SERANG MASUK dari owner25 troops=26196 (pasukan gw 135583)
[10162] POSTURE need=0.59 [serang=0.40 loss=0.00 kuat=0.31 brutal=0.50] dom=0.22 | jatah defense=0% -> SEIMBANG
[10163] LG ME rank=11 tiles=5641(0.7%) troops=146156/654191 gold=63000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG MATI owner5 (tiles terakhir 0)
[10163] LG MATI owner44 (tiles terakhir 0)
[10163] LG MATI owner74 (tiles terakhir 0)
[10163] LG MATI owner95 (tiles terakhir 0)
[10163] LG MATI owner22 (tiles terakhir 0)
[10163] LG MATI owner197 (tiles terakhir 0)
[10163] LG --- LEADERBOARD ---
[10163] LG #1 owner286 [musuh] hidup tiles=7635(1.0%) troops=135138/763686 gold=63000 jarak=571 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #2 owner259 [musuh] hidup tiles=7491(0.9%) troops=270498/756340 gold=63000 jarak=864 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #3 owner278 [ally] hidup tiles=6850(0.9%) troops=159120/721047 gold=121400 jarak=1094 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #4 owner265 [musuh] hidup tiles=6579(0.8%) troops=38070/707839 gold=75650 jarak=472 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #5 owner279 [ally] hidup tiles=6390(0.8%) troops=133366/697076 gold=63000 jarak=704 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #6 owner266 [musuh] hidup tiles=6300(0.8%) troops=201449/691900 gold=63000 jarak=930 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #7 owner274 [ally] hidup tiles=6208(0.8%) troops=77497/685444 gold=90350 jarak=630 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] LG #8 owner282 [musuh] hidup tiles=5990(0.8%) troops=122163/674520 gold=80350 jarak=246 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10163] REC troops=146156/654191 gold=63000 inc=1020/s tiles=5641 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=1(22803 troops) | tetangga terkuat=66(68142, kontak 9) | rival=- hostile=9 brutal=true | nuke di udara=0 | foeSilo=0
[10164] MOMENTUM owner 25 mom=0.50 (pasukan turun) pasukan=48529
[10167] boat scan: 146 target (<=70 langkah, reach x1) dari 24 titik pantai
[10167] ATKSIZE owner 71 N=99 ratio=0.34 mom=0.24 fill=0.30 P=4.38
[10167] troops=198387 A:1100503@0.34
[10168] FRONT owner 189 P=3.02 kerucut=73 tile, pasukan gw=134382 musuh=47156
[10168] ATKSIZE owner 184 N=40 ratio=0.03 mom=0.00 fill=0.21 P=1.69
[10168] troops=134382 A:1101702@0.03
[10168] ATKSIZE owner 184 N=40 ratio=0.03 mom=0.00 fill=0.21 P=1.67
[10168] troops=135499 A:1100439@0.03
[10169] LG ME rank=15 tiles=5892(0.7%) troops=141038/664096 gold=69000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10169] LG MATI owner46 (tiles terakhir 0)
[10169] LG MATI owner106 (tiles terakhir 0)
[10169] LG MATI owner50 (tiles terakhir 0)
[10169] LG MATI owner81 (tiles terakhir 0)
[10169] LG MATI owner187 (tiles terakhir 0)
[10169] ATKSIZE owner 71 N=103 ratio=0.06 mom=0.27 fill=0.21 P=3.22
[10169] troops=141038 A:1085329@0.06
[10169] ATKSIZE owner 19 N=57 ratio=0.05 mom=0.12 fill=0.21 P=2.03
[10169] troops=142188 A:1159866@0.05
[10170] ATKSIZE owner 71 N=107 ratio=0.08 mom=0.30 fill=0.22 P=3.64
[10170] troops=147915 A:1085340@0.08
[10170] ATKSIZE owner 19 N=57 ratio=0.05 mom=0.13 fill=0.21 P=2.04
[10170] troops=145517 A:1163663@0.05
[10171] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=48520
[10171] MOMENTUM owner 184 mom=0.45 (tanah turun, diserang pihak lain) pasukan=64809
[10171] FRONT -> owner 71 P=5.19 arah=(0.85,-0.53) pasukan musuh=37542
[10171] ATKSIZE owner 71 N=107 ratio=0.07 mom=0.30 fill=0.22 P=5.19
[10171] troops=151406 A:1081550@0.07
[10172] ATKSIZE owner 71 N=107 ratio=0.10 mom=0.30 fill=0.22 P=5.53
[10172] troops=157421 A:1079020@0.10
[10172] ATKSIZE owner 71 N=107 ratio=0.06 mom=0.30 fill=0.21 P=5.46
[10172] troops=151490 A:1080288@0.06
[10173] REC troops=139398/728179 gold=73000 inc=984/s tiles=7068 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=188(82811, kontak 29) | rival=- hostile=8 brutal=true | nuke di udara=0 | foeSilo=0
[10173] idle: nggak ada target layak (fokus=71 boatTargets=146)
[10174] MOMENTUM owner 71 mom=0.80 (pasukan turun, tanah turun) pasukan=30558
[10174] ATKSIZE owner 25 N=40 ratio=0.02 mom=0.00 fill=0.20 P=1.87
[10174] troops=151213 A:1180132@0.02
[10174] MOMENTUM owner 189 mom=0.55 (tanah turun, diserang pihak lain) pasukan=58863
[10174] ATKSIZE owner 188 N=46 ratio=0.04 mom=0.00 fill=0.21 P=2.08
[10174] troops=153766 A:1173852@0.04
[10175] ATKSIZE owner 188 N=46 ratio=0.04 mom=0.00 fill=0.21 P=2.05
[10175] troops=154279 A:1173836@0.04
[10175] LG ME rank=12 tiles=7274(0.9%) troops=160435/745270 gold=75500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10175] LG MATI owner155 (tiles terakhir 0)
[10175] LG MATI owner224 (tiles terakhir 0)
[10175] LG MATI owner212 (tiles terakhir 0)
[10175] boat scan: 180 target (<=70 langkah, reach x1) dari 24 titik pantai
[10175] troops=160435 A:1149737@0.07
[10176] troops=154926 A:1172577@0.04
[10176] MOMENTUM owner 188 mom=0.50 (pasukan turun) pasukan=60972
[10176] troops=155252 A:1195297@0.04
[10177] troops=155704 A:1125667@0.04
[10177] troops=156127 A:1084018@0.04
[10178] FOCUS -> owner 66 ratio=3.51 contact=true jarak=94 skor=9.00 brutal=true existential=false(0.3%)
[10178] MOMENTUM owner 66 mom=0.50 (pasukan turun) pasukan=44653
[10178] troops=156551 A:1084016@0.04
[10178] LG SERANG MASUK dari owner25 troops=29018 (pasukan gw 156790)
[10178] FRONT owner 71 P=5.85 kerucut=77 tile, pasukan gw=156790 musuh=36455
[10180] MOMENTUM owner 25 mom=0.50 (pasukan turun) pasukan=47486
[10180] MOMENTUM owner 85 mom=0.50 (pasukan turun) pasukan=57921
[10181] LG ME rank=15 tiles=7486(0.9%) troops=198838/756866 gold=81500 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10181] LG MATI owner252 (tiles terakhir 0)
[10181] LG MATI owner204 (tiles terakhir 0)
[10181] LG MATI owner91 (tiles terakhir 0)
[10181] LG MATI owner256 (tiles terakhir 0)
[10181] LG MATI owner159 (tiles terakhir 0)
[10181] WATCH leader ganti: owner 286 -> owner 259
[10181] WATCH #1 land: owner=259 tiles=11184(+0) troops=444891(+0) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10181] MOMENTUM owner 222 mom=0.47 (tanah turun, diserang pihak lain) pasukan=65762
[10181] MOMENTUM owner 184 mom=0.50 (pasukan turun) pasukan=45707
[10182] LG SERANG MASUK dari owner189 troops=32307 (pasukan gw 205380)
[10182] POSTURE need=0.44 [serang=0.40 loss=0.00 kuat=0.00 brutal=0.00] dom=0.37 | jatah defense=0% -> SEIMBANG
[10184] REC troops=223558/752646 gold=83500 inc=983/s tiles=7387 city=0(L0) def=0 sam=0 silo=0 | serangan masuk=2(32584 troops) | tetangga terkuat=19(87663, kontak 177) | rival=- hostile=7 brutal=true | nuke di udara=0 | foeSilo=0
[10184] boat scan: 174 target (<=70 langkah, reach x1) dari 24 titik pantai
[10185] MOMENTUM owner 189 mom=0.80 (pasukan turun, tanah turun) pasukan=38192
[10185] MOMENTUM owner 19 mom=0.50 (pasukan turun) pasukan=56409
[10186] troops=249373 A:1156069@0.40
[10186] troops=256253 A:1153538@0.42
[10187] troops=164950 A:1149745@0.07
[10187] troops=171238 A:1144686@0.09
[10188] LG ME rank=13 tiles=8242(1.0%) troops=177685/793308 gold=88000 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10188] LG MATI owner98 (tiles terakhir 0)
[10188] LG MATI owner2 (tiles terakhir 0)
[10188] LG MATI owner113 (tiles terakhir 0)
[10188] LG MATI owner142 (tiles terakhir 0)
[10188] LG MATI owner167 (tiles terakhir 0)
[10188] LG MATI owner242 (tiles terakhir 0)
[10188] troops=177685 A:1139628@0.11
[10188] troops=184311 A:1138364@0.13
[10189] FRONT owner 71 P=3.82 kerucut=77 tile, pasukan gw=191136 musuh=55757
[10189] troops=191136 A:1132039@0.15
[10189] troops=198094 A:1129510@0.16
[10190] troops=205181 A:1123186@0.18
[10190] LG ROADS jumlah=0 contoh: 
[10190] LG FACTORY field: 
[10190] troops=173448 A:1180128@0.02
[10191] troops=175748 A:1172554@0.03
[10191] FRONT -> owner 19 P=98.64 arah=(-0.92,-0.39) pasukan musuh=3523
[10191] troops=177307 A:1171286@0.03
[10192] boat scan: 103 target (<=70 langkah, reach x1) dari 24 titik pantai
[10192] MOMENTUM owner 188 mom=0.50 (pasukan turun) pasukan=59220
[10192] MOMENTUM owner 184 mom=0.60 (tanah turun, diserang pihak lain) pasukan=64447
[10192] FRONT -> owner 188 P=6.34 arah=(0.67,0.74) pasukan musuh=59220
[10192] placement signature #1 cocok
[10192] build city tile=1097971 cost~125000 gold=137950 inc=5392/s wealth=0.2 amount=1
[10192] troops=234507 A:1099172@0.26
[10192] troops=178914 A:1140976@0.03
[10193] FOCUS -> owner 222 ratio=4.07 contact=true jarak=60 skor=7.75 brutal=false existential=false(0.3%)
[10193] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=45614
[10193] troops=185781 A:1080224@0.06
[10193] POSTURE need=0.23 [serang=0.00 loss=0.00 kuat=0.01 brutal=0.00] dom=0.24 | jatah defense=0% -> SEIMBANG
[10193] troops=186953 A:1078951@0.06
[10194] LG ME rank=7 tiles=10224(1.3%) troops=182379/886627 gold=14950 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG MATI owner19 (tiles terakhir 0)
[10194] LG MATI owner244 (tiles terakhir 0)
[10194] LG MATI owner213 (tiles terakhir 0)
[10194] LG --- LEADERBOARD ---
[10194] LG #1 owner259 [musuh] hidup tiles=12923(1.6%) troops=561094/1010091 gold=80700 jarak=878 | cit=0 por=1 fac=0 def=0 sam=0 sil=0
[10194] LG #2 owner283 [ally] hidup tiles=12670(1.6%) troops=283567/994542 gold=304500 jarak=283 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG #3 owner258 [ally] hidup tiles=11818(1.5%) troops=250283/963504 gold=160200 jarak=1062 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG #4 owner268 [musuh] hidup tiles=11313(1.4%) troops=54580/939237 gold=135850 jarak=552 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG #5 owner282 [musuh] hidup tiles=10576(1.3%) troops=201877/908046 gold=197200 jarak=243 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG #6 owner261 [musuh] hidup tiles=10410(1.3%) troops=138646/898147 gold=127250 jarak=1317 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG #7 owner271 [GW] hidup tiles=10224(1.3%) troops=182379/886627 gold=14950 jarak=0 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10194] LG #8 owner286 [musuh] hidup tiles=10175(1.3%) troops=317814/879275 gold=94000 jarak=550 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10194] REC troops=182379/886627 gold=14950 inc=5392/s tiles=10224 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=85(89985, kontak 106) | rival=- hostile=7 brutal=false | nuke di udara=0 | foeSilo=0
[10194] troops=182379 A:1128366@0.03
[10194] build city OK, gold=15450 level+1 (minta 1)
[10195] idle: nggak ada target layak (fokus=222 boatTargets=103)
[10195] LG SERANG MASUK dari owner25 troops=26298 (pasukan gw 180471)
[10196] MOMENTUM owner 25 mom=0.80 (pasukan turun, tanah turun) pasukan=46070
[10199] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=37015
[10199] MOMENTUM owner 85 mom=0.50 (pasukan turun) pasukan=61514
[10199] FRONT owner 188 P=5.03 kerucut=26 tile, pasukan gw=249647 musuh=70340
[10200] troops=258105 A:1073893@0.10
[10200] LG ME rank=9 tiles=10586(1.3%) troops=239458/1157908 gold=21450 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10200] LG MATI owner131 (tiles terakhir 0)
[10200] LG MATI owner84 (tiles terakhir 0)
[10200] LG MATI owner76 (tiles terakhir 0)
[10200] LG MATI owner232 (tiles terakhir 0)
[10200] LG MATI owner43 (tiles terakhir 0)
[10200] boat scan: 184 target (<=70 langkah, reach x1) dari 24 titik pantai
[10200] troops=239458 A:1175122@0.03
[10201] troops=239701 A:1176369@0.03
[10201] troops=248069 A:1072629@0.06
[10202] WATCH #1 land: owner=259 tiles=13374(+2190) troops=536724(+91833) | city=0(+0) port=1(+1) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)  [20s]
[10202] troops=240251 A:1183922@0.03
[10202] MOMENTUM owner 188 mom=0.41 (tanah turun, diserang pihak lain) pasukan=71979
[10202] troops=240696 A:1089048@0.03
[10203] troops=241197 A:1104223@0.03
[10203] troops=241749 A:1105476@0.03
[10204] MOMENTUM owner 189 mom=0.50 (pasukan turun) pasukan=39892
[10204] troops=242374 A:1171287@0.03
[10204] REC troops=243016/1176566 gold=25450 inc=1945/s tiles=11019 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=85(73982, kontak 116) | rival=- hostile=3 brutal=true | nuke di udara=0 | foeSilo=0
[10204] troops=243016 A:1089046@0.03
[10205] troops=251583 A:1067570@0.06
[10205] troops=252160 A:1065035@0.06
[10206] troops=260881 A:1066294@0.09
[10206] LG ME rank=13 tiles=11283(1.4%) troops=253109/1187224 gold=27450 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10206] LG MATI owner165 (tiles terakhir 0)
[10206] LG MATI owner86 (tiles terakhir 0)
[10206] LG MATI owner63 (tiles terakhir 0)
[10206] LG MATI owner147 (tiles terakhir 0)
[10206] LG MATI owner32 (tiles terakhir 0)
[10206] LG MATI owner249 (tiles terakhir 0)
[10206] LG MATI owner97 (tiles terakhir 0)
[10206] LG MATI owner96 (tiles terakhir 0)
[10206] LG MATI owner245 (tiles terakhir 0)
[10206] troops=253109 A:1068820@0.06
[10208] troops=246629 A:1185218@0.03
[10208] troops=255288 A:1059974@0.06
[10209] boat scan: 151 target (<=70 langkah, reach x1) dari 24 titik pantai
[10209] MOMENTUM owner 222 mom=0.46 (pasukan turun, tanah turun) pasukan=54401
[10209] troops=255877 A:1058709@0.06
[10209] troops=256745 A:1058714@0.06
[10210] FRONT owner 188 P=3.69 kerucut=26 tile, pasukan gw=249225 musuh=83283
[10210] troops=249225 A:1176358@0.03
[10210] troops=249883 A:1185216@0.03
[10211] FOCUS -> owner 184 ratio=7.96 contact=true jarak=50 skor=9.65 brutal=false existential=false(0.1%)
[10211] troops=250541 A:1182684@0.03
[10211] LG SERANG MASUK dari owner25 troops=1925 (pasukan gw 251135)
[10211] MOMENTUM owner 25 mom=0.80 (pasukan turun, tanah turun) pasukan=41638
[10211] troops=251135 A:1128366@0.03
[10212] MOMENTUM owner 184 mom=0.80 (pasukan turun, tanah turun) pasukan=33180
[10212] troops=251619 A:1134682@0.03
[10212] FRONT -> owner 184 P=14.50 arah=(-0.62,-0.79) pasukan musuh=34050
[10212] troops=251932 A:1134680@0.03
[10213] LG ME rank=13 tiles=12023(1.5%) troops=252373/1221638 gold=33950 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10213] LG MATI owner21 (tiles terakhir 0)
[10213] LG MATI owner105 (tiles terakhir 0)
[10213] LG MATI owner13 (tiles terakhir 0)
[10213] LG MATI owner61 (tiles terakhir 0)
[10213] LG MATI owner181 (tiles terakhir 0)
[10213] LG MATI owner198 (tiles terakhir 0)
[10213] LG MATI owner128 (tiles terakhir 0)
[10213] LG MATI owner121 (tiles terakhir 0)
[10213] LG MATI owner139 (tiles terakhir 0)
[10213] MOMENTUM owner 112 mom=0.50 (pasukan turun) pasukan=52847
[10213] troops=252373 A:1143508@0.03
[10213] troops=252830 A:1177653@0.03
[10214] MOMENTUM owner 188 mom=0.50 (pasukan turun) pasukan=57612
[10214] POSTURE need=0.11 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.00] dom=0.45 | jatah defense=0% -> FOKUS INCOME
[10214] troops=253340 A:1199086@0.03
[10214] MOMENTUM owner 189 mom=0.44 (pasukan turun, tanah turun, diserang pihak lain) pasukan=46980
[10214] troops=253914 A:1072664@0.03
[10215] LG SERANG MASUK dari owner85 troops=32127 (pasukan gw 254211)
[10215] REC troops=254211/1231063 gold=35950 inc=1359/s tiles=12228 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=1(32127 troops) | tetangga terkuat=71(67182, kontak 106) | rival=- hostile=2 brutal=false | nuke di udara=0 | foeSilo=0
[10215] MOMENTUM owner 85 mom=0.50 (pasukan turun) pasukan=56753
[10215] POSTURE need=0.35 [serang=0.40 loss=0.00 kuat=0.00 brutal=0.00] dom=0.94 | jatah defense=0% -> SEIMBANG
[10217] boat scan: 106 target (<=70 langkah, reach x1) dari 24 titik pantai
[10218] LG SERANG MASUK dari owner71 troops=36293 (pasukan gw 315820)
[10219] LG ME rank=14 tiles=12218(1.5%) troops=324798/1231972 gold=39950 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10219] LG MATI owner104 (tiles terakhir 0)
[10219] LG MATI owner11 (tiles terakhir 0)
[10219] LG MATI owner110 (tiles terakhir 0)
[10219] LG MATI owner220 (tiles terakhir 0)
[10219] LG MATI owner178 (tiles terakhir 0)
[10219] LG MATI owner170 (tiles terakhir 0)
[10220] FRONT owner 184 P=6.79 kerucut=72 tile, pasukan gw=342981 musuh=47738
[10221] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=40650
[10222] LG SERANG MASUK dari owner222 troops=25965 (pasukan gw 390496)
[10222] WATCH leader ganti: owner 259 -> owner 270
[10222] WATCH #1 land: owner=270 tiles=16235(+0) troops=351661(+0) | city=1(+0) port=1(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10224] MOMENTUM owner 25 mom=0.50 (pasukan turun) pasukan=44747
[10224] MOMENTUM owner 222 mom=0.62 (pasukan turun, tanah turun) pasukan=35943
[10225] MOMENTUM owner 189 mom=0.50 (pasukan turun) pasukan=39987
[10225] LG ME rank=15 tiles=11968(1.5%) troops=449331/1220591 gold=46450 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10225] LG MATI owner82 (tiles terakhir 0)
[10225] LG MATI owner16 (tiles terakhir 0)
[10225] LG MATI owner239 (tiles terakhir 0)
[10225] LG MATI owner234 (tiles terakhir 0)
[10225] LG --- LEADERBOARD ---
[10225] LG #1 owner283 [ally] hidup tiles=22636(2.8%) troops=217246/1372317 gold=495300 jarak=251 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10225] LG #2 owner258 [ally] hidup tiles=18204(2.3%) troops=306591/1216465 gold=408600 jarak=1082 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10225] LG #3 owner270 [musuh] hidup tiles=16566(2.1%) troops=416703/1407541 gold=126850 jarak=753 | cit=1 por=1 fac=0 def=1 sam=0 sil=0
[10225] LG #4 owner282 [musuh] hidup tiles=16493(2.1%) troops=431718/1151667 gold=343700 jarak=247 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10225] LG #5 owner277 [musuh] hidup tiles=14937(1.9%) troops=446467/1092189 gold=235800 jarak=318 | cit=0 por=0 fac=0 def=1 sam=0 sil=0
[10225] LG #6 owner286 [musuh] hidup tiles=14610(1.8%) troops=396322/1077925 gold=51100 jarak=558 | cit=0 por=1 fac=0 def=0 sam=0 sil=0
[10225] LG #7 owner268 [musuh] hidup tiles=14584(1.8%) troops=62544/1079338 gold=150850 jarak=543 | cit=0 por=0 fac=1 def=0 sam=0 sil=0
[10225] LG #8 owner261 [musuh] hidup tiles=14223(1.8%) troops=30763/1064541 gold=206650 jarak=1294 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10225] REC troops=449331/1220591 gold=46450 inc=1096/s tiles=11968 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=2(20123 troops) | tetangga terkuat=85(83320, kontak 118) | rival=- hostile=7 brutal=true | nuke di udara=0 | foeSilo=0
[10225] boat scan: 115 target (<=70 langkah, reach x1) dari 24 titik pantai
[10226] troops=469801 A:1086516@0.48
[10227] FOCUS -> owner 189 ratio=5.73 contact=true jarak=65 skor=10.58 brutal=true existential=false(0.2%)
[10228] troops=275919 A:1138473@0.10
[10229] troops=255241 A:1185215@0.03
[10229] MOMENTUM owner 188 mom=0.50 (pasukan turun) pasukan=54646
[10229] troops=256607 A:1176342@0.03
[10230] MOMENTUM owner 66 mom=0.64 (tanah turun, diserang pihak lain) pasukan=66906
[10230] troops=265439 A:1139737@0.05
[10230] MOMENTUM owner 184 mom=0.80 (pasukan turun, tanah turun) pasukan=23562
[10230] FRONT owner 184 P=22.21 kerucut=36 tile, pasukan gw=266974 musuh=23562
[10230] troops=266974 A:1167542@0.05
[10231] troops=261252 A:1187746@0.03
[10231] LG ME rank=15 tiles=13299(1.7%) troops=270242/1273746 gold=52450 | cit=1 por=0 fac=0 def=0 sam=0 sil=0
[10231] LG MATI owner35 (tiles terakhir 0)
[10231] LG MATI owner28 (tiles terakhir 0)
[10231] LG MATI owner15 (tiles terakhir 0)
[10231] LG MATI owner240 (tiles terakhir 0)
[10231] LG MATI owner227 (tiles terakhir 0)
[10231] LG MATI owner216 (tiles terakhir 0)
[10231] LG MATI owner219 (tiles terakhir 0)
[10231] LG MATI owner34 (tiles terakhir 0)
[10231] troops=270242 A:1165015@0.06
[10232] troops=271323 A:1167544@0.06
[10233] troops=264632 A:1189011@0.03
[10233] troops=273700 A:1144795@0.06
[10234] boat scan: 135 target (<=70 langkah, reach x1) dari 24 titik pantai
[10234] MOMENTUM owner 85 mom=0.50 (pasukan turun) pasukan=58715
[10234] FRONT -> owner 189 P=17.03 arah=(0.86,0.51) pasukan musuh=31570
[10234] troops=274284 A:1173867@0.06
[10234] POSTURE need=0.15 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.00] dom=1.00 | jatah defense=0% -> SEIMBANG
[10234] troops=447025 A:1149858@0.42
[10235] MOMENTUM owner 112 mom=0.50 (pasukan turun) pasukan=55657
[10235] troops=441898 A:1151116@0.41
[10235] MOMENTUM owner 189 mom=0.80 (pasukan turun, tanah turun) pasukan=18238
[10235] troops=268362 A:1048586@0.02
[10236] REC troops=270736/1312339 gold=123900 inc=1008/s tiles=14170 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=51(76672, kontak 44) | rival=- hostile=4 brutal=false | nuke di udara=0 | foeSilo=0
[10236] troops=270736 A:1190275@0.03
[10236] troops=271485 A:1191539@0.03
[10237] troops=272372 A:1183945@0.03
[10237] FOCUS -> owner 85 ratio=6.95 contact=true jarak=93 skor=11.93 brutal=true existential=false(0.5%)
[10237] FRONT -> owner 112 P=13.48 arah=(0.46,-0.89) pasukan musuh=61070
[10237] build factory tile=1090386 cost~125000 gold=194150 inc=1008/s wealth=0.3 amount=1
[10237] troops=480211 A:1177569@0.45
[10238] LG ME rank=14 tiles=14612(1.8%) troops=271804/1327966 gold=69650 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10238] LG MATI owner6 (tiles terakhir 0)
[10238] LG MATI owner37 (tiles terakhir 0)
[10238] LG MATI owner124 (tiles terakhir 0)
[10238] LG MATI owner130 (tiles terakhir 0)
[10238] LG MATI owner118 (tiles terakhir 0)
[10238] LG MATI owner179 (tiles terakhir 0)
[10238] LG MATI owner150 (tiles terakhir 0)
[10238] LG MATI owner134 (tiles terakhir 0)
[10238] LG MATI owner184 (tiles terakhir 0)
[10238] LG MATI owner215 (tiles terakhir 0)
[10238] LG MATI owner89 (tiles terakhir 0)
[10238] LG MATI owner189 (tiles terakhir 0)
[10238] troops=271804 A:1178920@0.02
[10238] troops=274700 A:1166302@0.03
[10239] LG SERANG MASUK dari owner25 troops=13742 (pasukan gw 284043)
[10239] POSTURE need=0.36 [serang=0.40 loss=0.00 kuat=0.00 brutal=0.50] dom=0.73 | jatah defense=0% -> SEIMBANG
[10239] MOMENTUM owner 25 mom=0.80 (pasukan turun, tanah turun) pasukan=40736
[10239] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=40101
[10240] build factory OK, gold=71650 level+1 (minta 1)
[10240] MOMENTUM owner 66 mom=0.50 (pasukan turun) pasukan=45029
[10241] FRONT owner 112 P=7.56 kerucut=24 tile, pasukan gw=322498 musuh=66750
[10241] troops=322498 A:1205399@0.14
[10241] troops=332547 A:1206662@0.17
[10242] boat scan: 147 target (<=70 langkah, reach x1) dari 24 titik pantai
[10242] troops=293696 A:1211725@0.05
[10242] WATCH leader ganti: owner 270 -> owner 282
[10242] WATCH #1 land: owner=282 tiles=19179(+0) troops=777343(+0) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10243] idle: nggak ada target layak (fokus=85 boatTargets=147)
[10244] LG ME rank=11 tiles=16894(2.1%) troops=281023/1415149 gold=75650 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10244] LG MATI owner145 (tiles terakhir 0)
[10244] MOMENTUM owner 85 mom=0.80 (pasukan turun, tanah turun) pasukan=38015
[10245] troops=290601 A:1028325@0.02
[10245] MOMENTUM owner 112 mom=0.53 (tanah turun, diserang pihak lain) pasukan=74665
[10245] MOMENTUM owner 228 mom=0.50 (diserang pihak lain) pasukan=25176
[10245] troops=300336 A:1229434@0.05
[10246] troops=313257 A:1231959@0.08
[10246] REC troops=296087/1437156 gold=78150 inc=5666/s tiles=17356 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=1(1216 troops) | tetangga terkuat=51(105642, kontak 53) | rival=- hostile=2 brutal=false | nuke di udara=0 | foeSilo=0
[10246] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=36002
[10246] POSTURE need=0.16 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.00] dom=0.52 | jatah defense=0% -> SEIMBANG
[10246] troops=296087 A:1192803@0.03
[10247] troops=297082 A:1190274@0.03
[10247] troops=297849 A:1186474@0.03
[10248] troops=298672 A:1192810@0.03
[10248] troops=299476 A:1188989@0.03
[10249] LG SERANG MASUK dari owner51 troops=49127 (pasukan gw 300262)
[10249] MOMENTUM owner 51 mom=0.99 (pasukan turun, tanah turun, diserang pihak lain) pasukan=62002
[10249] POSTURE need=0.38 [serang=0.40 loss=0.00 kuat=0.00 brutal=0.50] dom=0.85 | jatah defense=0% -> SEIMBANG
[10250] MOMENTUM owner 25 mom=0.58 (tanah turun, diserang pihak lain) pasukan=52155
[10250] LG ME rank=9 tiles=18188(2.3%) troops=330202/1467425 gold=82150 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10250] LG MATI owner101 (tiles terakhir 0)
[10250] LG MATI owner251 (tiles terakhir 0)
[10250] LG MATI owner254 (tiles terakhir 0)
[10250] LG MATI owner48 (tiles terakhir 0)
[10250] LG MATI owner68 (tiles terakhir 0)
[10250] LG MATI owner168 (tiles terakhir 0)
[10250] boat scan: 156 target (<=70 langkah, reach x1) dari 24 titik pantai
[10252] MOMENTUM owner 188 mom=0.50 (pasukan turun) pasukan=60942
[10252] FRONT owner 112 P=4.90 kerucut=21 tile, pasukan gw=350935 musuh=85284
[10253] FOCUS -> owner 51 ratio=8.64 contact=true jarak=112 skor=10.55 brutal=false existential=false(0.6%)
[10253] COUNTER owner 51 serangan=37690 ratio=0.02
[10255] MOMENTUM owner 66 mom=0.50 (pasukan turun) pasukan=43923
[10255] COUNTER owner 51 serangan=20227 ratio=0.05
[10256] troops=629483 A:1027061@0.41
[10257] LG ME rank=13 tiles=18443(2.3%) troops=388211/1477553 gold=98650 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10257] LG MATI owner85 (tiles terakhir 0)
[10257] LG MATI owner72 (tiles terakhir 0)
[10257] LG MATI owner158 (tiles terakhir 0)
[10257] LG MATI owner228 (tiles terakhir 0)
[10257] LG MATI owner136 (tiles terakhir 0)
[10257] LG MATI owner154 (tiles terakhir 0)
[10257] LG MATI owner205 (tiles terakhir 0)
[10257] LG MATI owner144 (tiles terakhir 0)
[10257] LG --- LEADERBOARD ---
[10257] LG #1 owner283 [ally] hidup tiles=31294(3.9%) troops=731904/1649420 gold=948300 jarak=214 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10257] LG #2 owner258 [ally] hidup tiles=24246(3.0%) troops=621043/1678082 gold=140050 jarak=1068 | cit=1 por=2 fac=0 def=0 sam=0 sil=0
[10257] LG #3 owner282 [musuh] hidup tiles=24161(3.0%) troops=810485/1423500 gold=596150 jarak=214 | cit=0 por=0 fac=0 def=0 sam=0 sil=0
[10257] LG #4 owner270 [musuh] hidup tiles=21867(2.7%) troops=736689/1599140 gold=225700 jarak=748 | cit=1 por=1 fac=0 def=1 sam=0 sil=0
[10257] LG #5 owner274 [ally] hidup tiles=21477(2.7%) troops=485491/1333401 gold=67300 jarak=606 | cit=0 por=0 fac=2 def=1 sam=0 sil=0
[10257] LG #6 owner277 [musuh] hidup tiles=20799(2.6%) troops=180/1562566 gold=186700 jarak=299 | cit=1 por=0 fac=1 def=1 sam=0 sil=0
[10257] LG #7 owner257 [musuh] hidup tiles=20232(2.5%) troops=305019/1290995 gold=92350 jarak=148 | cit=0 por=0 fac=1 def=1 sam=0 sil=0
[10257] LG #8 owner279 [ally] hidup tiles=20043(2.5%) troops=666225/1534717 gold=291350 jarak=701 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10257] REC troops=388211/1477553 gold=98650 inc=3602/s tiles=18443 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=51(76790, kontak 54) | rival=- hostile=0 brutal=false | nuke di udara=0 | foeSilo=0
[10257] MOMENTUM owner 222 mom=0.63 (tanah turun, diserang pihak lain) pasukan=48762
[10257] MOMENTUM owner 112 mom=0.50 (pasukan turun) pasukan=53493
[10259] boat scan: 170 target (<=70 langkah, reach x1) dari 24 titik pantai
[10259] MOMENTUM owner 51 mom=0.60 (pasukan turun, tanah turun, diserang pihak lain) pasukan=71258
[10262] MOMENTUM owner 25 mom=0.80 (pasukan turun, tanah turun) pasukan=35312
[10262] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=45286
[10262] FRONT -> owner 25 P=27.36 arah=(-0.09,1.00) pasukan musuh=35312
[10262] FRONT owner 25 P=27.36 kerucut=60 tile, pasukan gw=492911 musuh=35312
[10263] LG ME rank=12 tiles=20180(2.5%) troops=542077/1538940 gold=105150 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10263] LG MATI owner236 (tiles terakhir 0)
[10263] LG MATI owner235 (tiles terakhir 0)
[10263] LG MATI owner33 (tiles terakhir 0)
[10263] LG MATI owner173 (tiles terakhir 0)
[10263] LG MATI owner156 (tiles terakhir 0)
[10263] WATCH #1 land: owner=282 tiles=27914(+8735) troops=568410(-208933) | city=0(+0) port=0(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)  [20s]
[10265] POSTURE need=0.17 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.00] dom=1.00 | jatah defense=0% -> SEIMBANG
[10267] REC troops=630455/1557382 gold=118650 inc=1945/s tiles=20726 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=112(73554, kontak 41) | rival=- hostile=0 brutal=false | nuke di udara=0 | foeSilo=0
[10267] boat scan: 275 target (<=70 langkah, reach x1) dari 24 titik pantai
[10267] troops=630455 A:984068@0.38
[10268] troops=656070 A:984072@0.40
[10269] troops=668925 A:989136@0.41
[10270] LG ME rank=9 tiles=21417(2.7%) troops=409514/1579835 gold=121150 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10270] LG MATI owner80 (tiles terakhir 0)
[10270] LG MATI owner223 (tiles terakhir 0)
[10270] LG MATI owner231 (tiles terakhir 0)
[10270] LG MATI owner45 (tiles terakhir 0)
[10270] LG MATI owner218 (tiles terakhir 0)
[10270] LG MATI owner117 (tiles terakhir 0)
[10270] LG MATI owner160 (tiles terakhir 0)
[10270] LG MATI owner183 (tiles terakhir 0)
[10270] MOMENTUM owner 188 mom=0.50 (pasukan turun) pasukan=64297
[10270] MOMENTUM owner 51 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=31801
[10271] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=36956
[10273] FRONT owner 25 P=13.52 kerucut=58 tile, pasukan gw=481400 musuh=48419
[10274] FOCUS -> owner 188 ratio=20.37 contact=true jarak=82 skor=10.24 brutal=false existential=false(0.2%)
[10274] troops=943271 A:1176398@0.57 B:1025731@0.25 B:1026994@0.25
[10275] boat scan: 241 target (<=70 langkah, reach x1) dari 24 titik pantai
[10275] MOMENTUM owner 100 mom=0.50 (diserang pihak lain) pasukan=42333
[10276] LG SERANG MASUK dari owner112 troops=45843 (pasukan gw 892487)
[10276] LG ME rank=10 tiles=22962(2.9%) troops=892487/1636292 gold=214800 | cit=1 por=0 fac=1 def=0 sam=0 sil=0
[10276] LG MATI owner51 (tiles terakhir 0)
[10276] LG MATI owner24 (tiles terakhir 0)
[10276] LG MATI owner26 (tiles terakhir 0)
[10276] LG MATI owner163 (tiles terakhir 0)
[10276] LG MATI owner116 (tiles terakhir 0)
[10276] LG MATI owner151 (tiles terakhir 0)
[10276] LG MATI owner201 (tiles terakhir 0)
[10276] LG MATI owner188 (tiles terakhir 0)
[10277] FOCUS -> owner 66 ratio=19.10 contact=true jarak=74 skor=10.72 brutal=false existential=false(0.4%)
[10277] COUNTER owner 112 serangan=45843 ratio=0.06
[10277] REC troops=859005/1637704 gold=215800 inc=9124/s tiles=22999 city=1(L1) def=0 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=250(110234, kontak 40) | rival=- hostile=1 brutal=true | nuke di udara=0 | foeSilo=0
[10277] MOMENTUM owner 25 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=32006
[10277] MOMENTUM owner 66 mom=0.50 (pasukan turun) pasukan=49019
[10277] troops=859005 A:1038404@0.52
[10278] MOMENTUM owner 112 mom=0.80 (pasukan turun, tanah turun) pasukan=52173
[10280] MOMENTUM owner 250 mom=0.50 (pasukan turun) pasukan=58321
[10280] MOMENTUM owner 127 mom=0.50 (pasukan turun) pasukan=61973
[10280] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=44368
[10281] POSTURE need=0.45 [serang=0.00 loss=0.00 kuat=0.59 brutal=0.00] dom=0.00 | jatah defense=0% -> SEIMBANG
[10281] build city tile=1082808 cost~250000 gold=392500 inc=9124/s wealth=0.5 amount=1
[10282] FRONT -> owner 66 P=36.70 arah=(-0.90,-0.44) pasukan musuh=31061
[10283] LG ME rank=7 tiles=25174(3.2%) troops=608389/1709052 gold=144500 | cit=2 por=0 fac=1 def=0 sam=0 sil=0
[10283] LG MATI owner57 (tiles terakhir 0)
[10283] LG MATI owner225 (tiles terakhir 0)
[10283] LG MATI owner25 (tiles terakhir 0)
[10283] LG MATI owner7 (tiles terakhir 0)
[10283] LG MATI owner115 (tiles terakhir 0)
[10283] LG MATI owner100 (tiles terakhir 0)
[10283] FRONT owner 66 P=42.59 kerucut=46 tile, pasukan gw=608389 musuh=27995
[10283] LG SERANG MASUK dari owner222 troops=33558 (pasukan gw 621643)
[10284] WATCH #1 land: owner=282 tiles=31737(+3823) troops=1121053(+552643) | city=1(+1) port=1(+1) factory=1(+1) def=0(+0) sam=0(+0) silo=0(+0)  [20s]
[10284] boat scan: 288 target (<=70 langkah, reach x1) dari 24 titik pantai
[10284] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=36005
[10284] POSTURE need=0.85 [serang=0.40 loss=0.00 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=0% -> DEFENSE DULU
[10284] build city OK, gold=145500 level+1 (minta 1)
[10284] build def tile=1061135 cost~50000 gold=145500 inc=45034/s wealth=0.2 amount=1 musuh=257 skor=13.7 tertutup=0% need=0.85 jatah=0% URGENT
[10286] build def OK, gold=98000 level+1 (minta 1)
[10287] MOMENTUM owner 257 mom=0.50 (pasukan turun) pasukan=442878
[10288] REC troops=736587/1974104 gold=109000 inc=27020/s tiles=25656 city=2(L2) def=1 sam=0 silo=0 | serangan masuk=1(9874 troops) | tetangga terkuat=257(455021, kontak 67) | rival=owner 257 hostile=1 brutal=false | nuke di udara=0 | foeSilo=0
[10288] MOMENTUM owner 66 mom=0.80 (pasukan turun, tanah turun) pasukan=19624
[10289] LG ME rank=7 tiles=25742(3.2%) troops=781370/1977513 gold=110500 | cit=2 por=0 fac=1 def=1 sam=0 sil=0
[10289] LG MATI owner75 (tiles terakhir 0)
[10289] LG MATI owner38 (tiles terakhir 0)
[10289] LG MATI owner164 (tiles terakhir 0)
[10289] LG MATI owner1 (tiles terakhir 0)
[10289] LG --- LEADERBOARD ---
[10289] LG #1 owner274 [ally] hidup tiles=36521(4.6%) troops=180657/1799963 gold=99300 jarak=544 | cit=0 por=0 fac=2 def=1 sam=0 sil=0
[10289] LG #2 owner283 [ally] hidup tiles=35492(4.4%) troops=1324450/1770978 gold=244000 jarak=223 | cit=0 por=0 fac=0 def=0 sam=0 sil=1
[10289] LG #3 owner282 [musuh] hidup tiles=33294(4.2%) troops=1252314/1956589 gold=215100 jarak=226 | cit=1 por=1 fac=1 def=0 sam=0 sil=0
[10289] LG #4 owner258 [ally] hidup tiles=28390(3.6%) troops=1712188/2061662 gold=170650 jarak=1032 | cit=2 por=2 fac=0 def=0 sam=0 sil=0
[10289] LG #5 owner286 [musuh] hidup tiles=27140(3.4%) troops=1071775/2022363 gold=188364 jarak=568 | cit=2 por=1 fac=0 def=0 sam=0 sil=0
[10289] LG #6 owner279 [ally] hidup tiles=26603(3.3%) troops=1112242/2004804 gold=351750 jarak=681 | cit=2 por=0 fac=1 def=0 sam=0 sil=0
[10289] LG #7 owner271 [GW] hidup tiles=25742(3.2%) troops=781370/1977513 gold=110500 jarak=0 | cit=2 por=0 fac=1 def=1 sam=0 sil=0
[10289] LG #8 owner270 [musuh] hidup tiles=25405(3.2%) troops=626090/1715461 gold=122766 jarak=726 | cit=1 por=1 fac=1 def=1 sam=0 sil=0
[10292] boat scan: 160 target (<=70 langkah, reach x1) dari 24 titik pantai
[10292] FOCUS -> owner 250 ratio=13.66 contact=true jarak=144 skor=10.51 brutal=false existential=false(0.5%)
[10292] FRONT -> owner 222 P=22.68 arah=(0.33,-0.94) pasukan musuh=50589
[10292] build def tile=1107959 cost~100000 gold=113500 inc=17558/s wealth=0.2 amount=1 musuh=257 skor=6.2 tertutup=50% need=0.70 jatah=11% URGENT
[10292] troops=1232817 A:952472@0.60
[10293] MOMENTUM owner 250 mom=0.44 (tanah turun, diserang pihak lain) pasukan=90688
[10293] FRONT owner 222 P=9.18 kerucut=102 tile, pasukan gw=515968 musuh=52425
[10295] build def OK, gold=16000 level+1 (minta 1)
[10295] LG ME rank=9 tiles=26313(3.3%) troops=571699/1994026 gold=16500 | cit=2 por=0 fac=1 def=2 sam=0 sil=0
[10295] LG MATI owner59 (tiles terakhir 0)
[10295] LG MATI owner137 (tiles terakhir 0)
[10297] MOMENTUM owner 127 mom=0.50 (pasukan turun) pasukan=66467
[10298] REC troops=659216/2015685 gold=19500 inc=10936/s tiles=27045 city=2(L2) def=2 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=257(733241, kontak 119) | rival=owner 257 hostile=1 brutal=true | nuke di udara=0 | foeSilo=0
[10300] boat scan: 317 target (<=70 langkah, reach x1) dari 24 titik pantai
[10300] MOMENTUM owner 71 mom=0.44 (tanah turun, diserang pihak lain) pasukan=81563
[10301] MOMENTUM owner 112 mom=0.65 (pasukan turun, diserang pihak lain) pasukan=51957
[10301] LG ME rank=9 tiles=27965(3.5%) troops=765707/2046413 gold=23000 | cit=2 por=0 fac=1 def=2 sam=0 sil=0
[10301] LG MATI owner237 (tiles terakhir 0)
[10301] LG MATI owner60 (tiles terakhir 0)
[10301] LG MATI owner90 (tiles terakhir 0)
[10301] LG MATI owner171 (tiles terakhir 0)
[10301] LG MATI owner166 (tiles terakhir 0)
[10301] LG MATI owner138 (tiles terakhir 0)
[10303] MOMENTUM owner 64 mom=0.50 (pasukan turun) pasukan=64391
[10303] MOMENTUM owner 102 mom=0.40 (diserang pihak lain) pasukan=49797
[10303] MOMENTUM owner 250 mom=0.80 (pasukan turun, tanah turun) pasukan=48812
[10303] FRONT owner 222 P=9.87 kerucut=102 tile, pasukan gw=827962 musuh=70465
[10304] WATCH #1 land: owner=282 tiles=35945(+4208) troops=1260070(+139017) | city=1(+0) port=1(+0) factory=1(+0) def=0(+0) sam=0(+0) silo=0(+0)  [20s]
[10304] POSTURE need=1.00 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=28% -> DEFENSE DULU
[10307] MOMENTUM owner 222 mom=0.50 (pasukan turun) pasukan=38877
[10308] LG ME rank=6 tiles=29188(3.7%) troops=969408/2084337 gold=39500 | cit=2 por=0 fac=1 def=2 sam=0 sil=0
[10308] LG MATI owner186 (tiles terakhir 0)
[10308] LG MATI owner206 (tiles terakhir 0)
[10308] LG MATI owner255 (tiles terakhir 0)
[10308] boat scan: 188 target (<=70 langkah, reach x1) dari 24 titik pantai
[10308] REC troops=985108/2087026 gold=40000 inc=3689/s tiles=29286 city=2(L2) def=2 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=257(649475, kontak 119) | rival=owner 257 hostile=1 brutal=true | nuke di udara=0 | foeSilo=0
[10310] FOCUS -> owner 127 ratio=16.81 contact=true jarak=108 skor=10.33 brutal=false existential=false(0.4%)
[10310] MOMENTUM owner 127 mom=0.50 (pasukan turun) pasukan=62863
[10310] MOMENTUM owner 257 mom=0.50 (pasukan turun) pasukan=706149
[10312] troops=1663871 A:970129@0.68
[10313] POSTURE need=0.80 [serang=0.00 loss=0.00 kuat=0.40 brutal=0.50] dom=0.00 | jatah defense=28% -> DEFENSE DULU
[10314] FRONT -> owner 127 P=17.33 arah=(-0.26,-0.96) pasukan musuh=62764
[10314] FRONT owner 127 P=17.33 kerucut=90 tile, pasukan gw=554882 musuh=62764
[10314] LG ME rank=6 tiles=30399(3.8%) troops=569366/2119219 gold=152050 | cit=2 por=0 fac=1 def=2 sam=0 sil=0
[10314] LG MATI owner194 (tiles terakhir 0)
[10314] LG MATI owner250 (tiles terakhir 0)
[10314] LG MATI owner262 (tiles terakhir 0)
[10314] LG MATI owner153 (tiles terakhir 0)
[10314] LG MATI owner99 (tiles terakhir 0)
[10316] boat scan: 129 target (<=70 langkah, reach x1) dari 24 titik pantai
[10319] REC troops=705820/2164581 gold=156550 inc=7546/s tiles=31892 city=2(L2) def=2 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=257(936300, kontak 119) | rival=owner 257 hostile=1 brutal=true | nuke di udara=0 | foeSilo=0
[10320] MOMENTUM owner 102 mom=0.45 (tanah turun, diserang pihak lain) pasukan=50473
[10320] MOMENTUM owner 4 mom=0.50 (pasukan turun) pasukan=61479
[10320] MOMENTUM owner 222 mom=0.58 (tanah turun, diserang pihak lain) pasukan=63048
[10320] POSTURE need=1.00 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=28% -> DEFENSE DULU
[10321] LG ME rank=6 tiles=32313(4.0%) troops=769333/2178852 gold=158550 | cit=2 por=0 fac=1 def=2 sam=0 sil=0
[10321] LG MATI owner233 (tiles terakhir 0)
[10321] LG MATI owner221 (tiles terakhir 0)
[10321] LG MATI owner149 (tiles terakhir 0)
[10321] LG MATI owner129 (tiles terakhir 0)
[10321] LG --- LEADERBOARD ---
[10321] LG #1 owner283 [ally] hidup tiles=37087(4.6%) troops=1594963/1815638 gold=383450 jarak=243 | cit=0 por=0 fac=0 def=0 sam=0 sil=1
[10321] LG #2 owner270 [musuh] hidup tiles=36192(4.5%) troops=1433941/2290535 gold=601860 jarak=671 | cit=2 por=1 fac=1 def=1 sam=0 sil=0
[10321] LG #3 owner282 [musuh] hidup tiles=35493(4.4%) troops=1383967/2020555 gold=267100 jarak=262 | cit=1 por=1 fac=1 def=0 sam=0 sil=0
[10321] LG #4 owner274 [ally] hidup tiles=35359(4.4%) troops=98434/1768491 gold=131300 jarak=533 | cit=0 por=0 fac=2 def=1 sam=0 sil=0
[10321] LG #5 owner259 [musuh] hidup tiles=35287(4.4%) troops=2001306/2265181 gold=838147 jarak=907 | cit=2 por=2 fac=0 def=0 sam=0 sil=0
[10321] LG #6 owner271 [GW] hidup tiles=32313(4.0%) troops=769333/2178852 gold=158550 jarak=0 | cit=2 por=0 fac=1 def=2 sam=0 sil=0
[10321] LG #7 owner257 [musuh] hidup tiles=30803(3.9%) troops=993359/1884519 gold=307300 jarak=156 | cit=1 por=0 fac=1 def=2 sam=0 sil=0
[10321] LG #8 owner286 [musuh] hidup tiles=30564(3.8%) troops=1164616/2377422 gold=474490 jarak=543 | cit=3 por=1 fac=0 def=0 sam=0 sil=0
[10321] MOMENTUM owner 127 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=15798
[10321] MOMENTUM owner 112 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=46018
[10322] MOMENTUM owner 66 mom=0.80 (pasukan turun, tanah turun) pasukan=18681
[10323] MOMENTUM owner 64 mom=0.50 (pasukan turun) pasukan=73573
[10323] MOMENTUM owner 257 mom=0.50 (pasukan turun) pasukan=538267
[10323] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=51072
[10324] FRONT owner 127 P=399.10 kerucut=13 tile, pasukan gw=866626 musuh=4256
[10325] WATCH leader ganti: owner 282 -> owner 259
[10325] WATCH #1 land: owner=259 tiles=36575(+0) troops=1601518(+0) | city=2(+0) port=2(+0) factory=0(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10325] boat scan: 286 target (<=70 langkah, reach x1) dari 24 titik pantai
[10325] FOCUS -> owner 4 ratio=26.22 contact=true jarak=125 skor=10.99 brutal=false existential=false(0.5%)
[10325] FRONT -> owner 66 P=132.79 arah=(-0.75,-0.66) pasukan musuh=28474
[10325] build def tile=957424 cost~150000 gold=274850 inc=14464/s wealth=0.4 amount=1 musuh=257 skor=2.7 tertutup=61% need=0.87 jatah=28% URGENT
[10325] troops=1929123 A:956194@0.72
[10326] POSTURE need=0.79 [serang=0.00 loss=0.00 kuat=0.47 brutal=0.50] dom=0.00 | jatah defense=48% -> DEFENSE DULU
[10327] LG ME rank=5 tiles=33888(4.2%) troops=596278/2216457 gold=126850 | cit=2 por=0 fac=1 def=3 sam=0 sil=0
[10327] LG MATI owner190 (tiles terakhir 0)
[10327] LG MATI owner248 (tiles terakhir 0)
[10327] LG MATI owner241 (tiles terakhir 0)
[10327] LG MATI owner58 (tiles terakhir 0)
[10327] LG MATI owner8 (tiles terakhir 0)
[10327] LG MATI owner23 (tiles terakhir 0)
[10327] LG MATI owner146 (tiles terakhir 0)
[10327] LG MATI owner157 (tiles terakhir 0)
[10327] LG MATI owner127 (tiles terakhir 0)
[10328] build def OK, gold=127350 level+1 (minta 1)
[10329] REC troops=673427/2257098 gold=129350 inc=9073/s tiles=35207 city=2(L2) def=3 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=257(710262, kontak 177) | rival=owner 257 hostile=2 brutal=true | nuke di udara=0 | foeSilo=0
[10331] MOMENTUM owner 222 mom=0.80 (pasukan turun, tanah turun) pasukan=40903
[10331] MOMENTUM owner 4 mom=0.80 (pasukan turun, tanah turun) pasukan=27161
[10331] MOMENTUM owner 112 mom=0.44 (tanah turun, diserang pihak lain) pasukan=63209
[10333] MOMENTUM owner 102 mom=0.58 (pasukan turun, tanah turun) pasukan=45795
[10333] LG ME rank=4 tiles=36854(4.6%) troops=803575/2307492 gold=133350 | cit=2 por=0 fac=1 def=3 sam=0 sil=0
[10333] LG MATI owner180 (tiles terakhir 0)
[10333] LG MATI owner79 (tiles terakhir 0)
[10333] LG MATI owner108 (tiles terakhir 0)
[10333] boat scan: 427 target (<=70 langkah, reach x1) dari 24 titik pantai
[10334] FOCUS -> owner 102 ratio=42.88 contact=true jarak=167 skor=10.76 brutal=false existential=false(0.3%)
[10334] build def tile=1126926 cost~200000 gold=250800 inc=5841/s wealth=0.3 amount=1 musuh=257 skor=3.1 tertutup=80% need=0.64 jatah=48% URGENT
[10334] troops=2057569 A:910731@0.72
[10334] FRONT owner 66 P=16.42 kerucut=12 tile, pasukan gw=581996 musuh=39509
[10336] troops=2105490 A:1052383@0.73
[10337] build def OK, gold=53300 level+1 (minta 1)
[10337] troops=2110100 A:1051120@0.73
[10337] LG SERANG MASUK dari owner66 troops=23264 (pasukan gw 592078)
[10338] POSTURE need=0.99 [serang=0.40 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=62% -> DEFENSE DULU
[10339] MOMENTUM owner 66 mom=0.50 (pasukan turun) pasukan=20501
[10339] MOMENTUM owner 64 mom=0.58 (pasukan turun, diserang pihak lain) pasukan=73110
[10340] LG ME rank=3 tiles=38310(4.8%) troops=200608/2346676 gold=56300 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10340] LG MATI owner176 (tiles terakhir 0)
[10340] LG MATI owner177 (tiles terakhir 0)
[10340] LG MATI owner47 (tiles terakhir 0)
[10340] LG MATI owner62 (tiles terakhir 0)
[10340] LG MATI owner4 (tiles terakhir 0)
[10340] LG MATI owner93 (tiles terakhir 0)
[10340] REC troops=200608/2346676 gold=56300 inc=14638/s tiles=38310 city=2(L2) def=4 sam=0 silo=0 | serangan masuk=1(20143 troops) | tetangga terkuat=257(1013750, kontak 175) | rival=owner 257 hostile=7 brutal=true | nuke di udara=0 | foeSilo=0
[10341] MOMENTUM owner 17 mom=0.50 (pasukan turun) pasukan=77053
[10341] MOMENTUM owner 284 mom=0.80 (tanah turun, diserang pihak lain) pasukan=402346
[10341] troops=2137793 A:999293@0.72
[10342] boat scan: 482 target (<=70 langkah, reach x1) dari 24 titik pantai
[10342] MOMENTUM owner 112 mom=0.45 (tanah turun, diserang pihak lain) pasukan=79211
[10342] troops=2142384 A:1000557@0.73
[10342] MOMENTUM owner 257 mom=0.50 (pasukan turun) pasukan=730228
[10342] MOMENTUM owner 71 mom=0.50 (pasukan turun) pasukan=50339
[10345] FRONT owner 66 P=11.79 kerucut=11 tile, pasukan gw=211936 musuh=28744
[10345] WATCH leader ganti: owner 259 -> owner 270
[10345] WATCH #1 land: owner=270 tiles=39760(+0) troops=2283034(+0) | city=3(+0) port=1(+0) factory=1(+0) def=1(+0) sam=0(+0) silo=0(+0)
[10346] LG ME rank=1 tiles=39914(5.0%) troops=230007/2392112 gold=183150 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10346] LG MATI owner203 (tiles terakhir 0)
[10346] LG MATI owner222 (tiles terakhir 0)
[10346] LG MATI owner87 (tiles terakhir 0)
[10346] LG MATI owner287 (tiles terakhir 0)
[10348] FRONT -> owner 112 P=52.72 arah=(0.90,-0.44) pasukan musuh=10384
[10349] FOCUS -> owner 112 ratio=35.33 contact=true jarak=109 skor=8.82 brutal=false existential=false(0.0%)
[10350] REC troops=311742/2400162 gold=187150 inc=12127/s tiles=40185 city=2(L2) def=4 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=257(924585, kontak 248) | rival=owner 257 hostile=4 brutal=true | nuke di udara=0 | foeSilo=0
[10350] boat scan: 277 target (<=70 langkah, reach x1) dari 24 titik pantai
[10350] FRONT -> owner 71 P=4.39 arah=(1.00,0.05) pasukan musuh=69060
[10351] MOMENTUM owner 284 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=240856
[10351] troops=2250101 A:1063841@0.73
[10352] troops=2253466 A:1087879@0.73
[10352] LG ME rank=2 tiles=40618(5.1%) troops=610697/2403546 gold=189150 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10352] LG MATI owner243 (tiles terakhir 0)
[10352] LG MATI owner54 (tiles terakhir 0)
[10352] LG MATI owner66 (tiles terakhir 0)
[10352] LG MATI owner18 (tiles terakhir 0)
[10352] LG --- LEADERBOARD ---
[10352] LG #1 owner259 [musuh] hidup tiles=40777(5.1%) troops=1808097/2413435 gold=559918 jarak=924 | cit=2 por=3 fac=0 def=0 sam=0 sil=0
[10352] LG #2 owner271 [GW] hidup tiles=40618(5.1%) troops=610697/2403546 gold=189150 jarak=0 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10352] LG #3 owner282 [musuh] hidup tiles=40314(5.0%) troops=844711/2398387 gold=88100 jarak=289 | cit=2 por=1 fac=1 def=0 sam=0 sil=0
[10352] LG #4 owner283 [ally] hidup tiles=40244(5.0%) troops=1555029/1898710 gold=414450 jarak=263 | cit=0 por=0 fac=0 def=0 sam=0 sil=1
[10352] LG #5 owner270 [musuh] hidup tiles=39760(5.0%) troops=2374119/2638794 gold=548206 jarak=643 | cit=3 por=1 fac=1 def=1 sam=0 sil=0
[10352] LG #6 owner257 [musuh] hidup tiles=38628(4.8%) troops=987953/2105848 gold=322300 jarak=150 | cit=1 por=0 fac=1 def=3 sam=0 sil=0
[10352] LG #7 owner286 [musuh] hidup tiles=33928(4.2%) troops=1143278/2473983 gold=731055 jarak=513 | cit=3 por=2 fac=0 def=0 sam=0 sil=0
[10352] LG #8 owner258 [ally] hidup tiles=32316(4.0%) troops=1737525/2169622 gold=677221 jarak=1023 | cit=2 por=2 fac=0 def=0 sam=0 sil=0
[10355] FRONT owner 71 P=26.14 kerucut=104 tile, pasukan gw=707400 musuh=31452
[10356] MOMENTUM owner 64 mom=0.50 (pasukan turun) pasukan=71712
[10356] MOMENTUM owner 257 mom=0.50 (pasukan turun) pasukan=606899
[10356] MOMENTUM owner 71 mom=0.80 (pasukan turun, tanah turun) pasukan=19995
[10358] LG SERANG MASUK dari owner257 troops=338347 (pasukan gw 825854)
[10358] LG ME rank=1 tiles=42613(5.3%) troops=825854/2464817 gold=195650 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10358] LG MATI owner193 (tiles terakhir 0)
[10358] LG MATI owner214 (tiles terakhir 0)
[10358] LG MATI owner65 (tiles terakhir 0)
[10358] boat scan: 319 target (<=70 langkah, reach x1) dari 24 titik pantai
[10358] DEFENSE DIBLOK: lagi diserang (masuk=41% pasukan, tanah hilang=0.0%) 45s
[10359] MOMENTUM owner 17 mom=0.44 (tanah turun, diserang pihak lain) pasukan=72493
[10359] POSTURE need=0.84 [serang=0.66 loss=0.00 kuat=0.00 brutal=0.50] dom=0.34 | jatah defense=62% -> DEFENSE DULU
[10360] REC troops=892833/2463609 gold=197650 inc=3414/s tiles=42573 city=2(L2) def=4 sam=0 silo=0 | serangan masuk=1(237523 troops) | tetangga terkuat=257(394725, kontak 240) | rival=- hostile=1 brutal=true | nuke di udara=0 | foeSilo=0
[10361] MOMENTUM owner 284 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=289800
[10361] FRONT -> owner 112 P=158.71 arah=(0.91,-0.41) pasukan musuh=18789
[10361] COUNTER owner 257 serangan=194244 ratio=0.10
[10362] troops=2219888 A:1001871@0.72
[10363] MOMENTUM owner 112 mom=0.49 (pasukan turun, tanah turun) pasukan=15620
[10364] LG SERANG MASUK dari owner257 troops=204309 (pasukan gw 665964)
[10364] FOCUS -> owner 17 ratio=7.99 contact=true jarak=172 skor=9.45 brutal=false existential=false(0.5%)
[10364] FRONT -> owner 17 P=14.78 arah=(0.04,-1.00) pasukan musuh=83401
[10364] POSTURE need=0.63 [serang=0.57 loss=0.00 kuat=0.40 brutal=0.50] dom=0.00 | jatah defense=62% -> DEFENSE DULU
[10365] LG SERANG MASUK dari owner102 troops=16109 (pasukan gw 2277201)
[10365] LG ME rank=3 tiles=42925(5.4%) troops=2277201/2473023 gold=464800 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10365] LG MATI owner246 (tiles terakhir 0)
[10365] LG MATI owner275 (tiles terakhir 0)
[10365] LG MATI owner71 (tiles terakhir 0)
[10365] LG MATI owner20 (tiles terakhir 0)
[10365] LG MATI owner92 (tiles terakhir 0)
[10365] LG MATI owner112 (tiles terakhir 0)
[10365] MOMENTUM owner 102 mom=0.42 (pasukan turun) pasukan=67025
[10365] COUNTER owner 257 serangan=185002 ratio=0.02
[10365] WATCH leader ganti: owner 270 -> owner 282
[10365] WATCH #1 land: owner=282 tiles=46634(+0) troops=951513(+0) | city=2(+0) port=1(+0) factory=1(+0) def=0(+0) sam=0(+0) silo=0(+0)
[10365] FRONT owner 17 P=46.12 kerucut=27 tile, pasukan gw=2226913 musuh=86301
[10365] troops=2226913 A:889200@0.50 A:884122@0.44
[10366] MOMENTUM owner 257 mom=0.50 (pasukan turun) pasukan=284699
[10366] boat scan: 351 target (<=70 langkah, reach x1) dari 24 titik pantai
[10369] FRONT -> owner 102 P=28.67 arah=(0.23,-0.97) pasukan musuh=76139
[10369] troops=2314515 A:1130714@0.50 A:911992@0.47
[10369] troops=2317612 A:1129448@0.50 A:918363@0.47
[10370] FRONT -> owner 64 P=7.83 arah=(0.54,-0.84) pasukan musuh=106262
[10371] REC troops=876390/2493888 gold=470300 inc=21485/s tiles=44290 city=2(L2) def=4 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=257(386358, kontak 236) | rival=- hostile=1 brutal=true | nuke di udara=0 | foeSilo=0
[10371] LG ME rank=3 tiles=44717(5.6%) troops=894142/2508429 gold=470800 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10371] LG MATI owner36 (tiles terakhir 0)
[10371] LG MATI owner122 (tiles terakhir 0)
[10371] LG MATI owner109 (tiles terakhir 0)
[10372] MOMENTUM owner 64 mom=0.80 (pasukan turun, tanah turun) pasukan=64513
[10372] POSTURE need=0.41 [serang=0.00 loss=0.00 kuat=0.00 brutal=0.00] dom=0.29 | jatah defense=62% -> SEIMBANG
[10375] boat scan: 404 target (<=70 langkah, reach x1) dari 24 titik pantai
[10375] FRONT owner 64 P=36.64 kerucut=26 tile, pasukan gw=1058616 musuh=62583
[10376] MOMENTUM owner 257 mom=0.80 (tanah turun, diserang pihak lain) pasukan=497676
[10377] LG ME rank=1 tiles=51521(6.5%) troops=1133925/2677260 gold=477300 | cit=2 por=0 fac=1 def=4 sam=0 sil=0
[10377] LG MATI owner69 (tiles terakhir 0)
[10380] FOCUS -> owner 64 ratio=21.38 contact=true jarak=200 skor=9.56 brutal=false existential=false(0.3%)
[10380] build port tile=1105438 cost~250000 gold=489800 inc=8362/s wealth=0.7 amount=1
[10381] REC troops=1271392/3047864 gold=250800 inc=8362/s tiles=56342 city=3(L3) def=4 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=264(1207934, kontak 5) | rival=- hostile=1 brutal=false | nuke di udara=0 | foeSilo=1
[10381] idle: nggak ada target layak (fokus=64 boatTargets=404)
[10382] MOMENTUM owner 64 mom=0.80 (pasukan turun, tanah turun) pasukan=52743
[10382] build port OK, gold=277300 level+1 (minta 1)
[10384] LG ME rank=1 tiles=60007(7.5%) troops=1419179/3138053 gold=279300 | cit=3 por=1 fac=1 def=4 sam=0 sil=0
[10384] LG MATI owner284 (tiles terakhir 0)
[10384] LG MATI owner207 (tiles terakhir 0)
[10384] LG MATI owner41 (tiles terakhir 0)
[10384] LG MATI owner27 (tiles terakhir 0)
[10384] LG MATI owner141 (tiles terakhir 0)
[10384] LG MATI owner135 (tiles terakhir 0)
[10384] LG MATI owner126 (tiles terakhir 0)
[10384] LG --- LEADERBOARD ---
[10384] LG #1 owner271 [GW] hidup tiles=60007(7.5%) troops=1419179/3138053 gold=279300 jarak=0 | cit=3 por=1 fac=1 def=4 sam=0 sil=0
[10384] LG #2 owner282 [musuh] hidup tiles=50656(6.3%) troops=1140170/2668574 gold=90600 jarak=312 | cit=2 por=1 fac=1 def=1 sam=0 sil=0
[10384] LG #3 owner259 [musuh] hidup tiles=48639(6.1%) troops=2711607/2868754 gold=1392916 jarak=918 | cit=3 por=3 fac=0 def=0 sam=0 sil=0
[10384] LG #4 owner283 [ally] hidup tiles=42186(5.3%) troops=1506852/1953531 gold=446950 jarak=283 | cit=0 por=0 fac=0 def=0 sam=0 sil=1
[10384] LG #5 owner270 [musuh] hidup tiles=42058(5.3%) troops=1227487/2698095 gold=356552 jarak=608 | cit=3 por=2 fac=1 def=3 sam=0 sil=0
[10384] LG #6 owner261 [musuh] hidup tiles=41013(5.1%) troops=1229885/2172407 gold=950084 jarak=1171 | cit=1 por=1 fac=1 def=0 sam=0 sil=0
[10384] LG #7 owner258 [ally] hidup tiles=41004(5.1%) troops=2223694/2671207 gold=738246 jarak=1032 | cit=3 por=2 fac=1 def=0 sam=0 sil=0
[10384] LG #8 owner286 [musuh] hidup tiles=37817(4.7%) troops=2585821/2585820 gold=380705 jarak=474 | cit=3 por=2 fac=0 def=0 sam=0 sil=1
[10384] boat scan: 383 target (<=70 langkah, reach x1) dari 24 titik pantai
[10386] WATCH #1 land: owner=282 tiles=50648(+4014) troops=1196730(+245217) | city=2(+0) port=1(+0) factory=1(+0) def=1(+1) sam=0(+0) silo=0(+0)  [20s]
[10386] FRONT owner 64 P=57.71 kerucut=23 tile, pasukan gw=1482905 musuh=50361
[10386] MOMENTUM owner 257 mom=0.80 (pasukan turun, tanah turun) pasukan=204193
[10391] LG ME rank=1 tiles=61327(7.7%) troops=1692398/3169772 gold=295800 | cit=3 por=1 fac=1 def=4 sam=0 sil=0
[10391] LG MATI owner185 (tiles terakhir 0)
[10391] LG MATI owner73 (tiles terakhir 0)
[10391] MOMENTUM owner 102 mom=0.50 (pasukan turun) pasukan=50520
[10391] REC troops=1712898/3170272 gold=306300 inc=5351/s tiles=61346 city=3(L3) def=4 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=264(1499966, kontak 52) | rival=owner 264 hostile=1 brutal=true | nuke di udara=0 | foeSilo=1
[10393] boat scan: 328 target (<=70 langkah, reach x1) dari 24 titik pantai
[10393] MOMENTUM owner 64 mom=0.62 (pasukan turun, tanah turun) pasukan=48335
[10393] POSTURE need=0.50 [serang=0.00 loss=0.00 kuat=0.40 brutal=0.50] dom=0.00 | jatah defense=42% -> SEIMBANG
[10395] FOCUS -> owner 257 ratio=30.99 contact=true jarak=126 skor=10.29 brutal=false existential=false(3.6%)
[10396] FRONT owner 64 P=95.37 kerucut=40 tile, pasukan gw=1892287 musuh=38888
[10397] LG ME rank=1 tiles=61967(7.8%) troops=1930763/3182845 gold=311800 | cit=3 por=1 fac=1 def=4 sam=0 sil=0
[10397] LG MATI owner175 (tiles terakhir 0)
[10397] LG MATI owner10 (tiles terakhir 0)
[10397] MOMENTUM owner 257 mom=0.80 (pasukan turun, tanah turun) pasukan=38660
[10397] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=839054
[10397] troops=1930763 A:1166081@0.26 A:862700@0.44
[10398] troops=1949798 A:1163547@0.26 A:898103@0.44
[10401] boat scan: 287 target (<=70 langkah, reach x1) dari 24 titik pantai
[10401] FRONT -> owner 102 P=48.79 arah=(0.57,-0.82) pasukan musuh=40775
[10401] REC troops=1037293/3838023 gold=466600 inc=3129/s tiles=69225 city=5(L5) def=4 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=264(989814, kontak 142) | rival=owner 264 hostile=1 brutal=true | nuke di udara=0 | foeSilo=2
[10401] MOMENTUM owner 102 mom=0.80 (pasukan turun, tanah turun) pasukan=37447
[10404] LG SERANG MASUK dari owner257 troops=11512 (pasukan gw 1130926)
[10404] LG ME rank=1 tiles=71941(9.0%) troops=1130926/4150564 gold=468600 | cit=6 por=1 fac=1 def=4 sam=0 sil=0
[10404] LG MATI owner64 (tiles terakhir 0)
[10404] LG MATI owner132 (tiles terakhir 0)
[10404] MOMENTUM owner 114 mom=0.57 (pasukan turun, diserang pihak lain) pasukan=29025
[10405] LG SERANG MASUK dari owner77 troops=31422 (pasukan gw 1227145)
[10406] WATCH #1 land: owner=282 tiles=58612(+7964) troops=1331244(+134514) | city=3(+1) port=1(+0) factory=2(+1) def=1(+0) sam=0(+0) silo=0(+0)  [20s]
[10406] MOMENTUM owner 17 mom=0.50 (pasukan turun) pasukan=71168
[10406] FRONT owner 102 P=275.70 kerucut=30 tile, pasukan gw=1251630 musuh=8898
[10407] MOMENTUM owner 257 mom=0.80 (pasukan turun, tanah turun) pasukan=3389
[10407] MOMENTUM owner 77 mom=0.50 (pasukan turun) pasukan=50200
[10408] FRONT -> owner 257 P=1622.59 arah=(-0.72,0.69) pasukan musuh=2262
[10408] build factory tile=1158487 cost~500000 gold=652050 inc=10380/s wealth=0.9 amount=1
[10409] boat scan: 290 target (<=70 langkah, reach x1) dari 24 titik pantai
[10410] LG ME rank=1 tiles=72396(9.1%) troops=1976171/4162967 gold=154050 | cit=6 por=1 fac=2 def=4 sam=0 sil=0
[10410] LG MATI owner169 (tiles terakhir 0)
[10410] LG MATI owner70 (tiles terakhir 0)
[10410] LG MATI owner102 (tiles terakhir 0)
[10411] build factory OK, gold=179550 level+1 (minta 1)
[10412] REC troops=2078867/4162584 gold=191050 inc=27957/s tiles=72383 city=6(L6) def=4 sam=0 silo=0 | serangan masuk=1(24579 troops) | tetangga terkuat=264(883765, kontak 155) | rival=- hostile=1 brutal=true | nuke di udara=0 | foeSilo=3
[10413] POSTURE need=0.47 [serang=0.00 loss=0.00 kuat=0.12 brutal=0.50] dom=1.00 | jatah defense=23% -> SEIMBANG
[10413] troops=2129831 A:1190097@0.35 A:872779@0.24
[10413] troops=2129831 A:1191362@0.35 A:874043@0.24
[10414] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=488629
[10416] MOMENTUM owner 31 mom=0.50 (pasukan turun) pasukan=64839
[10416] POSTURE need=0.68 [serang=0.00 loss=0.00 kuat=0.72 brutal=0.50] dom=0.00 | jatah defense=23% -> DEFENSE DULU
[10416] LG ME rank=1 tiles=79477(10.0%) troops=924830/4306352 gold=195550 | cit=6 por=1 fac=3 def=4 sam=0 sil=0
[10416] LG MATI owner195 (tiles terakhir 0)
[10416] LG MATI owner182 (tiles terakhir 0)
[10416] LG MATI owner272 (tiles terakhir 0)
[10416] LG MATI owner209 (tiles terakhir 0)
[10416] LG MATI owner120 (tiles terakhir 0)
[10416] LG MATI owner88 (tiles terakhir 0)
[10416] LG --- LEADERBOARD ---
[10416] LG #1 owner271 [GW] hidup tiles=79477(10.0%) troops=924830/4306352 gold=195550 jarak=0 | cit=6 por=1 fac=3 def=4 sam=0 sil=0
[10416] LG #2 owner282 [musuh] hidup tiles=61393(7.7%) troops=1005433/3170385 gold=142600 jarak=298 | cit=3 por=1 fac=2 def=1 sam=0 sil=0
[10416] LG #3 owner259 [musuh] hidup tiles=55924(7.0%) troops=2321199/3043908 gold=816685 jarak=910 | cit=3 por=3 fac=0 def=1 sam=1 sil=0
[10416] LG #4 owner261 [musuh] hidup tiles=47629(6.0%) troops=1752192/2343522 gold=1426316 jarak=1158 | cit=1 por=1 fac=1 def=0 sam=0 sil=0
[10416] LG #5 owner270 [musuh] hidup tiles=46958(5.9%) troops=2766556/2826598 gold=628891 jarak=572 | cit=3 por=2 fac=1 def=3 sam=0 sil=0
[10416] LG #6 owner258 [ally] hidup tiles=45603(5.7%) troops=2639836/2792176 gold=1195914 jarak=1027 | cit=3 por=2 fac=1 def=0 sam=0 sil=0
[10416] LG #7 owner283 [ally] hidup tiles=42790(5.4%) troops=1321226/1968621 gold=478950 jarak=293 | cit=0 por=0 fac=0 def=0 sam=0 sil=1
[10416] LG #8 owner264 [musuh] hidup tiles=41130(5.2%) troops=1207543/2674939 gold=4504101 jarak=239 | cit=3 por=1 fac=3 def=0 sam=0 sil=2
[10416] MOMENTUM owner 17 mom=0.90 (pasukan turun, tanah turun, diserang pihak lain) pasukan=64140
[10416] FRONT owner 257 P=152.61 kerucut=177 tile, pasukan gw=924830 musuh=11878
[10417] boat scan: 231 target (<=70 langkah, reach x1) dari 24 titik pantai
[10417] MOMENTUM owner 257 mom=0.80 (tanah turun, diserang pihak lain) pasukan=14464
[10417] POSTURE need=0.94 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.02 | jatah defense=23% -> DEFENSE DULU
[10420] MOMENTUM owner 77 mom=0.50 (pasukan turun) pasukan=48894
[10422] REC troops=1184709/4461174 gold=226050 inc=10722/s tiles=87367 city=6(L6) def=4 sam=0 silo=0 | serangan masuk=1(12051 troops) | tetangga terkuat=282(952843, kontak 84) | rival=owner 282 hostile=2 brutal=true | nuke di udara=0 | foeSilo=3
[10422] LG ME rank=1 tiles=87718(11.0%) troops=1209723/4470401 gold=226550 | cit=6 por=1 fac=3 def=4 sam=0 sil=0
[10422] LG MATI owner281 (tiles terakhir 0)
[10422] LG MATI owner217 (tiles terakhir 0)
[10424] build def tile=967436 cost~250000 gold=389900 inc=25203/s wealth=0.5 amount=1 musuh=264 skor=10.6 tertutup=0% need=0.75 jatah=23% URGENT
[10424] troops=1776047 E:1243228@0.08
[10425] MOMENTUM owner 14 mom=0.58 (pasukan turun, tanah turun) pasukan=75291
[10425] POSTURE need=0.73 [serang=0.00 loss=0.00 kuat=0.40 brutal=0.50] dom=0.00 | jatah defense=39% -> DEFENSE DULU
[10426] boat scan: 178 target (<=70 langkah, reach x1) dari 24 titik pantai
[10426] WATCH #1 land: owner=282 tiles=64573(+5961) troops=1626696(+295452) | city=3(+0) port=1(+0) factory=2(+0) def=1(+0) sam=0(+0) silo=0(+0)  [20s]
[10426] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=640458
[10426] FRONT owner 257 P=93.90 kerucut=22 tile, pasukan gw=1915169 musuh=27651
[10426] build def OK, gold=142400 level+1 (minta 1)
[10427] POSTURE need=0.95 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=39% -> DEFENSE DULU
[10429] LG ME rank=1 tiles=90497(11.3%) troops=2059479/4779668 gold=179900 | cit=7 por=1 fac=3 def=5 sam=0 sil=0
[10429] LG MATI owner196 (tiles terakhir 0)
[10429] LG MATI owner200 (tiles terakhir 0)
[10429] LG MATI owner52 (tiles terakhir 0)
[10429] LG MATI owner17 (tiles terakhir 0)
[10430] FOCUS -> owner 143 ratio=34.28 contact=true jarak=219 skor=10.22 brutal=false existential=false(0.6%)
[10430] FRONT -> owner 14 P=39.37 arah=(-0.13,-0.99) pasukan musuh=92186
[10432] MOMENTUM owner 143 mom=0.50 (pasukan turun) pasukan=71817
[10432] MOMENTUM owner 31 mom=0.80 (pasukan turun, tanah turun) pasukan=59475
[10432] REC troops=2495543/4780231 gold=228400 inc=18595/s tiles=90506 city=7(L7) def=5 sam=0 silo=0 | serangan masuk=1(2080 troops) | tetangga terkuat=282(1412288, kontak 289) | rival=- hostile=2 brutal=true | nuke di udara=0 | foeSilo=3
[10434] boat scan: 241 target (<=70 langkah, reach x1) dari 24 titik pantai
[10435] LG ME rank=1 tiles=90499(11.3%) troops=2633654/4780076 gold=230900 | cit=7 por=1 fac=3 def=5 sam=0 sil=0
[10435] LG MATI owner253 (tiles terakhir 0)
[10435] LG MATI owner53 (tiles terakhir 0)
[10435] MOMENTUM owner 133 mom=0.50 (pasukan turun) pasukan=53216
[10435] POSTURE need=0.74 [serang=0.00 loss=0.00 kuat=0.40 brutal=0.00] dom=0.00 | jatah defense=39% -> DEFENSE DULU
[10437] FRONT owner 14 P=28.40 kerucut=72 tile, pasukan gw=2741821 musuh=111108
[10437] POSTURE need=0.96 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=39% -> DEFENSE DULU
[10439] MOMENTUM owner 14 mom=0.48 (tanah turun, diserang pihak lain) pasukan=114118
[10439] MOMENTUM owner 282 mom=0.50 (pasukan turun) pasukan=1302808
[10439] troops=2873402 A:780377@0.17
[10440] troops=2899192 A:779113@0.18
[10441] LG ME rank=1 tiles=91039(11.4%) troops=2494604/4789875 gold=237400 | cit=7 por=1 fac=3 def=5 sam=0 sil=0
[10441] LG MATI owner39 (tiles terakhir 0)
[10442] LG SERANG MASUK dari owner114 troops=51336 (pasukan gw 2550289)
[10442] boat scan: 161 target (<=70 langkah, reach x1) dari 24 titik pantai
[10442] MOMENTUM owner 143 mom=0.44 (pasukan turun, tanah turun) pasukan=82233
[10442] COUNTER owner 114 serangan=51336 ratio=0.05
[10443] REC troops=2448919/4798647 gold=238900 inc=6273/s tiles=91575 city=7(L7) def=5 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=264(2200895, kontak 420) | rival=owner 264 hostile=2 brutal=false | nuke di udara=0 | foeSilo=3
[10443] MOMENTUM owner 77 mom=0.50 (pasukan turun) pasukan=55061
[10444] MOMENTUM owner 114 mom=0.80 (pasukan turun, tanah turun) pasukan=15460
[10446] MOMENTUM owner 133 mom=0.71 (tanah turun, diserang pihak lain) pasukan=67283
[10446] build def tile=781585 cost~250000 gold=424100 inc=20868/s wealth=0.6 amount=1 musuh=264 skor=7.7 tertutup=2% need=0.86 jatah=39% URGENT
[10447] WATCH #1 land: owner=282 tiles=65726(+1153) troops=1731848(+105152) | city=3(+0) port=1(+0) factory=2(+0) def=1(+0) sam=0(+0) silo=0(+0)  [20s]
[10447] LG ME rank=1 tiles=93930(11.8%) troops=2750934/4844776 gold=176100 | cit=7 por=1 fac=3 def=6 sam=0 sil=0
[10447] LG MATI owner67 (tiles terakhir 0)
[10447] LG MATI owner114 (tiles terakhir 0)
[10447] LG --- LEADERBOARD ---
[10447] LG #1 owner271 [GW] hidup tiles=93930(11.8%) troops=2750934/4844776 gold=176100 jarak=0 | cit=7 por=1 fac=3 def=6 sam=0 sil=0
[10447] LG #2 owner282 [musuh] hidup tiles=65769(8.2%) troops=1752878/3269056 gold=223600 jarak=288 | cit=3 por=1 fac=2 def=1 sam=0 sil=0
[10447] LG #3 owner259 [musuh] hidup tiles=56672(7.1%) troops=3062469/3062655 gold=606075 jarak=900 | cit=3 por=4 fac=0 def=1 sam=1 sil=0
[10447] LG #4 owner283 [ally] hidup tiles=52103(6.5%) troops=1484703/2703513 gold=519950 jarak=295 | cit=2 por=0 fac=2 def=0 sam=0 sil=1
[10447] LG #5 owner261 [musuh] hidup tiles=50649(6.3%) troops=2216187/2418403 gold=271051 jarak=1146 | cit=1 por=1 fac=1 def=0 sam=1 sil=0
[10447] LG #6 owner286 [musuh] hidup tiles=47085(5.9%) troops=1347897/2828668 gold=2769509 jarak=435 | cit=3 por=2 fac=0 def=0 sam=0 sil=1
[10447] LG #7 owner270 [musuh] hidup tiles=46949(5.9%) troops=2552260/2826320 gold=1461670 jarak=561 | cit=3 por=2 fac=1 def=3 sam=0 sil=0
[10447] LG #8 owner264 [musuh] hidup tiles=46068(5.8%) troops=1176096/2801361 gold=7328366 jarak=236 | cit=3 por=1 fac=3 def=0 sam=0 sil=2
[10447] FRONT owner 14 P=69.13 kerucut=119 tile, pasukan gw=2750934 musuh=78000
[10447] POSTURE need=0.76 [serang=0.00 loss=0.00 kuat=0.40 brutal=0.00] dom=0.03 | jatah defense=50% -> DEFENSE DULU
[10448] build def OK, gold=177100 level+1 (minta 1)
[10449] MOMENTUM owner 14 mom=0.50 (pasukan turun) pasukan=82556
[10450] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=1251955
[10450] boat scan: 241 target (<=70 langkah, reach x1) dari 24 titik pantai
[10450] FRONT -> owner 133 P=339.17 arah=(-0.28,-0.96) pasukan musuh=18884
[10451] MOMENTUM owner 103 mom=0.45 (tanah turun, diserang pihak lain) pasukan=75632
[10451] troops=2937434 A:753864@0.17
[10451] troops=2963420 A:729815@0.18
[10452] troops=2989230 A:741218@0.19
[10453] MOMENTUM owner 143 mom=0.80 (pasukan turun, tanah turun) pasukan=41323
[10453] MOMENTUM owner 31 mom=0.50 (pasukan turun) pasukan=65058
[10453] troops=3040314 A:732360@0.20
[10453] LG ME rank=1 tiles=95052(11.9%) troops=3065586/4866872 gold=182100 | cit=7 por=1 fac=3 def=6 sam=0 sil=0
[10453] LG MATI owner107 (tiles terakhir 0)
[10453] REC troops=3065586/4866872 gold=182100 inc=12951/s tiles=95052 city=7(L7) def=6 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=264(2470745, kontak 404) | rival=owner 264 hostile=2 brutal=false | nuke di udara=0 | foeSilo=3
[10453] MOMENTUM owner 77 mom=0.44 (tanah turun, diserang pihak lain) pasukan=79236
[10453] troops=3065586 A:755141@0.21
[10454] troops=3090674 A:755144@0.21
[10454] POSTURE need=0.97 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=50% -> DEFENSE DULU
[10454] troops=3115578 A:726048@0.22
[10455] troops=3140299 A:755150@0.22
[10455] troops=3164832 A:748833@0.23
[10456] MOMENTUM owner 133 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=12061
[10456] troops=3189173 A:750105@0.24
[10456] troops=3213320 A:746316@0.24
[10457] troops=3237273 A:726059@0.20
[10458] FRONT -> owner 143 P=862.63 arah=(0.40,-0.92) pasukan musuh=7463
[10458] FRONT owner 143 P=862.63 kerucut=35 tile, pasukan gw=3284583 musuh=7463
[10458] troops=3284583 A:723532@0.21
[10458] LG SERANG MASUK dari owner264 troops=1296597 (pasukan gw 3305599)
[10458] FOCUS -> owner 14 ratio=28.23 contact=true jarak=262 skor=10.10 brutal=false existential=false(0.7%)
[10458] DEFENSE DIBLOK: lagi diserang (masuk=39% pasukan, tanah hilang=0.0%) 45s
[10458] COUNTER owner 264 serangan=1296597 ratio=0.14
[10459] boat scan: 244 target (<=70 langkah, reach x1) dari 24 titik pantai
[10459] FRONT -> owner 103 P=128.89 arah=(0.23,-0.97) pasukan musuh=47869
[10459] troops=3147877 A:724664@0.17
[10459] LG ME rank=1 tiles=95945(12.0%) troops=3168495/4883303 gold=377550 | cit=7 por=1 fac=3 def=5 sam=0 sil=0
[10459] LG MATI owner226 (tiles terakhir 0)
[10459] LG MATI owner133 (tiles terakhir 0)
[10459] LG MATI owner143 (tiles terakhir 0)
[10460] build def tile=1009196 cost~250000 gold=377550 inc=6194/s wealth=0.5 amount=1 musuh=264 skor=9.8 tertutup=13% need=0.94 jatah=50% URGENT
[10460] COLLAPSE GUARD: nahan semua pasukan (need=0.94) -- fokus defense/front, expand/attack dihentikan sementara
[10460] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=1383371
[10461] MOMENTUM owner 103 mom=0.50 (pasukan turun) pasukan=53167
[10462] MOMENTUM owner 14 mom=0.80 (pasukan turun, tanah turun) pasukan=93318
[10462] build def gagal (1) tile=1009196
[10464] REC troops=2853407/4904836 gold=142050 inc=22439/s tiles=97052 city=7(L7) def=4 sam=0 silo=0 | serangan masuk=1(477187 troops) | tetangga terkuat=282(2713640, kontak 277) | rival=owner 282 hostile=2 brutal=true | nuke di udara=0 | foeSilo=3
[10464] LOSS struktur defense 6 -> 4
[10464] MOMENTUM owner 77 mom=0.50 (pasukan turun) pasukan=55811
[10466] LG ME rank=1 tiles=97400(12.2%) troops=2948279/4911387 gold=144050 | cit=7 por=1 fac=3 def=4 sam=0 sil=0
[10466] LG MATI owner247 (tiles terakhir 0)
[10466] LG MATI owner49 (tiles terakhir 0)
[10466] MOMENTUM owner 31 mom=0.41 (tanah turun, diserang pihak lain) pasukan=92810
[10466] troops=2948279 A:677854@0.17
[10466] STATE _seq: 1 -> 2
[10467] WATCH #1 land: owner=282 tiles=66662(+936) troops=2748490(+1016642) | city=3(+0) port=1(+0) factory=2(+0) def=2(+1) sam=0(+0) silo=0(+0)  [20s]
[10467] boat scan: 378 target (<=70 langkah, reach x1) dari 24 titik pantai
[10468] FRONT owner 103 P=33.01 kerucut=84 tile, pasukan gw=2535130 musuh=66971
[10471] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=968475
[10471] troops=2648779 A:633569@0.04
[10472] troops=2667036 A:631036@0.04
[10472] LG ME rank=1 tiles=95495(12.0%) troops=2703900/4377149 gold=150550 | cit=5 por=1 fac=3 def=4 sam=0 sil=0
[10472] LG ALIANSI owner259 <-> owner270 TERBENTUK
[10472] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1129860
[10472] POSTURE need=0.76 [serang=0.49 loss=0.00 kuat=0.46 brutal=0.50] dom=0.00 | jatah defense=50% -> DEFENSE DULU
[10472] COUNTER owner 264 serangan=733100 ratio=0.02
[10473] MOMENTUM owner 14 mom=0.80 (pasukan turun, tanah turun) pasukan=40972
[10473] troops=2656006 A:619647@0.03
[10473] MOMENTUM owner 103 mom=0.50 (diserang pihak lain) pasukan=77967
[10473] troops=2675471 A:614582@0.03
[10474] REC troops=2695059/4371366 gold=152050 inc=8464/s tiles=95201 city=5(L5) def=4 sam=0 silo=0 | serangan masuk=1(557616 troops) | tetangga terkuat=282(2885713, kontak 269) | rival=owner 282 hostile=3 brutal=true | nuke di udara=0 | foeSilo=4
[10474] LOSS struktur city 7 -> 5
[10474] MOMENTUM owner 208 mom=0.50 (pasukan turun) pasukan=52552
[10474] troops=2695059 A:610788@0.04
[10475] FOCUS -> owner 208 ratio=48.89 contact=true jarak=280 skor=10.07 brutal=false existential=false(0.4%)
[10475] idle: nggak ada target layak (fokus=208 boatTargets=378)
[10475] boat scan: 520 target (<=70 langkah, reach x1) dari 24 titik pantai
[10478] troops=3706293 A:641174@0.28
[10479] LG ME rank=1 tiles=95063(11.9%) troops=2656900/4368282 gold=355350 | cit=5 por=1 fac=3 def=4 sam=0 sil=0
[10479] LG MATI owner14 (tiles terakhir 0)
[10479] LG --- LEADERBOARD ---
[10479] LG #1 owner271 [GW] hidup tiles=95063(11.9%) troops=2656900/4368282 gold=355350 jarak=0 | cit=5 por=1 fac=3 def=4 sam=0 sil=0
[10479] LG #2 owner283 [ally] hidup tiles=69811(8.7%) troops=797939/3356435 gold=610950 jarak=330 | cit=3 por=0 fac=2 def=0 sam=0 sil=1
[10479] LG #3 owner282 [musuh] hidup tiles=66951(8.4%) troops=2952705/3294944 gold=388450 jarak=301 | cit=3 por=1 fac=2 def=2 sam=0 sil=0
[10479] LG #4 owner259 [musuh] hidup tiles=56672(7.1%) troops=3062469/3062655 gold=2444565 jarak=900 | cit=3 por=4 fac=0 def=1 sam=1 sil=0
[10479] LG #5 owner264 [musuh] hidup tiles=54765(6.9%) troops=1323346/3515182 gold=10009453 jarak=217 | cit=5 por=1 fac=3 def=0 sam=0 sil=2
[10479] LG #6 owner286 [musuh] hidup tiles=51338(6.4%) troops=1370855/2932680 gold=3862304 jarak=417 | cit=3 por=2 fac=0 def=1 sam=0 sil=1
[10479] LG #7 owner261 [musuh] hidup tiles=50815(6.4%) troops=2419361/2672468 gold=297983 jarak=1144 | cit=2 por=1 fac=1 def=0 sam=1 sil=0
[10479] LG #8 owner270 [musuh] hidup tiles=46991(5.9%) troops=2342004/2827381 gold=669784 jarak=553 | cit=3 por=2 fac=1 def=3 sam=1 sil=0
[10479] FRONT owner 103 P=137.17 kerucut=85 tile, pasukan gw=2656900 musuh=41148
[10481] LG NUKE baru owner=264 kind=0 target=nil
[10481] troops=2740785 A:628528@0.02
[10482] troops=2801776 A:627272@0.07
[10482] troops=2821632 A:620950@0.07
[10483] boat scan: 360 target (<=70 langkah, reach x1) dari 24 titik pantai
[10483] MOMENTUM owner 77 mom=0.50 (pasukan turun) pasukan=52951
[10483] POSTURE need=0.56 [serang=0.40 loss=0.02 kuat=0.42 brutal=0.50] dom=0.00 | jatah defense=50% -> SEIMBANG
[10483] troops=2860803 A:651299@0.08
[10484] STATE fallout_count: 0 -> 794
[10484] MOMENTUM owner 103 mom=0.80 (pasukan turun, tanah turun) pasukan=50998
[10484] LUBANG expand 689264@0.06 693043@0.06 693055@0.06 (fill=0.64)
[10484] troops=2762499 A:656370@0.04
[10484] STATE fallout_count: 794 -> 426
[10484] REC troops=2311177/4346996 gold=361350 inc=13516/s tiles=94343 city=5(L5) def=4 sam=0 silo=0 | serangan masuk=1(214122 troops) | tetangga terkuat=282(2942001, kontak 240) | rival=owner 282 hostile=3 brutal=true | nuke di udara=0 | foeSilo=4
[10485] MOMENTUM owner 208 mom=0.63 (pasukan turun, tanah turun) pasukan=57601
[10485] STATE fallout_count: 426 -> 187
[10485] LG ME rank=1 tiles=94616(11.8%) troops=2358419/4358997 gold=362350 | cit=5 por=1 fac=3 def=4 sam=0 sil=0
[10486] STATE fallout_count: 187 -> 116
[10486] STATE fallout_count: 116 -> 68
[10486] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=850426
[10486] MOMENTUM owner 31 mom=0.42 (tanah turun, diserang pihak lain) pasukan=96211
[10486] FRONT -> owner 208 P=88.64 arah=(0.01,-1.00) pasukan musuh=49523
[10487] STATE fallout_count: 68 -> 32
[10487] POSTURE need=0.78 [serang=0.75 loss=0.14 kuat=0.81 brutal=0.50] dom=0.00 | jatah defense=50% -> DEFENSE DULU
[10487] WATCH #1 land: owner=282 tiles=66994(+332) troops=2982345(+233855) | city=3(+0) port=1(+0) factory=2(+0) def=2(+0) sam=0(+0) silo=0(+0)  [20s]
[10488] build def tile=599393 cost~250000 gold=374850 inc=9468/s wealth=0.5 amount=1 musuh=286 skor=40.5 tertutup=0% need=0.91 jatah=50% URGENT
[10489] FRONT owner 208 P=55.13 kerucut=67 tile, pasukan gw=979320 musuh=34818
[10489] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1130788
[10489] POSTURE need=0.99 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=61% -> DEFENSE DULU
[10490] build def OK, gold=127350 level+1 (minta 1)
[10492] LG ME rank=1 tiles=99030(12.4%) troops=1145974/4441963 gold=128850 | cit=5 por=1 fac=3 def=5 sam=0 sil=0
[10492] LG MATI owner230 (tiles terakhir 0)
[10492] boat scan: 599 target (<=70 langkah, reach x1) dari 24 titik pantai
[10493] FOCUS -> owner 119 ratio=18.17 contact=true jarak=289 skor=9.10 brutal=false existential=false(0.5%)
[10493] FRONT -> owner 31 P=21.60 arah=(0.44,-0.90) pasukan musuh=71819
[10495] REC troops=2198252/4445672 gold=131850 inc=6090/s tiles=99183 city=5(L5) def=5 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=282(3296763, kontak 254) | rival=owner 282 hostile=2 brutal=true | nuke di udara=0 | foeSilo=4
[10496] LG SERANG MASUK dari owner282 troops=1648381 (pasukan gw 2249180)
[10496] MOMENTUM owner 172 mom=0.50 (pasukan turun) pasukan=49890
[10496] MOMENTUM owner 77 mom=0.62 (tanah turun, diserang pihak lain) pasukan=81144
[10496] COUNTER owner 282 serangan=1648381 ratio=0.21
[10496] LG NUKE baru owner=264 kind=0 target=nil
[10496] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=404163
[10496] MOMENTUM owner 282 mom=0.50 (pasukan turun) pasukan=1678618
[10498] LG ME rank=1 tiles=97868(12.3%) troops=1864923/4423672 gold=134850 | cit=5 por=1 fac=3 def=5 sam=0 sil=0
[10498] LG MATI owner208 (tiles terakhir 0)
[10498] LG MATI owner40 (tiles terakhir 0)
[10498] COUNTER owner 282 serangan=986930 ratio=0.06
[10499] FRONT owner 31 P=20.63 kerucut=130 tile, pasukan gw=1911065 musuh=85992
[10500] boat scan: 120 target (<=70 langkah, reach x1) dari 24 titik pantai
[10501] MOMENTUM owner 103 mom=0.50 (pasukan turun) pasukan=43286
[10502] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1202583
[10502] MOMENTUM owner 119 mom=0.50 (pasukan turun) pasukan=72971
[10504] LG ME rank=1 tiles=95672(12.0%) troops=1504028/4379353 gold=151350 | cit=5 por=1 fac=3 def=5 sam=0 sil=0
[10505] REC troops=1528238/4379372 gold=151850 inc=3099/s tiles=95663 city=5(L5) def=5 sam=0 silo=0 | serangan masuk=1(585817 troops) | tetangga terkuat=282(2034319, kontak 189) | rival=owner 282 hostile=2 brutal=true | nuke di udara=0 | foeSilo=5
[10506] MOMENTUM owner 77 mom=0.88 (pasukan turun, diserang pihak lain) pasukan=55598
[10507] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=394231
[10507] LG NUKE baru owner=264 kind=1 target=nil
[10507] WATCH #1 land: owner=282 tiles=71404(+4410) troops=2132883(-849462) | city=3(+0) port=1(+0) factory=2(+0) def=2(+0) sam=0(+0) silo=0(+0)  [20s]
[10509] boat scan: 345 target (<=70 langkah, reach x1) dari 24 titik pantai
[10509] MOMENTUM owner 31 mom=0.50 (pasukan turun) pasukan=67805
[10509] FRONT owner 31 P=41.51 kerucut=124 tile, pasukan gw=1759263 musuh=67805
[10509] POSTURE need=0.82 [serang=0.45 loss=0.01 kuat=0.66 brutal=0.50] dom=0.00 | jatah defense=61% -> DEFENSE DULU
[10510] LG ME rank=1 tiles=87575(11.0%) troops=1812216/4614204 gold=157350 | cit=5 por=1 fac=3 def=5 sam=0 sil=0
[10510] LG --- LEADERBOARD ---
[10510] LG #1 owner271 [GW] hidup tiles=87575(11.0%) troops=1812216/4614204 gold=157350 jarak=0 | cit=5 por=1 fac=3 def=5 sam=0 sil=0
[10510] LG #2 owner283 [ally] hidup tiles=73546(9.2%) troops=1935245/3684950 gold=692950 jarak=335 | cit=4 por=0 fac=2 def=0 sam=0 sil=1
[10510] LG #3 owner282 [musuh] hidup tiles=72002(9.0%) troops=1140843/3403184 gold=480450 jarak=300 | cit=3 por=1 fac=2 def=2 sam=0 sil=0
[10510] LG #4 owner286 [musuh] hidup tiles=57942(7.3%) troops=1489902/3342297 gold=4416216 jarak=413 | cit=4 por=3 fac=0 def=1 sam=0 sil=1
[10510] LG #5 owner259 [musuh] hidup tiles=56672(7.1%) troops=3062469/3062655 gold=2688658 jarak=906 | cit=3 por=6 fac=0 def=1 sam=1 sil=0
[10510] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=2611249/2672468 gold=522468 jarak=1150 | cit=2 por=1 fac=1 def=0 sam=1 sil=0
[10510] LG #7 owner264 [musuh] hidup tiles=49246(6.2%) troops=493426/3212658 gold=5144321 jarak=229 | cit=3 por=1 fac=3 def=0 sam=0 sil=2
[10510] LG #8 owner270 [musuh] hidup tiles=47108(5.9%) troops=2574517/2830359 gold=731130 jarak=555 | cit=3 por=3 fac=1 def=3 sam=1 sil=2
[10510] REBUT: 7331 tile hilang jadi netral/fallout (kena nuke?) -> expand ulang 25s
[10511] FOCUS -> owner 103 ratio=192.99 contact=true jarak=232 skor=10.62 brutal=false existential=false(0.2%)
[10511] MOMENTUM owner 103 mom=0.80 (pasukan turun, tanah turun) pasukan=6429
[10513] MOMENTUM owner 282 mom=0.50 (pasukan turun) pasukan=1251839
[10513] FRONT -> owner 103 P=236.52 arah=(0.23,-0.97) pasukan musuh=8471
[10515] REC troops=1088954/4240090 gold=171850 inc=2665/s tiles=88465 city=5(L5) def=5 sam=0 silo=0 | serangan masuk=1(264405 troops) | tetangga terkuat=282(1341932, kontak 251) | rival=owner 282 hostile=2 brutal=true | nuke di udara=0 | foeSilo=5
[10516] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1197189
[10516] MOMENTUM owner 119 mom=0.95 (pasukan turun, tanah turun, diserang pihak lain) pasukan=71416
[10517] LG ME rank=1 tiles=88551(11.1%) troops=887013/4238188 gold=173850 | cit=5 por=1 fac=3 def=5 sam=0 sil=0
[10517] LG MATI owner9 (tiles terakhir 0)
[10517] LG MATI owner123 (tiles terakhir 0)
[10517] boat scan: 438 target (<=70 langkah, reach x1) dari 24 titik pantai
[10517] MOMENTUM owner 264 mom=0.64 (pasukan turun, tanah turun) pasukan=156733
[10520] FRONT owner 103 P=131.50 kerucut=73 tile, pasukan gw=994841 musuh=14828
[10523] LG ME rank=1 tiles=94329(11.8%) troops=881232/4600057 gold=189850 | cit=6 por=1 fac=3 def=5 sam=0 sil=0
[10523] LG MATI owner3 (tiles terakhir 0)
[10523] MOMENTUM owner 282 mom=0.44 (tanah turun, diserang pihak lain) pasukan=1672020
[10523] MOMENTUM owner 77 mom=0.56 (pasukan turun, tanah turun) pasukan=47135
[10523] MOMENTUM owner 31 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=55445
[10525] REC troops=988604/4369044 gold=192350 inc=2590/s tiles=95085 city=5(L5) def=5 sam=0 silo=0 | serangan masuk=1(668568 troops) | tetangga terkuat=286(1480027, kontak 151) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=5
[10525] boat scan: 196 target (<=70 langkah, reach x1) dari 24 titik pantai
[10526] build def tile=1196431 cost~250000 gold=405750 inc=2590/s wealth=0.5 amount=1 musuh=282 skor=21.8 tertutup=0% need=1.00 jatah=61% URGENT
[10526] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1527930
[10527] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=103775
[10528] WATCH #1 land: owner=282 tiles=72647(+1243) troops=1225088(-907795) | city=4(+1) port=1(+0) factory=4(+2) def=2(+0) sam=0(+0) silo=0(+0)  [20s]
[10529] FOCUS -> owner 264 ratio=15.96 contact=true jarak=227 skor=10.12 brutal=false existential=false(5.9%)
[10529] build def OK, gold=158250 level+1 (minta 1)
[10529] LG ME rank=1 tiles=93815(11.7%) troops=988898/4345962 gold=158750 | cit=5 por=1 fac=1 def=6 sam=0 sil=0
[10529] LG MATI owner31 (tiles terakhir 0)
[10529] LG MATI owner94 (tiles terakhir 0)
[10529] MOMENTUM owner 119 mom=0.78 (pasukan turun, tanah turun) pasukan=68027
[10530] FRONT owner 103 P=35.50 kerucut=74 tile, pasukan gw=1031921 musuh=30527
[10530] POSTURE need=0.99 [serang=0.77 loss=0.33 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=70% -> DEFENSE DULU
[10533] MOMENTUM owner 77 mom=0.80 (pasukan turun, tanah turun) pasukan=46467
[10534] boat scan: 324 target (<=70 langkah, reach x1) dari 24 titik pantai
[10534] FRONT -> owner 264 P=65.73 arah=(-0.96,-0.27) pasukan musuh=29045
[10535] LG ME rank=1 tiles=93551(11.7%) troops=1265313/4337897 gold=164750 | cit=5 por=1 fac=1 def=5 sam=0 sil=0
[10535] MOMENTUM owner 282 mom=0.50 (pasukan turun) pasukan=650830
[10536] REC troops=1314579/4340217 gold=165750 inc=17064/s tiles=93640 city=5(L5) def=5 sam=0 silo=0 | serangan masuk=1(236267 troops) | tetangga terkuat=286(1390821, kontak 152) | rival=owner 286 hostile=3 brutal=true | nuke di udara=0 | foeSilo=5
[10536] LOSS struktur factory 3 -> 1
[10537] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1438657
[10537] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=27458
[10540] FRONT owner 264 P=115.77 kerucut=206 tile, pasukan gw=1518355 musuh=20985
[10541] MOMENTUM owner 103 mom=0.47 (diserang pihak lain) pasukan=49521
[10541] MOMENTUM owner 172 mom=0.70 (pasukan turun, diserang pihak lain) pasukan=47968
[10542] LG ME rank=1 tiles=94480(11.8%) troops=1622869/4356554 gold=171750 | cit=5 por=1 fac=1 def=5 sam=0 sil=0
[10542] LG --- LEADERBOARD ---
[10542] LG #1 owner271 [GW] hidup tiles=94480(11.8%) troops=1622869/4356554 gold=171750 jarak=0 | cit=5 por=1 fac=1 def=5 sam=0 sil=0
[10542] LG #2 owner283 [ally] hidup tiles=85130(10.7%) troops=1173959/4178285 gold=754450 jarak=361 | cit=5 por=0 fac=2 def=0 sam=0 sil=1
[10542] LG #3 owner282 [musuh] hidup tiles=78036(9.8%) troops=982765/3526646 gold=601950 jarak=356 | cit=3 por=1 fac=5 def=2 sam=0 sil=0
[10542] LG #4 owner286 [musuh] hidup tiles=64026(8.0%) troops=1679506/3730063 gold=2770991 jarak=387 | cit=5 por=3 fac=1 def=1 sam=1 sil=1
[10542] LG #5 owner259 [musuh] hidup tiles=56683(7.1%) troops=3062914/3062913 gold=2571236 jarak=900 | cit=3 por=6 fac=1 def=1 sam=1 sil=0
[10542] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=2825353/2922468 gold=271447 jarak=1143 | cit=3 por=1 fac=1 def=0 sam=1 sil=0
[10542] LG #7 owner264 [musuh] hidup tiles=47735(6.0%) troops=15255/2596157 gold=6336349 jarak=224 | cit=2 por=1 fac=3 def=0 sam=0 sil=2
[10542] LG #8 owner270 [musuh] hidup tiles=47190(5.9%) troops=3082452/3082451 gold=94011 jarak=535 | cit=4 por=3 fac=2 def=3 sam=1 sil=2
[10542] boat scan: 394 target (<=70 langkah, reach x1) dari 24 titik pantai
[10542] MOMENTUM owner 119 mom=0.50 (pasukan turun) pasukan=67051
[10543] MOMENTUM owner 77 mom=0.80 (pasukan turun, tanah turun) pasukan=11993
[10544] POSTURE need=0.79 [serang=0.40 loss=0.00 kuat=0.76 brutal=0.00] dom=0.00 | jatah defense=70% -> DEFENSE DULU
[10546] build def tile=1169935 cost~250000 gold=397850 inc=6793/s wealth=0.5 amount=1 musuh=282 skor=9.7 tertutup=22% need=0.93 jatah=70% URGENT
[10546] REC troops=1225926/4396988 gold=408350 inc=6793/s tiles=97390 city=5(L5) def=6 sam=0 silo=0 | serangan masuk=1(135988 troops) | tetangga terkuat=286(1871107, kontak 148) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=5
[10548] LG ME rank=1 tiles=100361(12.6%) troops=1326383/4458856 gold=160350 | cit=5 por=1 fac=2 def=6 sam=0 sil=0
[10548] LG MATI owner77 (tiles terakhir 0)
[10548] WATCH #1 land: owner=282 tiles=79410(+6763) troops=1235371(+10283) | city=3(-1) port=1(+0) factory=5(+1) def=2(+0) sam=0(+0) silo=0(+0)  [20s]
[10548] LG NUKE baru owner=283 kind=0 target=nil
[10548] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=6769
[10548] build def OK, gold=160850 level+1 (minta 1)
[10550] boat scan: 149 target (<=70 langkah, reach x1) dari 24 titik pantai
[10550] FRONT owner 264 P=500.04 kerucut=206 tile, pasukan gw=1456241 musuh=5708
[10552] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1325644
[10552] MOMENTUM owner 119 mom=0.80 (tanah turun, diserang pihak lain) pasukan=91586
[10553] MOMENTUM owner 282 mom=0.56 (tanah turun, diserang pihak lain) pasukan=1407960
[10553] COUNTER owner 282 serangan=75316 ratio=0.03
[10553] LG SERANG MASUK dari owner264 troops=5447 (pasukan gw 1878833)
[10554] build def tile=643827 cost~250000 gold=392200 inc=39343/s wealth=0.5 amount=1 musuh=286 skor=23.0 tertutup=49% need=0.97 jatah=76% URGENT
[10554] LG ME rank=1 tiles=106920(13.4%) troops=1460303/4578358 gold=142700 | cit=5 por=1 fac=2 def=7 sam=0 sil=0
[10554] LG MATI owner172 (tiles terakhir 0)
[10554] LG MATI owner229 (tiles terakhir 0)
[10554] POSTURE need=0.99 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=80% -> DEFENSE DULU
[10556] FOCUS -> owner 119 ratio=30.29 contact=true jarak=236 skor=8.73 brutal=false existential=false(0.2%)
[10556] FRONT -> owner 119 P=66.65 arah=(0.14,-0.99) pasukan musuh=49992
[10556] REC troops=1569175/4615203 gold=144700 inc=24023/s tiles=108512 city=5(L5) def=7 sam=0 silo=0 | serangan masuk=1(3697 troops) | tetangga terkuat=286(3682336, kontak 281) | rival=owner 286 hostile=3 brutal=true | nuke di udara=0 | foeSilo=6
[10557] LG SERANG MASUK dari owner103 troops=28441 (pasukan gw 1596698)
[10557] MOMENTUM owner 103 mom=0.80 (pasukan turun, tanah turun) pasukan=32593
[10557] build def OK, gold=145200 level+1 (minta 1)
[10558] boat scan: 279 target (<=70 langkah, reach x1) dari 24 titik pantai
[10560] LG ME rank=1 tiles=109643(13.7%) troops=1791495/4636555 gold=148700 | cit=5 por=1 fac=2 def=7 sam=0 sil=0
[10560] FRONT owner 119 P=601.26 kerucut=23 tile, pasukan gw=1791495 musuh=6555
[10561] FOCUS -> owner 103 ratio=45.99 contact=true jarak=186 skor=8.94 brutal=false existential=false(0.1%)
[10561] FRONT -> owner 103 P=73.58 arah=(0.32,-0.95) pasukan musuh=39566
[10563] MOMENTUM owner 282 mom=0.98 (pasukan turun, tanah turun, diserang pihak lain) pasukan=1302586
[10566] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1456105
[10567] LG ME rank=1 tiles=110479(13.8%) troops=1610726/4650571 gold=154700 | cit=5 por=1 fac=2 def=7 sam=0 sil=0
[10567] LG MATI owner119 (tiles terakhir 0)
[10567] REC troops=1610726/4650571 gold=154700 inc=9304/s tiles=110479 city=5(L5) def=7 sam=0 silo=0 | serangan masuk=1(10853 troops) | tetangga terkuat=286(1506047, kontak 382) | rival=owner 286 hostile=3 brutal=true | nuke di udara=0 | foeSilo=6
[10567] boat scan: 226 target (<=70 langkah, reach x1) dari 24 titik pantai
[10568] WATCH leader ganti: owner 282 -> owner 286
[10568] WATCH #1 land: owner=286 tiles=74930(+0) troops=1581433(+0) | city=5(+0) port=3(+0) factory=1(+0) def=1(+0) sam=1(+0) silo=1(+0)
[10569] LG NUKE baru owner=264 kind=0 target=nil
[10570] FRONT owner 103 P=26.75 kerucut=74 tile, pasukan gw=1835299 musuh=56466
[10571] LG SERANG MASUK dari owner282 troops=179443 (pasukan gw 1863636)
[10573] LG ME rank=1 tiles=110456(13.8%) troops=1914086/4652455 gold=161200 | cit=5 por=1 fac=2 def=7 sam=0 sil=0
[10573] LG --- LEADERBOARD ---
[10573] LG #1 owner271 [GW] hidup tiles=110456(13.8%) troops=1914086/4652455 gold=161200 jarak=0 | cit=5 por=1 fac=2 def=7 sam=0 sil=0
[10573] LG #2 owner283 [ally] hidup tiles=88310(11.1%) troops=1275087/4482516 gold=35450 jarak=372 | cit=6 por=1 fac=2 def=0 sam=0 sil=1
[10573] LG #3 owner286 [musuh] hidup tiles=75927(9.5%) troops=1834343/3986623 gold=4590381 jarak=374 | cit=5 por=3 fac=1 def=1 sam=1 sil=1
[10573] LG #4 owner282 [musuh] hidup tiles=72573(9.1%) troops=1108443/3172279 gold=747950 jarak=357 | cit=2 por=0 fac=5 def=1 sam=0 sil=0
[10573] LG #5 owner259 [musuh] hidup tiles=57595(7.2%) troops=3084208/3084207 gold=4186693 jarak=881 | cit=4 por=6 fac=1 def=1 sam=1 sil=0
[10573] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=2643256/2922468 gold=412435 jarak=1124 | cit=3 por=1 fac=1 def=0 sam=1 sil=0
[10573] LG #7 owner270 [musuh] hidup tiles=47267(5.9%) troops=3084392/3084392 gold=1061449 jarak=516 | cit=4 por=3 fac=2 def=3 sam=1 sil=2
[10573] LG #8 owner258 [ally] hidup tiles=46956(5.9%) troops=3121456/3575613 gold=1097866 jarak=995 | cit=6 por=4 fac=1 def=4 sam=1 sil=0
[10573] MOMENTUM owner 282 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=1108443
[10573] COUNTER owner 282 serangan=163121 ratio=0.03
[10575] boat scan: 292 target (<=70 langkah, reach x1) dari 24 titik pantai
[10575] POSTURE need=0.99 [serang=0.40 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=80% -> DEFENSE DULU
[10576] MOMENTUM owner 264 mom=0.50 (pasukan turun) pasukan=363568
[10577] REC troops=1608131/4693486 gold=175200 inc=3989/s tiles=112889 city=5(L5) def=7 sam=0 silo=0 | serangan masuk=2(78154 troops) | tetangga terkuat=286(3231428, kontak 405) | rival=owner 286 hostile=2 brutal=false | nuke di udara=0 | foeSilo=6
[10579] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1455766
[10579] LG ME rank=1 tiles=116896(14.6%) troops=469955/4759357 gold=177700 | cit=5 por=1 fac=2 def=7 sam=0 sil=0
[10579] LG MATI owner199 (tiles terakhir 0)
[10581] FRONT owner 103 P=5.89 kerucut=78 tile, pasukan gw=501653 musuh=72481
[10582] FOCUS -> owner 264 ratio=25.51 contact=true jarak=231 skor=10.11 brutal=false existential=false(3.4%)
[10582] FRONT -> owner 264 P=49.99 arah=(-0.76,-0.65) pasukan musuh=21631
[10583] boat scan: 402 target (<=70 langkah, reach x1) dari 24 titik pantai
[10583] MOMENTUM owner 282 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=951702
[10586] LG ME rank=1 tiles=132428(16.6%) troops=701004/5277500 gold=194200 | cit=6 por=1 fac=4 def=7 sam=0 sil=0
[10586] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=235
[10587] REC troops=741945/5569248 gold=195200 inc=2839/s tiles=135631 city=7(L7) def=7 sam=0 silo=1 | serangan masuk=1(3871 troops) | tetangga terkuat=286(1889898, kontak 387) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=5
[10588] WATCH #1 land: owner=286 tiles=80505(+5575) troops=1941070(+359637) | city=5(+0) port=3(+0) factory=1(+0) def=1(+0) sam=1(+0) silo=1(+0)  [20s]
[10591] FRONT owner 264 P=622.18 kerucut=191 tile, pasukan gw=920257 musuh=2899
[10591] build def tile=651356 cost~250000 gold=305832 inc=2839/s wealth=0.4 amount=1 musuh=286 skor=9.6 tertutup=20% need=1.00 jatah=80% URGENT
[10592] boat scan: 320 target (<=70 langkah, reach x1) dari 24 titik pantai
[10592] LG ME rank=1 tiles=145408(18.2%) troops=968249/5731076 gold=199706 | cit=7 por=2 fac=4 def=8 sam=0 sil=1
[10592] LG MATI owner55 (tiles terakhir 0)
[10592] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1522995
[10593] MOMENTUM owner 103 mom=0.50 (pasukan turun) pasukan=34458
[10593] MOMENTUM owner 282 mom=0.87 (pasukan turun, tanah turun, diserang pihak lain) pasukan=879510
[10594] build def OK, gold=354956 level+1 (minta 1)
[10595] POSTURE need=0.97 [serang=0.00 loss=0.00 kuat=0.91 brutal=0.50] dom=0.00 | jatah defense=84% -> DEFENSE DULU
[10597] FOCUS -> owner 103 ratio=13.65 contact=true jarak=168 skor=8.72 brutal=false existential=false(0.2%)
[10598] REC troops=1282951/5771476 gold=358956 inc=26704/s tiles=147099 city=7(L7) def=8 sam=0 silo=1 | serangan masuk=0(0 troops) | tetangga terkuat=286(3544348, kontak 399) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=6
[10598] LG ME rank=1 tiles=147174(18.4%) troops=985330/5772420 gold=359456 | cit=7 por=2 fac=4 def=8 sam=0 sil=1
[10598] LG MATI owner125 (tiles terakhir 0)
[10599] build def tile=680488 cost~250000 gold=370456 inc=26704/s wealth=0.5 amount=1 musuh=286 skor=22.1 tertutup=28% need=1.00 jatah=84% URGENT
[10600] LG SERANG MASUK dari owner103 troops=57892 (pasukan gw 1060592)
[10600] boat scan: 371 target (<=70 langkah, reach x1) dari 24 titik pantai
[10601] FRONT owner 264 P=3.38 kerucut=31 tile, pasukan gw=1138146 musuh=290987
[10602] FRONT -> owner 103 P=18.34 arah=(0.58,-0.81) pasukan musuh=38975
[10602] build def OK, gold=133456 level+1 (minta 1)
[10603] MOMENTUM owner 103 mom=0.50 (pasukan turun) pasukan=39908
[10605] LG ME rank=1 tiles=147920(18.5%) troops=1329646/5784243 gold=135956 | cit=7 por=2 fac=4 def=9 sam=0 sil=1
[10605] LG MATI owner83 (tiles terakhir 0)
[10605] LG --- LEADERBOARD ---
[10605] LG #1 owner271 [GW] hidup tiles=147920(18.5%) troops=1329646/5784243 gold=135956 jarak=0 | cit=7 por=2 fac=4 def=9 sam=0 sil=1
[10605] LG #2 owner283 [ally] hidup tiles=101600(12.7%) troops=363351/4742423 gold=157450 jarak=399 | cit=6 por=1 fac=3 def=0 sam=0 sil=1
[10605] LG #3 owner286 [musuh] hidup tiles=88200(11.0%) troops=4373387/4484813 gold=5202869 jarak=348 | cit=6 por=4 fac=1 def=1 sam=1 sil=1
[10605] LG #4 owner282 [musuh] hidup tiles=58633(7.3%) troops=869595/2856824 gold=819950 jarak=374 | cit=2 por=0 fac=4 def=1 sam=0 sil=0
[10605] LG #5 owner259 [musuh] hidup tiles=55696(7.0%) troops=3184541/3290066 gold=1915199 jarak=827 | cit=4 por=6 fac=1 def=3 sam=1 sil=1
[10605] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=2852528/2922468 gold=576920 jarak=1074 | cit=3 por=1 fac=1 def=0 sam=1 sil=0
[10605] LG #7 owner278 [ally] hidup tiles=50255(6.3%) troops=563469/2908734 gold=643004 jarak=704 | cit=3 por=1 fac=3 def=3 sam=0 sil=0
[10605] LG #8 owner258 [ally] hidup tiles=48923(6.1%) troops=3235818/3625619 gold=2591180 jarak=954 | cit=6 por=4 fac=1 def=4 sam=1 sil=0
[10606] MOMENTUM owner 282 mom=0.50 (pasukan turun) pasukan=887686
[10606] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=169877
[10608] build def tile=685397 cost~250000 gold=356061 inc=25150/s wealth=0.5 amount=1 musuh=286 skor=21.0 tertutup=25% need=1.00 jatah=87% URGENT
[10608] REC troops=400286/6051202 gold=241531 inc=48998/s tiles=149179 city=8(L8) def=10 sam=0 silo=1 | serangan masuk=1(9116 troops) | tetangga terkuat=286(4388003, kontak 441) | rival=owner 286 hostile=4 brutal=false | nuke di udara=0 | foeSilo=6
[10608] WATCH #1 land: owner=286 tiles=88414(+7909) troops=4388003(+2446933) | city=6(+1) port=4(+1) factory=1(+0) def=1(+0) sam=1(+0) silo=1(+0)  [20s]
[10608] boat scan: 603 target (<=70 langkah, reach x1) dari 24 titik pantai
[10610] LG NUKE baru owner=259 kind=0 target=nil
[10610] build def OK, gold=243531 level+1 (minta 1)
[10611] LG ME rank=1 tiles=152341(19.1%) troops=492585/6097147 gold=244531 | cit=8 por=2 fac=6 def=10 sam=0 sil=1
[10611] FRONT owner 103 P=8.74 kerucut=88 tile, pasukan gw=492585 musuh=56375
[10612] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=675828
[10615] POSTURE need=1.00 [serang=0.00 loss=0.00 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=89% -> DEFENSE DULU
[10616] MOMENTUM owner 282 mom=0.50 (pasukan turun, tanah turun) pasukan=565229
[10617] boat scan: 525 target (<=70 langkah, reach x1) dari 24 titik pantai
[10618] LG ME rank=1 tiles=159973(20.0%) troops=736805/6221172 gold=261031 | cit=8 por=2 fac=6 def=10 sam=0 sil=1
[10619] REC troops=779858/6252907 gold=272031 inc=19231/s tiles=162300 city=8(L8) def=10 sam=0 silo=1 | serangan masuk=0(0 troops) | tetangga terkuat=282(709125, kontak 216) | rival=owner 282 hostile=3 brutal=false | nuke di udara=0 | foeSilo=6
[10619] POSTURE need=0.78 [serang=0.00 loss=0.00 kuat=0.40 brutal=0.00] dom=0.00 | jatah defense=89% -> DEFENSE DULU
[10619] MOMENTUM owner 264 mom=0.69 (pasukan turun, tanah turun) pasukan=247080
[10620] build def tile=1212792 cost~250000 gold=283031 inc=19231/s wealth=0.4 amount=1 musuh=282 skor=5.2 tertutup=13% need=0.75 jatah=89% URGENT
[10622] LG SERANG MASUK dari owner103 troops=37040 (pasukan gw 893944)
[10622] FRONT owner 103 P=10.15 kerucut=83 tile, pasukan gw=893944 musuh=74876
[10623] MOMENTUM owner 103 mom=0.50 (pasukan turun) pasukan=40683
[10623] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=619926
[10623] build def OK, gold=199281 level+1 (minta 1)
[10624] LG ME rank=1 tiles=170573(21.4%) troops=1016753/6379729 gold=210281 | cit=8 por=2 fac=6 def=11 sam=0 sil=1
[10625] LG SERANG MASUK dari owner282 troops=233074 (pasukan gw 1068419)
[10625] LG NUKE baru owner=280 kind=1 target=nil
[10625] boat scan: 379 target (<=70 langkah, reach x1) dari 24 titik pantai
[10626] MOMENTUM owner 282 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=200958
[10626] POSTURE need=0.99 [serang=0.40 loss=0.00 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=90% -> DEFENSE DULU
[10628] build def tile=679105 cost~250000 gold=302044 inc=26046/s wealth=0.4 amount=1 musuh=286 skor=15.0 tertutup=68% need=1.00 jatah=90% URGENT
[10629] WATCH #1 land: owner=286 tiles=90063(+1649) troops=4521599(+133596) | city=6(+0) port=4(+0) factory=1(+0) def=2(+1) sam=1(+0) silo=1(+0)  [20s]
[10629] REC troops=351549/6668395 gold=63044 inc=24717/s tiles=172938 city=9(L9) def=12 sam=0 silo=1 | serangan masuk=1(2392 troops) | tetangga terkuat=286(4521599, kontak 343) | rival=owner 286 hostile=5 brutal=false | nuke di udara=1 | foeSilo=6
[10630] LG ME rank=1 tiles=174168(21.8%) troops=378727/6683797 gold=64044 | cit=9 por=2 fac=7 def=12 sam=0 sil=1
[10630] LG MATI owner267 (tiles terakhir 0)
[10631] build def OK, gold=64544 level+1 (minta 1)
[10632] FRONT owner 103 P=6.91 kerucut=84 tile, pasukan gw=437244 musuh=59874
[10633] boat scan: 261 target (<=70 langkah, reach x1) dari 24 titik pantai
[10637] LG NUKE baru owner=285 kind=0 target=nil
[10637] LG ME rank=1 tiles=176081(22.0%) troops=1174259/6718377 gold=223318 | cit=9 por=2 fac=7 def=12 sam=0 sil=1
[10637] LG --- LEADERBOARD ---
[10637] LG #1 owner271 [GW] hidup tiles=176081(22.0%) troops=1174259/6718377 gold=223318 jarak=0 | cit=9 por=2 fac=7 def=12 sam=0 sil=1
[10637] LG #2 owner283 [ally] hidup tiles=101558(12.7%) troops=88299/4739920 gold=229450 jarak=361 | cit=6 por=1 fac=3 def=0 sam=0 sil=1
[10637] LG #3 owner286 [musuh] hidup tiles=90063(11.3%) troops=4521599/4521598 gold=6298283 jarak=393 | cit=6 por=4 fac=1 def=2 sam=1 sil=1
[10637] LG #4 owner258 [ally] hidup tiles=55639(7.0%) troops=1583705/3287919 gold=4654739 jarak=941 | cit=4 por=4 fac=1 def=4 sam=1 sil=0
[10637] LG #5 owner278 [ally] hidup tiles=51469(6.4%) troops=1352294/2938309 gold=1256908 jarak=661 | cit=3 por=1 fac=4 def=3 sam=0 sil=0
[10637] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=2905600/2922468 gold=791405 jarak=1071 | cit=3 por=1 fac=1 def=0 sam=1 sil=0
[10637] LG #7 owner259 [musuh] hidup tiles=48637(6.1%) troops=2978922/3619177 gold=1293125 jarak=802 | cit=6 por=6 fac=1 def=6 sam=1 sil=1
[10637] LG #8 owner270 [musuh] hidup tiles=47359(5.9%) troops=3554971/3586708 gold=1112732 jarak=488 | cit=6 por=3 fac=2 def=3 sam=1 sil=2
[10637] MOMENTUM owner 264 mom=1.00 (pasukan turun, diserang pihak lain) pasukan=173049
[10639] build def tile=630958 cost~250000 gold=378068 inc=18588/s wealth=0.5 amount=1 musuh=286 skor=21.0 tertutup=63% need=1.00 jatah=92% URGENT
[10640] REC troops=891822/6718377 gold=226200 inc=18588/s tiles=176081 city=9(L9) def=13 sam=0 silo=1 | serangan masuk=0(0 troops) | tetangga terkuat=286(3626458, kontak 347) | rival=owner 286 hostile=3 brutal=false | nuke di udara=1 | foeSilo=6
[10640] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=3626458
[10641] LG SERANG MASUK dari owner286 troops=2085720 (pasukan gw 964740)
[10641] boat scan: 569 target (<=70 langkah, reach x1) dari 24 titik pantai
[10641] DEFENSE DIBLOK: lagi diserang (masuk=216% pasukan, tanah hilang=0.0%) 45s
[10641] build def gagal (1) tile=630958
[10643] LG ME rank=1 tiles=174020(21.8%) troops=1033154/6690273 gold=249200 | cit=9 por=2 fac=7 def=9 sam=0 sil=1
[10643] FRONT owner 103 P=10.99 kerucut=73 tile, pasukan gw=1033154 musuh=79847
[10647] POSTURE need=1.00 [serang=1.00 loss=0.00 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=92% -> DEFENSE DULU
[10647] MOMENTUM owner 264 mom=0.80 (pasukan turun, tanah turun) pasukan=79167
[10647] FRONT -> owner 264 P=29.45 arah=(-0.77,-0.64) pasukan musuh=79167
[10649] LG ME rank=1 tiles=158745(19.9%) troops=1268494/6469857 gold=275200 | cit=9 por=2 fac=7 def=6 sam=0 sil=1
[10649] WATCH #1 land: owner=286 tiles=108557(+18494) troops=2012304(-2509295) | city=6(+0) port=4(+0) factory=1(+0) def=2(+0) sam=1(+0) silo=1(+0)  [20s]
[10649] build def tile=728391 cost~250000 gold=275200 inc=10250/s wealth=0.4 amount=1 musuh=286 skor=13.2 tertutup=0% need=1.00 jatah=92% URGENT
[10650] LG SERANG MASUK dari owner103 troops=51590 (pasukan gw 1332731)
[10650] REC troops=1332731/6422966 gold=286700 inc=10250/s tiles=156517 city=9(L9) def=6 sam=0 silo=1 | serangan masuk=2(967224 troops) | tetangga terkuat=286(2100528, kontak 359) | rival=owner 286 hostile=4 brutal=true | nuke di udara=0 | foeSilo=5
[10650] LOSS tanah 176081 -> 156517 dalam 10s
[10650] LOSS struktur defense 13 -> 6
[10650] boat scan: 660 target (<=70 langkah, reach x1) dari 24 titik pantai
[10650] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=2100528
[10650] MOMENTUM owner 103 mom=0.50 (pasukan turun) pasukan=40089
[10651] MOMENTUM owner 282 mom=0.80 (tanah turun, diserang pihak lain) pasukan=656268
[10651] build def gagal (2) tile=728391
[10653] FOCUS -> owner 268 ratio=985.76 contact=true jarak=395 skor=9.82 brutal=false existential=false(0.1%)
[10653] FRONT owner 264 P=5.60 kerucut=16 tile, pasukan gw=380505 musuh=133058
[10655] LG ME rank=1 tiles=148331(18.6%) troops=439888/6291469 gold=514865 | cit=9 por=2 fac=7 def=6 sam=0 sil=0
[10657] build def tile=813178 cost~250000 gold=516865 inc=18289/s wealth=0.7 amount=1 musuh=286 skor=33.0 tertutup=0% need=1.00 jatah=92% URGENT
[10658] boat scan: 528 target (<=70 langkah, reach x1) dari 24 titik pantai
[10660] build def OK, gold=395792 level+1 (minta 1)
[10660] REC troops=603928/6362462 gold=396292 inc=12362/s tiles=153314 city=9(L9) def=7 sam=0 silo=0 | serangan masuk=2(37008 troops) | tetangga terkuat=286(2701112, kontak 280) | rival=owner 286 hostile=6 brutal=true | nuke di udara=0 | foeSilo=6
[10660] LOSS struktur factory 7 -> 6
[10660] LOSS struktur silo 1 -> 0
[10661] MOMENTUM owner 282 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=348247
[10662] LG ME rank=1 tiles=154736(19.4%) troops=661599/6390924 gold=551042 | cit=9 por=2 fac=6 def=7 sam=0 sil=0
[10663] MOMENTUM owner 264 mom=0.61 (pasukan turun, tanah turun) pasukan=166979
[10663] MOMENTUM owner 268 mom=0.50 (diserang pihak lain) pasukan=4318
[10663] FRONT owner 264 P=7.51 kerucut=12 tile, pasukan gw=722773 musuh=166979
[10665] build def tile=820692 cost~250000 gold=653867 inc=43802/s wealth=0.9 amount=1 musuh=286 skor=36.0 tertutup=11% need=1.00 jatah=93% URGENT
[10666] boat scan: 331 target (<=70 langkah, reach x1) dari 24 titik pantai
[10667] POSTURE need=1.00 [serang=0.00 loss=0.35 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=94% -> DEFENSE DULU
[10668] LG SERANG MASUK dari owner286 troops=1292319 (pasukan gw 1505367)
[10668] FRONT -> owner 268 P=8738.28 arah=(-0.80,0.60) pasukan musuh=379
[10668] LG ME rank=1 tiles=156525(19.6%) troops=1531820/6429419 gold=416367 | cit=9 por=2 fac=6 def=8 sam=0 sil=0
[10668] LG --- LEADERBOARD ---
[10668] LG #1 owner271 [GW] hidup tiles=156525(19.6%) troops=1531820/6429419 gold=416367 jarak=0 | cit=9 por=2 fac=6 def=8 sam=0 sil=0
[10668] LG #2 owner286 [musuh] hidup tiles=127984(16.0%) troops=1841238/5447632 gold=6124638 jarak=410 | cit=7 por=4 fac=2 def=2 sam=1 sil=2
[10668] LG #3 owner283 [ally] hidup tiles=102546(12.8%) troops=1192338/4758249 gold=290450 jarak=287 | cit=6 por=1 fac=3 def=0 sam=0 sil=1
[10668] LG #4 owner258 [ally] hidup tiles=54861(6.9%) troops=2669777/3519955 gold=5060511 jarak=925 | cit=5 por=4 fac=1 def=6 sam=1 sil=0
[10668] LG #5 owner278 [ally] hidup tiles=52983(6.6%) troops=1700760/2974980 gold=1732444 jarak=592 | cit=4 por=1 fac=4 def=3 sam=0 sil=0
[10668] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=2918192/2922468 gold=714884 jarak=1081 | cit=3 por=1 fac=2 def=0 sam=1 sil=0
[10668] LG #7 owner259 [musuh] hidup tiles=49415(6.2%) troops=3123929/3638017 gold=2917757 jarak=810 | cit=6 por=7 fac=1 def=8 sam=1 sil=1
[10668] LG #8 owner270 [musuh] hidup tiles=47769(6.0%) troops=3597010/3597010 gold=2427803 jarak=544 | cit=6 por=3 fac=2 def=3 sam=1 sil=2
[10668] build def OK, gold=416367 level+1 (minta 1)
[10669] WATCH #1 land: owner=286 tiles=129650(+21093) troops=1903568(-108736) | city=7(+1) port=5(+1) factory=2(+1) def=2(+0) sam=1(+0) silo=2(+1)  [20s]
[10670] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=1966460
[10671] REC troops=1264195/6359516 gold=419367 inc=27630/s tiles=152209 city=9(L9) def=7 sam=0 silo=0 | serangan masuk=1(827230 troops) | tetangga terkuat=286(2029870, kontak 277) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=6
[10671] LOSS struktur factory 6 -> 5
[10672] MOMENTUM owner 273 mom=0.80 (pasukan turun, tanah turun) pasukan=120591
[10673] MOMENTUM owner 265 mom=0.50 (diserang pihak lain) pasukan=177892
[10673] MOMENTUM owner 103 mom=0.43 (diserang pihak lain) pasukan=87233
[10673] build def tile=827071 cost~250000 gold=843037 inc=16973/s wealth=1.1 amount=1 musuh=286 skor=14.4 tertutup=0% need=0.94 jatah=94% URGENT
[10674] MOMENTUM owner 268 mom=0.80 (tanah turun, diserang pihak lain) pasukan=615
[10674] FRONT owner 268 P=3634.10 kerucut=49 tile, pasukan gw=1328304 musuh=615
[10675] LG SERANG MASUK dari owner265 troops=98452 (pasukan gw 1353150)
[10675] LG ME rank=1 tiles=149329(18.7%) troops=1353150/5813142 gold=604037 | cit=6 por=2 fac=5 def=6 sam=0 sil=0
[10675] LG MATI owner273 (tiles terakhir 0)
[10675] boat scan: 258 target (<=70 langkah, reach x1) dari 24 titik pantai
[10676] MOMENTUM owner 257 mom=0.42 (pasukan turun, tanah turun) pasukan=723144
[10676] build def gagal (1) tile=827071
[10680] LG NUKE baru owner=259 kind=0 target=nil
[10681] LG ME rank=1 tiles=146413(18.3%) troops=1705743/5511807 gold=736963 | cit=6 por=2 fac=4 def=6 sam=0 sil=0
[10681] LG SERANG MASUK dari owner268 troops=3505 (pasukan gw 1734299)
[10681] REC troops=1734299/5508794 gold=737463 inc=37639/s tiles=146145 city=6(L6) def=6 sam=0 silo=0 | serangan masuk=3(228004 troops) | tetangga terkuat=286(2682319, kontak 332) | rival=owner 286 hostile=3 brutal=true | nuke di udara=1 | foeSilo=7
[10681] LOSS struktur factory 5 -> 4
[10681] LOSS struktur city 9 -> 6
[10681] LOSS struktur defense 7 -> 6
[10681] build def tile=857448 cost~250000 gold=737463 inc=37639/s wealth=1.0 amount=1 musuh=286 skor=23.2 tertutup=0% need=0.98 jatah=94% URGENT
[10683] boat scan: 352 target (<=70 langkah, reach x1) dari 24 titik pantai
[10683] MOMENTUM owner 103 mom=0.80 (pasukan turun, tanah turun) pasukan=34472
[10683] MOMENTUM owner 265 mom=0.50 (pasukan turun) pasukan=8083
[10684] FRONT owner 268 P=1537.52 kerucut=42 tile, pasukan gw=1698159 musuh=859
[10684] build def OK, gold=792331 level+1 (minta 1)
[10686] MOMENTUM owner 268 mom=0.50 (pasukan turun) pasukan=456
[10687] LG ME rank=1 tiles=145605(18.2%) troops=2065357/5247739 gold=912257 | cit=5 por=2 fac=5 def=7 sam=0 sil=0
[10687] POSTURE need=1.00 [serang=0.40 loss=0.30 kuat=1.00 brutal=0.50] dom=0.00 | jatah defense=95% -> DEFENSE DULU
[10689] COUNTER owner 265 serangan=51710 ratio=0.03
[10689] WATCH #1 land: owner=286 tiles=140793(+11143) troops=3404548(+1500980) | city=11(+4) port=5(+0) factory=4(+2) def=2(+0) sam=2(+1) silo=2(+0)  [20s]
[10689] build def tile=756065 cost~250000 gold=924257 inc=42094/s wealth=1.2 amount=1 musuh=286 skor=12.0 tertutup=4% need=1.00 jatah=95% URGENT
[10691] boat scan: 221 target (<=70 langkah, reach x1) dari 24 titik pantai
[10692] REC troops=2282830/5247289 gold=676757 inc=42094/s tiles=145583 city=5(L5) def=8 sam=0 silo=0 | serangan masuk=2(2246 troops) | tetangga terkuat=286(3582620, kontak 346) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=7
[10692] LOSS struktur city 6 -> 5
[10692] build def OK, gold=677257 level+1 (minta 1)
[10693] LG ME rank=1 tiles=145579(18.2%) troops=2375533/5247193 gold=774996 | cit=5 por=2 fac=5 def=8 sam=0 sil=0
[10695] FRONT owner 268 P=498.66 kerucut=40 tile, pasukan gw=2437228 musuh=3601
[10696] LG SERANG MASUK dari owner268 troops=570 (pasukan gw 2529355)
[10696] LG SERANG MASUK dari owner265 troops=40693 (pasukan gw 2529355)
[10696] MOMENTUM owner 265 mom=0.50 (pasukan turun) pasukan=13564
[10698] build def tile=847252 cost~250000 gold=888322 inc=31423/s wealth=1.2 amount=1 musuh=286 skor=16.0 tertutup=32% need=1.00 jatah=95% URGENT
[10699] LG ME rank=1 tiles=145496(18.2%) troops=2740056/5245988 gold=843488 | cit=5 por=2 fac=5 def=9 sam=0 sil=0
[10699] LG --- LEADERBOARD ---
[10699] LG #1 owner271 [GW] hidup tiles=145496(18.2%) troops=2740056/5245988 gold=843488 jarak=0 | cit=5 por=2 fac=5 def=9 sam=0 sil=0
[10699] LG #2 owner286 [musuh] hidup tiles=141317(17.7%) troops=2394334/6677484 gold=4203267 jarak=403 | cit=11 por=5 fac=4 def=2 sam=2 sil=2
[10699] LG #3 owner283 [ally] hidup tiles=102414(12.8%) troops=1288414/5005828 gold=141950 jarak=273 | cit=7 por=1 fac=4 def=0 sam=0 sil=1
[10699] LG #4 owner258 [ally] hidup tiles=54862(6.9%) troops=3145268/4019979 gold=2099682 jarak=931 | cit=7 por=4 fac=1 def=6 sam=1 sil=0
[10699] LG #5 owner278 [ally] hidup tiles=53020(6.6%) troops=2812097/3225967 gold=1481714 jarak=590 | cit=4 por=1 fac=4 def=3 sam=0 sil=1
[10699] LG #6 owner261 [musuh] hidup tiles=50815(6.4%) troops=3010374/3172468 gold=298869 jarak=1090 | cit=3 por=1 fac=2 def=0 sam=1 sil=0
[10699] LG #7 owner259 [musuh] hidup tiles=49415(6.2%) troops=3491550/3638017 gold=4809958 jarak=819 | cit=6 por=7 fac=1 def=8 sam=1 sil=1
[10699] LG #8 owner270 [musuh] hidup tiles=47829(6.0%) troops=2526034/3848515 gold=3124553 jarak=558 | cit=7 por=3 fac=2 def=3 sam=1 sil=2
[10700] boat scan: 478 target (<=70 langkah, reach x1) dari 24 titik pantai
[10700] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=2394334
[10700] LUBANG expand 1217890@0.06 1220431@0.06 1224209@0.06 (fill=0.52)
[10700] build def OK, gold=844488 level+1 (minta 1)
[10700] COUNTER owner 265 serangan=49293 ratio=0.05
[10701] MOMENTUM owner 103 mom=0.80 (tanah turun, diserang pihak lain) pasukan=25176
[10701] FRONT -> owner 265 P=292.01 arah=(-0.90,0.44) pasukan musuh=4962
[10702] REC troops=2305306/5509195 gold=952414 inc=46967/s tiles=146514 city=6(L6) def=9 sam=0 silo=0 | serangan masuk=1(2317 troops) | tetangga terkuat=286(2576291, kontak 359) | rival=owner 286 hostile=2 brutal=true | nuke di udara=0 | foeSilo=7
[10702] MOMENTUM owner 268 mom=0.61 (tanah turun, diserang pihak lain) pasukan=8634
[10703] FRONT -> owner 268 P=309.64 arah=(-0.81,0.58) pasukan musuh=9275
[10703] POSTURE need=0.78 [serang=0.00 loss=0.32 kuat=0.50 brutal=0.00] dom=0.00 | jatah defense=96% -> DEFENSE DULU
[10704] build city tile=1118067 cost~500000 gold=1163318 inc=46967/s wealth=1.6 amount=1
[10705] LG SERANG MASUK dari owner286 troops=2804840 (pasukan gw 2960870)
[10705] FRONT owner 268 P=811.16 kerucut=22 tile, pasukan gw=2960870 musuh=3105
[10706] LG ME rank=1 tiles=145119(18.2%) troops=2993678/5492999 gold=664818 | cit=7 por=2 fac=5 def=8 sam=0 sil=0
[10706] LG MATI owner265 (tiles terakhir 0)
[10706] LG MATI owner29 (tiles terakhir 0)
[10706] MOMENTUM owner 282 mom=0.80 (tanah turun, diserang pihak lain) pasukan=476115
[10706] POSTURE need=0.98 [serang=1.00 loss=0.30 kuat=0.40 brutal=0.50] dom=0.00 | jatah defense=77% -> DEFENSE DULU
[10706] FOCUS -> owner 286 ratio=1.54 contact=true jarak=403 skor=8.31 brutal=true existential=false(18.1%)
[10706] FRONT -> owner 263 P=24.84 arah=(0.76,-0.65) pasukan musuh=120849
[10706] COUNTER owner 286 serangan=2559017 ratio=0.27
[10707] FOCUS -> owner 263 ratio=18.17 contact=true jarak=289 skor=7.52 brutal=false existential=false(0.0%)
[10707] LG NUKE baru owner=259 kind=1 target=nil
[10707] build city OK, gold=666318 level+1 (minta 1)
[10707] build def tile=872643 cost~250000 gold=666318 inc=48626/s wealth=0.9 amount=1 musuh=286 skor=14.2 tertutup=5% need=1.00 jatah=77% URGENT
[10708] boat scan: 247 target (<=70 langkah, reach x1) dari 24 titik pantai
[10709] COUNTER owner 286 serangan=1248397 ratio=0.05
[10710] WATCH #1 land: owner=286 tiles=151097(+10304) troops=2199377(-1205171) | city=12(+1) port=6(+1) factory=4(+0) def=2(+0) sam=2(+0) silo=2(+0)  [20s]
[10710] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=2199377
[10710] build def gagal (1) tile=872643
[10712] LG ME rank=2 tiles=137232(17.2%) troops=594741/5358021 gold=670818 | cit=6 por=1 fac=5 def=6 sam=0 sil=0
[10713] LG SERANG MASUK dari owner286 troops=138479 (pasukan gw 612874)
[10713] REC troops=612874/5362726 gold=696318 inc=54264/s tiles=136997 city=6(L6) def=6 sam=0 silo=0 | serangan masuk=1(138479 troops) | tetangga terkuat=286(1534712, kontak 283) | rival=owner 286 hostile=3 brutal=true | nuke di udara=1 | foeSilo=7
[10713] LOSS struktur port 2 -> 1
[10713] LOSS struktur defense 9 -> 6
[10715] FRONT owner 263 P=4.39 kerucut=10 tile, pasukan gw=530094 musuh=120849
[10716] LG SERANG MASUK dari owner286 troops=17871 (pasukan gw 564781)
[10716] MOMENTUM owner 282 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=311148
[10716] build def tile=897807 cost~250000 gold=831244 inc=32558/s wealth=1.1 amount=1 musuh=286 skor=16.3 tertutup=0% need=1.00 jatah=77% URGENT
[10716] boat scan: 314 target (<=70 langkah, reach x1) dari 24 titik pantai
[10718] LG ME rank=2 tiles=136433(17.1%) troops=656680/5348402 gold=593744 | cit=6 por=1 fac=5 def=7 sam=0 sil=0
[10718] MOMENTUM owner 257 mom=0.50 (diserang pihak lain) pasukan=832516
[10719] build def OK, gold=593744 level+1 (minta 1)
[10723] REC troops=493490/5353609 gold=598244 inc=14401/s tiles=136768 city=6(L6) def=7 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=286(2664263, kontak 315) | rival=owner 286 hostile=3 brutal=true | nuke di udara=0 | foeSilo=9
[10724] LG ME rank=2 tiles=136969(17.2%) troops=524582/5356737 gold=619744 | cit=6 por=1 fac=5 def=7 sam=0 sil=0
[10724] build def tile=734909 cost~250000 gold=619744 inc=14401/s wealth=0.8 amount=1 musuh=286 skor=22.5 tertutup=0% need=1.00 jatah=79% URGENT
[10725] boat scan: 18 target (<=70 langkah, reach x1) dari 24 titik pantai
[10725] LG SERANG MASUK dari owner286 troops=46192 (pasukan gw 558961)
[10725] FRONT owner 263 P=4.63 kerucut=9 tile, pasukan gw=558961 musuh=120849
[10726] POSTURE need=1.00 [serang=0.00 loss=0.35 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=81% -> DEFENSE DULU
[10727] build def OK, gold=382244 level+1 (minta 1)
[10728] LG SERANG MASUK dari owner286 troops=44188 (pasukan gw 633095)
[10730] WATCH #1 land: owner=286 tiles=151870(+773) troops=2903749(+704372) | city=12(+0) port=7(+1) factory=4(+0) def=2(+0) sam=2(+0) silo=2(+0)  [20s]
[10731] LG ME rank=2 tiles=136993(17.2%) troops=710647/5357741 gold=482484 | cit=6 por=1 fac=5 def=8 sam=0 sil=0
[10731] LG --- LEADERBOARD ---
[10731] LG #1 owner286 [musuh] hidup tiles=151881(19.0%) troops=2942362/7097431 gold=6839474 jarak=401 | cit=12 por=7 fac=4 def=2 sam=2 sil=2
[10731] LG #2 owner271 [GW] hidup tiles=136993(17.2%) troops=710647/5357741 gold=482484 jarak=0 | cit=6 por=1 fac=5 def=8 sam=0 sil=0
[10731] LG #3 owner283 [ally] hidup tiles=104420(13.1%) troops=1332313/5042771 gold=262950 jarak=253 | cit=7 por=1 fac=4 def=0 sam=0 sil=1
[10731] LG #4 owner278 [ally] hidup tiles=53020(6.6%) troops=2973602/3225967 gold=651809 jarak=584 | cit=4 por=1 fac=4 def=3 sam=1 sil=1
[10731] LG #5 owner261 [musuh] hidup tiles=52415(6.6%) troops=957236/3207315 gold=544851 jarak=1096 | cit=3 por=1 fac=2 def=0 sam=1 sil=0
[10731] LG #6 owner259 [musuh] hidup tiles=52249(6.5%) troops=2115034/3700240 gold=2583619 jarak=832 | cit=6 por=7 fac=1 def=8 sam=1 sil=1
[10731] LG #7 owner266 [musuh] hidup tiles=48973(6.1%) troops=1730188/3373830 gold=1982190 jarak=757 | cit=4 por=2 fac=1 def=3 sam=0 sil=0
[10731] LG #8 owner270 [musuh] hidup tiles=48497(6.1%) troops=3058690/3864567 gold=686698 jarak=576 | cit=8 por=3 fac=2 def=3 sam=2 sil=2
[10731] MOMENTUM owner 257 mom=0.80 (tanah turun, diserang pihak lain) pasukan=764562
[10732] build def tile=906811 cost~250000 gold=484484 inc=16683/s wealth=0.6 amount=1 musuh=286 skor=9.0 tertutup=38% need=1.00 jatah=81% URGENT
[10733] LG SERANG MASUK dari owner286 troops=48278 (pasukan gw 613647)
[10733] boat scan: 183 target (<=70 langkah, reach x1) dari 24 titik pantai
[10734] REC troops=631933/5356540 gold=235484 inc=16683/s tiles=136839 city=6(L6) def=9 sam=0 silo=0 | serangan masuk=1(26121 troops) | tetangga terkuat=286(2931479, kontak 306) | rival=owner 286 hostile=3 brutal=false | nuke di udara=0 | foeSilo=9
[10735] FRONT owner 263 P=5.87 kerucut=11 tile, pasukan gw=709716 musuh=120849
[10735] build def OK, gold=237484 level+1 (minta 1)
[10737] LG ME rank=2 tiles=136754(17.1%) troops=771942/5353675 gold=238984 | cit=6 por=1 fac=5 def=9 sam=0 sil=0
[10738] FRONT -> owner 257 P=11.08 arah=(-0.92,-0.38) pasukan musuh=166291
[10740] LG SERANG MASUK dari owner286 troops=43661 (pasukan gw 683636)
[10741] boat scan: 252 target (<=70 langkah, reach x1) dari 24 titik pantai
[10741] MOMENTUM owner 257 mom=1.00 (pasukan turun, tanah turun, diserang pihak lain) pasukan=92443
[10743] LG ME rank=2 tiles=136933(17.1%) troops=622603/5356095 gold=275484 | cit=6 por=1 fac=5 def=9 sam=0 sil=0
[10743] FOCUS -> owner 257 ratio=10.77 contact=true jarak=78 skor=7.87 brutal=false existential=false(0.0%)
[10743] build def tile=894118 cost~250000 gold=275484 inc=9489/s wealth=0.4 amount=1 musuh=286 skor=18.0 tertutup=26% need=1.00 jatah=83% URGENT
[10744] REC troops=641532/5358696 gold=50984 inc=8377/s tiles=137149 city=6(L6) def=10 sam=0 silo=0 | serangan masuk=0(0 troops) | tetangga terkuat=286(3507787, kontak 311) | rival=owner 286 hostile=2 brutal=false | nuke di udara=0 | foeSilo=9
[10744] FOCUS -> owner 263 ratio=5.31 contact=true jarak=293 skor=6.82 brutal=false existential=false(0.0%)
[10744] FRONT -> owner 263 P=5.31 arah=(0.75,-0.66) pasukan musuh=120849
[10745] LG SERANG MASUK dari owner286 troops=54951 (pasukan gw 397224)
[10746] FRONT owner 263 P=3.29 kerucut=10 tile, pasukan gw=397224 musuh=120849
[10746] build def OK, gold=52984 level+1 (minta 1)
[10747] POSTURE need=1.00 [serang=0.40 loss=0.00 kuat=1.00 brutal=0.00] dom=0.00 | jatah defense=84% -> DEFENSE DULU
[10749] LG SERANG MASUK dari owner286 troops=899117 (pasukan gw 503516)
[10750] LG ME rank=2 tiles=135388(17.0%) troops=388930/5346886 gold=106484 | cit=6 por=1 fac=5 def=8 sam=0 sil=0
[10750] LG MATI owner257 (tiles terakhir 0)
[10750] boat scan: 228 target (<=70 langkah, reach x1) dari 24 titik pantai
[10750] WATCH #1 land: owner=286 tiles=155013(+3143) troops=2566630(-337119) | city=12(+0) port=8(+1) factory=4(+0) def=2(+0) sam=2(+0) silo=2(+0)  [20s]
[10751] LG NUKE baru owner=269 kind=0 target=nil
[10751] MOMENTUM owner 286 mom=0.50 (pasukan turun) pasukan=2681916
[10753] MOMENTUM owner 282 mom=0.50 (diserang pihak lain) pasukan=354848
[10754] REC troops=450560/5254495 gold=133984 inc=8844/s tiles=130139 city=6(L6) def=7 sam=0 silo=0 | serangan masuk=1(502426 troops) | tetangga terkuat=286(2720605, kontak 188) | rival=owner 286 hostile=3 brutal=true | nuke di udara=1 | foeSilo=10
[10754] LOSS struktur defense 10 -> 7
[10756] LG ME rank=2 tiles=130139(16.3%) troops=450560/5254495 gold=133984 | cit=6 por=1 fac=5 def=7 sam=0 sil=0
[10756] LG MATI owner268 (tiles terakhir 0)
[10756] FRONT owner 263 P=3.73 kerucut=8 tile, pasukan gw=450560 musuh=120849
