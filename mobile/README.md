# Portal Médico — Aplicación Móvil (Flutter)

Aplicación móvil desarrollada en **Flutter** para el Sistema de Gestión de Portal Médico. Proporciona una interfaz moderna, intuitiva y reactiva con navegación dinámicamente adaptada según el rol del usuario autenticado (**Paciente** o **Médico**).

---

## Alcance y Descripción General

La aplicación móvil es la única interfaz de usuario cliente del sistema. Se conecta con la API RESTful del backend en .NET para ofrecer flujos de trabajo especializados para pacientes y profesionales de la salud.

### Principales Características por Rol

#### Portal del Médico
- **Agenda Semanal Interactiva**: Visualización clara de la programación semanal de citas (Lunes a Viernes, 8:00 AM - 6:00 PM), detallando hora, nombre del paciente y motivo de consulta.
- **Atención de Consultas**: Flujo para marcar citas como atendidas y registrar notas clínicas.
- **Historial de Pacientes**: Búsqueda en tiempo real de pacientes y consulta detallada de su historial de atenciones previas y notas médicas.
- **Gestión de Perfil**: Actualización de información de contacto y especialidad médica.

#### Portal del Paciente
- **Reserva de Citas**: Flujo asistido paso a paso para agendar citas:
  1. Selección de especialidad.
  2. Selección de médico disponible.
  3. Selección de fecha y bloque de horario (intervalos de 30 minutos).
  4. Confirmación del motivo de consulta.
- **Gestión de Mis Citas**: Listado de citas agendadas y completadas con opción de cancelación (aplicando la regla de negocio de cancelación permitida con más de 24 horas de anticipación).
- **Asistente Virtual con IA**: Chat interactivo integrado con Inteligencia Artificial para responder dudas médicas frecuentes y brindar sugerencias rápidas.
- **Gestión de Perfil**: Modificación de datos personales (teléfono, fecha de nacimiento, etc.).

---

## Arquitectura y Estructura del Proyecto

El proyecto sigue una arquitectura **Feature-First** limpia y modular, separando la lógica de negocio, acceso a datos e interfaz de usuario.

```text
mobile/
├── lib/
│   ├── main.dart                  # Punto de entrada de la aplicación
│   ├── core/                      # Núcleo de la aplicación
│   │   ├── app_state.dart         # Estado global centralizado (Provider)
│   │   ├── theme.dart             # Sistema de diseño y tema visual (Material 3)
│   │   ├── network/               # Cliente HTTP (Dio) e interceptor JWT
│   │   └── repositories/          # Repositorios de datos
│   │       ├── auth_repository.dart
│   │       ├── citas_repository.dart
│   │       ├── medicos_repository.dart
│   │       ├── pacientes_repository.dart
│   │       └── chat_repository.dart
│   ├── features/                  # Módulos por funcionalidad
│   │   ├── auth/                  # Inicio de sesión y registro de pacientes
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── paciente/              # Vistas del portal de paciente
│   │   │   ├── paciente_home_screen.dart
│   │   │   ├── reservar_cita_view.dart
│   │   │   ├── mis_citas_view.dart
│   │   │   └── chat_view.dart
│   │   └── medico/                # Vistas del portal de médico
│   │       ├── medico_home_screen.dart
│   │       ├── agenda_view.dart
│   │       └── historial_pacientes_view.dart
│   └── shared/                    # Componentes y modelos compartidos
│       ├── models/                # DTOs (Cita, Medico, Paciente, ChatMessage, etc.)
│       └── widgets/               # Modales y widgets reutilizables (ej. EditarPerfilModal)
└── pubspec.yaml                   # Configuración y dependencias del proyecto Flutter
```

---

## Tecnologías y Librerías

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Manejo de Estado**: `Provider` (`ChangeNotifier`) con patrón de Repositorios.
- **Cliente HTTP**: `Dio` con interceptores para inyección automática de JWT y captura global de errores.
- **Interfaz de Usuario**: Material Design 3, componentes personalizados y modales reactivos.
- **Fuentes y Tipografía**: `google_fonts` (Inter / Outfit).

---

## Requisitos e Instalación

### Prerrequisitos
- Flutter SDK (versión `>=3.0.0`)
- Dart SDK
- Emulador de Android / iOS o dispositivo físico configurado

### Pasos de Ejecución

1. **Obtener las dependencias del proyecto**:
   ```bash
   flutter pub get
   ```

2. **Configurar el endpoint del Backend**:
   Verificar la URL base de la API en `lib/core/network/api_client.dart` para apuntar a la dirección del servidor (ej. `http://localhost:5000/api` o IP local para emuladores).

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

---

## Autenticación y Flujo de Navegación

1. **Pantalla de Login**: Permite el ingreso tanto a Pacientes como a Médicos.
2. **Intercepción JWT**: El token de autenticación devuelto se almacena localmente y se decodifica para extraer el rol del usuario (`Paciente` o `Medico`).
3. **Enrutamiento Dinámico**:
   - **Rol Paciente** ➔ Dirige automáticamente a `PacienteHomeScreen`.
   - **Rol Médico** ➔ Dirige automáticamente a `MedicoHomeScreen`.
