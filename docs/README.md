# Sistema de Citas Médicas — Especificación Técnica (Final)

## 1. Alcance del proyecto

- **Backend:** .NET Web API con **Clean Architecture** — expone **todos** los endpoints, incluidos los de administrador.
- **Base de datos:** SQL Server.
- **Frontend:** Flutter — **una sola app** con selector de rol al iniciar sesión (Paciente / Médico). No hay apps separadas.
- **No hay frontend Angular.** El módulo de administrador vive completo en el backend y se opera **exclusivamente vía Postman/Swagger**, de forma permanente (no está previsto construirle interfaz).
- **Fuera de alcance en esta versión:** recuperación de contraseña ("olvidé mi contraseña").
- **Equipo:** 2 personas — 1 Backend (.NET + SQL Server), 1 Frontend (Flutter).

---

## 2. Roles del sistema

| Rol | Se autentica | Consume desde |
|---|---|---|
| Paciente | Sí (registro propio) | App Flutter (flujo Paciente) |
| Médico | Sí (cuenta creada por admin) | App Flutter (flujo Médico) |
| Administrador | Sí (cuenta interna) | Postman/Swagger únicamente |

---

## 3. Modelo de datos

### 3.1 Especialidades
| Campo | Tipo | Notas |
|---|---|---|
| id_especialidad | int (PK) | |
| nombre | varchar(100) | Ej. Pediatría, Cardiología |
| descripcion | varchar(255) | Nullable |

### 3.2 Medicos
| Campo | Tipo | Notas |
|---|---|---|
| id_medico | int (PK) | |
| nombre, apellido | varchar(100) | |
| correo | varchar(150) | Único, usado para login |
| password_hash | varchar(255) | |
| id_especialidad | int (FK → Especialidades) | |
| telefono | varchar(20) | Nullable |
| activo | bit | Alta/baja lógica |
| fecha_creacion | datetime | |

### 3.3 Pacientes
| Campo | Tipo | Notas |
|---|---|---|
| id_paciente | int (PK) | |
| nombre, apellido | varchar(100) | |
| correo | varchar(150) | Único |
| password_hash | varchar(255) | |
| telefono | varchar(20) | Nullable |
| fecha_nacimiento | date | Nullable |
| fecha_creacion | datetime | |

### 3.4 Administradores
| Campo | Tipo | Notas |
|---|---|---|
| id_administrador | int (PK) | |
| nombre | varchar(100) | |
| correo | varchar(150) | Único |
| password_hash | varchar(255) | |
| fecha_creacion | datetime | |

### 3.5 HorarioMedico
Disponibilidad recurrente semanal de cada médico (base para calcular bloques de 30 min).

| Campo | Tipo | Notas |
|---|---|---|
| id_horario | int (PK) | |
| id_medico | int (FK → Medicos) | |
| dia_semana | int | 1=Lunes … 5=Viernes |
| hora_inicio | time | |
| hora_fin | time | |

### 3.6 Citas
Tabla central del sistema.

| Campo | Tipo | Notas |
|---|---|---|
| id_cita | int (PK) | |
| id_paciente | int (FK → Pacientes) | |
| id_medico | int (FK → Medicos) | |
| fecha | date | |
| hora_inicio | time | |
| hora_fin | time | fecha_inicio + 30 min |
| motivo_consulta | varchar(255) | |
| estado | varchar(20) | `Programada` / `Atendida` / `Cancelada` |
| nota_medica | text | Nullable, se llena al marcar como atendida |
| cancelada_por | varchar(20) | Nullable: `Paciente` / `Administrador` |
| fecha_creacion | datetime | |
| fecha_actualizacion | datetime | |

**Relaciones:** Especialidades 1—N Medicos · Medicos 1—N HorarioMedico · Medicos 1—N Citas · Pacientes 1—N Citas

*(Diagrama ER compartido previamente — sigue vigente, no cambió.)*

---

## 4. Reglas de negocio (viven en el backend, no en la BD)

