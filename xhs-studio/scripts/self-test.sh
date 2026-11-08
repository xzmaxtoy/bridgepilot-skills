#!/usr/bin/env bash
# Offline self-test. Touches no XHS account, opens no browser. Uses a throw-away workspace.
# Usage: self-test.sh [--quick]    (--quick skips the cutdown on synthetic clips)
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
tmp="$(mktemp -d)"
export XHS_HOME="$tmp/home"
mkdir -p "$XHS_HOME"
pass=0; fail=0
t() { # t "name" expected_exit cmd...
  local name="$1" want="$2"; shift 2
  "$@" >"$tmp/out.txt" 2>&1; local got=$?
  if [ "$got" = "$want" ]; then pass=$((pass+1)); echo "PASS  $name"; else fail=$((fail+1)); echo "FAIL  $name (exit $got, wanted $want)"; sed 's/^/        /' "$tmp/out.txt" | head -8; fi
}

# workspace: no fixed folder; saved path read by every script
t "check-hyperframes script runs (exit 0 or 1, never a crash)" 0 bash -c 'bash "'"$here"'/check-hyperframes.sh" >/dev/null 2>&1; [ $? -le 1 ]'
( unset XHS_HOME; export XDG_CONFIG_HOME="$tmp/cfg"
  t "scripts stop with 12 when no workspace is chosen" 12 bash "$here/kill-switch.sh" status
  t "workspace.sh status says not set" 1 bash "$here/workspace.sh" status
  mkdir -p "$tmp/chosen"
  t "workspace.sh set creates xhs-studio folder and saves it" 0 bash "$here/workspace.sh" set "$tmp/chosen"
  t "workspace layout exists" 0 test -d "$tmp/chosen/xhs-studio/jobs"
  t "a script reads the saved path (no env var)" 0 bash "$here/kill-switch.sh" status
  t "workspace.sh get prints the saved path" 0 bash -c '[ "$(bash "'"$here"'/workspace.sh" get)" = "'"$(cd "$tmp/chosen" && pwd)"'/xhs-studio" ]'
  t "setting a missing folder fails" 1 bash "$here/workspace.sh" set "$tmp/nope"
)
t "no script keeps a hard-coded ~/xhs-studio default" 1 bash -c 'grep -rln "HOME/xhs-studio\|~/xhs-studio" "'"$here"'" | grep -v self-test.sh' 
t "no Remotion left in scripts" 1 bash -c 'grep -rli remotion "'"$here"'" | grep -v self-test.sh'

# profile: template alone is NOT complete
cp "$root/brand/profile.template.json" "$XHS_HOME/profile.json"
t "profile template is reported incomplete" 1 python3 "$here/profile-check.py" "$XHS_HOME/profile.json"
# a complete profile
python3 - "$XHS_HOME/profile.json" <<'PY'
import json, sys
p = json.load(open(sys.argv[1]))
p["client"]["business_name"] = "Test Co"
p["brand"]["services"] = [{"name": "草坪养护", "detail": "lawn care", "source": "client, test"}]
p["brand"]["service_area"] = {"value": ["San Jose"], "source": "client, test"}
p["voice"]["sample_post"] = "示例"
p["north_star"]["metric"] = "visits booked"
p["dms"]["who_answers"] = "owner"
p["automation"]["asked_on"] = "2026-10-14"
p["status"]["interview_complete"] = True
json.dump(p, open(sys.argv[1], "w"), ensure_ascii=False, indent=2)
PY
t "complete profile passes" 0 python3 "$here/profile-check.py" "$XHS_HOME/profile.json"

# switches: default off
for s in publish comments dms; do t "guard $s denied by default" 10 bash "$here/guard.sh" $s; done
python3 - "$XHS_HOME/profile.json" <<'PY'
import json, sys
p = json.load(open(sys.argv[1])); p["automation"]["auto_publish"] = True; p["automation"]["warning_acknowledged"] = True
json.dump(p, open(sys.argv[1], "w"), ensure_ascii=False, indent=2)
PY
t "guard publish allowed when switch on" 0 bash "$here/guard.sh" publish
t "guard comments still denied" 10 bash "$here/guard.sh" comments
t "kill switch on" 0 bash "$here/kill-switch.sh" on
t "guard publish denied while paused" 10 bash "$here/guard.sh" publish
t "kill switch off" 0 bash "$here/kill-switch.sh" off
t "guard publish allowed again" 0 bash "$here/guard.sh" publish
echo "x" > "$XHS_HOME/state/STOPPED"
t "guard denied on warning stop" 10 bash "$here/guard.sh" publish
t "clear warning" 0 bash "$here/kill-switch.sh" clear-warning
t "action log has entries" 0 test -s "$XHS_HOME/log/actions.jsonl"

