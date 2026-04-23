// lib/features/auth/auth_injection.dart

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/auth_usecases.dart';
import 'presentation/providers/auth_provider.dart';

List<SingleChildWidget> authProviders() {
  // ── 1. DataSources ───────────────────────────────────────────────
  final remoteDataSource = AuthRemoteDataSourceImpl(
    dio: ApiClient.instance.dio,
  );
  final localDataSource = AuthLocalDataSourceImpl();

  // ── 2. Repository ────────────────────────────────────────────────
  final repository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource:  localDataSource,
  );

  // ── 3. UseCases ──────────────────────────────────────────────────
  final loginUseCase            = LoginUseCase(repository);
  final loginOrangTuaUseCase    = LoginOrangTuaUseCase(repository);
  final loginGoogleUseCase      = LoginGoogleUseCase(repository);
  final logoutUseCase           = LogoutUseCase(repository);
  final checkLoginUseCase       = CheckLoginUseCase(repository);
  final getPenggunaLokalUseCase = GetPenggunaLokalUseCase(repository);
  final getAnakLoginUseCase     = GetAnakLoginUseCase(repository);
  final ubahPasswordUseCase     = UbahPasswordUseCase(repository);

  // ── 4. Provider — positional constructor ─────────────────────────
  return [
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(
        loginUseCase,
        loginOrangTuaUseCase,
        loginGoogleUseCase,
        logoutUseCase,
        checkLoginUseCase,
        getPenggunaLokalUseCase,
        getAnakLoginUseCase,
        ubahPasswordUseCase,
      ),
    ),
  ];
}