1. **Disponibilidad de horarios:** se calcula dinámicamente — se toma el `HorarioMedico` del día solicitado, se parte en bloques de 30 min, y se descartan los que ya existan en `Citas` con estado ≠ `Cancelada`.
2. **Cancelación por parte del paciente:** solo permitida si faltan **más de 1 día** entre `fecha`+`hora_inicio` de la cita y el momento actual. Si no se cumple, el backend responde con un error controlado (no un 500) que el frontend traduce al aviso de "llama a la clínica".
3. **Cancelación por administrador:** no aplica la regla anterior (puede cancelar en cualquier momento, ej. emergencia del médico).
4. **Contraseñas:** hash con bcrypt (o `BCrypt.Net`). Nunca texto plano. Sin flujo de recuperación en esta versión — si un paciente o médico la olvida, se resuelve manualmente (fuera de alcance del sistema por ahora).
5. **Autenticación:** JWT. El token incluye el rol (`Paciente` / `Medico` / `Administrador`) y el id correspondiente. Este rol es lo que la app Flutter usa para decidir a qué flujo enrutar tras el login.
6. **Permisos por rol:** un paciente solo puede ver/modificar sus propias citas y perfil; un médico solo su propia agenda; el administrador tiene acceso total.

---

## 5. Endpoints del Backend

Convención de respuesta sugerida: JSON con `{ "success": bool, "data": ..., "message": string }` y códigos HTTP estándar (200/201/400/401/403/404). Auth vía header `Authorization: Bearer {token}` salvo donde se indique "Público".

### 5.1 Autenticación — `/api/auth`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| POST | `/api/auth/pacientes/register` | Registro de paciente | Público |
| POST | `/api/auth/pacientes/login` | Login de paciente | Público |
| POST | `/api/auth/medicos/login` | Login de médico | Público |
| POST | `/api/auth/administradores/login` | Login de administrador | Público |

### 5.2 Pacientes — `/api/pacientes`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| GET | `/api/pacientes/{id}` | Ver perfil propio | Paciente (propio) |
| PUT | `/api/pacientes/{id}` | Editar perfil propio | Paciente (propio) |
| GET | `/api/pacientes?nombre=` | Buscar pacientes por nombre | Médico, Administrador |
| GET | `/api/pacientes/{id}/citas` | Historial de citas de un paciente | Paciente (propio), Médico, Administrador |

### 5.3 Especialidades — `/api/especialidades`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| GET | `/api/especialidades` | Listar especialidades | Paciente (para el flujo de reserva) |
| POST | `/api/especialidades` | Crear especialidad | Administrador |
| PUT | `/api/especialidades/{id}` | Editar especialidad | Administrador |
| DELETE | `/api/especialidades/{id}` | Eliminar especialidad | Administrador |

### 5.4 Médicos — `/api/medicos`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| GET | `/api/medicos?especialidadId=` | Listar médicos (filtro opcional) | Paciente, Médico, Admin |
| GET | `/api/medicos/{id}` | Detalle de un médico | Paciente, Médico, Admin |
| POST | `/api/medicos` | Alta de médico (crea datos + cuenta) | Administrador |
| PUT | `/api/medicos/{id}` | Editar datos/especialidad | Administrador |
| PATCH | `/api/medicos/{id}/estado` | Activar/desactivar médico | Administrador |

### 5.5 Horario y disponibilidad — `/api/medicos/{id}/horario`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| GET | `/api/medicos/{id}/horario` | Ver horario semanal configurado | Médico (propio), Admin |
| POST | `/api/medicos/{id}/horario` | Agregar bloque de horario | Administrador |
| PUT | `/api/medicos/{id}/horario/{idHorario}` | Editar bloque de horario | Administrador |
| DELETE | `/api/medicos/{id}/horario/{idHorario}` | Eliminar bloque de horario | Administrador |
| GET | `/api/medicos/{id}/disponibilidad?fecha=` | Bloques de 30 min disponibles ese día | Paciente |

### 5.6 Citas — `/api/citas`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| POST | `/api/citas` | Reservar cita | Paciente |
| GET | `/api/citas?pacienteId=&medicoId=&fecha=&estado=` | Listar citas con filtros | Paciente (propio), Médico (propio), Admin (todas) |
| GET | `/api/citas/{id}` | Detalle de una cita | Paciente (propio), Médico (propio), Admin |
| PATCH | `/api/citas/{id}/atender` | Marcar como atendida + nota médica | Médico |
| PATCH | `/api/citas/{id}/cancelar` | Cancelar cita (valida regla de +1 día si es paciente) | Paciente (propio), Administrador |
| PATCH | `/api/citas/{id}/reagendar` | Cambiar fecha/hora de una cita | Administrador |

