import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onion Status',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Weather(nodeId: ''), // Example usage of Weather widget
    );
  }
}

class Weather extends StatefulWidget {
  final String nodeId;

  const Weather({
    super.key,
    required this.nodeId,
  });

  @override
  State<Weather> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Weather> {
  List<apiData> chartData = [];
  late TooltipBehavior _tooltipBehavior;
  late DateTime _startDate;
  late DateTime _endDate;
  List<dynamic> data = [];
  String _nodeId = '';
  String errorMessage = '';
  late String Class = " ";
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final TextEditingController _nodeIdController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _startDate = DateTime.parse(DateTime.now().toString());
    _endDate = DateTime.parse(DateTime.now().toString());
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  Future<void> getAPIData(String nodeId, String startDate, TimeOfDay startTime,
      String endDate, TimeOfDay endTime) async {
    // Combine start date and time strings into DateTime objects
    String extractedDate1 = startDate.split(' ')[0];
    String extractedDate2 = endDate.split(' ')[0];
    String startTimeString =
        '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    String endTimeString =
        '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

    DateTime startDateTime = DateTime.parse('$extractedDate1 $startTimeString');
    DateTime endDateTime = DateTime.parse('$extractedDate2 $endTimeString');
    print(extractedDate1);
    // print(startTime.toString());

    String formattedStartDateTimeString =
        DateFormat('yyyy-MM-dd HH:mm').format(startDateTime);
    String formattedEndDateTimeString =
        DateFormat('yyyy-MM-dd HH:mm').format(endDateTime);
    DateTime parsedStartDateTime = DateTime.parse(formattedStartDateTimeString);
    DateTime parsedEndDateTime = DateTime.parse(formattedEndDateTimeString);
    DateTime formattedStartDateTime = DateTime(
      parsedStartDateTime.year,
      parsedStartDateTime.month,
      parsedStartDateTime.day,
      parsedStartDateTime.hour,
      parsedStartDateTime.minute,
    );
    DateTime formattedEndDateTime = DateTime(
      parsedEndDateTime.year,
      parsedEndDateTime.month,
      parsedEndDateTime.day,
      parsedEndDateTime.hour,
      parsedEndDateTime.minute,
    );

    final int startSeconds =
        formattedStartDateTime.millisecondsSinceEpoch ~/ 1000;
    final int endSeconds = formattedEndDateTime.millisecondsSinceEpoch ~/ 1000;
    print(formattedStartDateTime);
    print(startTimeString);
    print(startSeconds);
    //  print(startSeconds.toString());
    //  print(starttime);
    final uri = Uri.https(
      'bu98b5mygk.execute-api.us-east-1.amazonaws.com',
      '/v1/data',
      {
        'nodeId': nodeId,
        'starttime': startSeconds.toString(),
        'endtime': endSeconds.toString(),
      },
      // 'https://bu98b5mygk.execute-api.us-east-1.amazonaws.com',
      // '/v1/data',
      // {
      //   'nodeId': nodeId,
      //   'starttime': startSeconds.toString(),
      //   'endtime': endSeconds.toString(),
      // },
    );
    print(uri);
    final response = await http.get(uri);
    print("response");
    print(response.body);

    final parsed = jsonDecode(response.body);
    if (parsed is List && parsed.isNotEmpty) {
      setState(() {
        chartData = parsed.map((data) => apiData.fromJson(data)).toList();
      });
    } else if (parsed['statusCode'] == 400 ||
        parsed['statusCode'] == 404 ||
        parsed['statusCode'] == 500) {
      setState(() {
        errorMessage = parsed['body'][0]['message'];
      });
    } else {
      throw Exception('Failed to load api');
    }
  }

  void updateData() async {
    await getAPIData(_nodeId, _startDate.toString(), _startTime,
        _endDate.toString(), _endTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Onion Staus ',
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Node ID',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      ),
                                      textAlign: TextAlign.right, // Set text direction to right-to-left
                                      controller: TextEditingController(text: _nodeId),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(RegExp(r'[^0-9]')), // Allow only numbers
                                      ],
                                      onChanged: (value) {
                                        if (value.isEmpty || RegExp(r'^[0-9]+$').hasMatch(value)) {
                                          setState(() {
                                            _nodeId = value;
                                                                                // Node ID selection logic...

                                          // controller: TextEditingController(text: _nodeId ?? ''),
                                          // onChanged: (value) {
                                          //   setState(() {
                                          //     _nodeId = value;
                                        });
                                        };
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: TextFormField(
                                      onTap: () async {
                                        final DateTime? selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _startDate ?? DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.purple,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    elevation: 10,
                                                    backgroundColor: Colors
                                                        .black, // button text color
                                                  ),
                                                ),
                                              ),
                                              // child: child!,
                                              child: MediaQuery(
                                                data: MediaQuery.of(context)
                                                    .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true),
                                                child: child ?? Container(),
                                              ),
                                            );
                                          },
                                        );
                                        if (selectedDate != null) {
                                          setState(() {
                                            _startDate = selectedDate;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Start Date',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                      ),
                                      controller: TextEditingController(
                                          text: _startDate != null
                                              ? DateFormat('dd-MM-yyyy')
                                                  .format(_startDate)
                                              : ''),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      onTap: () async {
                                        final TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _startTime ?? TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.purple,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    elevation: 10,
                                                    backgroundColor:
                                                        Colors.black,
                                                  ),
                                                ),
                                              ),
                                              child: MediaQuery(
                                                data: MediaQuery.of(context)
                                                    .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true),
                                                child: child ?? Container(),
                                              ),
                                            );
                                          },
                                        );
                                        if (selectedTime != null) {
                                          setState(() {
                                            _startTime = selectedTime;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Start Time',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                      ),
                                      controller: TextEditingController(
                                        // text: _startTime != null ? '${_startTime!.format(context)}' : '',
                                        text: _startTime != null
                                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                            : '',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: TextFormField(
                                      onTap: () async {
                                        final DateTime? selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _endDate ?? DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.purple,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    elevation: 10,
                                                    backgroundColor:
                                                        Colors.black,
                                                  ),
                                                ),
                                              ),
                                              child: MediaQuery(
                                                data: MediaQuery.of(context)
                                                    .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true),
                                                child: child ?? Container(),
                                              ),
                                            );
                                          },
                                        );
                                        if (selectedDate != null) {
                                          setState(() {
                                            _endDate = selectedDate;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'End Date',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                      ),
                                      controller: TextEditingController(
                                          text: _endDate != null
                                              ? DateFormat('dd-MM-yyyy')
                                                  .format(_endDate)
                                              : ''),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      onTap: () async {
                                        final TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _endTime ?? TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.purple,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    elevation: 10,
                                                    backgroundColor:
                                                        Colors.black,
                                                  ),
                                                ),
                                              ),
                                              child: MediaQuery(
                                                data: MediaQuery.of(context)
                                                    .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true),
                                                child: child ?? Container(),
                                              ),
                                            );
                                          },
                                        );
                                        if (selectedTime != null) {
                                          setState(() {
                                            _endTime = selectedTime;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'End Time',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                      ),
                                      controller: TextEditingController(
                                        // text: _endTime != null ? '${_endTime!.format(context)}' : '',
                                        text: _endTime != null
                                            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                            : '',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateData();
                                    },
                                    child: Text(
                                      'Get Data',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .green, // Set the button color to green
                                      minimumSize: Size(80,
                                          0), // Set a minimum width for the button
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                ],
                              ),
                              SizedBox(height: 32.0),
                              if (errorMessage.isNotEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 400,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          errorMessage,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          semanticsLabel: errorMessage = "",
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 400,
                                        child: SfCartesianChart(
                                          title: ChartTitle(text: 'Temperature'),
                                          tooltipBehavior: _tooltipBehavior,
                                          primaryXAxis: DateTimeAxis(),
                                          series: <CartesianSeries>[
                                            LineSeries<apiData, DateTime>(
                                              dataSource: chartData,
                                              xValueMapper: (apiData data, _) => DateTime.fromMillisecondsSinceEpoch(int.parse(data.timestamp) * 1000),
                                              yValueMapper: (apiData data, _) => double.parse(data.temperature),
                                              name: 'Temperature',
                                              color: Color.fromARGB(255, 50, 110, 160),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20), // Add spacing between charts
                                      Container(
                                        height: 400,
                                        child: SfCartesianChart(
                                          title: ChartTitle(text: 'CO2'),
                                          tooltipBehavior: _tooltipBehavior,
                                          primaryXAxis: DateTimeAxis(),
                                          series: <CartesianSeries>[
                                            LineSeries<apiData, DateTime>(
                                              dataSource: chartData,
                                              xValueMapper: (apiData data, _) => DateTime.fromMillisecondsSinceEpoch(int.parse(data.timestamp) * 1000),
                                              yValueMapper: (apiData data, _) => double.parse(data.CO2),
                                              name: 'CO2',
                                              color: Color.fromARGB(255, 204, 103, 53),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 400,
                                        child: SfCartesianChart(
                                          title: ChartTitle(text: 'SO2'),
                                          tooltipBehavior: _tooltipBehavior,
                                          primaryXAxis: DateTimeAxis(),
                                          series: <CartesianSeries>[
                                            LineSeries<apiData, DateTime>(
                                              dataSource: chartData,
                                              xValueMapper: (apiData data, _) => DateTime.fromMillisecondsSinceEpoch(int.parse(data.timestamp) * 1000),
                                              yValueMapper: (apiData data, _) => double.parse(data.SO2),
                                              name: 'SO2',
                                              color: Color.fromARGB(255, 45, 167, 69),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 400,
                                        child: SfCartesianChart(
                                          title: ChartTitle(text: 'NH3'),
                                          tooltipBehavior: _tooltipBehavior,
                                          primaryXAxis: DateTimeAxis(),
                                          series: <CartesianSeries>[
                                            LineSeries<apiData, DateTime>(
                                              dataSource: chartData,
                                              xValueMapper: (apiData data, _) => DateTime.fromMillisecondsSinceEpoch(int.parse(data.timestamp) * 1000),
                                              yValueMapper: (apiData data, _) => double.parse(data.NH3),
                                              name: 'NH3',
                                              color: Color.fromARGB(255, 161, 36, 134),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 400,
                                        child: SfCartesianChart(
                                          title: ChartTitle(text: 'H2S'),
                                          tooltipBehavior: _tooltipBehavior,
                                          primaryXAxis: DateTimeAxis(),
                                          series: <CartesianSeries>[
                                            LineSeries<apiData, DateTime>(
                                              dataSource: chartData,
                                              xValueMapper: (apiData data, _) => DateTime.fromMillisecondsSinceEpoch(int.parse(data.timestamp) * 1000),
                                              yValueMapper: (apiData data, _) => double.parse(data.H2S),
                                              name: 'H2S',
                                              color: Color.fromARGB(255, 168, 39, 39),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 400,
                                        child: SfCartesianChart(
                                          title: ChartTitle(text: 'Humidity'),
                                          tooltipBehavior: _tooltipBehavior,
                                          primaryXAxis: DateTimeAxis(),
                                          series: <CartesianSeries>[
                                            LineSeries<apiData, DateTime>(
                                              dataSource: chartData,
                                              xValueMapper: (apiData data, _) => DateTime.fromMillisecondsSinceEpoch(int.parse(data.timestamp) * 1000),
                                              yValueMapper: (apiData data, _) => double.parse(data.humidity),
                                              name: 'Humidity',
                                              color: Color.fromARGB(255, 147, 151, 39),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class apiData {
  apiData({
    required this.humanTime,
    required this.CO2,
    required this.SO2,
    required this.timestamp,
    required this.nodeId,
    required this.NH3,
    required this.H2S,
    required this.humidity,
    required this.temperature,
  });

  final String humanTime;
  final String CO2;
  final String SO2;
  final String timestamp;
  final String nodeId;
  final String NH3;
  final String H2S;
  final String humidity;
  final String temperature;

  factory apiData.fromJson(Map<String, dynamic> json) {
    return apiData(
      humanTime: json['human_time'],
      CO2: json['CO2'],
      SO2: json['SO2'],
      timestamp: json['timestamp'],
      nodeId: json['nodeId'],
      NH3: json['NH3'],
      H2S: json['H2S'],
      humidity: json['humidity'],
      temperature: json['temperature'],
    );
  }
}