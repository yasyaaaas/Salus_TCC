import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Serviço central de comunicação com o backend FastAPI do Salus.
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // aponta para o FastAPI rodando localmente no emulador Android

  // salva o token de autenticação no SharedPreferences
  Future<void> _saveToken(String token) async {
    // essa função demora, e quando terminar, não devolve nada de útil
    // assync -> indica que a função é assíncrona e pode demorar
    // await -> espera a resposta do servidor antes de continuar
    final prefs = await SharedPreferences.getInstance(); // pega a instância do SharedPreferences
    await prefs.setString('auth_token', token); // salva o token de autenticação no SharedPreferences
  }

  // pega o token de autenticação do SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance(); // pega a instância do SharedPreferences
    return prefs.getString('auth_token'); // retorna o token de autenticação do SharedPreferences
  }

  // // LOGOUT DO USUARIO -> remove o token de autenticação do SharedPreferences
  Future<void> ClearToken() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('auth_token');
  }

  // LOGIN DO USUARIO
  Future<ApiResult<String>> login({ // precisa de email e senha para logar
    required String email,
    required String password,
  }) async {
    try { // tenta fazer a requisição, se der erro, cai no catch
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // faz uma requisição POST para a URL de login do servidor FastAPI
        headers: {'Content-Type': 'application/json'}, // fala pro servidor que o corpo da requisição é JSON
        body: jsonEncode({ // pega um map do flutter e transforma em JSON
          'email': email, 
          'password': password
        }), 
      );

      if (response.statusCode == 200) { // caso o login seja bem sucedido, o servidor retorna 200
        final dados = jsonDecode(response.body); // pega o corpo da resposta do servidor e transforma em um map do flutter
        final token = dados['access_token'] as String; // o servidor retorna um map com o token de acesso
        await _saveToken(token); // salva o token de acesso no SharedPreferences
        return ApiResult.success(token); // retorna o token de acesso para a UI
      } else {
        final erro = jsonDecode(response.body);
        return ApiResult.failure(erro['detail']?.toString() ?? 'Erro inesperado'); // retorna a mensagem de erro para a GUI
      }
    } catch (_) {
      return ApiResult.failure('Não foi possível conectar ao servidor.');
    }
  } // SEMPRE RETORNAR UM ApiResult, NUNCA NULL

  // CADASTRO DE USUARIO - PASSO INTERMEDIARIO
  Future<ApiResult<Map<String, dynamic>>> _createRegister({ // <Map<String, dynamic>> -> guarda no mapa chave e o valor do dado retornado pela API
    required String fullName,
    required String email,
    required String password,
    required int age,
    required double weightKg,
    required int heightCm,
    required String gender,
  }) async {
    try {
      final response = await http.post( // wait -> se der um erro (ex. email já cadastrado) vai parar aqui
        Uri.parse('$baseUrl/users'), // faz uma requisição POST para a URL de cadastro do servidor FastAPI
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'age': age,
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'gender': gender,
        }),
      );

      if (response.statusCode == 201) { // caso o cadastro seja bem sucedido, o servidor retorna 201
        return ApiResult.success(jsonDecode(response.body)); // retorna os dados do usuário cadastrado para a UI
      } else {
        final erro = jsonDecode(response.body);
        return ApiResult.failure(
          erro['detail']?.toString() ?? 'Erro ao criar conta',
        );
      }
    } catch (_) {
      return ApiResult.failure('Não foi possível conectar ao servidor.');
    }
  }

  // CADASTRO DE USUARIO - PASSO FINAL
  Future<ApiResult<String>> register({
    required String fullName,
    required String email,
    required String password,
    required int age,
    required double weightKg,
    required int heightCm,
    required String gender,
  }) async {
    final resultadoCadastro = await _createRegister( // chama o registro do usuário, se der erro, retorna o erro para a UI
      fullName: fullName,
      email: email,
      password: password,
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      gender: gender,
    );

    if (!resultadoCadastro.isSuccess) {
      return ApiResult.failure(resultadoCadastro.error);
    } else {
      // Conta criada com sucesso, mas sem token -> loga automaticamente
      return login(email: email, password: password);
    }
  }

  // PQ SEPAROU OS DOIS PASSOS DE CADASTRO? -> pq o backend do FastAPI não retorna o token de acesso no cadastro
  //                                           então precisa logar automaticamente depois do cadastro

  // BUSCA PERFIL DO USUARIO LOGADO
  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    final token = await _getToken(); // pega o token de autenticação do SharedPreferences

    if (token == null) { // se não tem token pede para logar novamente
      return ApiResult.failure('Sessão expirada. Faça login novamente.');
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/users/me',
        ), // faz uma requisição GET para a URL de perfil do servidor FastAPI
        headers: {
          'Authorization': 'Bearer $token',
        }, // fala pro servidor que o token de autenticação está no cabeçalho da requisição
      );

      if (response.statusCode == 200) {
        return ApiResult.success(
          jsonDecode(response.body),
        ); // retorna os dados do perfil para a UI
      } else {
        final erro = jsonDecode(response.body);
        return ApiResult.failure(
          erro['detail']?.toString() ?? 'Erro ao buscar perfil',
        ); // retorna a mensagem de erro para a UI
      }
    } catch (_) {
      return ApiResult.failure('Não foi possível conectar ao servidor.');
    }
  }

  // ATUALIZA PERFIL DO USUARIO LOGADO
  Future<ApiResult<Map<String, dynamic>>> updateProfile({ // <Map<String, dynamic>> -> guarda no mapa chave e o valor do dado retornado pela API
    String? fullName,
    int? age,
    double? weightKg,
    int? heightCm,
    String? gender,
    String? avatar,
  }) async {
    final token = await _getToken();
    if (token == null) { // se não tem token pede para logar novamente
      return ApiResult.failure('Sessão expirada. Faça login novamente.');
    }

    // monta o corpo só com os campos que vieram preenchidos
    final Map<String, dynamic> corpo = {};
    if (fullName != null) corpo['full_name'] = fullName;
    if (age != null) corpo['age'] = age;
    if (weightKg != null) corpo['weight_kg'] = weightKg;
    if (heightCm != null) corpo['height_cm'] = heightCm;
    if (gender != null) corpo['gender'] = gender;
    if (avatar != null) corpo['avatar'] = avatar;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/edit'), // faz uma requisição PUT para a URL de atualização do perfil do servidor FastAPI
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(jsonDecode(response.body));
      } else {
        final erro = jsonDecode(response.body);
        return ApiResult.failure(
          erro['detail']?.toString() ?? 'Erro ao atualizar perfil',
        );
      }
    } catch (_) {
      return ApiResult.failure('Não foi possível conectar ao servidor.');
    }
  }

  // UPDATE AVATAR DO USUARIO LOGADO
  Future<ApiResult<Map<String, dynamic>>> updateAvatar(String avatarFileName) {
    return updateProfile(avatar: avatarFileName);
  }

  // USUARIO MANDA MENSAGEM
  Future<ApiResult<Map<String, dynamic>>> sendChatMessage(
    String mensagem,
  ) async {
    final token = await _getToken();
    if (token == null) { // se não tiver token da erro
      return ApiResult.failure('Sessão expirada. Faça login novamente.');
    }

    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/chat',
        ), //  faz uma requisição POST para a URL de chat do servidor FastAPI
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mensagem': mensagem,
        }), // mensagem do usuario é a mensagem enviada par o chat_services.py
      );

      if (response.statusCode == 200) {
        // se da sucesso pega o retorno da resposat do chat e manda na tela
        return ApiResult.success(jsonDecode(response.body));
      }

      final erro = jsonDecode(response.body);
      return ApiResult.failure(
        erro['detail']?.toString() ?? 'Erro ao enviar mensagem',
      ); // erro
    } catch (_) {
      return ApiResult.failure('Não foi possível conectar ao servidor.');
    }
  }

  // BUSCAR HISTÓRICO
  Future<ApiResult<List<dynamic>>> getChatHistory() async { // é uma lista de mensagens por isso o list<dynamic>
    final token = await _getToken();
    if (token == null) { // se não tiver token da erro
      return ApiResult.failure('Sessão expirada. Faça login novamente.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/history'), // faz uma requisição GET para a URL de histórico do servidor FastAPI
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) { // se der sucesso pega as respostas antigas em ordem decrescente
        return ApiResult.success(jsonDecode(response.body));
      }

      final erro = jsonDecode(response.body);
      return ApiResult.failure( // erro
        erro['detail']?.toString() ?? 'Erro ao buscar histórico',
      );
    } catch (_) {
      return ApiResult.failure('Não foi possível conectar ao servidor.');
    }
  }
}

// Resultado de chamadas a API | <t> -> guarda qualquer tipo de dados
class ApiResult<T> {
  final T? data; // guarda os dados retornados pela API se a chamada tenha sido bem sucedida
  final String? error; // guarda a mensagem de erro se a chamada tenha falhado
  final bool isSuccess; // indica se a chamada foi bem sucedida ou não

  ApiResult.success(this.data) // construtor para sucesso
      : error = null,
        isSuccess = true;

  ApiResult.failure(this.error) // construtor para falha
      : data = null,
        isSuccess = false;
}