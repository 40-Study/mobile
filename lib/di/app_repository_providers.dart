import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/routes/router.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

abstract class AppRepositoryProviders {
  static List<SingleChildWidget> providers() {
    return [
      RepositoryProvider<NavigationService>(
        create: (context) => NavigationService(),
      ),
    ];
  }
}
