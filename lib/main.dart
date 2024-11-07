import 'package:challenge/services/exchange-rate-service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "exchangeRateRefresher",
    "refreshExchangeRates",
    initialDelay: const Duration(seconds: 10),
    frequency: const Duration(hours: 12),
  );

  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    refreshExchangeRates();
    return Future.value(true);
  });
}

void refreshExchangeRates() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/taux/refresh'));
  if (response.statusCode == 200) {
    // Update the exchange rate data in your app's state
  } else {
    throw Exception('Failed to refresh currency rates');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange Rates',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Exchange Rates'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> currencyRates = [];
  Set<String> companies = {};
  String selectedCompany = '';
  String fromCurrency = '';
  String toCurrency = '';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrencyRates();
  }

  Future<void> _fetchCurrencyRates() async {
    final List<dynamic> exchangeRates;
    try {
      exchangeRates =
          await ExchangeRateService.getInstance()?.fetchExchangeRates();
      setState(() {
        currencyRates = exchangeRates;
        companies = exchangeRates
            .map((rate) => rate['company_name'])
            .toSet()
            .cast<String>();
        selectedCompany = companies.first;
        fromCurrency = exchangeRates.first['from_currency'];
        toCurrency = exchangeRates.first['to_currency'];
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
      _showErrorToast();
    }
  }

  void _showErrorToast() {
    Fluttertoast.showToast(
      msg: "Error fetching exchange rates",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Exchange Rates'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCompany,
                    onChanged: (value) {
                      setState(() {
                        selectedCompany = value!;
                      });
                    },
                    items: companies.map((company) {
                      return DropdownMenuItem<String>(
                        value: company,
                        child: Text(company),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        fromCurrency = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'From Currency',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        toCurrency = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'To Currency',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('From')),
                  DataColumn(label: Text('To')),
                  DataColumn(label: Text('Exchange Rate')),
                ],
                rows: _filteredRates().map((rate) {
                  return DataRow(cells: [
                    DataCell(Text(rate['from_currency'])),
                    DataCell(Text(rate['to_currency'])),
                    DataCell(Text(rate['exchange_rate'].toString())),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchCurrencyRates,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  List<dynamic> _filteredRates() {
    return currencyRates
        .where((rate) => rate['company_name'] == selectedCompany)
        .where((rate) => rate['from_currency'].contains(fromCurrency))
        .where((rate) => rate['to_currency'].contains(toCurrency))
        .toList();
  }
}
