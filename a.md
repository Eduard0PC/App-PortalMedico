---
 
## Paso 9 — Verificación
 
Desde `monorepo/backend`:
 
 
Debe salir `Build succeeded`.
 
Luego, con la API corriendo (`dotnet run --project src/SistemaCitas.API`), abrí Swagger y usá el
botón "Authorize" con tokens JWT (Fase 5): vas a necesitar uno de Paciente, uno de Médico (si ya
existe alguno creado — si no, alcanza con el de Paciente y Administrador para la mayoría de los
casos) y uno de Administrador.
 
**Casos de éxito para probar:**
 
1. Login como Paciente (el registrado en la Fase 5) → copiar el token y su `id` (viene en la
   respuesta del login).
2. `GET /api/pacientes/{id}` con ese `id` y el token del propio paciente → `200 OK` con su
   `PacienteDto`.
3. `PUT /api/pacientes/{id}` con:
```json
   { "nombre": "Juan", "apellido": "Pérez", "telefono": "5599998888", "fechaNacimiento": "1995-04-12" }
```
   Debe responder `200 OK` con los datos actualizados.
4. Login como Administrador → `GET /api/pacientes?nombre=Juan` → `200 OK` con la lista de
   coincidencias (al menos el paciente de arriba).
5. `GET /api/pacientes/{id}/citas` con el token del propio paciente (o el de Administrador) → `200
   OK` con `[]` si todavía no existe ninguna cita (el módulo Citas es de una fase posterior) — es el
   resultado esperado, no un error.
 
**Casos de error para confirmar que `ValidationBehavior` y `AuthorizationBehavior` ya funcionan:**
 
- `PUT /api/pacientes/{id}` con `"nombre": ""` → `400 Bad Request` con el detalle del campo
  `Nombre` (esto lo maneja `ValidationBehavior`, no depende del middleware de la Fase 12).
- `PUT /api/pacientes/{id}` con `"fechaNacimiento": "2099-01-01"` → `400 Bad Request`.
- `GET /api/pacientes/{id}` con el token de un paciente **distinto** al `id` de la ruta → `500`
  crudo por ahora (`AccesoDenegadoException` sin capturar; en la Fase 12 será `403`). Confirmá que
  la respuesta **no** trae los datos del otro paciente — es la señal de que
  `AuthorizationBehavior` cortó la ejecución antes del Handler por el chequeo de `IOwnedRequest`.
- `GET /api/pacientes?nombre=` con el token de un Paciente → `500` crudo por ahora (rol no
  permitido), pero no debe devolver la lista.
- `GET /api/pacientes/{id}/citas` con el token de un Médico y un `id` de paciente cualquiera →
  `200 OK` (sin chequeo de propiedad, tal como se explicó en el Paso 6) — confirmá que **no** da
  error, a diferencia del caso anterior.
---
 
## Con esto queda completa la Fase 7
 
En `TODO-backend-sistema-citas.md` podés marcar como hechos:
 
- [x] `GET /api/pacientes/{id}` — Paciente (propio)
- [x] `PUT /api/pacientes/{id}` — Paciente (propio)
- [x] `GET /api/pacientes?nombre=` — Médico, Admin
- [x] `GET /api/pacientes/{id}/citas` — Paciente (propio), Médico, Admin
Adiciones no listadas literalmente en el TODO pero incorporadas en esta fase:
 
- [x] Primer uso real de `IOwnedRequest` (Fase 4) en 3 de los 4 endpoints — `AuthorizationBehavior`
      queda ejercitado tanto en su chequeo de rol como en su chequeo de propiedad del recurso
- [x] Validación de "el paciente existe" antes de listar su historial de citas (Paso 6), para
      distinguir `404` (paciente inexistente) de `200` con lista vacía (paciente sin citas todavía)
- [x] Ajuste en `CitaRepository.ListarAsync` (Fase 2, Paso 7 de esta guía): agrega
      `Include(Medico).ThenInclude(Especialidad)` para poder mostrar nombres en vez de solo ids en
      el historial — no cambia la interfaz `ICitaRepository` de `Domain`, solo su implementación
**Pendientes menores para revisar en la Fase 12 (middleware global de excepciones):**
 
- Hasta que exista el middleware, todos los `403`/`404` de negocio de este módulo responden `500`
  crudo — comportamiento esperado, documentado en el Paso 0
- El chequeo de propiedad de `AuthorizationBehavior` (Fase 4) lanza `AccesoDenegadoException` tanto
  para "rol incorrecto" como para "recurso ajeno" — ambos casos ya distinguibles por mensaje, pero
  hoy comparten el mismo código HTTP crudo hasta la Fase 12
---
 
