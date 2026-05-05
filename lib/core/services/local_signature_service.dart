import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for saving and loading a single signature image locally,
/// along with the signer's name and phone number.
class LocalSignatureService {
  static const String _signatureFileName = 'user_signature.png';
  static const String _nameKey = 'signature_name';
  static const String _numberKey = 'signature_number';

  Future<String> _getSignaturePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_signatureFileName';
  }

  /// Saves the image at [filePath] as the user's signature.
  /// Returns the local path of the saved signature.
  Future<String> saveSignature(String filePath) async {
    final destPath = await _getSignaturePath();
    final sourceFile = File(filePath);
    await sourceFile.copy(destPath);
    return destPath;
  }

  /// Returns the saved signature file, or null if none exists.
  Future<File?> getSignature() async {
    final path = await _getSignaturePath();
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }

  /// Returns the saved signature as a base64 string, or null if none exists.
  Future<String?> getSignatureBase64() async {
    final file = await getSignature();
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Deletes the saved signature, name, and number.
  Future<void> deleteSignature() async {
    final path = await _getSignaturePath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_numberKey);
  }

  /// Whether a signature has been saved.
  Future<bool> hasSignature() async {
    final path = await _getSignaturePath();
    return File(path).exists();
  }

  /// Saves the signer's name.
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  /// Returns the saved signer name, or null if not set.
  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Saves the signer's phone number.
  Future<void> saveNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_numberKey, number);
  }

  /// Returns the saved signer phone number, or null if not set.
  Future<String?> getNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_numberKey);
  }
}
