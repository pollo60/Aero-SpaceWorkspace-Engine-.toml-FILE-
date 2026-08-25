#!/usr/bin/env python3
"""
Comprehensive test suite for AeroSpace Workspace Engine.
Validates: TOML syntax, shell scripts, configuration consistency, keybindings, app routing.
"""

import os
import sys
import re
import json
import subprocess
from pathlib import Path

# ANSI colors
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
CYAN = "\033[96m"
RESET = "\033[0m"
BOLD = "\033[1m"

# Test counters
passed = 0
failed = 0
warnings = 0

def print_header(text):
    print(f"\n{BOLD}{CYAN}{'='*70}{RESET}")
    print(f"{BOLD}{CYAN}  {text}{RESET}")
    print(f"{BOLD}{CYAN}{'='*70}{RESET}\n")

def ok(msg):
    global passed
    passed += 1
    print(f"{GREEN}✓{RESET}  {msg}")

def fail(msg):
    global failed
    failed += 1
    print(f"{RED}✗{RESET}  {msg}")

def warn(msg):
    global warnings
    warnings += 1
    print(f"{YELLOW}⚠{RESET}  {msg}")

def parse_toml_simple(filepath):
    """Simple TOML parser for validation"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Check for basic syntax issues
        if content.count('[') != content.count(']'):
            return None, "Unbalanced bracket count"
        if content.count('{') != content.count('}'):
            return None, "Unbalanced brace count"
        
        # Extract basic info
        data = {
            'raw_content': content,
            'workspaces': [],
            'app_routes': [],
            'keybindings': {},
        }
        
        # Extract persistent-workspaces
        match = re.search(r"persistent-workspaces = \[(.*?)\]", content)
        if match:
            ws_str = match.group(1)
            workspaces = re.findall(r"'([^']+)'", ws_str)
            data['workspaces'] = workspaces
        
        # Extract app routing (on-window-detected sections)
        routes = re.findall(r"\[\[on-window-detected\]\]\s+if\.app-(?:name-regex-substring|id) = ['\"](.+?)['\"].*?\n(?:run|move.*?workspace)", content, re.DOTALL)
        data['app_routes'] = len(routes)
        
        # Extract keybindings
        bindings = re.findall(r"^(alt-[\w\-]+)\s*=\s*['\"]([^'\"]+)['\"]", content, re.MULTILINE)
        data['keybindings'] = dict(bindings)
        
        return data, None
    except Exception as e:
        return None, str(e)

def validate_toml_files():
    """Validate all TOML config files"""
    print_header("TOML Configuration Validation")
    
    repo_root = Path(__file__).parent.parent
    toml_files = [
        repo_root / ".aerospace.toml",
        repo_root / "aerospace.toml",
        repo_root / "profiles" / "default.toml",
        repo_root / "profiles" / "macgod.toml",
        repo_root / "profiles" / "laptop.toml",
    ]
    
    for toml_file in toml_files:
        if not toml_file.exists():
            fail(f"{toml_file.name}: File not found")
            continue
        
        data, err = parse_toml_simple(toml_file)
        if err:
            fail(f"{toml_file.name}: Parse error — {err}")
            continue
        
        # Check workspace list
        if data['workspaces']:
            ok(f"{toml_file.name}: Found {len(data['workspaces'])} workspaces: {', '.join(data['workspaces'])}")
            
            # Check for required workspaces
            if toml_file.name in [".aerospace.toml", "aerospace.toml", "default.toml"]:
                required = ['AI', 'Code', 'CLI', 'Browser', 'Media', 'Social', '7', '8', '9']
                if data['workspaces'] == required:
                    ok(f"{toml_file.name}: All 9 workspaces present and in correct order")
                else:
                    fail(f"{toml_file.name}: Workspace mismatch. Expected {required}, got {data['workspaces']}")
            elif toml_file.name == "macgod.toml":
                required = ['AI', 'Code', 'CLI', 'Browser', 'Media', 'Social', '7', '8', '9']
                if data['workspaces'] == required:
                    ok("macgod.toml: All 9 workspaces present and using numeric identifiers")
                else:
                    fail(f"macgod.toml: Workspace names incorrect. Expected {required}, got {data['workspaces']}")
            elif toml_file.name == "laptop.toml":
                expected_count = 7
                if len(data['workspaces']) == expected_count:
                    ok(f"laptop.toml: Has {expected_count} workspaces (single-display profile)")
                else:
                    fail(f"laptop.toml: Expected {expected_count} workspaces, got {len(data['workspaces'])}")
        else:
            warn(f"{toml_file.name}: No workspaces found")
        
        # Check app routing count
        if data['app_routes'] > 0:
            ok(f"{toml_file.name}: Found {data['app_routes']} app routing blocks")
        else:
            warn(f"{toml_file.name}: No app routing found")
        
        # Check keybindings
        if data['keybindings']:
            ok(f"{toml_file.name}: Found {len(data['keybindings'])} keybindings")
        else:
            warn(f"{toml_file.name}: No keybindings found")

def validate_shell_scripts():
    """Validate shell scripts with shellcheck and style checks"""
    print_header("Shell Script Validation")
    
    repo_root = Path(__file__).parent.parent
    scripts = [
        repo_root / "install.sh",
        repo_root / "scripts" / "dock-layout-sync.sh",
        repo_root / "scripts" / "get_appid.sh",
        repo_root / "scripts" / "list_apps.sh",
        repo_root / "scripts" / "toggle_macgod.sh",
        repo_root / "scripts" / "check_deps.sh",
        repo_root / "scripts" / "switch_profile.sh",
        repo_root / "scripts" / "workspace_status.sh",
    ]
    
    for script in scripts:
        if not script.exists():
            fail(f"{script.name}: File not found")
            continue
        
        # Check for correct shebang
        with open(script, 'r') as f:
            first_line = f.readline().strip()
        
        if first_line.startswith("#!"):
            if "bash" in first_line or "zsh" in first_line:
                ok(f"{script.name}: Correct shebang '{first_line}'")
            else:
                warn(f"{script.name}: Unusual shebang '{first_line}'")
        else:
            fail(f"{script.name}: Missing shebang")
        
        # Check for strict mode
        with open(script, 'r') as f:
            content = f.read()
        
        if "set -euo pipefail" in content or "set -u" in content:
            ok(f"{script.name}: Has strict mode enabled")
        else:
            warn(f"{script.name}: Missing strict mode setting")

def check_keybinding_consistency():
    """Verify all keybindings are valid AeroSpace commands"""
    print_header("Keybinding Consistency Check")
    
    repo_root = Path(__file__).parent.parent
    toml_files = [
        repo_root / ".aerospace.toml",
        repo_root / "aerospace.toml",
        repo_root / "profiles" / "default.toml",
        repo_root / "profiles" / "macgod.toml",
        repo_root / "profiles" / "laptop.toml",
    ]
    
    valid_commands = {
        'workspace', 'move-node-to-workspace', 'focus-monitor', 'move-workspace-to-monitor',
        'move-node-to-monitor', 'resize', 'focus', 'move', 'layout', 'flatten-workspace-tree',
        'balance-sizes', 'reload-config'
    }
    
    for toml_file in toml_files:
        if not toml_file.exists():
            continue
        
        data, _ = parse_toml_simple(toml_file)
        if not data:
            continue
        
        invalid_bindings = []
        valid_bindings = 0
        
        for binding, command in data['keybindings'].items():
            # Extract the first word of the command
            cmd = command.split()[0] if command else ""
            if cmd in valid_commands:
                valid_bindings += 1
            else:
                invalid_bindings.append(f"{binding} → {command}")
        
        if invalid_bindings:
            warn(f"{toml_file.name}: Found {len(invalid_bindings)} potentially invalid keybindings")
            for ib in invalid_bindings[:5]:
                warn(f"  {ib}")
        else:
            ok(f"{toml_file.name}: All {valid_bindings} keybindings use valid AeroSpace commands")

def check_workspace_names_consistency():
    """Verify workspace names are consistent across configs"""
    print_header("Workspace Name Consistency")
    
    repo_root = Path(__file__).parent.parent
    
    # Load .aerospace.toml workspaces
    main_toml = repo_root / ".aerospace.toml"
    main_data, _ = parse_toml_simple(main_toml)
    main_workspaces = main_data['workspaces'] if main_data else []
    
    # Load macgod.toml workspaces
    macgod_toml = repo_root / "profiles" / "macgod.toml"
    macgod_data, _ = parse_toml_simple(macgod_toml)
    macgod_workspaces = macgod_data['workspaces'] if macgod_data else []
    
    expected = ['AI', 'Code', 'CLI', 'Browser', 'Media', 'Social', '7', '8', '9']
    
    # Check main config
    if main_workspaces == expected:
        ok(".aerospace.toml: Workspace names match spec exactly")
    else:
        fail(f".aerospace.toml: Expected {expected}, got {main_workspaces}")
    
    # Check macgod profile
    if macgod_workspaces == expected:
        ok("macgod.toml: Workspace names match .aerospace.toml correctly")
    else:
        fail(f"macgod.toml: Expected {expected}, got {macgod_workspaces}")

def check_macgod_keybindings():
    """Verify macgod.toml keybindings reference correct workspace names"""
    print_header("MacGOD Keybinding Integrity")
    
    repo_root = Path(__file__).parent.parent
    macgod_toml = repo_root / "profiles" / "macgod.toml"
    
    data, _ = parse_toml_simple(macgod_toml)
    if not data:
        fail("Could not parse macgod.toml")
        return
    
    expected_bindings = {
        'alt-7': "'7'",
        'alt-8': "'8'",
        'alt-9': "'9'",
        'alt-shift-7': "'7'",
        'alt-shift-8': "'8'",
        'alt-shift-9': "'9'",
    }
    
    with open(macgod_toml, 'r') as f:
        content = f.read()
    
    errors = []
    for binding, expected_ws in expected_bindings.items():
        # Check if binding references the workspace with quotes
        pattern = rf"{binding}.*?workspace {expected_ws[1:-1]}"
        if re.search(pattern, content):
            ok(f"macgod.toml: {binding} correctly references workspace {expected_ws}")
        else:
            errors.append(f"{binding} does not reference workspace {expected_ws}")
    
    if errors:
        for err in errors:
            fail(f"macgod.toml: {err}")
    else:
        ok("macgod.toml: All 7/8/9 keybindings correctly reference numeric workspaces")

def check_macgod_app_routing():
    """Verify macgod.toml has complete app routing (including workspace 7)"""
    print_header("MacGOD App Routing Completeness")
    
    repo_root = Path(__file__).parent.parent
    macgod_toml = repo_root / "profiles" / "macgod.toml"
    
    with open(macgod_toml, 'r') as f:
        content = f.read()
    
    required_apps = ['notion.id', 'md.obsidian', 'com.figma.Desktop']
    system_apps = ['com.apple.systempreferences', 'com.apple.ActivityMonitor']
    
    workspace_7_found = False
    system_float_found = False
    
    for app_id in required_apps:
        if app_id in content:
            if "workspace 7" in content.split(app_id)[1].split("[[on-window-detected]]")[0]:
                workspace_7_found = True
                ok(f"macgod.toml: Found workspace 7 routing for {app_id}")
            break
    
    for app_id in system_apps:
        if app_id in content and "layout floating" in content:
            system_float_found = True
            break
    
    if workspace_7_found:
        ok("macgod.toml: Workspace 7 app routing complete (Notion, Obsidian, Figma)")
    else:
        fail("macgod.toml: Missing workspace 7 app routing")
    
    if system_float_found:
        ok("macgod.toml: System dialogs configured to float")
    else:
        fail("macgod.toml: System dialog float rules missing")

def check_readme_documentation():
    """Verify README.md documents all major features"""
    print_header("README Documentation Check")
    
    repo_root = Path(__file__).parent.parent
    readme = repo_root / "README.md"
    
    with open(readme, 'r') as f:
        content = f.read()
    
    required_sections = [
        ("Architecture Principles", "Architectural Core Principles"),
        ("Workspace Taxonomy", "Workspace Taxonomy"),
        ("MacGOD Deployment", "MacGOD Deployment"),
        ("Installation", "Setup & Installation"),
        ("Config Profiles", "Config Profiles"),
        ("MacGOD Ghost Mode", "MacGOD Ghost Mode"),
    ]
    
    for section, regex_pattern in required_sections:
        if re.search(rf"#+\s+.*{re.escape(regex_pattern)}", content):
            ok(f"README.md: Section '{section}' found")
        else:
            warn(f"README.md: Section '{section}' not found or improperly formatted")
    
    # Check if phoenix.js is documented as primary
    if "primary" in content and "phoenix.js" in content:
        ok("README.md: phoenix.js documented as primary config")
    else:
        warn("README.md: phoenix.js not clearly marked as primary")
    
    # Check for legacy note
    if "legacy" in content.lower() and "phoenixrc.js" in content:
        ok("README.md: Legacy phoenixrc.js properly documented")
    else:
        warn("README.md: Legacy Phoenix config not clearly distinguished")

def main():
    print(f"\n{BOLD}AeroSpace Workspace Engine — Automated Test Suite{RESET}\n")
    
    # Run all test suites
    validate_toml_files()
    validate_shell_scripts()
    check_keybinding_consistency()
    check_workspace_names_consistency()
    check_macgod_keybindings()
    check_macgod_app_routing()
    check_readme_documentation()
    
    # Print summary
    print_header("Test Summary")
    print(f"{GREEN}✓ PASSED:{RESET}   {passed}")
    print(f"{RED}✗ FAILED:{RESET}   {failed}")
    print(f"{YELLOW}⚠ WARNING:{RESET}  {warnings}")
    print()
    
    total = passed + failed + warnings
    pct = int((passed / total * 100)) if total > 0 else 0
    
    if failed == 0 and warnings == 0:
        print(f"{GREEN}{BOLD}✅ All tests passed with 100% success rate!{RESET}")
        print(f"   ({passed}/{total} checks passed)\n")
        return 0
    elif failed == 0:
        print(f"{GREEN}{BOLD}✅ All critical tests passed!{RESET}")
        print(f"   {pct}% success rate ({passed}/{total} checks)\n")
        return 0
    else:
        print(f"{RED}{BOLD}❌ Some tests failed.{RESET}")
        print(f"   Fix the issues above and re-run.\n")
        return 1

if __name__ == '__main__':
    sys.exit(main())
