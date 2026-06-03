import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/amal_controller.dart';
import '../models/amal_model.dart'; // নিশ্চিত করুন এই ফাইলে সঠিক মডেল ক্লাস আছে

class AmalTrackerHome extends StatelessWidget {
  const AmalTrackerHome({super.key});

  // কন্সট্যান্ট কালার প্যালেট
  static const Color _bg = Color(0xFF0A0F0F);
  static const Color _surface = Color(0xFF111A1A);
  static const Color _surfaceHigh = Color(0xFF182222);
  static const Color _teal = Color(0xFF12E5A0);
  static const Color _tealDark = Color(0xFF0A7A55);
  static const Color _tealMid = Color(0xFF0CBF82);
  static const Color _gold = Color(0xFFFFBD3E);
  static const Color _textPri = Color(0xFFECF4F3);
  static const Color _textSec = Color(0xFF7EA89F);
  static const Color _textMuted = Color(0xFF3D5C56);
  static const Color _divider = Color(0xFF1E3232);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AmalController>(context, listen: true);

    // সপ্তাহের দিনগুলো ক্যালকুলেট করা (সোমবার থেকে শুরু)
    final monday = controller.selectedDate
        .subtract(Duration(days: controller.selectedDate.weekday - 1));
    final List<DateTime> weekDays =
        List.generate(7, (i) => monday.add(Duration(days: i)));
    
