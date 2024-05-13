// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

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
      home: Weather(
        nodeId1: '',
        nodeId2: '',
      ), // Example usage of Weather widget
    );
  }
}

class Weather extends StatefulWidget {
  final String nodeId1;
  final String nodeId2;

  const Weather({
    Key? key, // Added Key? key here
    required this.nodeId1,
    required this.nodeId2,
  }) : super(key: key);

  @override
  State<Weather> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Weather> {
  
  late TooltipBehavior _tooltipBehavior;
  late DateTime _startDate;
  late DateTime _endDate;
  List<dynamic> data = [];
  String _nodeId1 = '';
  String _nodeId2 = '';
  String _gatewayId = '';
  String errorMessage = '';
  late String Class = " ";
  List<apiData> chartDataNode1 = [];
  List<apiData> chartDataNode2 = [];
  // ignore: unused_field
  final TextEditingController _nodeId1Controller = TextEditingController();
  final TextEditingController _nodeId2Controller = TextEditingController();
  final TextEditingController _gatewayIdController = TextEditingController();

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    _nodeId1 = widget.nodeId1;
    _nodeId2 = widget.nodeId2;
    _startDate = DateTime.parse(DateTime.now().toString());
    _endDate = DateTime.parse(DateTime.now().toString());
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  Future<void> getAPIData(String nodeId, String gatewayId, String startDate, TimeOfDay startTime, String endDate, TimeOfDay endTime) async {
    // Combine start date and time strings into DateTime objects
    String extractedDate1 = startDate.split(' ')[0];
    String extractedDate2 = endDate.split(' ')[0];
    String startTimeString =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    String endTimeString =
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

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
      'qqvlf6v6kc.execute-api.us-east-1.amazonaws.com',
      '/v1/data',
      {
        'nodeId': nodeId,
        'gatewayId': gatewayId,
        'starttime': startSeconds.toString(),
        'endtime': endSeconds.toString(),
      },
    );
    // 'https://bu98b5mygk.execute-api.us-east-1.amazonaws.com',
    // '/v1/data',
    // {
    //   'nodeId': nodeId,
    //   'starttime': startSeconds.toString(),
    //   'endtime': endSeconds.toString(),
    // },

    print(uri);
    final response = await http.get(uri);
    print("response");
    print(response.body);

    final parsed = jsonDecode(response.body);
    if (parsed != null) {
      if (parsed is List && parsed.isNotEmpty) {
        if (nodeId == _nodeId1) {
          setState(() {
            chartDataNode1 = parsed.map((data) => apiData.fromJson(data)).toList();
          });
        } else if (nodeId == _nodeId2) {
          setState(() {
            chartDataNode2 = parsed.map((data) => apiData.fromJson(data)).toList();
          });
        }
      } else if (parsed is Map && parsed.containsKey('statusCode')) {
        // Handle error response
        setState(() {
          errorMessage = parsed['body'][0]['message'];
        });
      } else {
        throw Exception('Failed to load api');
      }
    } else {
      throw Exception('Invalid response format');
    }
  }

