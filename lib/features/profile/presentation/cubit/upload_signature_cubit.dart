import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/core/services/local_signature_service.dart';
import 'upload_signature_state.dart';

class UploadSignatureCubit extends Cubit<UploadSignatureState> {
  UploadSignatureCubit({
    required LocalSignatureService localSignatureService,
  })  : _localSignatureService = localSignatureService,
        super(const UploadSignatureState.initial());

  final LocalSignatureService _localSignatureService;

  String _currentName() => state.maybeWhen(
        success: (signaturePath, name, number) => name,
        orElse: () => '',
      );

  String _currentNumber() => state.maybeWhen(
        success: (signaturePath, name, number) => number,
        orElse: () => '',
      );

  String? _currentPath() => state.maybeWhen(
        success: (signaturePath, name, number) => signaturePath,
        orElse: () => null,
      );

  Future<void> uploadSignature({required String filePath}) async {
    final name = _currentName();
    final number = _currentNumber();
    emit(const UploadSignatureState.loading());
    try {
      final savedPath =
          await _localSignatureService.saveSignature(filePath);
      emit(UploadSignatureState.success(
        signaturePath: savedPath,
        name: name,
        number: number,
      ));
    } catch (e) {
      emit(UploadSignatureState.error(e.toString()));
    }
  }

  Future<void> loadSignature() async {
    final file = await _localSignatureService.getSignature();
    final name = await _localSignatureService.getName() ?? '';
    final number = await _localSignatureService.getNumber() ?? '';
    if (file != null || name.isNotEmpty || number.isNotEmpty) {
      emit(UploadSignatureState.success(
        signaturePath: file?.path,
        name: name,
        number: number,
      ));
    }
  }

  Future<void> saveName(String name) async {
    await _localSignatureService.saveName(name);
    emit(UploadSignatureState.success(
      signaturePath: _currentPath(),
      name: name,
      number: _currentNumber(),
    ));
  }

  Future<void> saveNumber(String number) async {
    await _localSignatureService.saveNumber(number);
    emit(UploadSignatureState.success(
      signaturePath: _currentPath(),
      name: _currentName(),
      number: number,
    ));
  }

  Future<void> deleteSignature() async {
    emit(const UploadSignatureState.loading());
    try {
      await _localSignatureService.deleteSignature();
      emit(const UploadSignatureState.initial());
    } catch (e) {
      emit(UploadSignatureState.error(e.toString()));
    }
  }
}