    final List<String> bnWeekdays = [
      'সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি', 'রবি'
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: _bg,
            pinned: true,
            elevation: 0,
            expandedHeight: 100,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 14),
              title: const Text(
                'আমল ট্র্যাকার',
                style: TextStyle(
                  color: _textPri,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D1E1E), _bg],
                  ),
                ),
              ),
            ),
            actions: [
              _GlassButton(
                icon: Icons.calendar_month_rounded,
                onTap: () => _showDatePickerPopup(context, controller),
              ),
              const SizedBox(width: 12),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text(
                    controller.formattedDate,
                    style: const TextStyle(
                      color: _textSec,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 82,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final day = weekDays[index];
                      final isSelected = DateUtils.isSameDay(day, controller.selectedDate);

                      return GestureDetector(
                        onTap: () => controller.changeDate(day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: (MediaQuery.of(context).size.width - 32) / 7,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: isSelected
                                ? _tealDark.withValues(alpha: 0.55)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? _tealMid : Colors.transparent,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _teal.withValues(alpha: 0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                bnWeekdays[index],
                                style: TextStyle(
                                  color: isSelected ? _teal : _textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: isSelected ? _teal : _textSec,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                
                // কাস্টম টাস্ক বাটন - বাম পাশে, বক্স ছাড়া
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Tooltip(
                    message: 'আপনার নিজের মতো করে নতুন আমল যুক্ত করুন',
                    preferBelow: false,
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      color: Color(0xFF061A14),
                      fontWeight: FontWeight.w600,
                    ),
                    child: GestureDetector(
                      onTap: () => _showAddCustomTaskBottomSheet(context, controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _teal.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: _teal,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'কাস্টম টাস্ক যুক্ত করুন',
                                  style: TextStyle(
                                    color: _teal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'নিজের ইবাদত ও সময় যুক্ত করুন',
                                  style: TextStyle(
                                    color: _textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ProgressBanner(controller: controller),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _teal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'আমলের তালিকা',
                        style: TextStyle(
                          color: _textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = controller.categories[index];
                return _CategoryCard(
                  category: category,
                  controller: controller,
                );
              },
              childCount: controller.categories.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showDatePickerPopup(BuildContext context, AmalController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => _DatePickerDialog(controller: controller),
    );
  }

  // ঘড়িকে English AM/PM মোডে দেখানোর জন্য হেল্পার মেথড
  Future<TimeOfDay?> _pickTimeEnglish(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // force 12-hour AM/PM format overriding system locale
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: _teal,
                onPrimary: Color(0xFF061A14),
                surface: _surfaceHigh,
                onSurface: _textPri,
              ),
              timePickerTheme: const TimePickerThemeData(
                dayPeriodTextColor: _textPri,
                dayPeriodColor: _tealDark,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  void _showAddCustomTaskBottomSheet(BuildContext context, AmalController controller) {
    final titleController = TextEditingController();
    TimeOfDay? start;
    TimeOfDay? end;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24, left: 24, right: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'নতুন কাস্টম টাস্ক যুক্ত করুন',
                    style: TextStyle(color: _textPri, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      hintText: 'যেমন: কুরআন তিলাওয়াত, বই পড়া...',
                      hintStyle: const TextStyle(color: _textMuted),
                      filled: true,
                      fillColor: _surfaceHigh,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _teal),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'সময়সীমা নির্ধারণ করুন',
                    style: TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  
                  // ইন-লাইন সহজ টাইমলাইন ইন্টারফেস
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () async {
                            final picked = await _pickTimeEnglish(context);
                            if (picked != null) setModalState(() => start = picked);
                          },
                          child: Column(
                            children: [
                              const Text('শুরুর সময়', style: TextStyle(color: _textMuted, fontSize: 11)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_filled_rounded, size: 16, color: _teal),
                                  const SizedBox(width: 6),
                                  Text(
                                    start == null ? '-- : --' : start!.format(context),
                                    style: TextStyle(color: start == null ? _textSec : _textPri, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: _textMuted, size: 20),
                        InkWell(
                          onTap: () async {
                            final picked = await _pickTimeEnglish(context);
                            if (picked != null) setModalState(() => end = picked);
                          },
                          child: Column(
                            children: [
                              const Text('শেষের সময়', style: TextStyle(color: _textMuted, fontSize: 11)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.assignment_turned_in_rounded, size: 16, color: _gold),
                                  const SizedBox(width: 6),
                                  Text(
                                    end == null ? '-- : --' : end!.format(context),
                                    style: TextStyle(color: end == null ? _textSec : _textPri, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final taskTitle = titleController.text.trim();
                        if (taskTitle.isEmpty || start == null || end == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('অনুগ্রহ করে সবগুলো তথ্য পূরণ করুন।'))
                          );
                          return;
                        }

                        // ইন্টারনাল ডাটাবেজে সেভ করার জন্য ২৪ ঘণ্টার ফরম্যাট জেনারেট করা
                        final startStr = '${start!.hour.toString().padLeft(2, '0')}:${start!.minute.toString().padLeft(2, '0')}';
                        final endStr = '${end!.hour.toString().padLeft(2, '0')}:${end!.minute.toString().padLeft(2, '0')}';

                        final error = await controller.addCustomTask(taskTitle, startStr, endStr);
                        if (context.mounted) {
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(backgroundColor: Colors.redAccent, content: Text(error))
                            );
                          } else {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('টাস্কটি সফলভাবে যুক্ত হয়েছে!'))
                            );
                          }
                        }
                      },
                      child: const Text('নিশ্চিত করুন', style: TextStyle(color: Color(0xFF061A14), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF1A2E2E),
          border: Border.all(color: const Color(0xFF243E3E), width: 1),
        ),
        child: Icon(icon, color: AmalTrackerHome._textSec, size: 18),
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.controller});
  final AmalController controller;

  @override
  Widget build(BuildContext context) {
    final pct = controller.completionPercentage;
    final done = controller.completedTasks;
    final total = controller.totalTasks;
    final isComplete = pct >= 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152525), Color(0xFF0F1E1E)],
        ),
        border: Border.all(
          color: isComplete ? AmalTrackerHome._teal.withValues(alpha: 0.4) : AmalTrackerHome._divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 5,
                      backgroundColor: AmalTrackerHome._divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete ? AmalTrackerHome._teal : AmalTrackerHome._gold,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${(pct * 100).toInt()}%',
                      style: TextStyle(
                        color: isComplete ? AmalTrackerHome._teal : AmalTrackerHome._gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? 'মাশাআল্লাহ! সব আমল সম্পন্ন ✨' : 'আজকের আমল ট্র্যাক করুন',
                      style: const TextStyle(color: AmalTrackerHome._textPri, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'বাকি ${total - done}টি আমল',
                      style: const TextStyle(color: AmalTrackerHome._textSec, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(colors: [Color(0xFF9D6A10), Color(0xFF6B4508)]),
                ),
                child: Text(
                  '$done/$total',
                  style: const TextStyle(color: AmalTrackerHome._gold, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AmalTrackerHome._divider,
              valueColor: AlwaysStoppedAnimation<Color>(isComplete ? AmalTrackerHome._teal : AmalTrackerHome._gold),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.controller});
  final dynamic category; 
  final AmalController controller;

  @override
  Widget build(BuildContext context) {
    final tasks = category.tasks as List;
    final doneCount = tasks.where((t) => t.isCompleted == true).length;
    final total = tasks.length;
    final pct = total == 0 ? 0.0 : doneCount / total;
    final isExpanded = category.isExpanded as bool? ?? false;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AmalTrackerHome._surface,
        border: Border.all(
          color: (category.isCustomCategory as bool? ?? false) 
              ? AmalTrackerHome._teal.withValues(alpha: 0.3) 
              : AmalTrackerHome._divider, 
          width: 1
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.toggleCategoryExpansion(category),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pct >= 1.0 ? AmalTrackerHome._teal : AmalTrackerHome._tealDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title as String? ?? '',
                          style: const TextStyle(color: AmalTrackerHome._textPri, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: AmalTrackerHome._divider,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AmalTrackerHome._tealMid),
                                  minHeight: 3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$doneCount/$total',
                              style: const TextStyle(color: AmalTrackerHome._textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AmalTrackerHome._textMuted, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(height: 1, color: AmalTrackerHome._divider),
                ...tasks.map((task) => _TaskRow(task: task, controller: controller)),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 260),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.controller});
  final dynamic task; 
  final AmalController controller;

  @override
  Widget build(BuildContext context) {
    final bool done = task.isCompleted as bool? ?? false;
    final bool isCustom = task.isCustom as bool? ?? false;

    return InkWell(
      onTap: () async {
        final String? error = await controller.toggleTask(task);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(error, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                backgroundColor: const Color(0xFFB03030),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: done ? AmalTrackerHome._tealDark.withValues(alpha: 0.5) : AmalTrackerHome._surfaceHigh,
                border: Border.all(color: done ? AmalTrackerHome._tealMid.withValues(alpha: 0.5) : AmalTrackerHome._divider),
              ),
              child: Icon(
                isCustom ? Icons.star_border_rounded : Icons.wb_twilight_rounded,
                size: 15,
                color: done ? AmalTrackerHome._teal : AmalTrackerHome._textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title as String? ?? '',
                    style: TextStyle(
                      color: done ? AmalTrackerHome._textMuted : AmalTrackerHome._textSec,
                      fontSize: 13,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (isCustom && task.startTime != null && task.endTime != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'সময়: ${task.startTime} - ${task.endTime}',
                      style: const TextStyle(color: AmalTrackerHome._gold, fontSize: 10),
                    )
                  ]
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AmalTrackerHome._teal : Colors.transparent,
                border: Border.all(color: done ? AmalTrackerHome._teal : AmalTrackerHome._textMuted.withValues(alpha: 0.4)),
              ),
              child: done ? const Icon(Icons.check_rounded, color: Color(0xFF061A14), size: 15) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerDialog extends StatelessWidget {
  const _DatePickerDialog({required this.controller});
  final AmalController controller;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF141F1F),
          border: Border.all(color: AmalTrackerHome._divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('তারিখ নির্বাচন', style: TextStyle(color: AmalTrackerHome._textPri, fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    controller.changeDate(DateTime.now());
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AmalTrackerHome._tealDark.withValues(alpha: 0.4), 
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('আজ', style: TextStyle(color: AmalTrackerHome._teal, fontSize: 11)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AmalTrackerHome._teal,
                  onPrimary: Color(0xFF061A14),
                  surface: Color(0xFF141F1F),
                  onSurface: AmalTrackerHome._textPri,
                ),
              ),
              child: SizedBox(
                height: 260,
                width: 300,
                child: CalendarDatePicker(
                  initialDate: controller.selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    controller.changeDate(date);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}