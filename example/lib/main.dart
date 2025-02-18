import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ir_datetime_picker/ir_datetime_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale("fa"), Locale("en")],
      locale: const Locale("fa"),
      debugShowCheckedModeBanner: false,
      title: 'Example',
      theme: ThemeData(fontFamily: "IranSans"),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _jalaliDate = "Null";
  String _gregorianDate = "Null";
  String _time = "Null";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("تاریخ جلالی: $_jalaliDate", style: const TextStyle(fontSize: 18.0)),
            const SizedBox(height: 5.0),

            // Simple jalali date picker using top level functions showIRJalaliDatePickerDialog or showIRJalaliDatePickerRoute:
            // NOTE: For create your own JalaliDatePicker use IRJalaliDatePicker widget.
            ElevatedButton(
              child: const Text("انتخاب تاریخ"),
              onPressed: () async {
                Jalali? selectedDate = await showIRJalaliDatePickerDialog(
                  context: context,
                  title: "انتخاب تاریخ",
                  visibleTodayButton: true,
                  visibleDays: false,
                  todayButtonText: "انتخاب امروز",
                  confirmButtonText: "تایید",
                  initialDate: Jalali(1400, 4, 2),
                );
                if (selectedDate != null) {
                  setState(() {
                    _jalaliDate = "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}";
                  });
                }
              },
            ),
            const SizedBox(height: 30.0),

            Text("تاریخ میلادی: $_gregorianDate", style: const TextStyle(fontSize: 18.0)),
            const SizedBox(height: 5.0),

            // Simple gregorian date picker using top level functions showIRGregorianDatePickerDialog or showIRGregorianDatePickerRoute:
            // NOTE: For create your own GregorianDatePicker use IRGregorianDatePicker widget.
            ElevatedButton(
              child: const Text("انتخاب تاریخ"),
              onPressed: () async {
                Gregorian? selectedDate = await showIRGregorianDatePickerDialog(
                  context: context,
                  title: "انتخاب تاریخ",
                  visibleTodayButton: true,
                  todayButtonText: "انتخاب امروز",
                  confirmButtonText: "تایید",
                  initialDate: Gregorian(2020, 7, 15),
                );
                if (selectedDate != null) {
                  setState(() {
                    _gregorianDate =
                        "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}";
                  });
                }
              },
            ),
            const SizedBox(height: 30.0),

            Text("زمان: $_time", style: const TextStyle(fontSize: 18.0)),
            const SizedBox(height: 5.0),

            // Simple time picker using top level function showIRTimePickerDialog:
            // NOTE: For create your own TimePicker use IRTimePicker widget.
            ElevatedButton(
              child: const Text("انتخاب زمان"),
              onPressed: () async {
                IRTimeModel? time = await showIRTimePickerDialog(
                  context: context,
                  initialTime: IRTimeModel(hour: 18, minute: 59),
                  title: "انتخاب زمان",
                  visibleNowButton: true,
                  nowButtonText: "انتخاب اکنون",
                  confirmButtonText: "تایید",
                );
                if (time != null) {
                  setState(() {
                    _time = time.toString();
                  });
                }
              },
            ),
            const SizedBox(height: 30.0),

            // Sample IRJalaliDatePicker widget For create your own JalaliDatePicker.
            Container(
              color: Colors.green.withOpacity(0.1),
              child: IRJalaliDatePicker(
                initialDate: Jalali(1400, 3, 3),
                startDate: Jalali(1400, 3, 3),
                endDate: Jalali(1403, 6, 21),
                visibleTodayButton: true,
                visibleDays: true,
                todayButtonText: "انتخاب اکنون",
                constraints: const BoxConstraints.tightFor(width: 400, height: 200),
                onSelected: (Jalali date) {
                  if (kDebugMode) {
                    print(date.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
