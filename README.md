<div align="center">

# Portal Médico — Sistema de Gestión de Citas & Clínica

[![.NET 9](https://img.shields.io/badge/.NET-9.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-4169E1?logo=postgresql)](https://www.postgresql.org/)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-brightgreen)](#arquitectura-y-estructura)
[![MCP](https://img.shields.io/badge/AI-Model%20Context%20Protocol-orange)](#asistente-ia--mcp)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

*Plataforma integral de gestión de citas médicas con **.NET 9**, **Clean Architecture**, **PostgreSQL**, cliente multiplataforma en **Flutter** y **Asistente Virtual con IA** alimentado por OpenRouter y Model Context Protocol (MCP).*

</div>

---

## Tabla de Contenidos

- [Acerca del Proyecto](#acerca-del-proyecto)
- [Características Principales](#características-principales)
- [Stack Tecnológico](#stack-tecnológico)
- [Arquitectura y Estructura](#arquitectura-y-estructura)
- [Requisitos Previos](#requisitos-previos)
- [Configuración de Variables de Entorno & Secretos](#configuración-de-variables-de-entorno--secretos)
- [Guía de Instalación y Ejecución](#guía-de-instalación-y-ejecución)
  - [1. Base de Datos (PostgreSQL)](#1-base-de-datos-postgresql)
  - [2. Backend (.NET 9 Web API)](#2-backend-net-9-web-api)
  - [3. Frontend Móvil & Web (Flutter)](#3-frontend-móvil--web-flutter)
- [Asistente IA & MCP](#asistente-ia--mcp)
- [Documentación Adicional](#documentación-adicional)
- [Licencia](#licencia)

---

## Acerca del Proyecto

**Portal Médico** es una solución digital completa diseñada para modernizar la atención médica y agilizar la programación de consultas. Ofrece flujos de trabajo optimizados tanto para pacientes como para profesionales de la salud a través de una aplicación cliente unificada en Flutter, respaldada por una robusta arquitectura backend basada en **Clean Architecture** y capacidades conversacionales asistidas por Inteligencia Artificial.

---

## Características Principales

### Portal del Paciente (App Flutter)
- **Autenticación Segura**: Registro e inicio de sesión con correo y contraseña.
- **Reserva de Citas en Tiempo Real**:
  - Filtrado por especialidad médica y médico tratante.
  - Selección de horarios en bloques dinámicos de 30 minutos.
  - Registro del motivo de consulta.
- **Gestión de Citas**: Historial completo y estado de citas futuras.
- **Regla de Cancelación Controlada**: Cancelación automatizada permitida únicamente si faltan más de 24 horas para la consulta.
- **Asistente Virtual IA**: Chatbot inteligente para consultar médicos, especialidades y disponibilidad mediante lenguaje natural.

### Portal del Médico (App Flutter)
- **Agenda Semanal Interactiva**: Visualización clara de la jornada médica (Lunes a Viernes, 8:00 AM - 6:00 PM).
- **Atención Médica & Notas Clínicas**: Registro de consultas atendidas y notas médicas del paciente.
- **Historial Clínico**: Buscador en tiempo real de pacientes y sus registros previos.

### Portal del Administrador (Vía Swagger / API REST)
- **Dashboard Métrico**: Métricas de citas del día y resúmenes de atención.
- **Gestión de Personal Médico**: Alta, baja lógica y asignación de especialidades/horarios.
- **Control Global de Citas**: Reagendamiento y cancelación sin restricciones de tiempo.

---

## Stack Tecnológico

### Backend
- **Framework**: [.NET 9 Web API](https://dotnet.microsoft.com/)
- **Arquitectura**: Clean Architecture (Domain, Application, Infrastructure, API, MCP)
- **ORM**: Entity Framework Core 9 (Npgsql)
- **Autenticación**: JWT (JSON Web Tokens) & BCrypt para Hashing
- **AI & Integración**: OpenRouter API Client + Model Context Protocol (MCP) Server

### Base de Datos
- **Motor**: [PostgreSQL](https://www.postgresql.org/)

### Frontend (App Móvil & Web)
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Arquitectura**: Feature-First & Repository Pattern
- **Gestión de Estado**: Provider / `ChangeNotifier`
- **Cliente HTTP**: `Dio` con Interceptores JWT y Manejo de Errores
- **UI**: Material Design 3

---

## Arquitectura y Estructura

```text
App-PortalMedico/
├── backend/                             # Solución Backend (.NET 9)
│   ├── src/
│   │   ├── SistemaCitas.Domain/          # Entidades centrales, Enums y Contratos
│   │   ├── SistemaCitas.Application/     # Casos de uso, DTOs y Servicios
│   │   ├── SistemaCitas.Infrastructure/  # EF Core, PostgreSQL, JWT, OpenRouter Chat
│   │   ├── SistemaCitas.API/             # Controllers, Middlewares y OpenAPI/Swagger
│   │   └── SistemaCitas.Mcp/             # Herramientas MCP para el Asistente IA
│   └── gestorcitas.slnx
├── mobile/                              # Aplicación cliente unificada (Flutter)
│   ├── lib/
│   │   ├── core/                        # Estado global, Red (Dio), Tema y Repositorios
│   │   ├── features/                    # Módulos: auth, paciente, medico
│   │   └── shared/                      # Modelos DTOs y Widgets reutilizables
│   └── pubspec.yaml
├── db/                                  # Scripts de referencia SQL DDL
└── docs/                                # Especificación técnica y guía de endpoints
```

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- [.NET 9.0 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [PostgreSQL 13+](https://www.postgresql.org/download/) (o ejecución vía Docker)
- [Flutter SDK `>=3.0.0`](https://docs.flutter.dev/get-started/install) y Dart
- *(Opcional)* Herramienta global de EF Core CLI:
  ```bash
  dotnet tool install --global dotnet-ef
  ```

---

## Configuración de Variables de Entorno & Secretos

El backend lee la configuración desde `appsettings.json`, `appsettings.Development.json` o **Variables de Entorno**.

### Variables de Configuración

| Parámetro | Variable de Entorno | Descripción | Valor por defecto / Ejemplo |
|---|---|---|---|
| `ConnectionStrings:DefaultConnection` | `ConnectionStrings__DefaultConnection` | Cadena de conexión PostgreSQL | `Host=localhost;Database=SistemaCitasDB;Username=postgres;Password=postgres` |
| `Jwt:ClaveSecreta` | `Jwt__ClaveSecreta` | Clave secreta para JWT (>= 32 caracteres) | `TuClaveSecretaSuperSeguraYLargaDe32Caracteres!` |
| `Jwt:Issuer` | `Jwt__Issuer` | Emisor del token JWT | `SistemaCitasAPI` |
| `Jwt:Audience` | `Jwt__Audience` | Audiencia del token JWT | `SistemaCitasClientes` |
| `Jwt:ExpiracionMinutos` | `Jwt__ExpiracionMinutos` | Expiración del token (minutos) | `120` |
| `OpenRouter:ApiKey` | `OpenRouter__ApiKey` | API Key de OpenRouter (Asistente IA) | `sk-or-v1-...` |
| `OpenRouter:Model` | `OpenRouter__Model` | Modelo LLM (Opcional) | `qwen/qwen3-coder:free` |

### Plantilla de `appsettings.Development.json`

Crea o edita `backend/src/SistemaCitas.API/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=SistemaCitasDB;Username=postgres;Password=postgres"
  },
  "Jwt": {
    "ClaveSecreta": "TuClaveSecretaSuperSeguraYLargaDe32Caracteres!",
    "Issuer": "SistemaCitasAPI",
    "Audience": "SistemaCitasClientes",
    "ExpiracionMinutos": 120
  },
  "OpenRouter": {
    "ApiKey": "TU_OPENROUTER_API_KEY",
    "Model": "qwen/qwen3-coder:free"
  }
}
```

> **Nota de Desarrollo**: En entorno `Development`, la base de datos se inicializa y se alimenta automáticamente al iniciar la API gracias al `DbSeeder.cs` integrado.

---

## Guía de Instalación y Ejecución

### 1. Base de Datos (PostgreSQL)

Inicia el servicio de PostgreSQL en tu máquina local o mediante Docker:

```bash
docker run --name postgres-citas -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=SistemaCitasDB -p 5432:5432 -d postgres:latest
```

---

### 2. Backend (.NET 9 Web API)

1. Clona el repositorio e ingresa a la API:
   ```bash
   cd backend/src/SistemaCitas.API
   ```

2. Restaura las dependencias NuGet:
   ```bash
   dotnet restore
   ```

3. *(Opcional)* Aplica las migraciones de EF Core:
   ```bash
   dotnet ef database update --project ../SistemaCitas.Infrastructure
   ```

4. Inicia la API:
   ```bash
   dotnet run
   ```

- **URL base local**: `http://localhost:5250`  
- **Swagger / OpenAPI Specs**: `http://localhost:5250/openapi/v1.json`

---

### 3. Frontend Móvil & Web (Flutter)

1. Ingresa al directorio `mobile`:
   ```bash
   cd mobile
   ```

2. Descarga los paquetes de Flutter:
   ```bash
   flutter pub get
   ```

3. **Configuración de Host HTTP**:  
   En `mobile/lib/core/network/api_client.dart`:
   - **Navegador Web / Desktop**: `http://localhost:5250`
   - **Emulador Android**: `http://10.0.2.2:5250`

4. Ejecuta la aplicación:
   ```bash
   # En navegador Web (Chrome)
   flutter run -d chrome

   # En Android Emulator o Dispositivo
   flutter run

   # En Linux Desktop
   flutter run -d linux
   ```

---

## Asistente IA & MCP

La solución integra un chatbot médico accesible desde el perfil de Paciente en la aplicación móvil:
- **Tecnología**: Integra la API de OpenRouter con soporte para Tool Calling y el estándar **Model Context Protocol (MCP)** en la ruta `/mcp`.
- **Capacidades**: Permite a los pacientes realizar consultas en lenguaje natural como *"¿Qué cardiólogos están disponibles el próximo lunes por la tarde?"*.
- **Herramientas MCP Expuestas**:
  - `listar_especialidades`
  - `listar_medicos`
  - `obtener_disponibilidad_de_medico`
  - `buscar_medicos_disponibles`

---


