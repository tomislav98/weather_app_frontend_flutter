import 'package:http/http.dart' as http;

Future<void> callNotifyApi() async {
  //127.0.0.1 inside Flutter = Flutter emulator/device

  // 127.0.0.1 on your PC = your FastAPI server
  // 10.0.2.2 is a special alias that routes to your host machine from the emulator.
  final url = Uri.http('10.0.2.2:8000', '/notify');

  final response = await http.post(url);

  if (response.statusCode == 200) {
    print('API called successfully');
  } else {
    print('Failed to call API: ${response.statusCode}');
  }
}
