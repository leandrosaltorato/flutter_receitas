# Livro de Receitas (Flutter)

App Flutter que consome a API própria de receitas
(`https://receitasapi-b-2025.vercel.app`) com **CRUD completo**.

## Recursos
- `BottomNavigationBar` com 3 abas: **Receitas**, **Nova**, **Favoritas**
- Listar, buscar, filtrar por tipo (Doce / Salgada / Bebida), ver detalhes, cadastrar, editar e excluir
- Favoritas salvas no aparelho com `shared_preferences`

## Estrutura
```
lib/
  main.dart
  theme.dart
  models/receita.dart
  services/api_service.dart
  services/favoritos_service.dart
  screens/splash_screen.dart
  screens/home_shell.dart
  screens/receitas_page.dart
  screens/detalhe_page.dart
  screens/form_page.dart
  widgets/receita_card.dart
  widgets/receita_imagem.dart
```

## Como rodar

1. Crie o projeto base e copie esta pasta por cima (mantendo `android/`, `ios/` etc. gerados):
   ```bash
   flutter create livro_receitas
   ```
   Substitua `pubspec.yaml` e a pasta `lib/` pelos arquivos deste projeto
   (ou apenas copie a pasta `lib/` e rode os comandos abaixo).

2. Dependências:
   ```bash
   flutter pub add http
   flutter pub add intl
   flutter pub add shared_preferences
   flutter pub get
   ```

3. Em `android/app/src/main/AndroidManifest.xml`, **antes** da tag `<application>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

4. Executar:
   ```bash
   flutter run
   ```

5. Gerar o APK e colocar na pasta `assets` do repositório:
   ```bash
   flutter build apk --release
   cp build/app/outputs/flutter-apk/app-release.apk assets/livro_receitas.apk
   ```

[![Baixar APK](https://img.shields.io/badge/Baixar-APK-22C55E?style=for-the-badge&logo=android&logoColor=white)](app-release.apk)
