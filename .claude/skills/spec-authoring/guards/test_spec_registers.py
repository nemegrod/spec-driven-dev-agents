"""Guard: the specification set stays consistent (spec-authoring skill, Section 6).

Copy this file into the project's test folder. It runs the `spec-check.sh` of the spec-authoring
skill (under `.claude/skills/` or `.github/skills/`), which checks that every ID is defined exactly
once in its register, that no citation dangles, that the design documents carry no history text
(that belongs in docs/change_log.md) and that register items carry a Status: line.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

CHECK = Path("skills") / "spec-authoring" / "scripts" / "spec-check.sh"
HOMES = (".claude", ".github")


def _find_check() -> tuple[Path, Path]:
    for folder in Path(__file__).resolve().parents:
        for home in HOMES:
            script = folder / home / CHECK
            if script.is_file():
                return folder, script
    raise FileNotFoundError(f"{CHECK} not found under {HOMES} above {__file__}")


def test_spec_check_is_clean() -> None:
    root, script = _find_check()
    result = subprocess.run(
        ["bash", str(script)], cwd=root, capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, (
        "spec-check.sh reported findings:\n" + result.stdout + result.stderr
    )
