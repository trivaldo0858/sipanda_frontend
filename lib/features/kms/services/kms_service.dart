// lib/features/kms/services/kms_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/kms_model.dart';

class KmsService {
  final Dio _dio = ApiClient.instance.dio;

  Future<KmsModel> getKms(String nikAnak) async {
    try {
      final res = await _dio.get(
          ApiConstants.kms(nikAnak));
      return KmsModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}