### 5.7 Dashboard — `/api/admin`
| Método | Endpoint | Descripción | Rol |
|---|---|---|---|
| GET | `/api/admin/dashboard` | Resumen: citas de hoy, totales por estado | Administrador |

---

## 6. Arquitectura del Backend — .NET Clean Architecture

Estructura de proyecto en capas, cada una como su propio proyecto dentro de la solución:

```
/src
  SistemaCitas.Domain          → Entidades (Paciente, Medico, Cita, Especialidad,
                                  Administrador, HorarioMedico), enum EstadoCita,
                                  interfaces de repositorio (IPacienteRepository, etc.)
  SistemaCitas.Application      → Casos de uso / servicios, DTOs de entrada y salida,
                                  validaciones (FluentValidation), interfaces de
                                  servicios (IAuthService, ICitaService, IJwtService...)
  SistemaCitas.Infrastructure   → DbContext de EF Core, implementación de los
                                  repositorios, configuración de SQL Server,
                                  hashing de contraseñas, generación de JWT
  SistemaCitas.API              → Controllers (uno por módulo de la sección 5),
                                  middlewares (auth, manejo global de errores),
                                  Swagger, inyección de dependencias (Program.cs)
```

**Regla de dependencia:** `API → Application → Domain`, con `Infrastructure` implementando las interfaces definidas en `Application`/`Domain`. Domain no depende de nada.

Cada módulo de la sección 5 (Auth, Pacientes, Especialidades, Médicos, Horario, Citas, Admin) se traduce en: 1 Controller en `API`, 1-2 servicios/casos de uso en `Application`, y el repositorio correspondiente en `Infrastructure`.

---

## 7. Arquitectura del Frontend — Flutter (app única)

Una sola app; el login es único (`/api/auth/.../login`) y, según el rol que venga en el JWT de la respuesta, la app enruta internamente al flujo de Paciente o al de Médico.

```
/lib
  core/            → cliente HTTP (Dio), interceptor de JWT, tema, widgets
                     compartidos, manejo de errores
  features/
    auth/          → pantalla de login única + registro de paciente
    paciente/      → reservar cita (especialidad → médico → calendario → motivo),
                     mis citas, cancelar
    medico/        → agenda semanal, marcar cita como atendida + nota,
                     buscador de historial por paciente
  shared/          → modelos compartidos entre features (Cita, Medico, Especialidad)
```

**Ruteo post-login:** al recibir el JWT, decodificar el claim de rol → si es `Paciente`, navegar al home de Paciente; si es `Medico`, navegar al home de Médico. El administrador no tiene pantalla en la app (opera por Postman).

---

## 8. División de trabajo sugerida

### Backend (.NET)
- [ ] Setup de la solución en Clean Architecture (4 proyectos de la sección 6)
- [ ] Migraciones de EF Core según el modelo de datos (sección 3) sobre SQL Server
- [ ] Autenticación JWT + middleware de autorización por rol
- [ ] Módulos de auth + CRUD de Pacientes/Médicos/Especialidades
- [ ] Lógica de disponibilidad (bloques de 30 min) y validación de cancelación (regla +1 día)
- [ ] Endpoints de Citas (reservar, listar con filtros, atender, cancelar, reagendar)
- [ ] Dashboard de administrador
- [ ] Swagger como contrato vivo para el frontend

### Frontend (Flutter)
- [ ] Capa de red (Dio) + interceptor de JWT + decodificación de rol para el ruteo
- [ ] Pantalla de login única + registro de paciente
- [ ] **Flujo Paciente:** especialidad → médico → calendario de disponibilidad → confirmar motivo, "Mis citas" (futuras/pasadas), cancelar
- [ ] **Flujo Médico:** agenda semanal (Lunes–Viernes), marcar cita como atendida + nota, buscador de historial por nombre de paciente
- [ ] Manejo de estado (Provider/Riverpod/Bloc — a elección del frontend)

---

## 9. Decisiones finales del equipo

| Pregunta | Decisión |
|---|---|
| ¿App Flutter única o dos apps? | **Una sola app** con selector de rol vía JWT tras el login |
| Motor de base de datos y arquitectura backend | **SQL Server** + **.NET Clean Architecture** |
| ¿Recuperación de contraseña en esta versión? | **No**, fuera de alcance |
| ¿Interfaz para administrador? | **No**, opera únicamente vía Postman/Swagger, de forma permanente |