# page classifier
t "classifier: normal page" 0 bash -c "echo '{\"href\":\"https://creator.xiaohongshu.com/new/home\",\"title\":\"x\",\"text\":\"笔记管理 数据看板\"}' | python3 '$here/classify_page.py'"
t "classifier: login wall (url)" 3 bash -c "echo '{\"href\":\"https://creator.xiaohongshu.com/login\",\"title\":\"x\",\"text\":\"\"}' | python3 '$here/classify_page.py'"
t "classifier: captcha text" 3 bash -c "echo '{\"href\":\"https://www.xiaohongshu.com/explore\",\"text\":\"请完成安全验证 拖动滑块\"}' | python3 '$here/classify_page.py'"
t "classifier: warning" 4 bash -c "echo '{\"href\":\"https://www.xiaohongshu.com/explore\",\"text\":\"操作太频繁，请稍后再试\"}' | python3 '$here/classify_page.py'"

# copy lint
cat > "$tmp/good.md" <<'MD'
DRAFT 草稿
后院草坪翻新全过程
这是一个测试正文。我们记录了一块后院从旧草坪到新草坪的变化，整个过程分成三步：清理、整地、铺设。清理阶段先把旧草和杂物运走，再检查地面是否平整。整地阶段把土壤翻松并找平，让排水更顺畅。铺设阶段按照从边到中间的顺序铺开，接缝处压紧并浇水。每一步都拍了现场画面，方便你看清变化。
🌿
整个过程用了几天，期间天气正常，没有遇到意外。完工后的后院看起来整齐很多，孩子也可以在上面玩耍。我们也会把常见问题整理成下一期内容，比如旧草怎么清理，土壤怎么处理，接缝怎么压紧，浇水要浇多少，新草铺好以后头几天要注意什么，这些都会慢慢讲清楚。看完这条，你对哪一步最好奇？
🌱
你家后院现在是什么样子，想换成什么样的草坪？
#草坪翻新 #后院改造 #庭院设计 #草坪养护 #圣何塞
MD
cat > "$tmp/bad.md" <<'MD'
最好的草坪公司，持牌有保险，十年经验
加我微信 abc123 或打电话 408-555-0100，网站 www.example.com，抖音同号
#a
MD
t "lint: bad caption FAILS" 1 python3 "$here/lint-copy.py" "$tmp/bad.md"
grep -q "R-contact.*FAIL" "$tmp/out.txt" && grep -q "R-credential.*FAIL" "$tmp/out.txt" && grep -q "R-link.*FAIL" "$tmp/out.txt" && grep -q "R-platform.*FAIL" "$tmp/out.txt" && grep -q "R-absolute.*FAIL" "$tmp/out.txt" \
  && { pass=$((pass+1)); echo "PASS  lint: all five red-line checks fire"; } || { fail=$((fail+1)); echo "FAIL  lint: a red-line check did not fire"; }

# install into a temp Codex folder
t "install to temp dest" 0 bash "$here/install-to-codex.sh" --dest "$tmp/codex-skills"
t "installed SKILL.md exists" 0 test -f "$tmp/codex-skills/xhs-studio/SKILL.md"
t "second install refuses without --force" 1 bash "$here/install-to-codex.sh" --dest "$tmp/codex-skills"

