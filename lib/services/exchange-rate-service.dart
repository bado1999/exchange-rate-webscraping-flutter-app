import 'dart:convert';
import 'package:http/http.dart' as http;

//A service to isolate server side operations
class ExchangeRateService {
  static ExchangeRateService? _instance;

  //Ensure there is one of Exchange rate service running
  static ExchangeRateService? getInstance() {
    _instance ??= ExchangeRateService();
    return _instance;
  }

  //Retrieve exchange rates from api server
  Future<dynamic> fetchExchangeRates() async {
    final response = await http.get(Uri.parse('https://192.168.32.8:8080/taux'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load currency rates');
    }

    /*return [
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Mozambique (MZN)",
        "exchange_rate": 75,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Nepal (NPR)",
        "exchange_rate": 172.5,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Pakistan (PKR)",
        "exchange_rate": 363,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Rep. Congo (XAF)",
        "exchange_rate": 777,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Senegal (FCFA)",
        "exchange_rate": 773,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Sri Lanka (LKR)",
        "exchange_rate": 375,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Tanzania (TZS)",
        "exchange_rate": 3410,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "The Gambia (GMD)",
        "exchange_rate": 84,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Tunisia (TND)",
        "exchange_rate": 3.87,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Turkey (TRY)",
        "exchange_rate": 42.72,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Uganda (UGX)",
        "exchange_rate": 4685,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Vietnam (VND)",
        "exchange_rate": 32600,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Vietnam (USD)",
        "exchange_rate": 1,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Zambia (ZMW)",
        "exchange_rate": 33,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "United Kingdom (GBP)",
        "to_currency": "Zimbabwe (USD)",
        "exchange_rate": 1.25,
        "company_name": "TapTap Send"
      },
      {
        "from_currency": "XOF",
        "to_currency": "XAF",
        "exchange_rate": 1,
        "company_name": "Gandyam Pay"
      },
      {
        "from_currency": "XOF",
        "to_currency": "CNY",
        "exchange_rate": 0.0111,
        "company_name": "Gandyam Pay"
      },
      {
        "from_currency": "XOF",
        "to_currency": "USD",
        "exchange_rate": 0.00164,
        "company_name": "Gandyam Pay"
      },
      {
        "from_currency": "XOF",
        "to_currency": "CAD",
        "exchange_rate": 0.002,
        "company_name": "Gandyam Pay"
      }
    ];*/
  }

  //Refresh exchange rates from the api server
  void refreshExchangeRates() async {
    final response =
    await http.get(Uri.parse('http://192.168.32.8:8080/taux/refresh'));
    if (response.statusCode == 200) {
      // Update the exchange rate data in your app's state
    } else {
      throw Exception('Failed to refresh currency rates');
    }
  }

}
