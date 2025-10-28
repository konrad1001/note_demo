import 'package:flutter_riverpod/flutter_riverpod.dart';

const String kEnvironment = String.fromEnvironment("ENVIRONMENT");

final mockServiceProvider = Provider<bool>((_) => kEnvironment == "MOCK");
