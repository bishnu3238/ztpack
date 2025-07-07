class TranslationArgs<T extends Map<String, dynamic>> {
  final T args;

  TranslationArgs(this.args);

  String replace(String value) {
    String result = value;
    args.forEach((key, val) {
      result = result.replaceAll('{$key}', val.toString());
    });
    return result;
  }
}