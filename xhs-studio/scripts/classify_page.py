#!/usr/bin/env python3
"""Classify what bsk read from a page: normal, sign-in/verify wall, or platform warning.

Reads text on stdin (the output of the evaluate call in bsk-check-page.sh, or any sample).
Exit 0 = normal, 3 = wall (sign-in, 2FA, captcha, logged out), 4 = platform warning (stop all).
Prints one JSON line. Wording changes on the site: URL and structure are checked first,
phrases second. A false alarm only costs a stop; a miss could cost an account.
"""
import json, re, sys

WALL_URL = re.compile(r"(/login|passport|/captcha|verify|website-login|sso)", re.I)
WALL_TEXT = [
    "手机号登录", "扫码登录", "验证码登录", "请先登录", "登录后", "安全验证", "滑动验证", "拖动滑块",
    "点击验证", "完成验证", "账号已在其他地方登录", "登录已过期", "重新登录", "sign in", "log in to continue",
    "captcha",
]
WARN_TEXT = [
    "操作太频繁", "操作频繁", "请稍后再试", "稍后再试", "账号异常", "被限制", "限流", "账号存在风险",
    "违规", "暂时无法", "too frequent", "try later", "restricted",
]


def classify(text):
    low = text.lower()
    href = ""
    m = re.search(r'"href"\s*:\s*"([^"]*)"', text)
    if m:
        href = m.group(1)
    hits_w = [p for p in WALL_TEXT if p.lower() in low]
    hits_a = [p for p in WARN_TEXT if p.lower() in low]
    if href and WALL_URL.search(href):
        return "wall", ["url:" + href]
    if hits_a:
        return "warning", hits_a
    if hits_w:
        return "wall", hits_w
    return "normal", []


def main():
    text = sys.stdin.read()
    kind, why = classify(text)
    print(json.dumps({"kind": kind, "why": why}, ensure_ascii=False))
    sys.exit({"normal": 0, "wall": 3, "warning": 4}[kind])


if __name__ == "__main__":
    main()
