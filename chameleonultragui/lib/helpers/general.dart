import 'dart:io';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:chameleonultragui/bridge/chameleon.dart';

Future<void> asyncSleep(int milliseconds) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}

String bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

String bytesToHexSpace(Uint8List bytes) {
  return bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join(' ')
      .toUpperCase();
}

Uint8List hexToBytes(String hex) {
  List<int> bytes = [];
  for (int i = 0; i < hex.length; i += 2) {
    int byte = int.parse(hex.substring(i, i + 2), radix: 16);
    bytes.add(byte);
  }
  return Uint8List.fromList(bytes);
}

int bytesToU32(Uint8List byteArray) {
  return byteArray.buffer.asByteData().getUint32(0, Endian.big);
}

int bytesToU64(Uint8List byteArray) {
  return byteArray.buffer.asByteData().getUint64(0, Endian.big);
}

Uint8List u64ToBytes(int u64) {
  final ByteData byteData = ByteData(8)..setUint64(0, u64, Endian.big);
  return byteData.buffer.asUint8List();
}

bool isValidHexString(String hexString) {
  final hexPattern = RegExp(r'^[A-Fa-f0-9]+$');
  return hexPattern.hasMatch(hexString);
}

int calculateCRC32(List<int> data) {
  Uint8List bytes = Uint8List.fromList(data);
  Uint32List crcTable = generateCRCTable();
  int crc = 0xFFFFFFFF;

  for (int i = 0; i < bytes.length; i++) {
    crc = (crc >> 8) ^ crcTable[(crc ^ bytes[i]) & 0xFF];
  }

  crc = crc ^ 0xFFFFFFFF;
  return crc;
}

Uint32List generateCRCTable() {
  Uint32List crcTable = Uint32List(256);
  for (int i = 0; i < 256; i++) {
    int crc = i;
    for (int j = 0; j < 8; j++) {
      if ((crc & 1) == 1) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc = crc >> 1;
      }
    }
    crcTable[i] = crc;
  }
  return crcTable;
}

String chameleonTagToString(ChameleonTag tag) {
  if (tag == ChameleonTag.mifareMini) {
    return "Mifare Mini";
  } else if (tag == ChameleonTag.mifare1K) {
    return "Mifare Classic 1K";
  } else if (tag == ChameleonTag.mifare2K) {
    return "Mifare Classic 2K";
  } else if (tag == ChameleonTag.mifare4K) {
    return "Mifare Classic 4K";
  } else if (tag == ChameleonTag.em410X) {
    return "EM410X";
  } else if (tag == ChameleonTag.ntag213) {
    return "NTAG213";
  } else if (tag == ChameleonTag.ntag215) {
    return "NTAG215";
  } else if (tag == ChameleonTag.ntag216) {
    return "NTAG216";
  } else {
    return "Unknown";
  }
}

ChameleonTag getTagTypeByValue(int value) {
  return ChameleonTag.values.firstWhere((element) => element.value == value,
      orElse: () => ChameleonTag.unknown);
}

String platformToPath() {
  if (Platform.isAndroid) {
    return "android";
  } else if (Platform.isIOS) {
    return "ios";
  } else if (Platform.isLinux) {
    return "linux";
  } else if (Platform.isMacOS) {
    return "macos";
  } else if (Platform.isWindows) {
    return "windows";
  } else {
    return "../";
  }
}

String numToVerCode(int versionCode) {
  int major = (versionCode >> 8) & 0xFF;
  int minor = versionCode & 0xFF;
  return '$major.$minor';
}
