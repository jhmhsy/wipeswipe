import 'package:flutter/widgets.dart';

enum PageType {kept, discarded}
class ReviewPage extends StatefulWidget {
  final PageType pagetype;
  const ReviewPage({super.key, required this.pagetype});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
