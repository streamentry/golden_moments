"""Every senior-first feature has an honest, evidence-backed status."""
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = json.loads(
    (ROOT / 'docs/specs/senior-first/feature-catalog.json').read_text(encoding='utf-8'))
STATUS = json.loads(
    (ROOT / 'docs/specs/release-status.json').read_text(encoding='utf-8'))
FEATURES = STATUS['senior_first_features']['features']
ALLOWED = {'not_started', 'partial', 'implemented_unverified',
           'locally_verified', 'verified', 'deferred'}
NO_EVIDENCE_NEEDED = {'not_started', 'deferred'}


class SeniorStatusTests(unittest.TestCase):
    def test_every_catalog_feature_is_accounted_for(self):
        ids = {feature['id'] for feature in CATALOG['features']}
        self.assertEqual(set(FEATURES), ids)

    def test_statuses_are_known_and_scoped(self):
        for feature_id, entry in FEATURES.items():
            with self.subTest(feature=feature_id):
                self.assertIn(entry['status'], ALLOWED)
                self.assertTrue(entry.get('scope', '').strip())

    def test_started_work_cites_evidence_that_exists(self):
        for feature_id, entry in FEATURES.items():
            if entry['status'] in NO_EVIDENCE_NEEDED:
                continue
            with self.subTest(feature=feature_id):
                self.assertTrue(entry.get('evidence'), 'needs evidence')
                for path in entry['evidence']:
                    self.assertTrue((ROOT / path).exists(), path)

    def test_nothing_is_called_verified_without_device_evidence(self):
        for feature_id, entry in FEATURES.items():
            if entry['status'] == 'verified':
                with self.subTest(feature=feature_id):
                    self.assertTrue(entry.get('device_evidence'))

    def test_approval_gated_and_later_phase_work_is_not_claimed(self):
        by_id = {feature['id']: feature for feature in CATALOG['features']}
        for feature_id, entry in FEATURES.items():
            feature = by_id[feature_id]
            with self.subTest(feature=feature_id):
                if feature['phase'] == 'R3' and not feature.get('approved_on'):
                    self.assertEqual(entry['status'], 'deferred')
                if feature['phase'] == 'R2' and feature.get('approved_on'):
                    # A maintainer-started R2 item may be under way, but it
                    # is never called verified from here.
                    self.assertIn(
                        entry['status'],
                        {'not_started', 'partial', 'implemented_unverified'})
                elif feature['phase'] == 'R2':
                    # Gated: at most one unshipped prototype, never verified.
                    self.assertIn(
                        entry['status'], {'not_started', 'implemented_unverified'})
                    if entry['status'] == 'implemented_unverified':
                        self.assertIn('unshipped', entry['scope'].lower())
                        self.assertIn('GM_EXPERIMENTS', entry['scope'])

    def test_at_most_one_r2_activity_is_built(self):
        built = [
            feature_id for feature_id, entry in FEATURES.items()
            if feature_id in ('GM-009', 'GM-010')
            and entry['status'] != 'not_started'
        ]
        self.assertLessEqual(len(built), 1)

    def test_release_gates_stay_pending_until_evidenced(self):
        for gate, result in STATUS['gates'].items():
            if result['status'] == 'passed':
                with self.subTest(gate=gate):
                    self.assertTrue(result['evidence'])

    def test_device_acceptance_checklist_covers_every_feature(self):
        text = (ROOT / 'docs/release/device-acceptance.md').read_text(
            encoding='utf-8')
        # Expand ranges such as "GM-012 to 017" and plain mentions.
        mentioned = set(re.findall(r'GM-\d{3}', text))
        for first, last in re.findall(r'GM-(\d{3}) to (\d{3})', text):
            mentioned |= {f'GM-{n:03d}' for n in range(int(first), int(last) + 1)}
        ids = {feature['id'] for feature in CATALOG['features']}
        self.assertEqual(sorted(ids - mentioned), [])


if __name__ == '__main__':
    unittest.main()
