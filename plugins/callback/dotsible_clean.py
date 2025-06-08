# -*- coding: utf-8 -*-
# Copyright: (c) 2024, Dotsible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    name: dotsible_clean
    type: stdout
    short_description: Clean output callback for dotsible
    description:
        - This callback provides clean, readable output for dotsible deployments
        - Shows clear status indicators and progress tracking
        - Reduces verbose output while maintaining essential information
    version_added: "2.0"
    requirements:
      - set as stdout in configuration
'''

from ansible.plugins.callback import CallbackBase

# Simple color class for output formatting
class SimpleColor:
    @staticmethod
    def colorize(text, color_name):
        """Simple colorization - just return text for now"""
        return text

    # Color constants (not used for actual coloring in this simple version)
    CYAN = 'cyan'
    GREEN = 'green'
    RED = 'red'
    YELLOW = 'yellow'
    HEADER = 'header'
    WHITE = 'white'

COLOR = SimpleColor()

class CallbackModule(CallbackBase):
    '''
    This callback module provides clean output for dotsible deployments
    '''
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'dotsible_clean'

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.task_start_time = None
        self.play_start_time = None
        self.current_play = None
        self.task_counter = 0
        self.play_counter = 0
        self.total_tasks = 0
        self.completed_tasks = 0
        self.failed_tasks = 0
        self.changed_tasks = 0
        self.skipped_tasks = 0
        self.status_messages = []
        self.current_role = None
        self.package_status = {}
        self.error_log = []  # Store detailed error information
        self._setup_error_logging()

    def _setup_error_logging(self):
        """Setup error logging to file"""
        import os
        import datetime

        # Create dotsible log directory
        log_dir = os.path.expanduser("~/.dotsible")
        os.makedirs(log_dir, exist_ok=True)

        # Create error log file with timestamp
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        self.error_log_file = os.path.join(log_dir, f"error_details_{timestamp}.log")

    def _log_error_to_file(self, task_name, error_details):
        """Log detailed error information to file"""
        import datetime

        try:
            with open(self.error_log_file, 'a') as f:
                timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                f.write(f"\n{'='*80}\n")
                f.write(f"TIMESTAMP: {timestamp}\n")
                f.write(f"TASK: {task_name}\n")
                f.write(f"{'='*80}\n")
                f.write(f"{error_details}\n")
        except Exception as e:
            # Don't let logging errors break the callback
            pass

    def _get_status_icon(self, status):
        """Get appropriate icon for status"""
        icons = {
            'ok': '✅',
            'changed': '🔄',
            'failed': '❌',
            'skipped': '⏭️',
            'unreachable': '🚫',
            'rescued': '🔧',
            'ignored': '⚠️',
            'installed': '✅',
            'missing': '❌',
            'working': '🔄'
        }
        return icons.get(status.lower(), '•')

    def _colorize(self, text, color=None):
        """Colorize text if color is enabled"""
        # For now, just return text without coloring
        return text

    def _print_clean(self, msg, color=None):
        """Print message with optional color"""
        if color:
            msg = self._colorize(msg, color)
        print(msg)

    def _is_status_task(self, task_name):
        """Check if this is a status/display task"""
        status_keywords = [
            'display', 'show', 'status', 'inventory', 'banner', 
            'completed', 'summary', 'verification', 'check'
        ]
        return any(keyword in task_name.lower() for keyword in status_keywords)

    def _is_package_task(self, task_name):
        """Check if this is a package-related task"""
        package_keywords = [
            'homebrew', 'brew', 'apt', 'pacman', 'scoop', 'chocolatey',
            'npm', 'pip', 'pipx', 'package', 'install'
        ]
        return any(keyword in task_name.lower() for keyword in package_keywords)

    def _extract_package_status(self, result):
        """Extract package status from task result"""
        if hasattr(result, '_result') and 'msg' in result._result:
            msg = result._result['msg']
            if ':' in msg and ('INSTALLED' in msg or 'MISSING' in msg):
                parts = msg.split(':')
                if len(parts) >= 2:
                    package = parts[0].strip()
                    status = parts[1].strip()
                    return package, status
        return None, None

    def v2_playbook_on_start(self, playbook=None):
        """Called when playbook starts"""
        self._print_clean("\n" + "="*70, COLOR.CYAN)
        self._print_clean("🚀 DOTSIBLE DEPLOYMENT STARTING", COLOR.CYAN)
        self._print_clean("="*70, COLOR.CYAN)

    def v2_playbook_on_play_start(self, play):
        """Called when play starts"""
        self.current_play = play.get_name()
        self.play_counter += 1
        
        # Extract meaningful play names
        play_name = self.current_play
        if "Pre-Flight" in play_name:
            display_name = "🔍 System Validation"
        elif "Platform-Specific" in play_name:
            display_name = "🔧 Platform Configuration"
        elif "Application" in play_name:
            display_name = "📱 Application Setup"
        elif "Profile-Specific" in play_name:
            display_name = "👤 Profile Configuration"
        elif "Final" in play_name:
            display_name = "🏁 Final Setup"
        else:
            display_name = f"📋 {play_name}"
            
        self._print_clean(f"\n{display_name}", COLOR.HEADER)
        self._print_clean("-" * 50, COLOR.CYAN)

    def v2_playbook_on_task_start(self, task, is_conditional=False):
        """Called when task starts"""
        self.task_counter += 1
        task_name = task.get_name()
        
        # Skip verbose output for certain tasks
        if self._is_status_task(task_name):
            return
            
        # Show progress for important tasks
        if any(keyword in task_name.lower() for keyword in ['install', 'configure', 'setup', 'create']):
            self._print_clean(f"  🔄 {task_name}", COLOR.CYAN)

    def v2_runner_on_ok(self, result):
        """Called when task succeeds"""
        task_name = result._task.get_name()
        
        # Handle package status display tasks
        if 'status' in task_name.lower() and 'package' in task_name.lower():
            package, status = self._extract_package_status(result)
            if package and status:
                icon = self._get_status_icon('installed' if 'INSTALLED' in status else 'missing')
                color = COLOR.GREEN if 'INSTALLED' in status else COLOR.YELLOW
                self._print_clean(f"    {icon} {package}: {status}", color)
                return

        # Handle banner/summary tasks
        if self._is_status_task(task_name):
            if hasattr(result, '_result') and 'msg' in result._result:
                msg = result._result['msg']
                if '===' in msg or '✅' in msg:
                    # This is a summary or completion message
                    lines = msg.split('\n')
                    for line in lines:
                        if line.strip():
                            if '✅' in line or 'completed' in line.lower():
                                self._print_clean(f"  {line.strip()}", COLOR.GREEN)
                            elif line.startswith('•') or line.startswith('-'):
                                self._print_clean(f"    {line.strip()}", COLOR.WHITE)
            return

        # Handle regular successful tasks
        if result._result.get('changed', False):
            self.changed_tasks += 1
            if not self._is_status_task(task_name):
                self._print_clean(f"    ✅ {task_name}", COLOR.GREEN)
        else:
            if not self._is_status_task(task_name) and not 'check' in task_name.lower():
                self._print_clean(f"    ✅ {task_name} (no change needed)", COLOR.GREEN)

    def v2_runner_on_failed(self, result, ignore_errors=False):
        """Called when task fails"""
        task_name = result._task.get_name()
        self.failed_tasks += 1

        if ignore_errors:
            self._print_clean(f"    ⚠️  {task_name} (ignored)", COLOR.YELLOW)
        else:
            self._print_clean(f"    ❌ {task_name}", COLOR.RED)

            # Enhanced error reporting
            error_details = []
            if hasattr(result, '_result'):
                result_data = result._result

                # Show main error message
                if 'msg' in result_data:
                    error_msg = result_data['msg']
                    self._print_clean(f"       Error: {error_msg}", COLOR.RED)
                    error_details.append(f"Main Error: {error_msg}")

                # Show specific failure details for loops
                if 'results' in result_data:
                    failed_items = []
                    for item_result in result_data['results']:
                        if item_result.get('failed', False):
                            item_name = item_result.get('item', {})
                            if isinstance(item_name, dict):
                                item_name = item_name.get('item', str(item_name))

                            item_error = item_result.get('msg', 'Unknown error')
                            item_stderr = item_result.get('stderr', '')
                            item_stdout = item_result.get('stdout', '')

                            failed_items.append(f"{item_name}: {item_error}")

                            # Add detailed info to error log
                            error_details.append(f"Failed Item: {item_name}")
                            error_details.append(f"  Error: {item_error}")
                            if item_stderr:
                                error_details.append(f"  stderr: {item_stderr}")
                            if item_stdout:
                                error_details.append(f"  stdout: {item_stdout}")

                    if failed_items:
                        self._print_clean(f"       Failed items:", COLOR.RED)
                        for failed_item in failed_items[:5]:  # Limit to first 5 failures
                            self._print_clean(f"         • {failed_item}", COLOR.RED)
                        if len(failed_items) > 5:
                            self._print_clean(f"         ... and {len(failed_items) - 5} more", COLOR.RED)
                            self._print_clean(f"         📝 See ~/.dotsible/error_details_*.log for full details", COLOR.YELLOW)

                # Show stderr if available
                if 'stderr' in result_data and result_data['stderr']:
                    stderr_lines = result_data['stderr'].strip().split('\n')
                    self._print_clean(f"       stderr:", COLOR.RED)
                    for line in stderr_lines[:3]:  # Show first 3 lines of stderr
                        if line.strip():
                            self._print_clean(f"         {line.strip()}", COLOR.RED)
                    if len(stderr_lines) > 3:
                        self._print_clean(f"         ... ({len(stderr_lines) - 3} more lines)", COLOR.RED)
                    error_details.append(f"stderr: {result_data['stderr']}")

                # Show stdout if available and different from msg
                if 'stdout' in result_data and result_data['stdout'] and result_data['stdout'] != result_data.get('msg', ''):
                    stdout_lines = result_data['stdout'].strip().split('\n')
                    self._print_clean(f"       stdout:", COLOR.RED)
                    for line in stdout_lines[:2]:  # Show first 2 lines of stdout
                        if line.strip():
                            self._print_clean(f"         {line.strip()}", COLOR.RED)
                    error_details.append(f"stdout: {result_data['stdout']}")

                # Show return code if available
                if 'rc' in result_data and result_data['rc'] != 0:
                    self._print_clean(f"       Return code: {result_data['rc']}", COLOR.RED)
                    error_details.append(f"Return code: {result_data['rc']}")

                # Log full error details to file
                if error_details:
                    full_error_log = "\n".join(error_details)
                    self._log_error_to_file(task_name, full_error_log)

    def v2_runner_on_skipped(self, result):
        """Called when task is skipped"""
        task_name = result._task.get_name()
        self.skipped_tasks += 1
        
        # Only show skipped tasks for important operations
        if any(keyword in task_name.lower() for keyword in ['install', 'configure', 'platform']):
            self._print_clean(f"    ⏭️  {task_name} (skipped)", COLOR.CYAN)

    def v2_runner_on_unreachable(self, result):
        """Called when host is unreachable"""
        task_name = result._task.get_name()
        self._print_clean(f"    🚫 {task_name} (unreachable)", COLOR.RED)

    def v2_playbook_on_stats(self, stats):
        """Called when playbook ends"""
        self._print_clean("\n" + "="*70, COLOR.CYAN)
        self._print_clean("📊 DEPLOYMENT SUMMARY", COLOR.CYAN)
        self._print_clean("="*70, COLOR.CYAN)
        
        for host in stats.processed.keys():
            summary = stats.summarize(host)
            
            total = sum([summary['ok'], summary['changed'], summary['failures'], summary['skipped']])
            
            self._print_clean(f"\nHost: {host}", COLOR.HEADER)
            self._print_clean(f"  ✅ Successful: {summary['ok']}", COLOR.GREEN)
            self._print_clean(f"  🔄 Changed: {summary['changed']}", COLOR.YELLOW)
            self._print_clean(f"  ❌ Failed: {summary['failures']}", COLOR.RED)
            self._print_clean(f"  ⏭️  Skipped: {summary['skipped']}", COLOR.CYAN)
            self._print_clean(f"  📊 Total: {total}", COLOR.WHITE)
            
            if summary['failures'] > 0:
                self._print_clean(f"\n❌ DEPLOYMENT FAILED", COLOR.RED)
                self._print_clean("Check the errors above and retry.", COLOR.RED)
            elif summary['changed'] > 0:
                self._print_clean(f"\n🎉 DEPLOYMENT COMPLETED WITH CHANGES", COLOR.GREEN)
                self._print_clean("Your system has been updated successfully!", COLOR.GREEN)
            else:
                self._print_clean(f"\n✅ DEPLOYMENT COMPLETED - NO CHANGES NEEDED", COLOR.GREEN)
                self._print_clean("Your system is already up to date!", COLOR.GREEN)

        self._print_clean("\n" + "="*70, COLOR.CYAN)

    def v2_playbook_on_no_hosts_matched(self):
        """Called when no hosts match"""
        self._print_clean("❌ No hosts matched. Check your inventory configuration.", COLOR.RED)

    def v2_playbook_on_no_hosts_remaining(self):
        """Called when no hosts remain"""
        self._print_clean("❌ No hosts remaining. All hosts failed or were unreachable.", COLOR.RED)
