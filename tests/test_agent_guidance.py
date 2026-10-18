"""Mechanical checks for the agent instruction map, not agent-quality claims."""

from collections.abc import Iterator
import json
from pathlib import Path
import re
import unittest
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
GUIDES = (
    Path("AGENTS.md"),
    Path("docs/engineering/flutter.md"),
    Path("docs/engineering/agentic.md"),
    Path("docs/engineering/sources.md"),
)
LINK = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
FENCES = re.compile(r"```.*?```", re.DOTALL)


def local_link_paths(markdown: str) -> Iterator[str]:
    """Read this map's inline Markdown links, excluding code and remote URLs."""
    for target in LINK.findall(FENCES.sub("", markdown)):
        parsed = urlsplit(target)
        if parsed.scheme or parsed.netloc or not parsed.path:
            continue
        yield unquote(parsed.path)


class AgentGuidanceTests(unittest.TestCase):
    def test_root_uses_one_canonical_filename(self):
        aliases = sorted(
            path.name
            for path in ROOT.iterdir()
            if path.is_file() and path.name.casefold() == "agents.md"
        )
        self.assertEqual(aliases, ["AGENTS.md"])

    def test_root_stays_a_small_instruction_map(self):
        content = (ROOT / "AGENTS.md").read_bytes()
        self.assertLessEqual(len(content), 12_000)
        self.assertLessEqual(len(content.decode("utf-8").splitlines()), 160)

    def test_strategy_copy_matches_canonical_metadata(self):
        metadata = json.loads(
            (ROOT / "metadata/app-store.en-US.json").read_text(encoding="utf-8")
        )
        instructions = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
        for value in (
            metadata["name"],
            metadata["subtitle"],
            metadata["screenshots"][0]["headline"],
        ):
            with self.subTest(value=value):
                self.assertIn(value, instructions)

    def test_local_reference_paths_exist_inside_repository(self):
        for relative in GUIDES:
            source = ROOT / relative
            content = source.read_text(encoding="utf-8")
            for target in local_link_paths(content):
                with self.subTest(source=str(relative), target=target):
                    resolved = (source.parent / target).resolve()
                    self.assertTrue(resolved.is_relative_to(ROOT))
                    self.assertTrue(resolved.is_file(), f"Missing {resolved}")

    def test_link_parser_excludes_remote_and_fenced_examples(self):
        content = (
            "[local](../specs/product.md) [section](#title) "
            "[remote](https://example.com/a) [mail](mailto:a@example.com)\n"
            "```md\n[example](not-a-file.md)\n```"
        )
        self.assertEqual(list(local_link_paths(content)), ["../specs/product.md"])


if __name__ == "__main__":
    unittest.main()
