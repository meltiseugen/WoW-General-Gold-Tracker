#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
TOC_PATH = REPO_ROOT / "General-Gold-Tracker.toc"
RUNTIME_DIRS = ("Core", "Tracking", "UI", "Libs", "Data")
REQUIRED_HEADERS = ("Interface", "Title", "Version", "SavedVariables")
SEMVER_PATTERN = re.compile(r"^\d+\.\d+\.\d+$")


def parse_toc(toc_path: Path) -> tuple[dict[str, str], list[str]]:
    headers: dict[str, str] = {}
    entries: list[str] = []

    for raw_line in toc_path.read_text(encoding="utf-8").splitlines():
        stripped = raw_line.strip()
        if not stripped:
            continue
        if stripped.startswith("##"):
            match = re.match(r"^##\s*([^:]+):\s*(.*)$", stripped)
            if match:
                headers[match.group(1).strip()] = match.group(2).strip()
            continue
        if stripped.startswith("#"):
            continue
        entries.append(stripped)

    return headers, entries


def collect_runtime_files() -> set[str]:
    runtime_files: set[str] = set()
    for directory_name in RUNTIME_DIRS:
        runtime_dir = REPO_ROOT / directory_name
        if not runtime_dir.is_dir():
            continue
        for file_path in runtime_dir.rglob("*.lua"):
            runtime_files.add(file_path.relative_to(REPO_ROOT).as_posix())
    return runtime_files


def main() -> int:
    errors: list[str] = []

    if not TOC_PATH.is_file():
        print(f"Missing TOC file: {TOC_PATH}", file=sys.stderr)
        return 1

    headers, entries = parse_toc(TOC_PATH)

    for header_name in REQUIRED_HEADERS:
        if not headers.get(header_name):
            errors.append(f"Missing required TOC header: {header_name}")

    version = headers.get("Version", "")
    if version and not SEMVER_PATTERN.fullmatch(version):
        errors.append(f"TOC version must use semantic versioning, got: {version}")

    manifests = [(TOC_PATH, entries)]
    for module_toc in sorted((REPO_ROOT / "Data").glob("General-Gold-Tracker_*/*.toc")):
        module_headers, module_entries = parse_toc(module_toc)
        if module_headers.get("Interface") != headers.get("Interface"):
            errors.append(f"Catalog interface must match the main addon: {module_toc.name}")
        if module_toc.stem == "General-Gold-Tracker_TSMRealmData":
            if module_headers.get("LoadOnDemand", "0") != "0":
                errors.append("TSM realm capture must load at startup")
            if module_headers.get("Dependencies") != "General-Gold-Tracker, TradeSkillMaster":
                errors.append("TSM realm capture must depend on GGT and TSM")
            if module_headers.get("SavedVariables") != "GGTTSMRealmDataSettings" or "SavedVariablesPerCharacter" in module_headers:
                errors.append("TSM realm module may save diagnostic preferences only")
        else:
            if module_headers.get("LoadOnDemand") != "1":
                errors.append(f"Catalog must load on demand: {module_toc.name}")
            if module_headers.get("Dependencies") != "General-Gold-Tracker":
                errors.append(f"Catalog must depend on GGT: {module_toc.name}")
        if not module_entries or module_entries[0] != "Namespace.lua":
            errors.append(f"Catalog namespace must load first: {module_toc.name}")
        manifests.append((module_toc, module_entries))

    toc_runtime_files: set[str] = set()
    for manifest, manifest_entries in manifests:
        seen_entries: set[str] = set()
        for entry in manifest_entries:
            if "\\" in entry:
                errors.append(f"TOC entry must use forward slashes: {entry}")
            if entry in seen_entries:
                errors.append(f"Duplicate TOC entry: {entry}")
                continue
            seen_entries.add(entry)
            file_path = manifest.parent / entry
            if not file_path.is_file():
                errors.append(f"TOC entry does not exist: {file_path}")
            if entry.endswith(".lua"):
                relative = file_path.relative_to(REPO_ROOT).as_posix()
                if relative in toc_runtime_files:
                    errors.append(f"Runtime file loaded by multiple manifests: {relative}")
                toc_runtime_files.add(relative)

    runtime_files = collect_runtime_files()
    missing_runtime_entries = sorted(runtime_files - toc_runtime_files)
    if missing_runtime_entries:
        for missing_entry in missing_runtime_entries:
            errors.append(f"Runtime Lua file missing from TOC: {missing_entry}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print("Addon manifest validation passed.")
    print(f"Validated {len(manifests)} manifests and {len(runtime_files)} runtime Lua files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
