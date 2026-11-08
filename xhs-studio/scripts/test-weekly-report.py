#!/usr/bin/env python3
"""Offline checks for weekly report safety and data semantics."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('build-weekly-report.py')
spec = importlib.util.spec_from_file_location('weekly_report', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def fixture():
    return {'meta': {'account': 'Synthetic account'},
            'weekly': {'views': 2, 'local_inquiries': None, 'comments': 0},
            'daily': [{'date': '2026-01-02', 'views': 1},
                      {'date': '2026-01-01', 'views': 1}]}


class WeeklyReportTests(unittest.TestCase):
    def test_missing_and_zero_survive(self):
        result = module.validate(fixture())
        self.assertIsNone(result['weekly']['local_inquiries'])
        self.assertEqual(result['weekly']['comments'], 0)
        self.assertEqual(result['daily'][0]['date'], '2026-01-01')
        self.assertEqual(result['validation_notes'], [])

    def test_mismatch_is_exposed_without_rewriting_source(self):
        data = fixture()
        data['weekly']['views'] = 9
        result = module.validate(data)
        self.assertEqual(result['weekly']['views'], 9)
        self.assertEqual(len(result['validation_notes']), 1)

    def test_invalid_counts_rejected(self):
        for value in (-1, True, '2', 1.5, float('nan'), float('inf')):
            with self.subTest(value=value):
                data = fixture()
                data['weekly']['views'] = value
                with self.assertRaises(ValueError):
                    module.validate(data)

    def test_duplicate_dates_rejected(self):
        data = fixture()
        data['daily'][1]['date'] = data['daily'][0]['date']
        with self.assertRaises(ValueError):
            module.validate(data)

    def test_source_links_restricted(self):
        for path in ('../private.txt', '/etc/passwd', 'javascript:alert(1)',
                     'https://example.com', '%2e%2e/private', 'folder\\file'):
            with self.subTest(path=path):
                data = fixture()
                data['sources'] = [{'path': path}]
                with self.assertRaises(ValueError):
                    module.validate(data)
        data['sources'] = [{'path': 'sources/weekly.xlsx'}]
        module.validate(data)

    def test_cli_escape_and_overwrite(self):
        with tempfile.TemporaryDirectory() as folder:
            source, out = Path(folder) / 'data.json', Path(folder) / 'report.html'
            data = fixture()
            data['summary'] = {'title': '</script><img src=x onerror=alert(1)>'}
            source.write_text(json.dumps(data))
            cmd = [sys.executable, str(SCRIPT), str(source), '--out', str(out)]
            subprocess.run(cmd, check=True, capture_output=True)
            content = out.read_text()
            self.assertNotIn('</script><img', content)
            self.assertIn('\\u003c/script\\u003e', content)
            self.assertIn('"local_inquiries": null', content)
            self.assertNotEqual(subprocess.run(cmd, capture_output=True).returncode, 0)
            subprocess.run(cmd + ['--overwrite'], check=True, capture_output=True)


if __name__ == '__main__':
    unittest.main()
