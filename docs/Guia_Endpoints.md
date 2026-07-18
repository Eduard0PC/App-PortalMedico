# Guía de Endpoints — Sistema de Citas Médicas

> **Qué es este documento:** una guía de referencia para probar la API desde **Postman/Swagger**
> y para que el **frontend** sepa qué endpoints existen, qué rol necesita cada uno, qué body
> enviar y qué errores puede recibir. Cubre todos los endpoints actualmente disponibles en el
> backend, organizados por módulo.

---

## Cómo autenticarse

1. Hacé login en el endpoint correspondiente (`/api/auth/pacientes/login`,
   `/api/auth/medicos/login` o `/api/auth/administradores/login`) o registrate como paciente en
   `/api/auth/pacientes/register`.
2. La respuesta incluye un `token` (JWT).
3. En cualquier otro endpoint, enviá ese token en el header:
   ```
   Authorization: Bearer {token}
   ```
4. Los únicos 4 endpoints que **no** requieren token son los de `/api/auth` (login y registro).

Roles del sistema: `Paciente`, `Medico`, `Administrador`.

**"(propio)"** en la columna Rol significa que, además del rol correcto, el `id` de la URL/query
debe coincidir con el usuario autenticado (por ejemplo, un paciente solo puede ver su propio
perfil, aunque conozca el `id` de otro).

---

## Cómo interpretar los errores

El manejo centralizado de errores todavía está en desarrollo. Esto significa que, **por ahora**,
muchos errores de negocio (recurso no encontrado, rol no permitido, credenciales inválidas,
conflictos de concurrencia) se ven en Swagger/Postman como un `500 Internal Server Error` genérico
con detalle técnico, en lugar del código HTTP que le corresponde semánticamente. La tabla de abajo
resume cómo leer esto hoy y qué vas a ver una vez que el manejo de errores esté completo:

| Tipo de error | Código HTTP correcto (una vez completado el manejo de errores) | Qué se ve HOY en Swagger/Postman |
|---|---|---|
| Recurso no encontrado (`id` inexistente) | `404 Not Found` | `500` con detalle técnico |
| Regla de negocio violada (ej. horario fuera de grilla, cancelación tardía) | `400 Bad Request` | `500` con detalle técnico |
| Rol incorrecto o recurso ajeno a otro usuario | `403 Forbidden` | `500` con detalle técnico |
| Correo o contraseña incorrectos | `401 Unauthorized` | `500` con detalle técnico |
| Conflicto de concurrencia (dos operaciones chocando, doble reserva del mismo horario) | `409 Conflict` | `500` con detalle técnico |
| Campo inválido (formato, longitud, obligatorio) | `400 Bad Request` | **✅ Ya funciona correctamente hoy** |

**En la práctica:** si probás un caso de error de negocio y te devuelve `500`, no es necesariamente
un bug — puede ser que el caso sí esté controlado a nivel de lógica (y lo vas a ver como el código
correcto más adelante), pero el mapeo final a código HTTP todavía no está conectado. Los errores de
**validación de campos** (formato de correo, longitud máxima, campo obligatorio, etc.) sí devuelven
ya el `400 Bad Request` correcto, con el detalle de qué campo falló.

La columna **"Casos de error controlados"** de cada tabla de abajo describe el comportamiento
esperado (el código HTTP final), no necesariamente lo que ves hoy literalmente en pantalla si el
manejo de errores para ese caso puntual todavía no está conectado.

Tampoco hay todavía un formato de respuesta uniforme tipo `{ success, data, message }` — los
ejemplos de abajo muestran la forma real que devuelve la API hoy (el objeto o la lista, sin
envoltorio).

---

## Resumen general

| Módulo | Base | Cantidad de endpoints |
|---|---|---|
| Autenticación | `/api/auth` | 4 |
| Pacientes | `/api/pacientes` | 4 |
| Especialidades | `/api/especialidades` | 4 |
| Médicos | `/api/medicos` | 5 |
| Horario y disponibilidad | `/api/medicos/{id}/horario` y `/disponibilidad` | 5 |
| Citas | `/api/citas` | 6 |
| Dashboard Admin | `/api/admin` | 1 |
| **Total** | | **29** |

---

## 1. Autenticación — `/api/auth`

