import 'package:anttec_movil/data/repositories/auth/auth_repository.dart';
import 'package:anttec_movil/data/repositories/auth/auth_respository_remote.dart';
import 'package:anttec_movil/data/services/api/v1/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersRemote {
  return [
    Provider<AuthService>(create: (_) => AuthService()),
    Provider(create: (context) => AuthRespositoryRemote(authService: context.read(),) as AuthRepository)
  ];
}
