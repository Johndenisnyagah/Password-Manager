import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/password_generator_service.dart';

/// Configuration for the password generator.
class GeneratorConfig {
  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useNumbers;
  final bool useSymbols;

  const GeneratorConfig({
    this.length = 16,
    this.useUppercase = true,
    this.useLowercase = true,
    this.useNumbers = true,
    this.useSymbols = true,
  });

  GeneratorConfig copyWith({
    int? length,
    bool? useUppercase,
    bool? useLowercase,
    bool? useNumbers,
    bool? useSymbols,
  }) {
    return GeneratorConfig(
      length: length ?? this.length,
      useUppercase: useUppercase ?? this.useUppercase,
      useLowercase: useLowercase ?? this.useLowercase,
      useNumbers: useNumbers ?? this.useNumbers,
      useSymbols: useSymbols ?? this.useSymbols,
    );
  }
}

/// State notifier for managing generator configuration and the generated password.
class GeneratorNotifier extends StateNotifier<({GeneratorConfig config, String password, double entropy})> {
  final PasswordGeneratorService _service;

  GeneratorNotifier(this._service) : super((
    config: const GeneratorConfig(),
    password: '',
    entropy: 0,
  )) {
    generate();
  }

  void updateConfig(GeneratorConfig newConfig) {
    state = (config: newConfig, password: state.password, entropy: state.entropy);
    generate(); // Re-generate when config changes
  }

  void generate() {
    final password = _service.generate(
      length: state.config.length,
      useUppercase: state.config.useUppercase,
      useLowercase: state.config.useLowercase,
      useNumbers: state.config.useNumbers,
      useSymbols: state.config.useSymbols,
    );
    final entropy = _service.calculateEntropy(
      password,
      useUppercase: state.config.useUppercase,
      useLowercase: state.config.useLowercase,
      useNumbers: state.config.useNumbers,
      useSymbols: state.config.useSymbols,
    );
    state = (config: state.config, password: password, entropy: entropy);
  }
}

final passwordGeneratorServiceProvider = Provider((ref) => PasswordGeneratorService());

final generatorProvider = StateNotifierProvider<GeneratorNotifier, ({GeneratorConfig config, String password, double entropy})>((ref) {
  final service = ref.watch(passwordGeneratorServiceProvider);
  return GeneratorNotifier(service);
});