4 endpoints públicos: registro de paciente y login de los 3 roles. Ninguno requiere token — son la
puerta de entrada al sistema. El login siempre devuelve la misma forma de respuesta (token + datos
básicos del usuario + rol), que el frontend usa para decidir a qué pantalla navegar.

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| POST | `/api/auth/pacientes/register` | Público | `201 Created` → `{ "token": "...", "id": 4, "nombreCompleto": "Juan Pérez", "correo": "...", "rol": "Paciente" }` | • Campos obligatorios vacíos, correo con formato inválido, password < 6 caracteres, fecha de nacimiento futura → `400 Bad Request`<br>• Correo ya registrado → `400 Bad Request` |
| POST | `/api/auth/pacientes/login` | Público | `200 OK` → `{ "token": "...", "rol": "Paciente", ... }` | • Correo inexistente o contraseña incorrecta → `401 Unauthorized` (mensaje genérico a propósito, no distingue cuál de los dos falló)<br>• Campos vacíos → `400 Bad Request` |
| POST | `/api/auth/medicos/login` | Público | `200 OK` → `{ "token": "...", "rol": "Medico", ... }` | • Correo inexistente o contraseña incorrecta → `401 Unauthorized`<br>• Médico dado de baja → `401 Unauthorized` (mismo mensaje genérico)<br>• Campos vacíos → `400 Bad Request` |
| POST | `/api/auth/administradores/login` | Público | `200 OK` → `{ "token": "...", "rol": "Administrador", ... }` | • Correo inexistente o contraseña incorrecta → `401 Unauthorized`<br>• Campos vacíos → `400 Bad Request` |

---

## 2. Pacientes — `/api/pacientes`

Un paciente autenticado solo puede ver/editar su propio perfil, aunque conozca el `id` de otro.
`GET /{id}/citas` es la excepción: Médico y Administrador también pueden consultarlo sin
restricción de propiedad, porque necesitan ver el historial clínico de cualquier paciente.

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| GET | `/api/pacientes/{id}` | Paciente (propio) | `200 OK` → `{ "id": 4, "nombre": "Juan", "apellido": "Pérez", "correo": "...", "telefono": "...", "fechaNacimiento": "1995-04-12", "fechaCreacion": "..." }` | • `id` no existe → `404 Not Found`<br>• Paciente pide el `id` de **otro** paciente → `403 Forbidden`<br>• Token de Médico o Administrador → `403 Forbidden`<br>• Sin token → `403 Forbidden` |
| PUT | `/api/pacientes/{id}` | Paciente (propio) | Body: `{ "nombre", "apellido", "telefono", "fechaNacimiento" }` → `200 OK` con el perfil actualizado | • Nombre/apellido vacío o > 100 caracteres → `400`<br>• Teléfono > 20 caracteres → `400`<br>• Fecha de nacimiento futura → `400`<br>• `id` no existe → `404`<br>• Paciente pide editar el `id` de otro → `403` |
| GET | `/api/pacientes?nombre=` | Médico, Administrador | `200 OK` → lista de pacientes (puede ser vacía) | • Sin `nombre` → `200 OK` con todos los pacientes (no es error)<br>• Sin coincidencias → `200 OK` con `[]`<br>• Token de Paciente → `403 Forbidden`<br>• Sin token → `403 Forbidden` |
| GET | `/api/pacientes/{id}/citas` | Paciente (propio), Médico, Administrador | `200 OK` → lista de citas con nombre del médico y especialidad ya resueltos | • `id` de paciente no existe → `404`<br>• Paciente pide el historial de otro paciente → `403`<br>• Paciente sin citas → `200 OK` con `[]` (no es error)<br>• Sin token → `403` |

---

## 3. Especialidades — `/api/especialidades`

`POST`/`PUT`/`DELETE` son exclusivos de Administrador. El `GET` puede usarlo tanto Paciente (para
el flujo de reserva de cita) como Administrador (para obtener los `id` que necesita al operar el
resto del módulo).

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| GET | `/api/especialidades` | Paciente, Administrador | `200 OK` → `[ { "id": 1, "nombre": "Cardiología", "descripcion": "..." } ]` | • Sin token → `403 Forbidden`<br>• Token de Médico → `403 Forbidden` (rol no permitido) |
| POST | `/api/especialidades` | Administrador | Body: `{ "nombre", "descripcion" }` → `201 Created` con la especialidad creada | • `nombre` vacío o > 100 caracteres → `400`<br>• `descripcion` > 255 caracteres → `400`<br>• Token de rol distinto a Administrador → `403`<br>• Sin token → `403` |
| PUT | `/api/especialidades/{id}` | Administrador | Body: `{ "nombre", "descripcion" }` → `200 OK` actualizado | • Mismas validaciones de longitud que `POST` → `400`<br>• `id` no existe → `404`<br>• Rol no permitido → `403` |
| DELETE | `/api/especialidades/{id}` | Administrador | `204 No Content` | • `id` no existe → `404`<br>• Especialidad con médicos asociados → `400 Bad Request`<br>• Rol no permitido → `403` |

---

## 4. Médicos — `/api/medicos`

