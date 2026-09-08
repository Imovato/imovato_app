import 'package:flutter/material.dart';

import 'app/app.dart';
import 'shared/services/auth_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const demoMode = bool.fromEnvironment('IMOVATO_DEMO', defaultValue: true);
  if (!demoMode) {
    await AuthStorageService().clearAuthData();
  }

  runApp(const App(demoMode: demoMode));
}

//TODO: Criar uma estrutura de pastas para o backend.
//TODO: Estruturar uma camada de comunicacao HTTP.
//TODO: Configurar o cliente HTTP.
//TODO: Criar o service que consome os endpoints.
//TODO: Adaptar o modelo.
//TODO: Usar o repository no controller / provider
//TODO: Integre com seu estado (Provider, Riverpod, etc.)
//TODO: Autenticação.
//TODO: Configurar arquivos para ambientes (.env)

//Fluxo visual da requisicao: Flutter UI → Controller (Provider) → Repository → Dio → Backend Java

//TODO: Validar se o usuário está logado ao tentar pagar.
