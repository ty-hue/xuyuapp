import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FetchLoadingView extends StatelessWidget {
  const FetchLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitChasingDots(color: Color.lerp(Color.fromRGBO(218, 68, 83, 1,), Color.fromRGBO(137, 33, 107, 1), 0.5), size: 30.0);
  }
}
