import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDateRangePicker({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;

  // Selection Mode: 0 = Start Date, 1 = End Date
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            // Tabs
            Row(
              children: [
                Expanded(child: _buildTab("Desde", _startDate, 0)),
                Expanded(child: _buildTab("Hasta", _endDate, 1)),
              ],
            ),
            const Divider(color: Colors.white10),

            Expanded(
              child: _DateSelector(
                key: ValueKey("selector_$_tabIndex"),

                focusedDate: _tabIndex == 0 ? _startDate : _endDate,
                startDate: _startDate,
                endDate: _endDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onChanged: (newDate) {
                  setState(() {
                    if (_tabIndex == 0) {
                      // Selecting Start Date
                      _startDate = newDate;
                      // Smart Flow: Reset end date to start date to start a fresh range selection from here.
                      // This avoids jumping to an old end date 3 months away.
                      _endDate = newDate;
                      // Auto-advance to End selection
                      _tabIndex = 1;
                    } else {
                      // Selecting End Date
                      if (newDate.isBefore(_startDate)) {
                        // If selected date is before start, treating it as a correction of Start Date
                        _startDate = newDate;
                        _endDate = newDate;
                        // Keep focus on End tab to allow finishing the range immediately
                      } else {
                        _endDate = newDate;
                        // Range completed
                      }
                    }
                  });
                },
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: AppTheme.textSubtle),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTimeRange(start: _startDate, end: _endDate),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Aplicar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, DateTime date, int index) {
    final isSelected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textAccent.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppTheme.textAccent) : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
              style: TextStyle(
                color: isSelected ? AppTheme.textAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatefulWidget {
  final DateTime focusedDate;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _DateSelector({
    super.key,
    required this.focusedDate,
    required this.startDate,
    required this.endDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  State<_DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<_DateSelector> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.focusedDate.year;
    _month = widget.focusedDate.month;
  }

  @override
  void didUpdateWidget(covariant _DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDate != oldWidget.focusedDate) {
      // Only jump if year/month drastically different?
      // Or just respect parent's wish to focus.
      _year = widget.focusedDate.year;
      _month = widget.focusedDate.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Dropdowns Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Month Dropdown
            _buildDropdown(
              value: _month,
              items: List.generate(12, (i) => i + 1),
              labelBuilder: (m) => _monthName(m),
              onChanged: (val) {
                if (val != null) setState(() => _month = val);
              },
            ),
            const SizedBox(width: 12),
            // Year Dropdown
            _buildDropdown(
              value: _year,
              items: List.generate(
                widget.lastDate.year - widget.firstDate.year + 1,
                (i) => widget.lastDate.year - i,
              ),
              labelBuilder: (y) => y.toString(),
              onChanged: (val) {
                if (val != null) setState(() => _year = val);
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Days Grid
        Expanded(child: _buildCalendarGrid()),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: AppTheme.cardBackground,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textAccent),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstDayWeekday = DateTime(_year, _month, 1).weekday; // 1=Mon, 7=Sun
    final offset = firstDayWeekday - 1;

    // Normalize comparison dates
    final start = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
    );
    final end = DateTime(
      widget.endDate.year,
      widget.endDate.month,
      widget.endDate.day,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ["L", "M", "M", "J", "V", "S", "D"]
              .map(
                (d) => Text(
                  d,
                  style: const TextStyle(
                    color: AppTheme.textSubtle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            itemCount: daysInMonth + offset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 0, // Remove spacing for continuous highlight
            ),
            itemBuilder: (ctx, i) {
              if (i < offset) return const SizedBox.shrink();

              final d = i - offset + 1;
              final currentDate = DateTime(_year, _month, d);

              // Logic
              final isStart = _isSameDay(currentDate, start);
              final isEnd = _isSameDay(currentDate, end);
              final isInRange =
                  currentDate.isAfter(start) && currentDate.isBefore(end);
              final isSelected = isStart || isEnd;

              // Advanced Airline Style: Continuous Background Strip + Circle for endpoints
              return InkWell(
                onTap: () {
                  widget.onChanged(currentDate);
                },
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Highlight Strip (Visible if in range or endpoint)
                    if (isInRange || isStart || isEnd)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                          ), // Small vertical gap
                          decoration: BoxDecoration(
                            color: AppTheme.textAccent.withValues(alpha: 0.2),
                            // Rounded corners for range edges
                            borderRadius: BorderRadius.horizontal(
                              left: isStart
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              right: isEnd
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      ),

                    // Foreground Selected Circle (Only Start/End)
                    if (isSelected)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppTheme.textAccent,
                          shape: BoxShape.circle,
                        ),
                      ),

                    Text(
                      "$d",
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isInRange
                                  ? AppTheme.textAccent
                                  : Colors.white70),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthName(int m) {
    const months = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    return months[m - 1];
  }
}