  void updateData() async {
    if (_gatewayId.isNotEmpty &&
        _startDate != null &&
        _startTime != null &&
        _endDate != null &&
        _endTime != null) {
      // Fetch data for Node ID 1 and Node ID 2 simultaneously
      final future1 = getAPIData(_nodeId1, _gatewayId, _startDate.toString(),
          _startTime, _endDate.toString(), _endTime);
      final future2 = getAPIData(_nodeId2, _gatewayId, _startDate.toString(),
          _startTime, _endDate.toString(), _endTime);

      // Wait for both futures to complete
      await Future.wait([future1, future2]);

      // Update the chartData state after both sets of data are fetched
      setState(() {
        var chartData;
        print('Chart Data Length: ${chartData.length}');
      });
    } else {
      print('Some required values are null or empty');
    }
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
                      child: TextFormField(
                        controller: _gatewayIdController,
                        decoration: InputDecoration(
                          labelText: 'Enter Gateway ID',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _gatewayId = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _nodeId1Controller,
                      decoration: InputDecoration(
                        labelText: 'Enter Node ID 1 ',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        {
                          // Remove leading zeros
                          setState(() {
                            _nodeId1 = value;
                          });
                        }
                        ;
                      },
                    )),
                    SizedBox(width: 16.0),
                    Expanded(
                        child: TextFormField(
                      controller: _nodeId2Controller,
                      decoration: InputDecoration(
                        labelText: 'Enter Node ID 2 ',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        {
                          // Remove leading zeros
                          setState(() {
                            _nodeId2 = value;
                          });
                        }
                        ;
                      },
                    )),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.purple,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor:
                                          Colors.black, // button text color
                                    ),
                                  ),
                                ),
                                // child: child!,
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
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
                                ? DateFormat('dd-MM-yyyy').format(_startDate)
                                : ''),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          final TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.purple,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
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
                              ? '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'
                              : '',
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.purple,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
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
                                ? DateFormat('dd-MM-yyyy').format(_endDate)
                                : ''),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          final TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.purple,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
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
                              ? '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'
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
                        backgroundColor:
                            Colors.green, // Set the button color to green
                        minimumSize:
                            Size(80, 0), // Set a minimum width for the button
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                        Card(
                  child: Container(
                    height: 400,
                    child: SfCartesianChart(
                      title: ChartTitle(
                        text: 'Gases Data for Node $_nodeId1',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tooltipBehavior: _tooltipBehavior,
                      primaryXAxis: DateTimeAxis(title: AxisTitle(text: 'Time')),
                      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                      series: <CartesianSeries>[
                        LineSeries<apiData, DateTime>(
                          dataSource: chartDataNode1,
                          xValueMapper: (apiData data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(data.timestamp) * 1000),
                          yValueMapper: (apiData data, _) =>
                              double.parse(data.temperature),
                          name: 'Temperature Node $_nodeId1',
                          color: Color.fromARGB(255, 50, 110, 160),
                        ),
                        LineSeries<apiData, DateTime>(
                          dataSource: chartDataNode1,
                          xValueMapper: (apiData data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(data.timestamp) * 1000),
                          yValueMapper: (apiData data, _) =>
                              double.parse(data.CO2),
                          name: 'CO2 Node $_nodeId1',
                          color: Color.fromARGB(255, 204, 103, 53),
                        ),
                        LineSeries<apiData, DateTime>(
                          dataSource: chartDataNode1,
                          xValueMapper: (apiData data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(data.timestamp) * 1000),
                          yValueMapper: (apiData data, _) =>
                              double.parse(data.humidity),
                          name: 'Humidity Node $_nodeId1',
                          color: Color.fromARGB(255, 147, 151, 39),                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                            height:
                                16), // Add some space between the two charts
                       Card(
                  child: Container(
                    height: 400,
                    child: SfCartesianChart(
                      title: ChartTitle(
                        text: 'Gases Data for Node $_nodeId2',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tooltipBehavior: _tooltipBehavior,
                      primaryXAxis: DateTimeAxis(title: AxisTitle(text: 'Time')),
                      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                      series: <CartesianSeries>[
                        LineSeries<apiData, DateTime>(
                          dataSource: chartDataNode2,
                          xValueMapper: (apiData data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(data.timestamp) * 1000),
                          yValueMapper: (apiData data, _) =>
                              double.parse(data.temperature),
                          name: 'Temperature Node $_nodeId2',
                          color: Color.fromARGB(255, 50, 110, 160),
                        ),
                        LineSeries<apiData, DateTime>(
                          dataSource: chartDataNode2,
                          xValueMapper: (apiData data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(data.timestamp) * 1000),
                          yValueMapper: (apiData data, _) =>
                              double.parse(data.CO2),
                          name: 'CO2 Node $_nodeId2',
                          color: Color.fromARGB(255, 204, 103, 53),
                        ),
                        LineSeries<apiData, DateTime>(
                          dataSource: chartDataNode2,
                          xValueMapper: (apiData data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(data.timestamp) * 1000),
                          yValueMapper: (apiData data, _) =>
                              double.parse(data.humidity),
                          name: 'Humidity Node $_nodeId2',
                          color: Color.fromARGB(255, 147, 151, 39),
                                ),
                              ],
                            ),
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
    );
  }
}
  

card(Container container, {required Container child}) {}

class apiData {
  apiData({
    required this.humanTime,
    required this.CO2,
    required this.timestamp,
    required this.nodeId,
    required this.gatewayId,
    required this.humidity,
    required this.temperature,
  });

  final String humanTime;
  final String CO2;

  final String timestamp;
  final String nodeId;
  final String gatewayId;

  final String humidity;
  final String temperature;

  factory apiData.fromJson(Map<String, dynamic> json) {
    return apiData(
      humanTime: json['human_time'] ?? '', // Provide default value if null
      CO2: json['co2'] ?? '', // Provide default value if null
      timestamp: json['timestamp'] ?? '', // Provide default value if null
      nodeId: json['nodeId'] ?? '',
      // Provide default value if null
      gatewayId: json['gatewayId'] ?? '', // Provide default value if null
      humidity: json['humidity'] ?? '', // Provide default value if null
      temperature: json['temperature'] ?? '', // Provide default value if null
    );
  }
}