# lint: documented layout (DRAFT line 1, title line 2, FIRST COMMENT section) and 第一步 is not a ranking claim
cat > "$tmp/doc.md" <<'MD'
DRAFT 草稿 (delete this line only after the client approves) — extra note that makes this first line long
后院草坪翻新全过程
第一步，清理旧草和杂物。这是一个测试正文。我们记录了一块后院从旧草坪到新草坪的变化，整个过程分成三步：清理、整地、铺设。清理阶段先把旧草和杂物运走，再检查地面是否平整。整地阶段把土壤翻松并找平，让排水更顺畅。铺设阶段按照从边到中间的顺序铺开，接缝处压紧并浇水。每一步都拍了现场画面，方便你看清变化。
🌿
整个过程用了几天，期间天气正常，没有遇到意外。完工后的后院看起来整齐很多，孩子也可以在上面玩耍。我们也会把常见问题整理成下一期内容，比如旧草怎么清理，土壤怎么处理，接缝怎么压紧，浇水要浇多少，新草铺好以后头几天要注意什么，这些都会慢慢讲清楚。看完这条，你对哪一步最好奇？
🌱
你家后院现在是什么样子，想换成什么样的草坪？
#草坪翻新 #后院改造 #庭院设计 #草坪养护 #圣何塞
FIRST COMMENT:
你家后院最想改哪里？
MD
t "lint: doc-conformant caption (DRAFT line, 第一步, FIRST COMMENT) has no FAIL" 0 python3 "$here/lint-copy.py" "$tmp/doc.md"
printf 'DRAFT 草稿\n标题\n我们是行业第一的草坪公司？\n#a #b #c #d #e\n' > "$tmp/rank.md"
t "lint: 行业第一 IS flagged" 1 python3 "$here/lint-copy.py" "$tmp/rank.md" --first-comment x

# size cap helper
if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -v error -nostdin -y -f lavfi -i "testsrc2=size=1080x1920:rate=30" -t 12 -c:v libx264 -crf 12 "$tmp/big.mp4" >/dev/null 2>&1
  bigsz="$(wc -c < "$tmp/big.mp4" | tr -d ' ')"
  mb=$(( bigsz / 1000000 / 2 ))
  [ "$mb" -lt 1 ] && mb=1
  t "shrink-to-limit re-encodes an oversize file" 0 bash "$here/shrink-to-limit.sh" "$tmp/big.mp4" "$mb"
  t "shrunk file is under the limit" 0 bash -c "[ \$(wc -c < '$tmp/big.mp4' | tr -d ' ') -le $((mb * 1000000)) ]"
fi

# safe unzip with a Chinese file name
mkdir -p "$tmp/zsrc"; head -c 3000000 /dev/zero > "$tmp/zsrc/大文件-视频.bin"; echo hi > "$tmp/zsrc/说明.txt"
python3 - "$tmp" <<'PY'
import sys, zipfile, os
d = sys.argv[1]
with zipfile.ZipFile(d + "/foot.zip", "w", zipfile.ZIP_DEFLATED) as z:
    for f in os.listdir(d + "/zsrc"):
        z.write(d + "/zsrc/" + f, "folder/" + f)
PY
t "unpack-footage: Chinese names, all files verified" 0 python3 "$here/unpack-footage.py" "$tmp/foot.zip" "$tmp/unz"
t "unpack-footage: file count matches" 0 bash -c "[ \$(ls '$tmp/unz/folder' | wc -l | tr -d ' ') = 2 ]"

if [ "${1:-}" != "--quick" ] && command -v ffmpeg >/dev/null 2>&1; then
  bash "$here/make-test-footage.sh" "$tmp/in" >/dev/null 2>&1
  # result clip = the FIRST clip in order (the old logic would have dropped it)
  t "cutdown with --result on a clip that is NOT last" 0 python3 "$here/cutdown.py" "$tmp/in" --result test-landscape.mp4 --out "$tmp/job"
  t "plan has a segment from the result clip" 0 python3 -c "
import json,sys
p=json.load(open('$tmp/job/cut-plan.json'))
r=[s for s in p['segments'] if s['file'].endswith('test-landscape.mp4') and s['role'] in ('hook','after')]
sys.exit(0 if r else 1)"
  t "plan AFTER segments come only from the result clip" 0 python3 -c "
