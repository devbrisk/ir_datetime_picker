import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ir_datetime_picker/src/helpers/date.dart';
import 'package:ir_datetime_picker/src/helpers/print.dart';
import 'package:ir_datetime_picker/src/helpers/responsive.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// * [IRJalaliDatePickerOnSelected] is a callback function that will call when user change cupertino pickers.

typedef IRJalaliDatePickerOnSelected = void Function(Jalali jalaliDate);

/// * You can use [IRJalaliDatePicker] to design your own date pickers.

class IRJalaliDatePicker extends StatefulWidget {
  final Jalali? initialDate;
  final Jalali? startDate;
  final Jalali? endDate;
  final bool visibleTodayButton;
  final bool visibleDays;
  final String todayButtonText;
  final BoxConstraints? constraints;
  final IRJalaliDatePickerOnSelected onSelected;
  final TextStyle? textStyle;
  final double diameterRatio;
  final double magnification;
  final double offAxisFraction;
  final double squeeze;

  const IRJalaliDatePicker({
    super.key,
    this.initialDate,
    this.startDate,
    this.endDate,
    this.visibleTodayButton = true,
    this.visibleDays = true,
    required this.todayButtonText,
    this.constraints,
    required this.onSelected,
    this.textStyle,
    this.diameterRatio = 1.0,
    this.magnification = 1.3,
    this.offAxisFraction = 0.0,
    this.squeeze = 1.3,
  });

  @override
  State<IRJalaliDatePicker> createState() => _IRJalaliDatePickerState();
}

class _IRJalaliDatePickerState extends State<IRJalaliDatePicker> {
  late Jalali _initialDate;
  late Jalali _startDate;
  late Jalali _endDate;
  late bool _refreshCupertinoPickers;
  late final yearScrollController =
      FixedExtentScrollController(initialItem: _years.indexOf(_selectedYear));
  late final monthScrollController = FixedExtentScrollController(
      initialItem: _months.indexOf(IRJalaliDateHelper.getMonthName(monthNumber: _selectedMonth)));
  late final dayScrollController =
      FixedExtentScrollController(initialItem: _days.indexOf(_selectedDay));
  String lastAction = '';
  int _selectedYear = 1400;
  int _selectedMonth = 1;
  int _selectedDay = 1;
  List<int> _years = [];
  List<String> _months = IRJalaliDateHelper.months;
  List<int> _days = [];
  String lastMonth = '';
  int lastDay = 0;

