"""Regression tests for translation backend failures in site/scripts/agy_translate.py."""

import importlib.util
import io
from pathlib import Path
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "site/scripts/agy_translate.py"
SPEC = importlib.util.spec_from_file_location("agy_translate", MODULE_PATH)
agy_translate = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(agy_translate)


class FakeProcess:
    def __init__(self, events: list[dict[str, object]]) -> None:
        self.stdout = io.StringIO("\n".join(agy_translate.json.dumps(event) for event in events))
        self.returncode: int | None = 0

    def kill(self) -> None:
        self.returncode = -9

    def wait(self) -> int:
        return self.returncode or 0

    def poll(self) -> int | None:
        return self.returncode


class AgyTranslateTests(unittest.TestCase):
    def test_quota_retry_discards_partial_opencode_translation(self) -> None:
        process = FakeProcess(
            [
                {"type": "text", "part": {"text": "partial translation"}},
                {
                    "type": "retry",
                    "error": {"message": "rate limit exceeded"},
                    "timestamp": 0,
                    "nextRetryAt": 5000,
                },
            ]
        )

        with (
            patch.object(agy_translate.subprocess, "Popen", return_value=process),
            patch.object(agy_translate.threading, "Timer"),
        ):
            with self.assertRaises(agy_translate.BackendError) as error:
                agy_translate._run_opencode(["opencode"], str(ROOT), 10)

        self.assertEqual(error.exception.kind, "quota")
        self.assertIn("retry in 5s", str(error.exception))


if __name__ == "__main__":
    unittest.main()