import json,sys
p=json.load(open('$tmp/job/cut-plan.json'))
a=[s for s in p['segments'] if s['role']=='after']
sys.exit(0 if a and all(s['file'].endswith('test-landscape.mp4') for s in a) else 1)"
  t "review sheet and table written" 0 bash -c "test -s '$tmp/job/plan-review.jpg' && test -s '$tmp/job/plan-review.md'"
  t "rough.mp4 is 1080x1920" 0 bash -c "ffprobe -v error -show_entries stream=width,height -of csv=p=0 '$tmp/job/rough.mp4' | grep -q '1080,1920'"
  t "unknown --result name is refused" 1 python3 "$here/cutdown.py" "$tmp/in" --result nope.mp4 --out "$tmp/job2"
  # --avoid and a still, then hand edit pan/zoom and re-render
  ffmpeg -v error -nostdin -y -f lavfi -i "testsrc=size=1600x1200:rate=1" -frames:v 1 "$tmp/photo.jpg" >/dev/null 2>&1
  t "cutdown with --avoid, --still, --cover-still" 0 python3 "$here/cutdown.py" "$tmp/in" --result test-vertical.mp4 --avoid "test-landscape.mp4@0-6" --still before:"$tmp/photo.jpg" --cover-still "$tmp/photo.jpg" --out "$tmp/job3" --plan-only
  t "still segment is in the plan" 0 python3 -c "
import json,sys
p=json.load(open('$tmp/job3/cut-plan.json'))
sys.exit(0 if any(s.get('still') for s in p['segments']) else 1)"
  t "no segment starts inside the avoided stretch" 0 python3 -c "
import json,sys
p=json.load(open('$tmp/job3/cut-plan.json'))
bad=[s for s in p['segments'] if s['file'].endswith('test-landscape.mp4') and not s.get('still') and s['start']<6 and s['start']+s['src_dur']>0]
sys.exit(1 if bad else 0)"
  python3 - "$tmp/job3/cut-plan.json" <<'PY'
import json, sys
p = json.load(open(sys.argv[1]))
for s in p["segments"]:
    if not s.get("still"):
        s["pan"], s["zoom"] = 0.9, 1.3
json.dump(p, open(sys.argv[1], "w"), indent=2)
PY
  t "render-plan with pan and zoom" 0 python3 "$here/cutdown.py" --render-plan "$tmp/job3/cut-plan.json" --cover-still "$tmp/photo.jpg"
  t "video-brief.json skeleton is written, approved=false" 0 python3 -c "
import json,sys
b=json.load(open('$tmp/job/video-brief.json'))
sys.exit(0 if b['approved'] is False and 'requirements' in b and 'on_screen_text' in b else 1)"
  t "final-check refuses unapproved brief" 2 bash "$here/final-check.sh" "$tmp/job"
  grep -q "BLOCKED" "$tmp/out.txt" && { pass=$((pass+1)); echo "PASS  refusal prints the BLOCKED reason"; } || { fail=$((fail+1)); echo "FAIL  refusal message missing"; }
  python3 - "$tmp/job/video-brief.json" <<'PY2'
import json, sys
b = json.load(open(sys.argv[1])); b["approved"] = True
json.dump(b, open(sys.argv[1], "w"), ensure_ascii=False)
PY2
  t "approved brief but no final.mp4 is refused" 1 bash "$here/final-check.sh" "$tmp/job"
  ffmpeg -v error -nostdin -y -f lavfi -i "testsrc=size=1080x1920:rate=10:duration=4" -pix_fmt yuv420p "$tmp/job/final.mp4" >/dev/null 2>&1
  t "approved brief + 1080x1920 final.mp4 is accepted" 0 bash "$here/final-check.sh" "$tmp/job"
  ffmpeg -v error -nostdin -y -f lavfi -i "testsrc=size=640x360:rate=10:duration=4" -pix_fmt yuv420p "$tmp/job/final.mp4" >/dev/null 2>&1
  t "wrong frame size is refused" 1 bash "$here/final-check.sh" "$tmp/job"
fi

if command -v sips >/dev/null 2>&1 && [ "${1:-}" != "--quick" ]; then
  sips -s format heic "$tmp/photo.jpg" --out "$tmp/hin/p.heic" >/dev/null 2>&1 || { mkdir -p "$tmp/hin"; sips -s format heic "$tmp/photo.jpg" --out "$tmp/hin/p.heic" >/dev/null 2>&1; }
  if [ -f "$tmp/hin/p.heic" ]; then t "prep-stills converts HEIC to JPG" 0 bash "$here/prep-stills.sh" "$tmp/hin" "$tmp/hout"; t "converted jpg exists" 0 test -s "$tmp/hout/p.jpg"; fi
fi

echo
echo "self-test: $pass passed, $fail failed"
[ "$fail" = 0 ]
