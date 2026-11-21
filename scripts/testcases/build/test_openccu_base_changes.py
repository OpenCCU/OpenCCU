#!/usr/bin/env python3
"""Check the "OpenCCU-Base Changes" category of the release notes.

scripts/openccu-base-changes.py groups the new OpenCCU-Base changelog
entries by component under a heading linked to the changelog of the
component and keeps every pull request, issue and commit linked at the end
of an entry. The output of scripts/changelog-sections.py is given as text,
so no OpenCCU-Base checkout is needed.
"""
import importlib.util
from pathlib import Path
import re
import sys
import unittest

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
_spec = importlib.util.spec_from_file_location(
    "openccu_base_changes", ROOT / "scripts/openccu-base-changes.py")
obc = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(obc)

URL = "https://github.com/OpenCCU/OpenCCU-Base"
SECTIONS = f"""## Component changes

### ReGaHss

#### R1.00.0388.0269 (2026-11-11)

* fix the setters BreakOnRestart(value) of a rule destination leaving an
  extra value on the internal stack.
  (cf. [OpenCCU/OpenCCU#4722](https://github.com/OpenCCU/OpenCCU/issues/4722))

#### R1.00.0388.0268 (2026-11-02)

* add the option `-v` / `--version`.
  (cf. [OpenCCU/OpenCCU-Base#294]({URL}/pull/294))

### hmipserver

#### 3.89.14 (2026-11-21)

* update `HMIPServer.jar` to the build of 2026-11-19 from eQ-3. A client no
  longer leaks
  ([#399]({URL}/pull/399),
  [homematicip#18](https://github.com/homematicip/OpenCCU-Base/pull/18),
  fixes [#36]({URL}/issues/36), @cn-eq3).
* update `HMIPServer.jar` to the build of 2026-10-08 from eQ-3.
  ([8be251d]({URL}/commit/8be251dab67c05c3dd9a5daa48d89558ad709acc),
  @cn-eq3)

### rfd

#### 2.7.1 (2026-11-18)

* fix a request getting the answer of another one
  ([#282]({URL}/pull/282), @jens-maus).

#### 2.6.1 (2026-10-01)

* fix events getting lost under load ([#274]({URL}/pull/274), @hobbyquaker).

##### Migrated from OpenCCU patches

* patch 0001: something OpenCCU already had ([#1]({URL}/pull/1), @a).
"""


class OpenccuBaseChangesTest(unittest.TestCase):
    def render(self):
        body, versions = obc.groups(SECTIONS)
        return obc.render(body, versions, URL, "3.89.14")

    def test_components_are_linked_headings_with_versions(self):
        text = self.render()
        self.assertTrue(text.startswith(obc.TITLE + "\n\n"))
        self.assertIn(
            f"##### [ReGaHss]({URL}/blob/3.89.14/src/ReGaHss/CHANGELOG.md) "
            "R1.00.0388.0268 – R1.00.0388.0269\n", text)
        self.assertIn(f"##### [rfd]({URL}/blob/3.89.14/src/rfd/CHANGELOG.md) "
                      "2.6.1 – 2.7.1\n", text)
        # the OpenCCU-Base release is not repeated for these components
        self.assertIn(f"##### [hmipserver]({URL}/blob/3.89.14/src/hmipserver/"
                      "CHANGELOG.md)\n", text)

    def test_entries_have_no_component_prefix(self):
        for line in self.render().splitlines():
            if line.startswith("- "):
                self.assertNotRegex(line, r"^- (ReGaHss|hmipserver|rfd): ")

    def test_cf_references_are_kept(self):
        text = self.render()
        self.assertIn("- fix the setters BreakOnRestart(value) of a rule destination "
                      "leaving an extra value on the internal stack "
                      "([OpenCCU#4722](https://github.com/OpenCCU/OpenCCU/issues/4722))",
                      text)
        self.assertIn(f"([OpenCCU-Base#294]({URL}/pull/294))", text)

    def test_all_pull_requests_issues_and_commits_are_kept(self):
        text = self.render()
        self.assertIn(
            f"([OpenCCU-Base#399]({URL}/pull/399), "
            "[homematicip/OpenCCU-Base#18](https://github.com/homematicip/OpenCCU-Base/pull/18), "
            f"[OpenCCU-Base#36]({URL}/issues/36), @cn-eq3)", text)
        self.assertIn(f"([8be251d]({URL}/commit/8be251dab67c05c3dd9a5daa48d89558ad709acc), "
                      "@cn-eq3)", text)

    def test_migrated_patches_are_left_out(self):
        self.assertNotIn("OpenCCU already had", self.render())

    def test_component_list_of_the_workflows(self):
        # .github/workflows/release*.yml read the components from the headings
        names = re.findall(r"^##### \[([A-Za-z0-9_.-]*)\]\(", self.render(), re.M)
        self.assertEqual(names, ["ReGaHss", "hmipserver", "rfd"])


if __name__ == "__main__":
    unittest.main()
