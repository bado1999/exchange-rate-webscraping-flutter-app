import 'package:challenge/services/exchange-rate-service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize the workmanager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  //Register a task that runs every 12 hours to refresh exchange rates
  Workmanager().registerPeriodicTask(
    "exchangeRateRefresher",
    "refreshExchangeRates",
    initialDelay: const Duration(seconds: 10),
    frequency: const Duration(hours: 12),
  );

  runApp(const MyApp());
}

//A callback that will be called in the background
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ExchangeRateService.getInstance()?.refreshExchangeRates();
    return Future.value(true);
  });
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
  Set<String> fromCurrencies = {};
  Set<String> toCurrencies = {};
  String selectedCompany = '';
  String selectedFromCurrency = '';
  String selectedToCurrency = '';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  //Fetch exchange rates from the servers
  Future<void> _fetchExchangeRates() async {
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
        selectedFromCurrency = ''; // Clear selected from currency
        selectedToCurrency = ''; // Clear selected to currency
        _updateCurrencyFilters();
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
      _showErrorToast();
    }
  }

  //Update the currency filters
  void _updateCurrencyFilters() {
    // Filter currencies based on the selected company
    final companyRates =
        currencyRates.where((rate) => rate['company_name'] == selectedCompany);
    fromCurrencies =
        companyRates.map((rate) => rate['from_currency']).toSet().cast();
    toCurrencies =
        companyRates.map((rate) => rate['to_currency']).toSet().cast();
  }

  //Show a message to indicate failure to fetch exchange rates from the server
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
        title: const Text('Currency Exchange Rates'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Company dropdown with border
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    value: selectedCompany.isEmpty ? null : selectedCompany,
                    onChanged: (value) {
                      setState(() {
                        selectedCompany = value!;
                        _updateCurrencyFilters();
                        selectedFromCurrency = '';
                        selectedToCurrency = '';
                      });
                    },
                    items: companies.map((company) {
                      return DropdownMenuItem<String>(
                        value: company,
                        child: Text(
                          company,
                          overflow: TextOverflow.fade,
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('Select Company'),
                  ),
                ),
                const SizedBox(height: 16.0),

                // From and To Currency dropdowns with border
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DropdownButton<String>(
                          value: selectedFromCurrency.isEmpty
                              ? null
                              : selectedFromCurrency,
                          onChanged: (value) {
                            setState(() {
                              selectedFromCurrency = value!;
                            });
                          },
                          items: fromCurrencies.map((fromCurrency) {
                            return DropdownMenuItem<String>(
                              value: fromCurrency,
                              child: Text(
                                fromCurrency,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          hint: const Text('From Currency'),
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DropdownButton<String>(
                          value: selectedToCurrency.isEmpty
                              ? null
                              : selectedToCurrency,
                          onChanged: (value) {
                            setState(() {
                              selectedToCurrency = value!;
                            });
                          },
                          items: toCurrencies.map((toCurrency) {
                            return DropdownMenuItem<String>(
                              value: toCurrency,
                              child: Text(
                                toCurrency,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          hint: const Text('To Currency'),
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchExchangeRates,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  //Filter exchange rates by the origin and destination currencies
  List<dynamic> _filteredRates() {
    return currencyRates
        .where((rate) => rate['company_name'] == selectedCompany)
        .where((rate) =>
            selectedFromCurrency.isEmpty ||
            rate['from_currency'] == selectedFromCurrency)
        .where((rate) =>
            selectedToCurrency.isEmpty ||
            rate['to_currency'] == selectedToCurrency)
        .toList();
  }
}
