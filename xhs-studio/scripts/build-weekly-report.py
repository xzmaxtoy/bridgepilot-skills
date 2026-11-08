#!/usr/bin/env python3
"""Build an offline report from analyst-normalized XHS data; never contacts XHS."""
import argparse
import datetime as dt
import json
import math
from pathlib import Path, PurePosixPath

COUNT_FIELDS = ('views', 'impressions', 'new_follows', 'likes', 'saves', 'comments',
                'shares', 'profile_visitors', 'local_inquiries', 'business_outcomes', 'follows')


def validate(data):
    if not isinstance(data, dict):
        raise ValueError('Input must be a JSON object')
    if not isinstance(data.get('meta'), dict) or not data['meta'].get('account'):
        raise ValueError('meta.account is required')
    for key in ('weekly', 'summary', 'local_targeting', 'experiment'):
        if not isinstance(data.get(key, {}), dict):
            raise ValueError(f'{key} must be an object')
    for key in ('daily', 'results', 'sources', 'method_notes'):
        if not isinstance(data.get(key, []), list):
            raise ValueError(f'{key} must be an array')
    rows = [data.get('weekly', {})] + data.get('daily', []) + data.get('results', [])
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError('Metric rows must be objects')
        for key in COUNT_FIELDS:
            value = row.get(key)
            if value is not None and (type(value) not in (int, float) or not math.isfinite(value)
                                      or value < 0 or int(value) != value):
                raise ValueError(f'{key} must be a nonnegative integer or null')
    dates = []
    for row in data.get('daily', []):
        date = row.get('date')
        if not isinstance(date, str) or dt.date.fromisoformat(date).isoformat() != date:
            raise ValueError('Daily dates must use YYYY-MM-DD')
        dates.append(date)
    if len(set(dates)) != len(dates):
        raise ValueError('Duplicate daily dates; reconcile source rows first')
    data['daily'] = sorted(data.get('daily', []), key=lambda row: row['date'])
    for source in data.get('sources', []):
        path = source.get('path', '')
        if not isinstance(path, str) or not path or any(c in path for c in (':', '\\', '?', '#', '%')):
            raise ValueError('Source links must be local relative paths')
        parts = PurePosixPath(path)
        if parts.is_absolute() or '..' in parts.parts:
            raise ValueError('Source links must stay inside the report folder')
    for row in data.get('local_targeting', {}).get('rows', []):
        if row.get('status', 'unknown') not in ('confirmed', 'gap', 'unknown'):
            raise ValueError('Targeting status must be confirmed, gap or unknown')
    warnings = []
    for key in ('views', 'impressions'):
        daily = data['daily']
        total = data.get('weekly', {}).get(key)
        if daily and total is not None and all(row.get(key) is not None for row in daily):
            summed = sum(row[key] for row in daily)
            if summed != total:
                warnings.append(f'{key}: daily sum {summed:g} differs from account total {total:g}; verify period and scope.')
    data['validation_notes'] = warnings
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--overwrite', action='store_true')
    args = parser.parse_args()
    if args.out.exists() and not args.overwrite:
        parser.error('Output exists; choose a new path or pass --overwrite')
    if args.input.resolve() == args.out.resolve():
        parser.error('Input and output must differ')
    try:
        data = validate(json.loads(args.input.read_text(encoding='utf-8')))
        # Escape markup delimiters even inside JSON strings; JS uses textContent/escaped text.
        payload = json.dumps(data, ensure_ascii=True, allow_nan=False).replace('<', '\\u003c').replace('>', '\\u003e').replace('&', '\\u0026')
        template = (Path(__file__).resolve().parent.parent / 'assets' / 'weekly-report.html').read_text(encoding='utf-8')
        assert template.count('__REPORT_DATA__') == 1
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(template.replace('__REPORT_DATA__', payload), encoding='utf-8')
    except (ValueError, TypeError, AttributeError) as exc:
        parser.error(str(exc))
    for warning in data['validation_notes']:
        print('WARNING: ' + warning)
    print(f'Report written: {args.out}')


if __name__ == '__main__':
    main()
