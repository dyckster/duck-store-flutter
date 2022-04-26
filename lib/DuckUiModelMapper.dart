import 'package:duck_store/models/DuckDTO.dart';
import 'package:duck_store/models/DuckUiModel.dart';

class DuckUiModelMapper {

  DuckUiModel map(DuckDTO duckDTO) {
    final numRegex = RegExp("[0-9]");
    final duckId = int.parse(numRegex.firstMatch(duckDTO.url)?.group(0) ?? "0");

    bool isRare = duckId % 11 == 1;

    return DuckUiModel(url: duckDTO.url, isRare: isRare);
  }
}
