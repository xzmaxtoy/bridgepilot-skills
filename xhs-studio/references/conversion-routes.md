# Conversion routes: from XHS to a real customer

## Evidence caveat
No official XHS rule text was obtained for a non-mainland personal account. The rules below come from news reports and third-party pages (2025-01 DM rule, 2025-03 off-platform-transaction rule). Treat risk ratings as estimates, re-check before relying on any detail, and report unknowns as unknowns.

## What may never appear on any surface (note, comment, bio, nickname, DM)
- Contact IDs (WeChat or other messengers), phone numbers, QR codes.
- Names, links, screenshots or watermarks of other platforms; a website link or domain.
- Wording that steers a user off the platform to trade.
A website link "in the bio" or "in a DM" has no source support: treat it as NOT allowed. Professional ("专业号") and company accounts have official lead tools (business card, lead form, store component); eligibility for a non-mainland entity is unverified.

## Routes, in order of preference
1. **DM answer in plain text** using the client's hand-off wording (`profile.json` > `contact_handoff.plain_text_wording`): for example invite the customer to send details by private message, name the areas served in city names. No ID, no number, no link, no platform name. Filtering of such wording is unverified.
2. **Location (POI) tag** on notes, if the client has a listing and the picker offers it (`publish-route.md` location step). Optional: the note publishes without it.
3. **Professional-account tools:** parked until eligibility is confirmed and the client decides.
Rejected: a link or ID in a note, comment, bio or DM; any code or phrase shown publicly that points off platform.

## Hand-off wording rules
- Written by the client or approved by the client, in the profile. The skill never improvises a new one.
- Contains no contact data. If the customer insists on giving a number: the skill does not copy it into any note or reply; it tells the client, who handles it outside the skill.
- Requests from outside the service area: escalate to the client with the nickname, place and request.

## Measuring conversion
Reach alone is never a result. Report reach next to follows, intent DMs and the client's north-star number (`north_star`). Say what cannot be traced.
