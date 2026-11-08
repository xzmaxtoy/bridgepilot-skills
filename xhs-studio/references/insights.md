# Insights: export first, then a visual weekly review

For supplied exports/reports, work offline with the available analysis tools; no browser or completed setup is required. For fresh account collection, use read-only BrowserSkill in the client's explicitly selected browser and follow its cooperation, profile binding, download and cleanup instructions. Never change posts or send messages as part of analytics. Keep automatic actions off during tests.

## Collect once, analyze locally

1. Verify account identity. Confirm the business goal and service geography from the profile; if testing another account, do not reuse the original business's conversion metric. Ask one compact question for untracked business outcomes; an unknown count stays `null`.
2. Prefer Creator Center **导出数据** before extracting screen tables. Navigate from the visible 数据看板 menu to 账号概览 and 内容分析; previously observed routes are `/statistics/data-analysis` for content analysis and `/new/note-manager` for note management. Recheck labels rather than inventing dashboard URLs.
3. Download the account's latest available complete seven-day viewing export and the relevant note-list export using `bsk download <fresh-ref> --session <id> --context <current-context> --out <job>/sources/<descriptive-name>.xlsx`. Download other relevant engagement/follow exports if offered and useful; otherwise capture the missing weekly metrics from the page. A viewing export alone does not establish follows, engagement or inquiries. Preserve original files and their active filters. Use browser-skill's native download workflow, not private API calls.
4. Inspect workbook sheets and rows locally with the available spreadsheet skill/runtime. Preserve dates, units and numeric percentages (e.g. 0.083 may mean 8.3%, while another sheet stores 8.3). Record export time, account, page period, export row dates, filter meaning, count and coverage. Keep downloads separate from normalized data. Do not collect all historical content by default.
5. Use UI reads only for missing context: weekly engagement/follows, profile positioning, note titles, actual caption keywords/topics/location tags and audience geography when available. Small page budget: exports first, then a few targeted pages. Do not open customer DMs just to fill a dashboard. If a public post or geography panel is blocked, report that field unavailable and continue with the exports; do not bypass the blocker.

Observed on one account, 2026-11-08: content export “笔记列表明细表.xlsx” included title, first publication, format, impressions, views, CTR, likes, comments, saves, follows, shares, average duration and danmaku. Viewing export “近7日观看数据.xlsx” contained summary plus daily trends. These exports did **not** include audience geography, captions or hashtags. Treat the fields as a tested example, not a permanent platform guarantee. Note-list export advertised at most the first 1,000 sorted notes; report truncation if relevant.

For a covered export button, inspect the page and download outcome before retrying. Reveal it with normal scrolling; never replay an uncertain download blindly. Site clicks may open analytics/public notes in extra tabs: inspect owned tabs, reconcile and close them using browser-skill. Never borrow other user tabs without its required workflow. Record successful routes and limitations in `$XHS_HOME/log/patterns/insights-pages.md`; stop the owned session at completion.

## Reconcile before drawing charts

- Separate **account weekly totals**, **per-note cumulative totals**, and **notes published during a filter**. A 首发时间 filter selects notes by publication; it does not make their cumulative metrics weekly increments. Do not sum them into a weekly headline or divide one scope by another.
- Reconcile daily counts against account totals. Keep UI period and export dates independently when they differ; do not shift dates or assume a timezone to make them agree. The test account had a one-day date-label difference and a 12-hour publication-time difference across surfaces.
- For average duration and rates, check numerator/denominator compatibility. If the visible counts do not reproduce a metric, preserve its source definition, explain the unresolved denominator, and omit misleading retention/ratio comparisons. Do not evaluate image posts using a video completion metric.
- Preserve official CTR; do not replace it with total views / total impressions without a verified matching definition. Copy displayed period comparisons without reverse-engineering exact prior counts from rounded percentages.
- Missing and untracked figures are `null`, never zero. Label owner observations, derived calculations and hypotheses separately from backend figures. Language does not identify location. Do not infer “zero local traffic” from “mostly Chinese readers,” or zero orders from no tracking.

## Local traffic and keyword targeting

For a local business, always include this analysis; for a nonlocal business adapt to its intended audience instead of inventing a city:

- State target city/neighborhood and commercial goal. Present measured local audience share only if the source gives the relevant **viewer** geography and period. Follower geography is a different population. If unavailable, say so.
- Compare local intent across account name/bio, recent titles/covers, opening/body, existing hashtags, location tag, and CTA. Mark each as observed or unverified. Distinguish broad topic/US-wide advice from city + purchase/service intent. A missing city in a title is evidence of that omission, not proof of the distribution cause.
- Inspect the actual captions/topics when accessible before diagnosing a hashtag problem. Suggest a small set of city/neighborhood + product/service keyword candidates and matched topic candidates. Verify existing XHS topics in the picker/search before describing them as usable public-post topics. Do not invent search volume, competition scores or geographic targeting guarantees. No unsupported algorithm-weight folklore.
- Recommend one concrete content experiment with a local hook and commercial context, marked DRAFT 草稿. Preserve real services and claims. Define observation windows (e.g. 24 h / 72 h / 7 d) and a next-decision rule; one post cannot prove causation.
- Put views, follows, locally qualified inquiries, and the business outcome side by side, with unavailable values explicit. Offer a minimal anonymous tally: date, source note, voluntarily supplied city/area, intent class and attributable visit/order/booking. The client owns business counts; do not silently configure tracking or messaging automations.

## Build the visual report

Default durable destination: `$XHS_HOME/reports/<account-key>/<period>/` for official source exports, normalized `results.json`, and a self-contained `weekly-report.html`, unless the client explicitly chose another final destination. Host temporary/output folders are staging or review copies, not the final client library. Copy the complete portable bundle, verify links and files at the destination, and report that saved location. Maintain an account-scoped `latest-report.json` with relative report/data paths, period, collection date and mode; update it only after the bundle is verified. Keep simulations in a separate test folder and `latest-test-report.json` so they cannot silently become live production evidence. Save a dated copy of normalized results in `$XHS_HOME/log/`. Follow the client's language and branding; use the approved visual dashboard as a reusable starting point, not account-specific copy.

Read [weekly-report.md](weekly-report.md) for the data contract and reusable renderer. The bundled template has headline metric cards (including unknown business outcomes), switchable daily views/impressions, per-note comparisons with scope labels, a local targeting audit, a draft next experiment, and expandable source/method notes. Keep sources linked using relative paths so the report folder is portable. No external chart/font/CDN dependencies or credentials.

Choose a few meaningful charts, show counts and sample sizes, and keep independently measured stages out of a fake conversion funnel. Highlight concentration or trend only if daily data supports it. Never choose a “winner” from tiny denominators or reach alone: use saves/comments per view and business relevance with uncertainty. When daily data is absent, show an unavailable state, not invented trend lines.

Verify chart values against the normalized data, null vs zero, source links, desktop/mobile layout, chart toggles and browser errors. Render and inspect the report locally; this requires no logged-in account. A PDF is optional only with appropriate PDF checks. Report what was tested and what remains unavailable.

## Per-post follow-up

At +24 h and +72 h record views, likes, saves, comments, shares and follows when available. Recommendation-feed entry or a second distribution wave needs a source, not an assumption from views alone. Comment sweeps and the prepared first comment belong to the separately authorized inbox workflow; analytics never authorizes sending them.

## Close the production loop
The next video must read the latest matching-account report and prior experiment before selecting its new direction. Follow `production-cycle.md` to link findings and limitations into a job brief, then evaluate that hypothesis after publication. A report suggestion does not authorize creating, scheduling or publishing a new post on its own.
