import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "site" / "scripts" / "translate_illustration_names.py"
SPEC = importlib.util.spec_from_file_location("translate_illustration_names", SCRIPT_PATH)
TRANSLATOR = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(TRANSLATOR)


class IllustrationNameWriterTests(unittest.TestCase):
    def test_inserts_illustration_map_without_reformatting_other_fields(self):
        original = '{\n  "ui": {},\n  "pictures": {},\n  "content": {\n    "sayings": []\n  }\n}\n'
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "es.json"
            path.write_text(original)

            TRANSLATOR.write_names(path, {"rocking-chair": "Mecedora"})

            updated = path.read_text()
            parsed = json.loads(updated)
            self.assertEqual(parsed["ui"], {})
            self.assertEqual(parsed["pictures"], {})
            self.assertEqual(parsed["illustrations"], {"rocking-chair": "Mecedora"})
            self.assertEqual(parsed["content"], {"sayings": []})
            self.assertTrue(updated.index('"illustrations"') < updated.index('"content"'))

    def test_replaces_only_the_existing_illustration_map(self):
        original = '{\n  "ui": {},\n  "illustrations": {\n    "rocking-chair": "Silla vieja"\n  },\n  "content": {\n    "sayings": []\n  }\n}\n'
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "es.json"
            path.write_text(original)

            TRANSLATOR.write_names(path, {"rocking-chair": "Mecedora"})

            parsed = json.loads(path.read_text())
            self.assertEqual(parsed["illustrations"], {"rocking-chair": "Mecedora"})
            self.assertEqual(parsed["ui"], {})
            self.assertEqual(parsed["content"], {"sayings": []})


if __name__ == "__main__":
    unittest.main()
