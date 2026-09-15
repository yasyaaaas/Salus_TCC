# Salus App

Aplicativo mobile desenvolvido em **Flutter** que permite ao usuário relatar sintomas, enviar exames laboratoriais e encontrar unidades de saúde próximas, sempre com moderação ética e sem substituir o diagnóstico médico.

## Estrutura do projeto
``` bash 
salus/
├── lib/
│ ├── main.dart # Ponto de entrada do app (rotas e configuração)
│ ├── core/
│ │ ├── constants/ # Cores, textos, avatares e termos legais
│ │ ├── services/
│ │ │ └── api_service.dart # Comunicação com o backend FastAPI
│ │ └── theme/
│ │ └── app_theme.dart # Tema visual global
│ ├── features/ # Telas organizadas por funcionalidade
│ │ ├── onboarding/ # Tela inicial de apresentação
│ │ ├── auth/ # Cadastro e login
│ │ ├── chat/ # Chatbot de sintomas
│ │ ├── exams/ # Análise de exames laboratoriais
│ │ ├── location/ # Unidades de saúde próximas
│ │ └── profile/ # Perfil do usuário e histórico
│ └── shared/
│ └── widgets/ # Componentes reutilizáveis (barra de navegação, avisos)
├── pubspec.yaml # Dependências e configuração do projeto
└── android/, ios/, web/ # Configurações específicas de cada plataforma
```

## Como rodar

```bash
cd Salus_TCC/salus

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```
Nota: Para testar no emulador Android, o backend deve estar acessível em http://10.0.2.2:8000. Para dispositivo físico, use adb reverse tcp:8000 tcp:8000.

## Tecnologias
- Flutter + Dart
- flutter_map + latlong2 (mapas com OpenStreetMap)
- geolocator (GPS)
- file_picker (seleção de PDFs)
- http + shared_preferences
