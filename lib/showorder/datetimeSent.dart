import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget extends StatefulWidget {
  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime selectedDate = DateTime.now();

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // child: Padding(
      //   padding: const EdgeInsets.all(10.0),
      child: Container(
        margin: EdgeInsets.only(top: 16.0),
        width: 200.0,
        child: Card(
          child: Column(
            children: <Widget>[
              // MyStyle().showTitleH3green('ເລືອກວັນທີ່ ແລະ ເວລາສົ່ງ'),
              // Divider(),
              dateTime(),
            ],
          ),
        ),
      ),
    );
  }

  Widget dateTimesentForm() => SingleChildScrollView(
        // child: Padding(
        //   padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.only(top: 16.0),
          width: 200.0,
          child: Card(
            child: Column(
              children: <Widget>[
                // MyStyle().showTitleH3green('ເລືອກວັນທີ່ ແລະ ເວລາສົ່ງ'),
                // Divider(),
                dateTime(),
              ],
            ),
          ),
        ),
      );

  Widget dateTime() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ElevatedButton(
              onPressed: () async {
                final selectedDate = await _selectDateTime(context);
                if (selectedDate == null) return;

                print(selectedDate);

                final selectedTime = await _selectTime(context);
                if (selectedTime == null) return;
                print(selectedTime);

                setState(() {
                  this.selectedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                });
              },
              child: Text(dateFormat.format(selectedDate))),
        ],
      );

  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();

    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  Future<DateTime> _selectDateTime(BuildContext context) => showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(seconds: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
}
