import 'package:share_plus/share_plus.dart';

void main() async {
  SharePlus.instance.share(
    ShareParams(
      files: [],
      text: 'hello',
      subject: 'sub'
    ),
  );
}
