import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}


//TODO: Estruturar uma camada de comunicacao HTTP.
//TODO: Criar uma estrutura de pastas para o backend.
//TODO: Configurar o cliente HTTP.
//TODO: Criar o service que consome os endpoints.
//TODO: Adaptar o modelo.
//TODO: Usar o repository no controller / provider
//TODO: Integre com seu estado (Provider, Riverpod, etc.)
//TODO: Autenticação.
//TODO: Configurar arquivos para ambientes (.env)


//Fluxo visual da requisicao: Flutter UI → Controller (Provider) → Repository → Dio → Backend Java



//TODO: Validar se o usuário está logado ao tentar pagar.

