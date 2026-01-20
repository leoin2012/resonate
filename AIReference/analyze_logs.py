#!/usr/bin/env python3
"""
iOS App Log Analyzer
Analyzes collected iOS and Flutter logs to identify issues
"""

import os
import re
import sys
from datetime import datetime
from pathlib import Path
from collections import defaultdict
from typing import List, Dict, Tuple

# Configuration
LOG_DIR = Path(__file__).parent.parent / "AIReference" / "debug_logs"
REPORT_DIR = Path(__file__).parent.parent / "AIReference" / "debug_reports"

# ANSI colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class LogAnalyzer:
    def __init__(self, log_dir: Path = LOG_DIR):
        self.log_dir = log_dir
        self.errors = []
        self.warnings = []
        self.fatal_errors = []
        self.debug_info = []
        
    def print_color(self, color: str, message: str):
        """Print colored message"""
        print(f"{color}{message}{Colors.NC}")
    
    def print_section(self, title: str):
        """Print section header"""
        print(f"\n{Colors.CYAN}{'='*80}{Colors.NC}")
        print(f"{Colors.CYAN}{title}{Colors.NC}")
        print(f"{Colors.CYAN}{'='*80}{Colors.NC}\n")
    
    def find_latest_logs(self) -> List[Path]:
        """Find the most recent log files"""
        log_files = {
            'ios': list(self.log_dir.glob("ios_log_*.log")),
            'flutter': list(self.log_dir.glob("flutter_log_*.log")),
            'build': list(self.log_dir.glob("build_*.log")),
            'session': list(self.log_dir.glob("session_*.log")),
        }
        
        latest_logs = {}
        for log_type, files in log_files.items():
            if files:
                # Sort by modification time and get the latest
                latest = max(files, key=lambda f: f.stat().st_mtime)
                latest_logs[log_type] = latest
        
        return latest_logs
    
    def analyze_log_file(self, file_path: Path) -> Dict[str, List[str]]:
        """Analyze a log file and categorize messages"""
        if not file_path.exists():
            return {'errors': [], 'warnings': [], 'fatal': [], 'info': []}
        
        categories = {
            'errors': [],
            'warnings': [],
            'fatal': [],
            'info': []
        }
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    line_lower = line.lower()
                    
                    # Fatal errors
                    if any(keyword in line_lower for keyword in ['fatal', 'crash', 'assertion failure']):
                        categories['fatal'].append(line.strip())
                    
                    # Errors
                    elif any(keyword in line_lower for keyword in ['error', 'exception', 'failed']):
                        categories['errors'].append(line.strip())
                    
                    # Warnings
                    elif any(keyword in line_lower for keyword in ['warning', 'warn']):
                        categories['warnings'].append(line.strip())
                    
                    # Info (debug messages, lifecycle events)
                    elif any(keyword in line_lower for keyword in ['lifecycle', 'build', 'state', 'debug']):
                        categories['info'].append(line.strip())
        
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")
        
        return categories
    
    def identify_issues(self, log_files: Dict[str, Path]) -> List[Dict]:
        """Identify specific issues from logs"""
        issues = []
        
        # Analyze iOS log
        if 'ios' in log_files:
            ios_categories = self.analyze_log_file(log_files['ios'])
            
            # Xcode module errors
            for line in ios_categories['errors']:
                if 'Could not build module' in line:
                    issues.append({
                        'type': 'XCODE_MODULE_ERROR',
                        'severity': 'HIGH',
                        'description': 'Xcode module build failure',
                        'log_line': line,
                        'suggestion': 'Clean DerivedData: rm -rf ~/Library/Developer/Xcode/DerivedData'
                    })
                
                # Missing plugin
                if 'MissingPluginException' in line:
                    issues.append({
                        'type': 'MISSING_PLUGIN',
                        'severity': 'HIGH',
                        'description': 'Missing Flutter plugin',
                        'log_line': line,
                        'suggestion': 'Check pubspec.yaml and run: cd ios && pod install'
                    })
                
                # Symbol not found
                if 'Symbol not found' in line or 'Undefined symbol' in line:
                    issues.append({
                        'type': 'LINKER_ERROR',
                        'severity': 'MEDIUM',
                        'description': 'Linker error - missing symbol',
                        'log_line': line,
                        'suggestion': 'Clean rebuild: flutter clean && flutter build ios'
                    })
        
        # Analyze Flutter log
        if 'flutter' in log_files:
            flutter_categories = self.analyze_log_file(log_files['flutter'])
            
            # Framework errors
            for line in flutter_categories['fatal']:
                issues.append({
                    'type': 'FLUTTER_FATAL',
                    'severity': 'CRITICAL',
                    'description': 'Flutter framework fatal error',
                    'log_line': line,
                    'suggestion': 'Check widget tree and state management'
                })
        
        # Analyze build log
        if 'build' in log_files:
            build_categories = self.analyze_log_file(log_files['build'])
            
            # Build failures
            for line in build_categories['errors']:
                if 'Build failed' in line or 'Compilation failed' in line:
                    issues.append({
                        'type': 'BUILD_FAILURE',
                        'severity': 'CRITICAL',
                        'description': 'Build compilation failed',
                        'log_line': line,
                        'suggestion': 'Check for syntax errors and dependencies'
                    })
        
        return issues
    
    def generate_report(self, log_files: Dict[str, Path]) -> str:
        """Generate analysis report"""
        report_lines = []
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        report_lines.append(f"# iOS App Log Analysis Report")
        report_lines.append(f"\n**Generated:** {timestamp}\n")
        
        # Log file information
        report_lines.append("## Analyzed Log Files\n")
        for log_type, path in log_files.items():
            if path.exists():
                size = path.stat().st_size
                modified = datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")
                report_lines.append(f"- **{log_type.upper()} Log:** `{path.name}`")
                report_lines.append(f"  - Size: {size} bytes")
                report_lines.append(f"  - Modified: {modified}\n")
        
        # Analyze issues
        self.print_section("Identifying Issues...")
        issues = self.identify_issues(log_files)
        
        if issues:
            report_lines.append("## Issues Found\n")
            for idx, issue in enumerate(issues, 1):
                severity_colors = {
                    'CRITICAL': Colors.RED,
                    'HIGH': Colors.RED,
                    'MEDIUM': Colors.YELLOW,
                    'LOW': Colors.BLUE
                }
                color = severity_colors.get(issue['severity'], Colors.NC)
                
                report_lines.append(f"### Issue {idx}: {issue['description']}")
                report_lines.append(f"- **Type:** `{issue['type']}`")
                report_lines.append(f"- **Severity:** {issue['severity']}")
                report_lines.append(f"- **Suggestion:** {issue['suggestion']}")
                report_lines.append(f"- **Log:** `{issue['log_line'][:100]}...`\n")
                
                self.print_color(color, f"Issue {idx}: {issue['description']}")
                print(f"  Type: {issue['type']}")
                print(f"  Severity: {issue['severity']}")
                print(f"  Suggestion: {issue['suggestion']}")
                print()
        else:
            report_lines.append("## Issues Found\n")
            report_lines.append("✅ No critical issues detected in logs.\n")
            self.print_color(Colors.GREEN, "✅ No critical issues detected")
        
        # Summary statistics
        report_lines.append("## Log Statistics\n")
        for log_type, path in log_files.items():
            if path.exists():
                categories = self.analyze_log_file(path)
                report_lines.append(f"### {log_type.upper()} Log\n")
                report_lines.append(f"- Fatal Errors: {len(categories['fatal'])}")
                report_lines.append(f"- Errors: {len(categories['errors'])}")
                report_lines.append(f"- Warnings: {len(categories['warnings'])}")
                report_lines.append(f"- Info: {len(categories['info'])}\n")
        
        # Save report
        report_content = '\n'.join(report_lines)
        timestamp_str = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_path = REPORT_DIR / f"analysis_report_{timestamp_str}.md"
        
        os.makedirs(REPORT_DIR, exist_ok=True)
        with open(report_path, 'w') as f:
            f.write(report_content)
        
        self.print_section("Report Generated")
        self.print_color(Colors.GREEN, f"Report saved to: {report_path}")
        
        return report_content
    
    def show_app_logs(self, log_files: Dict[str, Path], lines: int = 50):
        """Display recent app logs"""
        self.print_section("Recent App Logs")
        
        for log_type, path in log_files.items():
            if path.exists():
                self.print_color(Colors.BLUE, f"\n--- {log_type.upper()} Log (last {lines} lines) ---\n")
                
                try:
                    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                        log_lines = f.readlines()
                        for line in log_lines[-lines:]:
                            print(line.rstrip())
                except Exception as e:
                    self.print_color(Colors.RED, f"Error reading {log_type} log: {e}")

def main():
    """Main execution"""
    analyzer = LogAnalyzer()
    
    print(f"\n{Colors.CYAN}{'='*80}{Colors.NC}")
    print(f"{Colors.CYAN}iOS App Log Analyzer{Colors.NC}")
    print(f"{Colors.CYAN}{'='*80}{Colors.NC}\n")
    
    # Find latest logs
    analyzer.print_color(Colors.BLUE, "Finding latest log files...")
    log_files = analyzer.find_latest_logs()
    
    if not log_files:
        analyzer.print_color(Colors.YELLOW, "No log files found. Run debug_ios_app.sh first.")
        sys.exit(1)
    
    analyzer.print_color(Colors.GREEN, f"Found {len(log_files)} log file(s) to analyze")
    
    # Generate report
    report = analyzer.generate_report(log_files)
    
    # Option to show logs
    print("\n" + "-" * 80)
    response = input("Show recent app logs? (y/n): ").strip().lower()
    if response == 'y':
        analyzer.show_app_logs(log_files)

if __name__ == '__main__':
    main()
