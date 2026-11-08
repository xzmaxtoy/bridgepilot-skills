#!/usr/bin/env python3
"""Mechanical part of the review gate for caption.md. Prints a PASS/FAIL table.

caption.md layout (same as references/copy-drafting.md):
  line 1       DRAFT marker line (optional once approved; ignored by the length checks)
  next line    title
  then         body; topics (#tag) at the end; the last body line is a question
  FIRST COMMENT:  (or 首评:) on its own line, then the first comment text (optional)
Usage: lint-copy.py caption.md [--profile profile.json] [--first-comment "text"]
Exit 0 = no FAIL, 1 = at least one FAIL. It cannot judge taste or truth: the human checks
in references/review-gate.md still apply (invented details, faces, promises).
"""
import json, re, sys

# Banned on every account. Prohibitions, not claims.
CONTACT = [r"微信", r"wechat", r"vx", r"v信", r"薇", r"加我", r"私我.*号", r"电话", r"手机号", r"whatsapp", r"telegram", r"二维码", r"扫码", r"line id"]
PHONE = re.compile(r"(?<!\d)(\+?\d[\d\-\s().]{7,}\d)(?!\d)")
LINKS = re.compile(r"(https?://|www\.|\b[a-z0-9\-]+\.(com|net|org|io|co|cn)\b)", re.I)
OTHER_PLATFORMS = [r"抖音", r"淘宝", r"拼多多", r"instagram", r"\big\b", r"facebook", r"脸书", r"youtube", r"油管", r"tiktok",
                   r"yelp", r"大众点评", r"微博", r"b站", r"知乎", r"thumbtack", r"nextdoor", r"google"]
CREDENTIALS = [r"持牌", r"有牌照", r"执照", r"许可证", r"已投保", r"保险", r"licensed", r"insured", r"bonded", r"cslb",
               r"\d+\s*年(经验|老店|专业)", r"多年经验", r"十年", r"二十年", r"资深"]
# 第一 is only a claim as a ranking ("第一名", "行业第一"); not in 第一步 / 第一次 / 第一时间 / 第一个 ...
ABSOLUTES = [r"最好(?!奇)", r"最佳", r"最便宜", r"最专业", r"第一(?![步个次章天条点眼期批遍种时间印象])", r"唯一", r"全网最", r"100\s*%", r"保证", r"绝对", r"永久", r"终身", r"免费"]


def hits(patterns, text):
    out = []
    for p in patterns:
        m = re.search(p, text, re.I)
        if m:
            out.append(m.group(0))
    return out


def main():
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    path = args[0]
    prof = None
    first_comment = ""
    if "--profile" in args:
        prof = json.load(open(args[args.index("--profile") + 1], encoding="utf-8"))
    if "--first-comment" in args:
        first_comment = args[args.index("--first-comment") + 1]
    lines = open(path, encoding="utf-8").read().splitlines()
    # split off the first comment
    fc_idx = next((i for i, l in enumerate(lines) if re.match(r"^\s*(FIRST COMMENT|首评)\s*[:：]", l)), None)
    if fc_idx is not None:
        head = re.sub(r"^\s*(FIRST COMMENT|首评)\s*[:：]\s*", "", lines[fc_idx])
        fc_text = (head + "\n" + "\n".join(lines[fc_idx + 1:])).strip()
        if fc_text and not first_comment:
            first_comment = fc_text
        lines = lines[:fc_idx]
    while lines and not lines[0].strip():
        lines.pop(0)
    # a DRAFT marker line (short, starts with DRAFT or 草稿) is not the title
    draft_marker = False
    if lines and re.match(r"^\W*(DRAFT|草稿)", lines[0].strip(), re.I) and len(lines[0].strip()) <= 120:
        draft_marker = True
        lines = lines[1:]
        while lines and not lines[0].strip():
            lines.pop(0)
    title = lines[0].strip().lstrip("#").strip() if lines else ""
    rest = lines[1:]
    full = "\n".join(lines) + "\n" + first_comment
    tags = re.findall(r"#[^\s#]+", "\n".join(rest))
    body_lines = [l for l in rest if l.strip() and not re.fullmatch(r"(\s*#[^\s#]+\s*)+", l)]
    body = "\n".join(body_lines)
    body_len = len(re.sub(r"\s", "", body))
    rows = []

    def row(code, label, ok, detail=""):
        rows.append((code, label, "PASS" if ok else "FAIL", detail))

    row("F3", "title <= 20 characters", 0 < len(title) <= 20, "%d characters" % len(title))
    row("F2", "body 300-500 characters", 300 <= body_len <= 500, "%d characters" % body_len)
    row("F4", "5-8 topics", 5 <= len(tags) <= 8, "%d topics" % len(tags))
    last = body_lines[-1].strip() if body_lines else ""
    row("F5", "last line is a question", last.endswith(("？", "?")), last[-20:])
    row("F6", "first comment prepared", bool(first_comment), "" if first_comment else "pass --first-comment")
    h = hits(CONTACT, full) + (["phone number"] if PHONE.search(full) else [])
    row("R-contact", "no contact ID / phone / QR", not h, ", ".join(h))
    h = hits([LINKS.pattern], full)
    row("R-link", "no link or domain", not h, ", ".join(h))
    h = hits(OTHER_PLATFORMS, full)
    row("R-platform", "no other platform named", not h, ", ".join(h))
    h = hits(CREDENTIALS, full)
    allowed = bool(prof and prof.get("red_lines", {}).get("licence_claim_allowed") is True)
    row("R-credential", "no licence / insurance / years claim", (not h) or allowed,
        ", ".join(h) + (" (allowed: client-sourced claim; check the source)" if h and allowed else ""))
    h = hits(ABSOLUTES, full)
    row("R-absolute", "no absolute claim or promise", not h, ", ".join(h))
    if prof:
        banned = [w for w in prof.get("red_lines", {}).get("banned_words", []) if w]
        h = [w for w in banned if w.lower() in full.lower()]
        row("R-client", "client's own banned words", not h, ", ".join(h))
        names = [w for w in prof.get("red_lines", {}).get("never_name", []) if w]
        h = [w for w in names if w.lower() in full.lower()]
        row("R-never-name", "client's never-name list", not h, ", ".join(h))
    draft = draft_marker or "DRAFT" in full or "草稿" in full
    rows.append(("A", "client approval", "PENDING" if draft else "CHECK", "DRAFT marker still present; remove only after the client approves" if draft else "no DRAFT marker; confirm the client approved this text"))
    w = max(len(r[1]) for r in rows)
    print("%-10s %-*s  %-7s %s" % ("check", w, "rule", "result", "detail"))
    for c, l, r, d in rows:
        print("%-10s %-*s  %-7s %s" % (c, w, l, r, d))
    fails = [r for r in rows if r[2] == "FAIL"]
    print("\nRESULT:", "FAIL (%d)" % len(fails) if fails else "no FAIL (human checks still apply)")
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
