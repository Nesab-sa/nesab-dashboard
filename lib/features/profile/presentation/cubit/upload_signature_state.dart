import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_signature_state.freezed.dart';

@freezed
sealed class UploadSignatureState with _$UploadSignatureState {
  const factory UploadSignatureState.initial() = _Initial;
  const factory UploadSignatureState.loading() = _Loading;
  const factory UploadSignatureState.success({
    String? signaturePath,
    @Default('') String name,
    @Default('') String number,
  }) = _Success;
  const factory UploadSignatureState.error(String message) = _Error;
}