`POST` da de alta datos del médico **y** su cuenta de login a la vez. Los 2 endpoints de lectura
son abiertos a los 3 roles, sin chequeo de propiedad — un médico no administra su propia ficha
desde acá, eso es exclusivo del Administrador.

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| GET | `/api/medicos?especialidadId=` | Paciente, Médico, Administrador | `200 OK` → `[ { "id": 1, "nombre": "Ana", "apellido": "Gómez", "correo": "...", "idEspecialidad": 1, "nombreEspecialidad": "Cardiología", "telefono": "...", "activo": true, "fechaCreacion": "..." } ]` | • Sin `especialidadId` → `200 OK` con todos los médicos (no es error)<br>• Sin coincidencias → `200 OK` con `[]`<br>• Sin token → `403` |
| GET | `/api/medicos/{id}` | Paciente, Médico, Administrador | `200 OK` → los datos de un médico | • `id` no existe → `404`<br>• Sin token → `403` |
| POST | `/api/medicos` | Administrador | Body: `{ "nombre", "apellido", "correo", "password", "idEspecialidad", "telefono" }` → `201 Created` | • Nombre/apellido vacío o > 100 → `400`<br>• Correo inválido o > 150 → `400`<br>• Password < 6 caracteres → `400`<br>• `idEspecialidad` ≤ 0 → `400`<br>• Teléfono > 20 → `400`<br>• Correo ya usado por otro médico → `400`<br>• `idEspecialidad` inexistente → `404`<br>• Rol no permitido → `403` |
| PUT | `/api/medicos/{id}` | Administrador | Body: `{ "nombre", "apellido", "idEspecialidad", "telefono" }` (sin correo ni password) → `200 OK` | • Mismas validaciones de formato que `POST` → `400`<br>• `id` de médico no existe → `404`<br>• `idEspecialidad` nueva inexistente → `404`<br>• Rol no permitido → `403` |
| PATCH | `/api/medicos/{id}/estado` | Administrador | Body: `{ "activo": false }` → `200 OK` con el médico actualizado | • `id` no existe → `404`<br>• Rol no permitido → `403`<br>• Efecto colateral esperado (no es error de este endpoint): un médico desactivado ya no puede loguearse en `/api/auth/medicos/login` |

---

## 5. Horario y disponibilidad — `/api/medicos/{id}/horario` y `/disponibilidad`

4 endpoints de gestión del horario semanal del médico (exclusivos de Administrador, salvo la
lectura que también puede hacer el propio médico) + 1 endpoint de cálculo de disponibilidad real
(exclusivo de Paciente, es el que arma la grilla de bloques de 30 minutos para reservar).

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| GET | `/api/medicos/{id}/horario` | Médico (propio), Administrador | `200 OK` → `[ { "id": 1, "idMedico": 3, "diaSemana": 1, "horaInicio": "08:30:00", "horaFin": "12:00:00" } ]` | • `id` de médico no existe → `404`<br>• Médico pide el horario de **otro** médico → `403`<br>• Token de Paciente → `403`<br>• Médico sin bloques cargados → `200 OK` con `[]` (no es error)<br>• Sin token → `403` |
| POST | `/api/medicos/{id}/horario` | Administrador | Body: `{ "diaSemana": 1, "horaInicio": "09:00:00", "horaFin": "12:00:00" }` → `201 Created` | • `diaSemana` fuera de 1-5 → `400`<br>• `horaFin` ≤ `horaInicio` → `400`<br>• `id` de médico no existe → `404`<br>• Rango solapado con otro bloque del mismo médico/día → `400`<br>• Rol no permitido → `403` |
| PUT | `/api/medicos/{id}/horario/{idHorario}` | Administrador | Body igual a `POST` → `200 OK` actualizado | • `diaSemana`/`horaFin` inválidos → `400`<br>• `idHorario` no existe → `404`<br>• `idHorario` pertenece a otro médico → `404`<br>• Rango solapado (excluyendo el propio) → `400`<br>• Rol no permitido → `403` |
| DELETE | `/api/medicos/{id}/horario/{idHorario}` | Administrador | `204 No Content` | • `idHorario` no existe → `404`<br>• `idHorario` pertenece a otro médico → `404`<br>• Rol no permitido → `403` |
| GET | `/api/medicos/{id}/disponibilidad?fecha=` | Paciente | `200 OK` → `[ { "horaInicio": "08:30:00", "horaFin": "09:00:00" }, ... ]` (bloques libres de 30 min) | • `id` de médico no existe → `404`<br>• `fecha` ausente o formato inválido → `400`<br>• `fecha` cae sábado/domingo → `200 OK` con `[]` (no es error)<br>• Médico sin horario ese día, o todo ocupado → `200 OK` con `[]` (no es error)<br>• Token de Médico o Administrador → `403` (rol no habilitado para este endpoint puntual) |

