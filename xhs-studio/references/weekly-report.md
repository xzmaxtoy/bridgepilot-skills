# Weekly visual report contract

Prepare normalized JSON from inspected exports and supplementary UI evidence. Final bundles belong in the client's chosen destination, normally `$XHS_HOME/reports/<account-key>/<period>/`; use host output/temp folders only for staging. Preserve original files and relative links, verify the destination copy, and update the matching account's latest-report pointer. Keep test and production pointers separate (see `insights.md`). This is an analyst step: the renderer does not parse or guess changing XHS workbook layouts. Use the installed spreadsheet skill for workbook analysis. Generate with:

```sh
python3 "$SKILL_DIR/scripts/build-weekly-report.py" /path/to/results.json --out /path/to/weekly-report.html
```

The reusable HTML asset is `assets/weekly-report.html`. It contains no client data. The renderer escapes embedded JSON, validates counts and dates, and renders text as text rather than HTML. Relative source links may point to files inside the report folder; remote links and parent-directory traversal are not accepted. Existing report HTML is replaced only with `--overwrite`.

Top-level contract (omit optional unknown text; use null for unknown numeric metrics):

```json
{
  "meta": {
    "account": "Example account", "collected_date": "2026-01-08",
    "weekly_period": "UI: Jan 1–7", "daily_period": "Export: Jan 1–7",
    "scope_note": "Timezone unverified; per-note values are cumulative.",
    "target_area": "Client-confirmed service area"
  },
  "summary": {"title": "Evidence-led conclusion", "text": "What changed and what remains unknown."},
  "weekly": {"views": 40, "impressions": 500, "new_follows": 1,
    "likes": 2, "saves": 1, "comments": 0, "shares": 0,
    "profile_visitors": null, "local_inquiries": null, "business_outcomes": null},
  "daily": [{"date": "2026-01-01", "views": 40, "impressions": 500}],
  "results": [{"note_id": null, "title": "Example", "published_at": "2026-01-01",
    "metric_scope": "Cumulative at collection, not weekly increments",
    "views": 40, "impressions": 500, "likes": 2, "saves": 1,
    "comments": 0, "shares": 0, "follows": 1}],
  "local_targeting": {
    "rows": [{"label": "Title contains locality", "value": "Unverified", "status": "unknown"}],
    "interpretation": "Separate evidence from hypothesis.",
    "owner_observation": "Optional qualitative input; not geography measurement."
  },
  "experiment": {"title": "DRAFT local content idea", "hook": "Draft opening",
    "keywords": ["Candidate term; not verified search demand"],
    "action": "What to change", "measure": "What to count and how to decide"},
  "sources": [{"label": "Official export", "path": "sources/weekly.xlsx", "description": "Period and coverage"}],
  "method_notes": ["Unknown values are not zero. Geography unavailable."]
}
```

All text is authored for the client's language; template interface labels default to Simplified Chinese. `local_targeting.rows[].status` is `confirmed`, `gap`, or `unknown`. These denote evidence state, not an invented performance score. For nonlocal clients use their audience targeting analysis in the same panel. Missing `daily` or `results` becomes an explicit empty state. Counts are nonnegative integers or null; invalid values fail rather than being silently coerced. Daily total mismatches warn and appear in method notes, allowing the analyst to explain distinct scopes; do not override source totals.

Keep a field/source map or notes with normalized data when metrics originate from different files/pages. Per-post fields are compatible with the existing insight results shape; use `notes` for a source limitation. Save original timestamps separately if their displays conflict. The output should contain no raw customer messages or contact details.
