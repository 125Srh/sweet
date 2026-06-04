# sweet

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Información de configuración del proyecto

### 1) Dependencias / entorno (Flutter)

Archivo: `pubspec.yaml`

- SDK Dart/Flutter:
  - `environment: sdk: ^3.11.1`
- Paquetes relevantes usados por la app:
  - `supabase_flutter: ^2.12.4`
  - `provider: ^6.1.5+1`
  - `go_router: ^17.2.1`

### 2) Configuración de Supabase (actual)

Archivo: `lib/main.dart`

La inicialización de Supabase está **hardcodeada** en el `main()`:

- `Supabase.initialize(`
  - `url: 'https://olknfwrgwfxufjmrrdpk.supabase.co'`
  - `anonKey: 'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce'`
- Se ejecuta antes de `runApp(...)`.

> Nota: si planeas publicar el proyecto o compartirlo, se recomienda mover `url`/`anonKey` a un archivo de configuración (por ejemplo `.env`) para evitar credenciales en el repo.

