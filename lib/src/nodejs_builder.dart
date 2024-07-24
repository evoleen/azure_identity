import 'package:build/build.dart';

/// Copy contents of a `txt` files into `name.txt.copy`.
///
/// A header row is added pointing to the input file name.
class NodeJsBuilder implements Builder {
  @override
  Future build(BuildStep buildStep) async {
    print('EXECUTED');

    // Each [buildStep] has a single input.
    var inputId = buildStep.inputId;

    // Create a new target [AssetId] based on the old one.
    var contents = await buildStep.readAsString(inputId);

    var copy = inputId.addExtension('.bin');

    // Write out the new asset.
    await buildStep.writeAsString(copy, '// Copied from $inputId\n$contents');
  }

  @override
  final buildExtensions = const {
    '.js': ['.js.bin']
  };
}
