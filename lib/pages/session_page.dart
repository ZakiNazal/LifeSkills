import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/session.dart';
import '../data/stats_service.dart';
import '../theme/app_text.dart';
import '../widgets/app_snack.dart';

class SessionPage extends StatefulWidget {
  final SessionPlan plan;

  const SessionPage({super.key, required this.plan});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  Timer? _ticker;
  int _stepIndex = 0;
  late int _remaining = widget.plan.steps.first.seconds;
  bool _paused = false;
  bool _saving = false;
  bool _saveFailed = false;
  SessionResult? _result;

  SessionPlan get _plan => widget.plan;
  SessionStep get _step => _plan.steps[_stepIndex];
  bool get _onLastStep => _stepIndex == _plan.steps.length - 1;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused || _result != null) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        _advance(auto: true);
      }
    });
  }

  void _advance({bool auto = false}) {
    if (_onLastStep) {
      _finish();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _stepIndex++;
      _remaining = _step.seconds;
    });
    if (!auto) _startTicker();
  }

  void _restartStep() {
    HapticFeedback.selectionClick();
    setState(() => _remaining = _step.seconds);
    _startTicker();
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() => _paused = !_paused);
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    if (_saving || _result != null) return;
    setState(() => _saving = true);
    HapticFeedback.heavyImpact();
    try {
      final result = await StatsService.completeSession(points: _plan.points);
      if (!mounted) return;
      setState(() {
        _result = result;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      // The work still happened, so show the summary rather than dropping the
      // user back to the list with nothing to show for it.
      setState(() {
        _saving = false;
        _saveFailed = true;
        _result = SessionResult(
          pointsEarned: _plan.points,
          streak: 0,
          sessionsToday: 0,
          dailyGoal: 0,
        );
      });
      showSnack(context, 'Could not reach your profile to save this',
          isError: true);
    }
  }

  Future<void> _confirmExit() async {
    final leave = await confirm(
      context,
      title: 'End session?',
      message: 'You are partway through. Nothing gets counted if you leave now.',
      confirmLabel: 'End session',
      destructive: true,
    );
    if (leave && mounted) Navigator.of(context).pop();
  }

  double get _overallProgress {
    var elapsed = 0;
    for (var i = 0; i < _stepIndex; i++) {
      elapsed += _plan.steps[i].seconds;
    }
    elapsed += _step.seconds - _remaining;
    final total = _plan.totalSeconds;
    return total == 0 ? 0 : (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final color = _plan.color;
    final done = _result != null;

    return PopScope<Object?>(
      canPop: done,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit();
      },
      child: Scaffold(
        backgroundColor: color.solid,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: done ? _summary(context) : _runner(context),
          ),
        ),
      ),
    );
  }

  Widget _runner(BuildContext context) {
    const onColor = Colors.white;

    return Column(
      key: const ValueKey('runner'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: _confirmExit,
                icon: const Icon(Icons.close, color: onColor, size: 22),
              ),
              const Spacer(),
              Text(
                '${_stepIndex + 1} / ${_plan.steps.length}',
                style: AppText.label.copyWith(
                  color: onColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _overallProgress,
              minHeight: 3,
              backgroundColor: onColor.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(onColor),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _plan.title.toUpperCase(),
                  style: AppText.overline.copyWith(
                    color: onColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _step.title,
                  style: AppText.h1.copyWith(fontSize: 30, color: onColor),
                ),
                const SizedBox(height: 12),
                Text(
                  _step.detail,
                  style: AppText.body.copyWith(
                    fontSize: 16,
                    color: onColor.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 44),
                Center(
                  child: AnimatedOpacity(
                    opacity: _paused ? 0.55 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      formatClock(_remaining),
                      style: AppText.display.copyWith(
                        fontSize: 78,
                        letterSpacing: -3,
                        color: onColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _paused ? 'PAUSED' : 'REMAINING',
                    style: AppText.overline.copyWith(
                      color: onColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleButton(
                icon: Icons.restart_alt,
                onTap: _restartStep,
                label: 'Restart',
              ),
              _primaryButton(),
              _circleButton(
                icon: _onLastStep ? Icons.done_all : Icons.skip_next,
                onTap: () => _advance(),
                label: _onLastStep ? 'Finish' : 'Skip',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _primaryButton() {
    final color = _plan.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _saving ? null : _togglePause,
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _saving
                ? Padding(
                    padding: const EdgeInsets.all(28),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: color.solid,
                    ),
                  )
                : Icon(
                    _paused ? Icons.play_arrow : Icons.pause,
                    size: 34,
                    color: color.solid,
                  ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          _paused ? 'RESUME' : 'PAUSE',
          style: AppText.overline.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 23, color: Colors.white),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label.toUpperCase(),
          style: AppText.overline.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final result = _result!;
    final color = _plan.color;
    const onColor = Colors.white;

    return Padding(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: onColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 28, color: onColor),
          ),
          const SizedBox(height: 26),
          Text(
            result.goalMet && !_saveFailed
                ? 'Daily goal met'
                : 'Session complete',
            style: AppText.display.copyWith(fontSize: 38, color: onColor),
          ),
          const SizedBox(height: 12),
          Text(
            '${_plan.title}  ·  ${_plan.lengthLabel}',
            style: AppText.body.copyWith(
              color: onColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          if (_saveFailed)
            _summaryRow('Not saved', 'offline')
          else ...[
            _summaryRow('Points earned', '+${result.pointsEarned}'),
            _summaryRow('Day streak', '${result.streak}'),
            _summaryRow(
              'Today',
              '${result.sessionsToday} of ${result.dailyGoal}',
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: onColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).pop(),
                child: Center(
                  child: Text(
                    'Done',
                    style: AppText.button.copyWith(color: color.solid),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    const onColor = Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppText.overline.copyWith(
                  color: onColor.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: AppText.h2.copyWith(color: onColor),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Divider(height: 1, color: onColor.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}
