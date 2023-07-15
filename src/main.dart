import 'dart:io';
import 'dart:math';

import 'lat_lon.dart';

const double rasterSize = 0.001000;

Future<void> main() async {
  // Every item in this list is a new list
  final List<String> text = ["Hi Hanno", "any CDTM tips"];

  final startCoordinate = LatLon(lat: 48.081544, lon: 11.565858);
  final List<List<LatLon>> coordinates = List.filled(text.length, []);
  coordinates[0] = [startCoordinate];

  for (var line = 0; line < text.length; line++) {
    // Draw every letter from current line
    text[line].split("").forEach((letter) {
      List<LatLon> letterCoordinates;
      try {
        letterCoordinates =
            getCoordinatesOfALetter(letter, coordinates[line].last);
      } catch (e) {
        print("Skiping '$letter', because: '$e'");
        return;
      }
      coordinates[line].addAll(letterCoordinates);

      // Add a blank every letter
      coordinates[line]
          .addAll(getCoordinatesOfALetter(" ", coordinates[line].last));
    });

    // Remove last blank, because the word is finished
    coordinates[line].removeLast();

    // If it is not the last line, start a new line
    if (line != text.length - 1) {
      final int nextLine = line + 1;
      final list = <LatLon>[];
      list.add(
        LatLon(
          lat: coordinates[line].last.lat - rasterSize,
          lon: coordinates[line].last.lon,
        ),
      );
      // If you want to move the start of the next line to the left, you can
      // change the value of the second parameter of the next line.
      list.add(LatLon(
          lat: list.last.lat,
          lon: coordinates[line].first.lon - (rasterSize * 4)));
      list.add(
          LatLon(lat: list.last.lat - (rasterSize * 3), lon: list.last.lon));
      list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
      coordinates[nextLine] = list;
    }
  }

  await createGpxFile(coordinates);
}

/// Generates with [coordinates] a GPX file, which can be imported to Strava,
/// etc.
Future<void> createGpxFile(List<List<LatLon>> coordinates) async {
  String xmlString = '';

  // Every track point in a gpx file needs a timestamp. Every track point should
  // have a gap of one minute.
  DateTime tempDate = DateTime.now().subtract(Duration(hours: 7)).toUtc();

  final String fileBeginning =
      '<?xml version="1.0" encoding="UTF-8"?><gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1"><metadata><time>${tempDate.toIso8601String()}</time></metadata><trk><name>Scripting...</name><type>1</type><trkseg>';
  xmlString += fileBeginning;

  for (final line in coordinates) {
    for (final letter in line) {
      final elevationBase = 520;
      final randomElevation = elevationBase + Random().nextDouble() * 10;
      xmlString +=
          '<trkpt lat="${makeDoubleFuzzy(letter.lat)}" lon="${makeDoubleFuzzy(letter.lon)}"><ele>$randomElevation</ele><time>${tempDate.toIso8601String()}</time></trkpt>';
      tempDate = tempDate.add(Duration(minutes: Random().nextInt(3) + 3));
    }
  }

  final String fileEnding = '</trkseg></trk></gpx>';
  xmlString += fileEnding;

  await File("output.gpx").writeAsString(xmlString);
  print("Generated GPX file ✅");
}

/// This function makes a double value a little bit fuzzy to make it look more
/// realistic.
double makeDoubleFuzzy(double value) {
  final randomBool = Random().nextBool();
  if (randomBool) {
    return value - (Random().nextDouble() / 11000);
  }
  return value + (Random().nextDouble() / 11000);
}

List<LatLon> getCoordinatesOfALetter(String letter, LatLon sLatLon) {
  // This script can only handle big letter, so we transform all small letters
  // into big letters.
  letter = letter.toUpperCase();

  if (letter == " ") {
    return [LatLon(lat: sLatLon.lat, lon: sLatLon.lon + rasterSize)];
  }

  if (letter == "A") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    return list;
  }

  if (letter == "B") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "C") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat + (rasterSize / 4), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - (rasterSize / 4), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "D") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(
        lat: list.last.lat - (rasterSize / 3),
        lon: list.last.lon + rasterSize));
    list.add(
        LatLon(lat: list.last.lat - rasterSize * 1.34, lon: list.last.lon));
    list.add(LatLon(
        lat: list.last.lat - (rasterSize / 3),
        lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize * 0.5));
    return list;
  }

  if (letter == "E") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat + (rasterSize / 4), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - (rasterSize / 4), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "F") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "G") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "H") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat + rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    return list;
  }

  if (letter == "I") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(sLatLon);
    return list;
  }

  if (letter == "J") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize / 2), lon: sLatLon.lon));
    list.add(sLatLon);
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat + (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    return list;
  }

  if (letter == "K") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(
        lat: list.last.lat + rasterSize, lon: list.last.lon + rasterSize));
    list.add(LatLon(
        lat: list.last.lat - rasterSize, lon: list.last.lon - rasterSize));
    list.add(LatLon(
        lat: list.last.lat - rasterSize, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "L") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat + (rasterSize / 4), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - (rasterSize / 4), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "M") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(
        lat: list.last.lat - (rasterSize / 2),
        lon: list.last.lon + (rasterSize / 2)));
    list.add(LatLon(
        lat: list.last.lat + (rasterSize / 2),
        lon: list.last.lon + (rasterSize / 2)));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    return list;
  }

  if (letter == "N") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: sLatLon.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat + (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    return list;
  }

  if (letter == "O") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "P") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "Q") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "R") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat + (rasterSize * 2), lon: sLatLon.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(
        lat: list.last.lat - rasterSize, lon: list.last.lon + rasterSize));
    return list;
  }

  if (letter == "S") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat, lon: sLatLon.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat + rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat + rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat - rasterSize, lon: list.last.lon));
    return list;
  }

  if (letter == "T") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat, lon: sLatLon.lon + (rasterSize / 2)));
    list.add(LatLon(lat: list.last.lat + (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - (rasterSize / 2)));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + rasterSize));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon - (rasterSize / 2)));
    list.add(LatLon(lat: list.last.lat - (rasterSize * 2), lon: list.last.lon));
    list.add(LatLon(lat: list.last.lat, lon: list.last.lon + (rasterSize / 2)));
    return list;
  }

  if (letter == "U") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "V") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "W") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "X") {
    final list = <LatLon>[];
    return list;
  }

  if (letter == "Y") {
    final list = <LatLon>[];
    list.add(LatLon(lat: sLatLon.lat, lon: sLatLon.lon + (rasterSize / 2)));
    list.add(LatLon(lat: list.last.lat + rasterSize * 1.5, lon: list.last.lon));
    list.add(LatLon(
        lat: list.last.lat + (rasterSize / 2),
        lon: list.last.lon - (rasterSize / 2)));
    list.add(LatLon(
        lat: list.last.lat - (rasterSize / 2),
        lon: list.last.lon + (rasterSize / 2)));
    list.add(LatLon(
        lat: list.last.lat + (rasterSize / 2),
        lon: list.last.lon + (rasterSize / 2)));
    list.add(LatLon(
        lat: list.last.lat - (rasterSize / 2),
        lon: list.last.lon - (rasterSize / 2)));
    list.add(LatLon(lat: list.last.lat - rasterSize * 1.5, lon: list.last.lon));
    return list;
  }

  if (letter == "Z") {
    final list = <LatLon>[];
    return list;
  }

  throw Exception("This letter is not supported!");
}
