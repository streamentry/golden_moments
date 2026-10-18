"""Mechanical checks for the senior-first specification, not release approval."""
from __future__ import annotations

import json
import re
import unittest
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / 'docs/specs/senior-first'
ALLOWED_STATES = {'source_present', 'partial', 'proposed', 'deferred'}
PHASES = {'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3}


def local_links(text: str) -> list[str]:
    """Extract the ordinary inline links used by this spec package."""
    text = re.sub(r'```.*?```', '', text, flags=re.S)
    result = []
    for raw in re.findall(r'\[[^\]]+\]\(([^)]+)\)', text):
        target = raw.strip().strip('<>')
        parts = urlsplit(target)
        if parts.scheme or parts.netloc or not parts.path:
            continue
        result.append(unquote(parts.path))
    return result


def validate_graph(features: list[dict]) -> None:
    nodes = {f['id']: f for f in features}
    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(node: str) -> None:
        if node in visiting:
            raise ValueError(f'Dependency cycle at {node}')
        if node in visited:
            return
        visiting.add(node)
        feature = nodes[node]
        for dependency in feature['depends_on']:
            if dependency not in nodes:
                raise ValueError(f'{node}: unknown dependency {dependency}')
            if PHASES[nodes[dependency]['phase']] > PHASES[feature['phase']]:
                raise ValueError(f'{node}: depends on a later phase {dependency}')
            visit(dependency)
        visiting.remove(node)
        visited.add(node)

    for node in nodes:
        visit(node)


class ParserAndGraphTests(unittest.TestCase):
    def test_link_parser_ignores_remote_fragments_and_examples(self):
        text = ('[local](other.md#section) [remote](https://example.com/a) '
                '[mail](mailto:hello@example.com) [anchor](#section)\n'
                '```md\n[example](missing.md)\n```')
        self.assertEqual(local_links(text), ['other.md'])

    def test_graph_rejects_cycles_unknown_and_later_dependencies(self):
        with self.assertRaises(ValueError):
            validate_graph([{'id': 'A', 'phase': 'R0', 'depends_on': ['A']}])
        with self.assertRaises(ValueError):
            validate_graph([{'id': 'A', 'phase': 'R0', 'depends_on': ['B']}])
        with self.assertRaises(ValueError):
            validate_graph([
                {'id': 'A', 'phase': 'R0', 'depends_on': ['B']},
                {'id': 'B', 'phase': 'R1', 'depends_on': []},
            ])
        validate_graph([
            {'id': 'A', 'phase': 'R0', 'depends_on': []},
            {'id': 'B', 'phase': 'R1', 'depends_on': ['A']},
        ])


class SeniorSpecificationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.catalog = json.loads((SPEC / 'feature-catalog.json').read_text())
        cls.features = cls.catalog['features']

    def test_catalog_has_valid_unique_feature_definitions(self):
        self.assertEqual(self.catalog['schema_version'], 1)
        self.assertRegex(self.catalog['baseline_commit'], r'^[0-9a-f]{40}$')
        self.assertEqual(set(self.catalog['phases']), set(PHASES))
        self.assertTrue(self.features)
        ids = [f['id'] for f in self.features]
        self.assertEqual(len(ids), len(set(ids)))
        for feature in self.features:
            with self.subTest(feature=feature['id']):
                self.assertRegex(feature['id'], r'^GM-[0-9]{3}$')
                self.assertTrue(feature['title'].strip())
                self.assertIn(feature['phase'], PHASES)
                self.assertIn(feature['baseline_state'], ALLOWED_STATES)
                self.assertIsInstance(feature['approval_required'], bool)
                self.assertEqual(len(feature['depends_on']),
                                 len(set(feature['depends_on'])))

    def test_each_feature_has_one_specification_owner(self):
        headings: dict[str, list[Path]] = {}
        for doc in SPEC.glob('*.md'):
            for feature_id in re.findall(r'^## (GM-[0-9]{3})\s*$',
                                         doc.read_text(), flags=re.M):
                headings.setdefault(feature_id, []).append(doc)
        self.assertEqual(set(headings), {f['id'] for f in self.features})
        for feature in self.features:
            with self.subTest(feature=feature['id']):
                path, anchor = feature['spec'].split('#', 1)
                expected = (SPEC / path).resolve()
                self.assertTrue(expected.is_relative_to(SPEC.resolve()))
                self.assertEqual(anchor, feature['id'].lower())
                self.assertEqual(headings[feature['id']], [expected])

    def test_dependency_graph_is_acyclic_and_phase_ordered(self):
        validate_graph(self.features)

    def test_deferred_features_still_require_explicit_approval(self):
        deferred = [f for f in self.features if f['phase'] == 'R3']
        self.assertTrue(deferred)
        for feature in deferred:
            self.assertEqual(feature['baseline_state'], 'deferred')
            self.assertTrue(feature['approval_required'])
        self.assertNotIn('gates', self.catalog)
        self.assertNotIn('released', self.catalog)
        self.assertTrue((ROOT / 'docs/specs/release-status.json').is_file())

    def test_repository_local_links_are_real_and_confined(self):
        docs = list(SPEC.glob('*.md')) + [
            ROOT / 'docs/specs/README.md', ROOT / 'docs/specs/product.md',
            ROOT / 'docs/specs/offline-photos.md',
        ]
        for doc in docs:
            for link in local_links(doc.read_text()):
                with self.subTest(document=str(doc), link=link):
                    target = (doc.parent / link).resolve()
                    self.assertTrue(target.is_relative_to(ROOT.resolve()))
                    self.assertTrue(target.exists(), str(target))


if __name__ == '__main__':
    unittest.main()