  @override
  void initState() {
    super.initState();
    _initialDate = widget.initialDate ?? Jalali.now();
    _startDate = widget.startDate ?? Jalali.now().addYears(-50);
    _endDate = widget.endDate ?? Jalali.now().addYears(50);
    _refreshCupertinoPickers = false;
    _selectedYear = _initialDate.year;
    _selectedMonth = _initialDate.month;
    _selectedDay = _initialDate.day;
    _years = _yearsList(_startDate.year, _endDate.year);
    lastMonth = IRJalaliDateHelper.getMonthName(monthNumber: _selectedMonth);
    lastDay = _selectedDay;
    checkMinMax();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCupertinoPickers = false;
    });
    BoxConstraints cupertinoPickersConstraints = BoxConstraints.loose(
      Size(100.0.percentOfWidth(context), 30.0.percentOfHeight(context)),
    );
    Widget cupertinoPickers = Directionality(
      textDirection: TextDirection.ltr,
      child: ConstrainedBox(
        constraints: widget.constraints ?? cupertinoPickersConstraints,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context)
              .copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _cupertinoPicker(
                context: context,
                list: _years,
                scrollController: yearScrollController,
                onSelectedItemChanged: (selectedIndex) {
                  setState(() {
                    lastAction = 'year';
                    _selectedYear = _years[selectedIndex];
                    checkMinMax();

                    var realMonthIndex = IRJalaliDateHelper.getMonthNumber(monthName: lastMonth);
                    var monthIndex = _months.indexWhere((el) => el == lastMonth);
                    if (monthIndex >= 0) {
                      monthScrollController.jumpToItem(monthIndex);
                      _selectedMonth = realMonthIndex;
                    } else {
                      final firstIndex = IRJalaliDateHelper.getMonthNumber(monthName: _months[0]);
                      monthIndex = realMonthIndex <= firstIndex ? 0 : _months.length - 1;
                      realMonthIndex =
                          IRJalaliDateHelper.getMonthNumber(monthName: _months[monthIndex]);
                      _selectedMonth = realMonthIndex;
                      monthScrollController.jumpToItem(monthIndex);
                    }
                    checkMinMax();
                    lastAction = 'month';

                    if (widget.visibleDays) {
                      var dayIndex = _days.indexWhere((el) => el == lastDay);
                      if (dayIndex >= 0) {
                        dayScrollController.jumpToItem(dayIndex);
                        _selectedDay = dayIndex + 1;
                      } else {
                        final firstIndex = _days[0];
                        dayIndex = _selectedDay <= firstIndex ? 0 : _days.length - 1;
                        _selectedDay = dayIndex + 1;
                        dayScrollController.jumpToItem(dayIndex);
                      }
                      lastAction = 'day';
                    }
                  });

                  widget.onSelected(_getSelectedJalaliDate());
                },
              ),
              _cupertinoPicker(
                context: context,
                list: _months,
                scrollController: monthScrollController,
                onSelectedItemChanged: (selectedIndex) {
                  if (lastAction != '' && lastAction != 'month' && lastAction != 'day') {
                    setState(() {
                      lastAction = 'month';
                    });
                    return;
                  }

                  setState(() {
                    _selectedMonth =
                        IRJalaliDateHelper.getMonthNumber(monthName: _months[selectedIndex]);
                    lastMonth = IRJalaliDateHelper.getMonthName(monthNumber: _selectedMonth);
                    checkMinMax();

                    if (widget.visibleDays) {
                      final dayIndex = _days.indexWhere((el) => el == _selectedDay);
                      if (dayIndex >= 0) dayScrollController.jumpToItem(dayIndex);
                    }
                  });

                  widget.onSelected(_getSelectedJalaliDate());
                },
              ),
              widget.visibleDays
                  ? _cupertinoPicker(
                      context: context,
                      list: _days,
                      scrollController: dayScrollController,
                      onSelectedItemChanged: (selectedIndex) {
                        if (lastAction != '' && lastAction != 'day') {
                          setState(() {
                            lastAction = 'day';
                          });
                          return;
                        }

                        setState(() {
                          _selectedDay = _days[selectedIndex];
                          lastDay = _selectedDay;
                        });

                        widget.onSelected(_getSelectedJalaliDate());
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
    Widget todayButton = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 1.0.percentOfHeight(context)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0.percentOfWidth(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton.icon(
                icon: Icon(Icons.info,
                    size: 6.5.percentOfWidth(context),
                    color:
                        widget.textStyle?.color ?? Theme.of(context).textTheme.titleMedium?.color),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(2.0.percentOfWidth(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                label: Text(widget.todayButtonText,
                    style: (widget.textStyle ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
                        fontSize: 14.responsiveFont(context), fontWeight: FontWeight.w600)),
                onPressed: () {
                  setState(() {
                    _refreshCupertinoPickers = true;
                    Jalali now = Jalali.now();
                    _selectedYear = now.year;
                    _selectedMonth = now.month;
                    _selectedDay = now.day;
                  });
                  widget.onSelected(_getSelectedJalaliDate());
                },
              ),
            ],
          ),
        ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cupertinoPickers,
        Visibility(
          visible: widget.visibleTodayButton,
          child: todayButton,
        ),
      ],
    );
  }

  Widget _cupertinoPicker(
      {required BuildContext context,
      required List list,
      required FixedExtentScrollController scrollController,
      required ValueChanged<int> onSelectedItemChanged}) {
    BoxConstraints cupertinoPickerConstraints = BoxConstraints.loose(
      Size(30.0.percentOfWidth(context), double.infinity),
    );
    return ConstrainedBox(
      constraints: cupertinoPickerConstraints,
      child: CupertinoPicker(
        key: _refreshCupertinoPickers ? UniqueKey() : null,
        scrollController: scrollController,
        itemExtent: 8.5.percentOfWidth(context),
        diameterRatio: widget.diameterRatio,
        magnification: widget.magnification,
        offAxisFraction: widget.offAxisFraction,
        squeeze: widget.squeeze,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: widget.textStyle?.color?.withOpacity(0.35) ?? Colors.grey.shade400,
                  width: 0.5),
              bottom: BorderSide(
                  color: widget.textStyle?.color?.withOpacity(0.35) ?? Colors.grey.shade400,
                  width: 0.5),
            ),
          ),
        ),
        onSelectedItemChanged: onSelectedItemChanged,
        children: list.map<Widget>(
          (element) {
            return Center(
              child: Text(
                element.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.textStyle?.color,
                      fontSize: widget.textStyle?.fontSize ?? 16.5.responsiveFont(context),
                      fontWeight: widget.textStyle?.fontWeight,
                    ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  List<int> _yearsList(int minYear, int maxYear) {
    List<int> years = [];
    for (int i = minYear; i <= maxYear; i++) {
      years.add(i);
    }
    return years;
  }

  Jalali _getSelectedJalaliDate() {
    if (widget.visibleDays) {
      return Jalali(_selectedYear, _selectedMonth, _selectedDay);
    } else {
      return Jalali(_selectedYear, _selectedMonth);
    }
  }

  void checkMinMax() {
    final months = [1, 12];
    for (var j = 1; j <= 12; j++) {
      if (Jalali(_selectedYear, j, 1).distanceFrom(_startDate) <= 0) {
        months[0] = j;
      }

      if (Jalali(_selectedYear, j, 1).distanceTo(_endDate) >= 0) {
        months[1] = j;
      }
    }
    _months = IRJalaliDateHelper.months.sublist(months[0] - 1, months[1]);

    if (widget.visibleDays) {
      int monthLength =
          IRJalaliDateHelper.getMonthLength(year: _selectedYear, month: _selectedMonth);

      final days = [1, monthLength];

      for (var i = 1; i <= monthLength; i++) {
        if (Jalali(_selectedYear, _selectedMonth, i).distanceFrom(_startDate) <= 0) {
          days[0] = i;
        }

        if (Jalali(_selectedYear, _selectedMonth, i).distanceTo(_endDate) >= 0) {
          days[1] = i;
        }
      }
      _days = List<int>.generate(days[1] - days[0] + 1, (index) => index + days[0]);

      if (_selectedDay > monthLength) {
        _selectedDay = monthLength;
      }
    }
  }
}
