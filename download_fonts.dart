import 'dart:io';

void main() async {
  final regularUrl = 'https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Regular.ttf';
  final boldUrl = 'https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Bold.ttf';

  await downloadFile(regularUrl, 'assets/fonts/Cairo-Regular.ttf');
  await downloadFile(boldUrl, 'assets/fonts/Cairo-Bold.ttf');
  print('Done downloading fonts.');
}

Future<void> downloadFile(String url, String path) async {
  final request = await HttpClient().getUrl(Uri.parse(url));
  final response = await request.close();
  final file = File(path);
  final sink = file.openWrite();
  await response.pipe(sink);
  await sink.close();
  print('Downloaded ${file.lengthSync()} bytes to $path');
}