**Cómo funciona `/disponibilidad`:** toma los bloques de horario configurados para el médico ese
día, los parte en tramos de exactamente 30 minutos, y descarta los que ya se superponen con una
cita que no esté cancelada. El resultado es la lista de horarios que el paciente puede reservar.

---

## 6. Citas — `/api/citas`

El módulo central del sistema: reservar, listar, consultar, marcar como atendida, cancelar y
reagendar. Tiene dos protecciones importantes contra condiciones de carrera que conviene tener en
cuenta al probar:

1. **Doble reserva del mismo horario** (dos pacientes reservando a la vez): si dos personas
   intentan reservar exactamente el mismo bloque casi al mismo tiempo, solo una lo consigue; la
   otra recibe un error de conflicto en vez de que ambas queden agendadas.
2. **Edición simultánea de la misma cita**: los endpoints `atender`, `cancelar` y `reagendar`
   requieren enviar el campo `rowVersion` que viene en la respuesta de un `GET` previo. Si alguien
   más modificó esa cita mientras tanto, el `rowVersion` ya no coincide y la operación se rechaza
   con un error de conflicto — hay que volver a pedir la cita (`GET`) y reintentar con el
   `rowVersion` actualizado.

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| POST | `/api/citas` | Paciente | Body: `{ "idMedico", "fecha", "horaInicio", "motivoConsulta" }` → `201 Created` con la cita creada (incluye `rowVersion`) | • `horaInicio` no coincide con un bloque exacto de 30 min → `400`<br>• Bloque ya no disponible → `400`<br>• Bloque tomado por otra reserva simultánea → `409 Conflict`, nunca un `500` real una vez conectado el manejo de errores<br>• `idMedico` inexistente → `404`<br>• Rol no permitido → `403` |
| GET | `/api/citas?pacienteId=&medicoId=&fecha=&estado=` | Paciente (propio), Médico (propio), Administrador (todas) | `200 OK` → lista de citas con nombres resueltos | • Paciente pasa un `pacienteId` de otro paciente → se **ignora silenciosamente**, devuelve solo sus propias citas (no da error)<br>• Sin resultados → `200 OK` con `[]`<br>• Sin token → `403` |
| GET | `/api/citas/{id}` | Paciente (propio), Médico (propio), Administrador | `200 OK` → los datos completos de una cita | • `id` no existe → `404`<br>• Paciente o Médico piden una cita ajena → `403` |
| PATCH | `/api/citas/{id}/atender` | Médico (propio, el asignado a la cita) | Body: `{ "notaMedica", "rowVersion" }` → `200 OK` con `"estado": "Atendida"` | • Cita no existe → `404`<br>• Cita no está en estado `Programada` → `400`<br>• `notaMedica` vacía → `400`<br>• Médico distinto al asignado → `403`<br>• `rowVersion` no coincide (editada mientras tanto) → `409` |
| PATCH | `/api/citas/{id}/cancelar` | Paciente (propio, solo si falta **más de 1 día**), Administrador (sin restricción de tiempo) | Body: `{ "rowVersion" }` → `200 OK` con `"estado": "Cancelada"` y quién la canceló | • Cita no existe → `404`<br>• Cita ya cancelada o ya atendida → `400`<br>• Paciente cancela con ≤ 1 día de anticipación → `400`<br>• Paciente cancela una cita ajena → `403`<br>• `rowVersion` no coincide → `409` |
| PATCH | `/api/citas/{id}/reagendar` | Administrador | Body: `{ "fecha", "horaInicio", "rowVersion" }` → `200 OK` con la nueva fecha/hora | • Cita no existe → `404`<br>• Nuevo horario fuera de la grilla de 30 min → `400`<br>• Nuevo bloque ya ocupado → `400`/`409` según el caso<br>• Rol no permitido → `403`<br>• `rowVersion` no coincide → `409` |

**Nota:** `atender`, `cancelar` y `reagendar` usan `PATCH` (no `PUT`) porque son modificaciones
parciales de un solo aspecto de la cita, no un reemplazo completo de sus datos.

---

## 7. Dashboard Admin — `/api/admin`

Único endpoint pensado para el Administrador (la app de pacientes/médicos no tiene esta pantalla).
Es una lectura agregada simple, no recibe parámetros, así que no tiene casos de `404` ni `400` —
siempre responde `200` mientras el rol sea correcto.

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| GET | `/api/admin/dashboard` | Administrador | `200 OK` → `{ "fecha": "2026-07-18", "citasHoy": 3, "citasPorEstado": { "Programada": 12, "Atendida": 30, "Cancelada": 4 } }` | • Sin token o token con rol distinto a Administrador → `403 Forbidden` (único caso de error posible en este endpoint) |
