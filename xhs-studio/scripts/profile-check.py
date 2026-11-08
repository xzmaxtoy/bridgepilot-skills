#!/usr/bin/env python3
"""Check profile.json: structure, sources, switches.

Usage: profile-check.py PROFILE.json [--brief]
  default: print every problem; exit 1 if any.
  --brief: print nothing on success; exit 0 only when the interview is marked complete AND valid.
"""
import json, sys

REQUIRED_TOP = ["client", "brand", "voice", "final_cut", "red_lines", "customer_permission",
                "contact_handoff", "dms", "north_star", "automation", "system", "status"]
SWITCHES = ["auto_publish", "auto_reply_comments", "auto_reply_dms"]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    brief = "--brief" in sys.argv
    if not args:
        sys.exit("usage: profile-check.py PROFILE.json [--brief]")
    try:
        p = json.load(open(args[0], encoding="utf-8"))
    except Exception as e:
        print("cannot read profile: %s" % e)
        sys.exit(1)
    problems = []
    for k in REQUIRED_TOP:
        if k not in p:
            problems.append("missing section: %s" % k)
    a = p.get("automation", {})
    for s in SWITCHES:
        if not isinstance(a.get(s), bool):
            problems.append("automation.%s must be true or false (asked one by one in the interview)" % s)
    import re as _re
    style = (p.get("brand") or {}).get("style") or {}
    for k in ("accent_colour", "text_colour"):
        v = str(style.get(k) or "")
        if v and not _re.fullmatch(r"#[0-9a-fA-F]{6}", v):
            problems.append("brand.style.%s must look like #1F5A3A (or be empty)" % k)
    st = p.get("status", {})
    complete = bool(st.get("interview_complete"))
    if complete:
        c = p.get("client", {})
        if not c.get("business_name"):
            problems.append("client.business_name is empty")
        b = p.get("brand", {})
        svc = [s for s in b.get("services", []) if s.get("name")]
        if not svc:
            problems.append("brand.services has no service")
        for s in svc:
            if not str(s.get("source", "")).strip():
                problems.append("service '%s' has no source (write UNVERIFIED if not confirmed)" % s["name"])
        sa = b.get("service_area", {})
        if not sa.get("value"):
            problems.append("brand.service_area is empty")
        if not str(sa.get("source", "")).strip():
            problems.append("brand.service_area has no source")
        for d in b.get("differentiators", []):
            if d.get("claim") and not str(d.get("source", "")).strip():
                problems.append("differentiator '%s' has no source" % d["claim"])
        rl = p.get("red_lines", {})
        if rl.get("licence_claim_allowed") is True and not [c for c in rl.get("claims_sourced_by_client", []) if c.get("claim") and c.get("source")]:
            problems.append("licence_claim_allowed is true but no sourced claim is listed")
        for c in rl.get("claims_sourced_by_client", []):
            if c.get("claim") and not str(c.get("source", "")).strip():
                problems.append("client claim '%s' has no source" % c["claim"])
        v = p.get("voice", {})
        if not v.get("language") or not v.get("register"):
            problems.append("voice.language / voice.register missing")
        if not v.get("sample_post"):
            problems.append("voice.sample_post is empty (ask for one finished post)")
        fc = p.get("final_cut", {})
        ls = fc.get("length_sec")
        if not isinstance(ls, (int, float)) or not 10 <= ls <= 30:
            problems.append("final_cut.length_sec must be 10 to 30")
        if not p.get("north_star", {}).get("metric"):
            problems.append("north_star.metric is empty")
        if not p.get("dms", {}).get("who_answers"):
            problems.append("dms.who_answers is empty")
        if not a.get("asked_on"):
            problems.append("automation.asked_on is empty (the three switches must be asked in the interview)")
        if any(a.get(s) is True for s in SWITCHES) and not a.get("warning_acknowledged"):
            problems.append("a switch is ON but warning_acknowledged is false (the client must hear the XHS limit warning first)")
    else:
        problems.append("interview not complete (status.interview_complete is false)")
    if brief:
        sys.exit(0 if not problems else 1)
    if problems:
        print("PROFILE PROBLEMS:")
        for x in problems:
            print(" -", x)
        sys.exit(1)
    print("profile OK")


if __name__ == "__main__":
    main()
