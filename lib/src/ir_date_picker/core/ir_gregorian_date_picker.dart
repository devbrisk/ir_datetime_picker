import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ir_datetime_picker/src/helpers/date.dart';
import 'package:ir_datetime_picker/src/helpers/print.dart';
import 'package:ir_datetime_picker/src/helpers/responsive.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// * [IRGregorianDatePickerOnSelected] is a callback function that will call when user change cupertino pickers.

typedef IRGregorianDatePickerOnSelected = void Function(Gregorian gregorianDate);

/// * You can use [IRGregorianDatePicker] to design your own date pickers.

class IRGregorianDatePicker extends StatefulWidget {
  final Gregorian? initialDate;
  final Gregorian? startDate;
  final Gregorian? endDate;
  final bool visibleTodayButton;
  final bool visibleDays;
  final String todayButtonText;
  final BoxConstraints? constraints;
  final IRGregorianDatePickerOnSelected onSelected;
  final TextStyle? textStyle;
  final double diameterRatio;
  final double magnification;
  final double offAxisFraction;
  final double squeeze;

  const IRGregorianDatePicker({
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
  State<IRGregorianDatePicker> createState() => _IRGregorianDatePickerState();
}

class _IRGregorianDatePickerState extends State<IRGregorianDatePicker> {
  late Gregorian _initialDate;
  late Gregorian _startDate;
  late Gregorian _endDate;
  late bool _refreshCupertinoPickers;
  late final yearScrollController =
      FixedExtentScrollController(initialItem: _years.indexOf(_selectedYear));
  late final monthScrollController = FixedExtentScrollController(
      initialItem:
          _months.indexOf(IRGregorianDateHelper.getMonthName(monthNumber: _selectedMonth)));
  late final dayScrollController =
      FixedExtentScrollController(initialItem: _days.indexOf(_selectedDay));
  String lastAction = '';
  int _selectedYear = 2020;
  int _selectedMonth = 1;
  int _selectedDay = 1;
  List<int> _years = [];
  List<String> _months = IRGregorianDateHelper.months;
  List<int> _days = [];
  String lastMonth = '';
  int lastDay = 0;

  @override
  void initState() {
    super.initState();
    _initialDate = widget.initialDate ?? Gregorian.now();
    _startDate = widget.startDate ?? Gregorian.now().addYears(-50);
    _endDate = widget.endDate ?? Gregorian.now().addYears(50);
    _refreshCupertinoPickers = false;
    _selectedYear = _initialDate.year;
    _selectedMonth = _initialDate.month;
    _selectedDay = _initialDate.day;
    _years = _yearsList(_startDate.year, _endDate.year);
    lastMonth = IRGregorianDateHelper.getMonthName(monthNumber: _selectedMonth);
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

                  var realMonthIndex = IRGregorianDateHelper.getMonthNumber(monthName: lastMonth);
                  var monthIndex = _months.indexWhere((el) => el == lastMonth);
                  if (monthIndex >= 0) {
                    monthScrollController.jumpToItem(monthIndex);
                    _selectedMonth = realMonthIndex;
                  } else {
                    final firstIndex = IRGregorianDateHelper.getMonthNumber(monthName: _months[0]);
                    monthIndex = realMonthIndex <= firstIndex ? 0 : _months.length - 1;
                    realMonthIndex =
                        IRGregorianDateHelper.getMonthNumber(monthName: _months[monthIndex]);
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

                widget.onSelected(_getSelectedGregorianDate());
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
                      IRGregorianDateHelper.getMonthNumber(monthName: _months[selectedIndex]);
                  lastMonth = IRGregorianDateHelper.getMonthName(monthNumber: _selectedMonth);
                  checkMinMax();

                  if (widget.visibleDays) {
                    final dayIndex = _days.indexWhere((el) => el == _selectedDay);
                    if (dayIndex >= 0) dayScrollController.jumpToItem(dayIndex);
                  }
                });

                widget.onSelected(_getSelectedGregorianDate());
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

                      widget.onSelected(_getSelectedGregorianDate());
                    },
                  )
                : const SizedBox.shrink(),
          ],
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
                    Gregorian now = Gregorian.now();
                    _selectedYear = now.year;
                    _selectedMonth = now.month;
                    _selectedDay = now.day;
                  });
                  widget.onSelected(_getSelectedGregorianDate());
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

  List<int> _daysList(int monthLength) {
    return List<int>.generate(monthLength, (index) => index + 1);
  }

  Gregorian _getSelectedGregorianDate() {
    return Gregorian(_selectedYear, _selectedMonth, _selectedDay);
  }

  void checkMinMax() {
    final months = [1, 12];
    for (var j = 0; j < 12; j++) {
      if (Gregorian(_selectedYear, j + 1, _startDate.day).distanceFrom(_startDate) <= 0) {
        months[0] = j + 1;
      }

      if (Gregorian(_selectedYear, j + 1, _endDate.day).distanceTo(_endDate) >= 0) {
        months[1] = j + 1;
      }
    }
    _months = IRGregorianDateHelper.months.sublist(months[0] - 1, months[1]);

    if (widget.visibleDays) {
      int monthLength =
          IRGregorianDateHelper.getMonthLength(year: _selectedYear, month: _selectedMonth);

      final days = [1, monthLength];

      for (var i = 0; i < monthLength; i++) {
        if (Gregorian(_selectedYear, _selectedMonth, i + 1).distanceFrom(_startDate) <= 0) {
          days[0] = i + 1;
        }

        if (Gregorian(_selectedYear, _selectedMonth, i + 1).distanceTo(_endDate) >= 0) {
          days[1] = i + 1;
        }
      }
      _days = List<int>.generate(days[1] - days[0] + 1, (index) => index + days[0]);

      if (_selectedDay > monthLength) {
        _selectedDay = monthLength;
      }
    }
  }
}
