# Fase 9 — Horario y Disponibilidad · `/api/medicos/{id}/horario` (Sistema de Citas Médicas)

Guía paso a paso para completar la Fase 9 del TODO (`Application` + `API` — módulo de horario y
disponibilidad): el primer módulo que ejercita `IOwnedRequest` con `RolPropietario = "Medico"`
(hasta ahora solo se había usado con `"Paciente"` en la Fase 7), y el módulo que implementa la
**regla de negocio #1** de la especificación — el cálculo dinámico de bloques de 30 minutos
disponibles para reservar una cita. Sigue directamente a la Fase 8 (`Médicos`), que ya está
completada.

El código nuevo va en dos proyectos:
- `monorepo/backend/src/SistemaCitas.Application` → 2 DTOs de salida, un helper de dominio de
  aplicación (`HorarioSuperposicion`), 2 Queries + 3 Commands, con sus Handlers y Validators
- `monorepo/backend/src/SistemaCitas.API` → `HorariosController`

No hace falta tocar `Domain` ni `Infrastructure` en esta fase: la entidad `HorarioMedico` (con su
método `Actualizar`), `IHorarioMedicoRepository`, y `ICitaRepository.ObtenerPorMedicoYFechaAsync`
(que ya filtra por `Estado <> Cancelada` a nivel de consulta) existen desde la Fase 1, y sus
implementaciones concretas (`HorarioMedicoRepository`, `CitaRepository`) existen desde la Fase 2.

---

## Qué vamos a construir

- [ ] **(Application)** `Horarios/HorarioDto.cs` — DTO de salida de un bloque de horario
- [ ] **(Application)** `Horarios/BloqueDisponibleDto.cs` — DTO de salida de un bloque de 30 min
      disponible
- [ ] **(Application)** `Horarios/HorarioSuperposicion.cs` — helper compartido para detectar
      bloques de horario que se solapan
- [ ] **(Application)** `ListarHorarioDeMedicoQuery` + Handler + Validator
- [ ] **(Application)** `CrearHorarioCommand` + Handler + Validator
- [ ] **(Application)** `ActualizarHorarioCommand` + Handler + Validator
- [ ] **(Application)** `EliminarHorarioCommand` + Handler
- [ ] **(Application)** `ObtenerDisponibilidadQuery` + Handler + Validator — la lógica clave
      (regla de negocio #1)
- [ ] **(API)** `HorariosController` — despacha las 2 Queries y los 3 Commands vía `ISender`
      (MediatR), incluyendo una ruta con override absoluto para `/disponibilidad`

---

## Paso 0 — Prerrequisitos

**Fase 8 completa** — necesitás el pipeline de la Fase 4 (`ValidationBehavior`,
`AuthorizationBehavior`, `IAuthorizedRequest`, `IOwnedRequest`) y las entidades/repositorios de la
Fase 1/2: `HorarioMedico`, `IHorarioMedicoRepository`, `Medico`, `IMedicoRepository`,
`ICitaRepository.ObtenerPorMedicoYFechaAsync`, `IUnitOfWork`. También vas a necesitar un token de
Administrador (para crear/editar/borrar bloques de horario), un token de Médico (con al menos un
bloque de horario configurado, para probar el caso "propio") y un token de Paciente (para probar
`/disponibilidad`).

**Misma nota que en las Fases 5 a 8 sobre el middleware de errores:** todavía no existe (se
construye en la Fase 12). Los casos de éxito de abajo van a responder bien; los de error de negocio
(`NotFoundException`, `ReglaDeNegocioException`, `AccesoDenegadoException`) van a devolver
`500 Internal Server Error` crudo en vez de `404`/`400`/`403` — es esperado, no es un bug de esta
fase. Lo que sí funciona ya correctamente es el `400` de FluentValidation y el `400` automático de
`[ApiController]` cuando falta un parámetro obligatorio de la query string (ver Paso 7).

**A diferencia de la Fase 8, este módulo sí usa `IOwnedRequest`, pero con `RolPropietario =
"Medico"`** (no `"Paciente"` como en la Fase 7): un médico puede ver su propio horario
(`GET /api/medicos/{id}/horario`), pero no el de otro médico, aunque tenga el rol correcto. Los
otros 4 endpoints no llevan chequeo de propiedad: los 3 de escritura son exclusivos de
Administrador (sin noción de "propio"), y `/disponibilidad` es de Paciente sin restricción de
dueño — cualquier paciente puede consultar la disponibilidad de cualquier médico, es justamente el
flujo de reserva.

---

## Paso 1 — Carpetas nuevas en Application

Desde `monorepo/backend/src/SistemaCitas.Application`:

```bash
mkdir -p Horarios/Queries/ListarHorarioDeMedico
mkdir -p Horarios/Queries/ObtenerDisponibilidad
mkdir -p Horarios/Commands/CrearHorario
mkdir -p Horarios/Commands/ActualizarHorario
mkdir -p Horarios/Commands/EliminarHorario
```

(En PowerShell: `New-Item -ItemType Directory -Force -Path Horarios\Queries\ListarHorarioDeMedico,
Horarios\Queries\ObtenerDisponibilidad, Horarios\Commands\CrearHorario,
Horarios\Commands\ActualizarHorario, Horarios\Commands\EliminarHorario`)

`Horarios/` es la carpeta del módulo, misma convención que `Auth/` (Fase 5), `Especialidades/`
(Fase 6), `Pacientes/` (Fase 7) y `Medicos/` (Fase 8): un módulo por sección de la especificación,
`Queries/` para lecturas y `Commands/` para escrituras. Aunque la sección 5.5 de la especificación
define dos rutas distintas (`/horario` y `/disponibilidad`), ambas comparten el mismo recurso de
fondo (`HorarioMedico`), así que viven en un único módulo `Horarios/` en vez de dos.

---

## Paso 2 — DTOs de salida y helper de superposición

### `Horarios/HorarioDto.cs`

Forma de salida común a los 4 endpoints de `/horario`. Igual que `EspecialidadDto` (Fase 6), evita
exponer la entidad `HorarioMedico` de `Domain` directamente.

```csharp
namespace SistemaCitas.Application.Horarios;

/// <summary>
/// Forma de salida común a los 4 endpoints de /api/medicos/{id}/horario.
/// </summary>
public sealed record HorarioDto(
    int Id,
    int IdMedico,
    int DiaSemana,
    TimeOnly HoraInicio,
    TimeOnly HoraFin);
```

### `Horarios/BloqueDisponibleDto.cs`

Forma de salida de `GET /api/medicos/{id}/disponibilidad`. Deliberadamente más chico que
`HorarioDto`: un bloque disponible no tiene `Id` propio (es un cálculo, no una fila de la base de
datos) ni `DiaSemana` (ya lo definió el `fecha` de la query).

```csharp
namespace SistemaCitas.Application.Horarios;

/// <summary>
/// Un bloque de 30 minutos disponible para reservar, calculado dinámicamente por
/// ObtenerDisponibilidadQueryHandler. No corresponde a ninguna fila de la base de datos.
/// </summary>
public sealed record BloqueDisponibleDto(TimeOnly HoraInicio, TimeOnly HoraFin);
```

### `Horarios/HorarioSuperposicion.cs`

**Concepto nuevo de esta fase:** a diferencia de `Citas`, que en la Fase 2 recibió un índice único
filtrado en la base de datos contra la doble reserva del mismo bloque, `HorarioMedicoConfiguration`
(Fase 2) **no** tiene ninguna restricción que impida guardar dos bloques de horario del mismo
médico y día que se solapen en el tiempo (ej. `09:00–12:00` y `11:00–14:00` el mismo lunes). Si eso
llegara a pasar, `ObtenerDisponibilidadQuery` (Paso 7) generaría bloques de 30 min duplicados o
contradictorios para el rango solapado. Por eso `CrearHorarioCommandHandler` y
`ActualizarHorarioCommandHandler` (Pasos 4 y 5) validan la ausencia de superposición **antes** de
guardar, con este helper compartido.

```csharp
namespace SistemaCitas.Application.Horarios;

/// <summary>
/// Determina si dos bloques de horario (del mismo médico y día) se solapan en el tiempo. Dos
/// bloques adyacentes (ej. HoraFin de uno == HoraInicio del otro) NO se consideran superpuestos.
/// Usado por CrearHorarioCommandHandler y ActualizarHorarioCommandHandler porque, a diferencia de
/// la doble reserva de Citas (Fase 2), no existe ninguna restricción a nivel de base de datos que
/// lo impida para HorarioMedico.
/// </summary>
public static class HorarioSuperposicion
{
    public static bool Existe(TimeOnly aInicio, TimeOnly aFin, TimeOnly bInicio, TimeOnly bFin) =>
        aInicio < bFin && bInicio < aFin;
}
```

---

## Paso 3 — `ListarHorarioDeMedicoQuery`

Según la sección 5.5: `GET /api/medicos/{id}/horario`, rol "Médico (propio), Admin". El primer
Query del proyecto que declara `RolPropietario = "Medico"` en vez de `"Paciente"` — el mismo
mecanismo de `AuthorizationBehavior` (Fase 4) aplica sin cambios, solo cambia el rol comparado.

### `Horarios/Queries/ListarHorarioDeMedico/ListarHorarioDeMedicoQuery.cs`

```csharp
using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;

public sealed record ListarHorarioDeMedicoQuery(int IdMedico)
    : IRequest<List<HorarioDto>>, IAuthorizedRequest, IOwnedRequest
{
    public string[] RolesPermitidos => new[] { "Medico", "Administrador" };
    public int IdPropietario => IdMedico;
    public string RolPropietario => "Medico";
}
```

> Con esta declaración, `AuthorizationBehavior` exige rol `Medico` o `Administrador` y, si quien
> llama es justo un Médico, que el `IdMedico` de la ruta coincida con su propio id — un
> Administrador nunca queda sujeto a esa comparación (ver el Paso 7 de la Fase 4).

### `Horarios/Queries/ListarHorarioDeMedico/ListarHorarioDeMedicoQueryValidator.cs`

```csharp
using FluentValidation;

namespace SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;

public sealed class ListarHorarioDeMedicoQueryValidator
    : AbstractValidator<ListarHorarioDeMedicoQuery>
{
    public ListarHorarioDeMedicoQueryValidator()
    {
        RuleFor(x => x.IdMedico).GreaterThan(0);
    }
}
```

### `Horarios/Queries/ListarHorarioDeMedico/ListarHorarioDeMedicoQueryHandler.cs`

```csharp
using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;

public sealed class ListarHorarioDeMedicoQueryHandler
    : IRequestHandler<ListarHorarioDeMedicoQuery, List<HorarioDto>>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;

    public ListarHorarioDeMedicoQueryHandler(
        IMedicoRepository medicoRepository, IHorarioMedicoRepository horarioRepository)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
    }

    public async Task<List<HorarioDto>> Handle(
        ListarHorarioDeMedicoQuery request, CancellationToken ct)
    {
        _ = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        var horarios = await _horarioRepository.ObtenerPorMedicoAsync(request.IdMedico, ct);

        return horarios
            .Select(h => new HorarioDto(h.Id, h.IdMedico, h.DiaSemana, h.HoraInicio, h.HoraFin))
            .OrderBy(h => h.DiaSemana)
            .ThenBy(h => h.HoraInicio)
            .ToList();
    }
}
```

> Se valida que el médico exista antes de listar (mismo patrón que
> `ListarCitasDePacienteQueryHandler` en la Fase 7): así se distingue `404` (médico inexistente) de
> `200` con lista vacía (médico real que todavía no tiene ningún bloque de horario cargado).

---

## Paso 4 — `CrearHorarioCommand`

Según la sección 5.5: `POST /api/medicos/{id}/horario`, rol Administrador.

### `Horarios/Commands/CrearHorario/CrearHorarioCommand.cs`

```csharp
using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Commands.CrearHorario;

public sealed record CrearHorarioCommand(
    int IdMedico, int DiaSemana, TimeOnly HoraInicio, TimeOnly HoraFin)
    : IRequest<HorarioDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}
```

### `Horarios/Commands/CrearHorario/CrearHorarioCommandValidator.cs`

```csharp
using FluentValidation;

namespace SistemaCitas.Application.Horarios.Commands.CrearHorario;

public sealed class CrearHorarioCommandValidator : AbstractValidator<CrearHorarioCommand>
{
    public CrearHorarioCommandValidator()
    {
        RuleFor(x => x.IdMedico).GreaterThan(0);

        RuleFor(x => x.DiaSemana)
            .InclusiveBetween(1, 5)
            .WithMessage("El día de la semana debe estar entre 1 (Lunes) y 5 (Viernes).");

        RuleFor(x => x.HoraFin)
            .GreaterThan(x => x.HoraInicio)
            .WithMessage("La hora de fin debe ser posterior a la hora de inicio.");
    }
}
```

> `DiaSemana` entre 1 y 5, y `HoraFin > HoraInicio`, son las mismas dos reglas que ya valida el
> constructor de `HorarioMedico` (`ValidarRango`, Fase 1) — acá se duplican deliberadamente en
> FluentValidation, igual que las longitudes de `HasMaxLength` se duplicaron en la Fase 6 y 8: sin
> esta duplicación, violar cualquiera de las dos reglas dispararía `ReglaDeNegocioException` desde
> la entidad, que hoy (hasta la Fase 12) se ve como un `500` crudo en vez de un `400` prolijo. Con
> el validador, se obtiene el `400` ya desde esta fase.

### `Horarios/Commands/CrearHorario/CrearHorarioCommandHandler.cs`

```csharp
using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Horarios.Commands.CrearHorario;

public sealed class CrearHorarioCommandHandler : IRequestHandler<CrearHorarioCommand, HorarioDto>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public CrearHorarioCommandHandler(
        IMedicoRepository medicoRepository,
        IHorarioMedicoRepository horarioRepository,
        IUnitOfWork unitOfWork)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<HorarioDto> Handle(CrearHorarioCommand request, CancellationToken ct)
    {
        _ = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(
            request.IdMedico, request.DiaSemana, ct);

        if (horariosDelDia.Any(h =>
                HorarioSuperposicion.Existe(h.HoraInicio, h.HoraFin, request.HoraInicio, request.HoraFin)))
            throw new ReglaDeNegocioException(
                "Ya existe un bloque de horario para ese médico y día que se superpone con el rango indicado.");

        var horario = new HorarioMedico(
            request.IdMedico, request.DiaSemana, request.HoraInicio, request.HoraFin);

        _horarioRepository.Agregar(horario);
        await _unitOfWork.SaveChangesAsync(ct);

        return new HorarioDto(
            horario.Id, horario.IdMedico, horario.DiaSemana, horario.HoraInicio, horario.HoraFin);
    }
}
```

**(pendiente menor — misma familia que los pendientes de correo duplicado de las Fases 5, 6 y 8)**
El chequeo de superposición de arriba tiene la misma limitación ya documentada: no es atómico. Si
dos `POST` casi simultáneos crean bloques que se solapan para el mismo médico y día, ninguno ve el
bloque del otro a tiempo y ambos se guardan. A diferencia de `Citas` (Fase 2), acá no hay un índice
único a nivel de base de datos que sirva de última defensa, porque la condición de carrera que pide
el TODO (regla obligatoria #3) es específicamente sobre la reserva de citas, no sobre la
configuración de horarios — un evento raro en la práctica (el Administrador es el único rol que
puede llegar a este endpoint) y fuera de alcance de esta fase. Anotado para revisar si se vuelve
relevante.

---

## Paso 5 — `ActualizarHorarioCommand`

Según la sección 5.5: `PUT /api/medicos/{id}/horario/{idHorario}`, rol Administrador. Mismo patrón
de "`id` de la URL + body" que `ActualizarEspecialidadCommand` (Fase 6): el Controller (Paso 8)
arma el Command combinando ambos ids de la ruta con el body.

**Concepto nuevo:** a diferencia de `ActualizarEspecialidadCommand`, acá la ruta trae **dos** ids
(`{id}` del médico y `{idHorario}` del bloque). El Handler valida que realmente estén relacionados
— que el bloque `idHorario` pertenezca al médico `id` — para no permitir que alguien edite (o, en
el Paso 6, borre) el bloque de un médico usando la URL de otro médico distinto.

### `Horarios/Commands/ActualizarHorario/ActualizarHorarioCommand.cs`

```csharp
using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Commands.ActualizarHorario;

public sealed record ActualizarHorarioCommand(
    int Id, int IdMedico, int DiaSemana, TimeOnly HoraInicio, TimeOnly HoraFin)
    : IRequest<HorarioDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}
```

> `Id` es el `idHorario` de la ruta (el bloque a editar); `IdMedico` es el `id` de la ruta (el
> médico dueño esperado). Nombrado `Id`/`IdMedico` para mantener la misma convención que
> `ActualizarEspecialidadCommand(Id, ...)` de la Fase 6.

### `Horarios/Commands/ActualizarHorario/ActualizarHorarioCommandValidator.cs`

```csharp
using FluentValidation;

namespace SistemaCitas.Application.Horarios.Commands.ActualizarHorario;

public sealed class ActualizarHorarioCommandValidator : AbstractValidator<ActualizarHorarioCommand>
{
    public ActualizarHorarioCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.IdMedico).GreaterThan(0);

        RuleFor(x => x.DiaSemana)
            .InclusiveBetween(1, 5)
            .WithMessage("El día de la semana debe estar entre 1 (Lunes) y 5 (Viernes).");

        RuleFor(x => x.HoraFin)
            .GreaterThan(x => x.HoraInicio)
            .WithMessage("La hora de fin debe ser posterior a la hora de inicio.");
    }
}
```

### `Horarios/Commands/ActualizarHorario/ActualizarHorarioCommandHandler.cs`

```csharp
using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Horarios.Commands.ActualizarHorario;

public sealed class ActualizarHorarioCommandHandler
    : IRequestHandler<ActualizarHorarioCommand, HorarioDto>
{
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ActualizarHorarioCommandHandler(
        IHorarioMedicoRepository horarioRepository, IUnitOfWork unitOfWork)
    {
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<HorarioDto> Handle(ActualizarHorarioCommand request, CancellationToken ct)
    {
        var horario = await _horarioRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un bloque de horario con id {request.Id}.");

        if (horario.IdMedico != request.IdMedico)
            throw new NotFoundException(
                $"El bloque de horario {request.Id} no pertenece al médico con id {request.IdMedico}.");

        var otrosDelDia = (await _horarioRepository.ObtenerPorMedicoYDiaAsync(
                request.IdMedico, request.DiaSemana, ct))
            .Where(h => h.Id != request.Id);

        if (otrosDelDia.Any(h =>
                HorarioSuperposicion.Existe(h.HoraInicio, h.HoraFin, request.HoraInicio, request.HoraFin)))
            throw new ReglaDeNegocioException(
                "Ya existe otro bloque de horario para ese médico que se superpone con el rango indicado.");

        horario.Actualizar(request.DiaSemana, request.HoraInicio, request.HoraFin);
        await _unitOfWork.SaveChangesAsync(ct);

        return new HorarioDto(
            horario.Id, horario.IdMedico, horario.DiaSemana, horario.HoraInicio, horario.HoraFin);
    }
}
```

> `.Where(h => h.Id != request.Id)` excluye al propio bloque de la comparación de superposición —
> si no se excluyera, el bloque siempre "chocaría contra sí mismo" con sus valores previos y jamás
> se podría editar.
>
> `horario.Actualizar(...)` es el método de la entidad definido en la Fase 1 — la regla de qué es
> un rango válido vive en `Domain`, el Handler solo orquesta (buscar, verificar pertenencia,
> verificar superposición, pedirle a la entidad que se actualice, guardar), mismo estilo que
> `ActualizarEspecialidadCommandHandler` (Fase 6).

---

## Paso 6 — `EliminarHorarioCommand`

Según la sección 5.5: `DELETE /api/medicos/{id}/horario/{idHorario}`, rol Administrador. No hace
falta validar dependencias antes de borrar (a diferencia de `EliminarEspecialidadCommand`, Fase 6):
`Cita` no tiene ninguna referencia a `HorarioMedico.Id` — guarda `Fecha`/`HoraInicio`/`HoraFin`
propios, no un `IdHorario` — así que borrar un bloque de horario nunca deja una cita huérfana ni
choca con ninguna FK.

### `Horarios/Commands/EliminarHorario/EliminarHorarioCommand.cs`

```csharp
using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Commands.EliminarHorario;

public sealed record EliminarHorarioCommand(int Id, int IdMedico) : IRequest, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}
```

No lleva Validator: `Id` e `IdMedico` llegan como `int` desde segmentos de ruta (`{idHorario}` y
`{id}`), ya validados como enteros por el enrutado de ASP.NET Core antes de llegar a MediatR — mismo
criterio que `EliminarEspecialidadCommand` (Fase 6), que tampoco lleva Validator.

### `Horarios/Commands/EliminarHorario/EliminarHorarioCommandHandler.cs`

```csharp
using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Horarios.Commands.EliminarHorario;

public sealed class EliminarHorarioCommandHandler : IRequestHandler<EliminarHorarioCommand>
{
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public EliminarHorarioCommandHandler(
        IHorarioMedicoRepository horarioRepository, IUnitOfWork unitOfWork)
    {
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task Handle(EliminarHorarioCommand request, CancellationToken ct)
    {
        var horario = await _horarioRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un bloque de horario con id {request.Id}.");

        if (horario.IdMedico != request.IdMedico)
            throw new NotFoundException(
                $"El bloque de horario {request.Id} no pertenece al médico con id {request.IdMedico}.");

        _horarioRepository.Eliminar(horario);
        await _unitOfWork.SaveChangesAsync(ct);
    }
}
```

---

## Paso 7 — `ObtenerDisponibilidadQuery` (la lógica clave)

Según la sección 5.5: `GET /api/medicos/{id}/disponibilidad?fecha=`, rol **solo Paciente** (a
diferencia de los otros 4 endpoints de este módulo, acá ni Médico ni Administrador están en la
lista de roles permitidos — así lo define literalmente la especificación, sección 5.5). Implementa
la **regla de negocio #1**: tomar el `HorarioMedico` del día de la semana que corresponde a
`fecha`, partirlo en bloques de 30 minutos, y descartar los que ya choquen con una `Cita` no
cancelada de ese médico en esa fecha.

### `Horarios/Queries/ObtenerDisponibilidad/ObtenerDisponibilidadQuery.cs`

```csharp
using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed record ObtenerDisponibilidadQuery(int IdMedico, DateOnly Fecha)
    : IRequest<List<BloqueDisponibleDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente" };
}
```

> No implementa `IOwnedRequest`: no hay noción de "dueño" acá — cualquier paciente autenticado
> puede consultar la disponibilidad de cualquier médico, es el paso previo a reservar (Fase 10).

### `Horarios/Queries/ObtenerDisponibilidad/ObtenerDisponibilidadQueryValidator.cs`

```csharp
using FluentValidation;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed class ObtenerDisponibilidadQueryValidator : AbstractValidator<ObtenerDisponibilidadQuery>
{
    public ObtenerDisponibilidadQueryValidator()
    {
        RuleFor(x => x.IdMedico).GreaterThan(0);
    }
}
```

> No valida `Fecha` explícitamente: como se ve en el Paso 8, `fecha` se recibe como
> `[FromQuery] DateOnly fecha` (no nullable) — si el query string no la trae o trae un valor que no
> parsea como fecha, el *model binding* de ASP.NET Core rechaza la petición con `400 Bad Request`
> automáticamente, antes incluso de que MediatR reciba el Query. Es un mecanismo distinto al de
> `ValidationBehavior` (FluentValidation), pero da el mismo resultado prolijo sin código adicional.

### `Horarios/Queries/ObtenerDisponibilidad/ObtenerDisponibilidadQueryHandler.cs`

```csharp
using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed class ObtenerDisponibilidadQueryHandler
    : IRequestHandler<ObtenerDisponibilidadQuery, List<BloqueDisponibleDto>>
{
    private static readonly TimeSpan DuracionBloque = TimeSpan.FromMinutes(30);

    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly ICitaRepository _citaRepository;

    public ObtenerDisponibilidadQueryHandler(
        IMedicoRepository medicoRepository,
        IHorarioMedicoRepository horarioRepository,
        ICitaRepository citaRepository)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
        _citaRepository = citaRepository;
    }

    public async Task<List<BloqueDisponibleDto>> Handle(
        ObtenerDisponibilidadQuery request, CancellationToken ct)
    {
        _ = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        // DayOfWeek de .NET: Sunday=0 ... Saturday=6. HorarioMedico.DiaSemana: 1=Lunes ... 5=Viernes
        // (Fase 1). Coinciden numéricamente de Lunes a Viernes; sábado y domingo caen fuera de 1-5.
        var diaSemana = (int)request.Fecha.DayOfWeek;

        if (diaSemana is < 1 or > 5)
            return new List<BloqueDisponibleDto>();

        var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(
            request.IdMedico, diaSemana, ct);

        if (horariosDelDia.Count == 0)
            return new List<BloqueDisponibleDto>();

        // Ya viene filtrado a Estado <> Cancelada por CitaRepository (Fase 2) — no hace falta
        // volver a filtrar acá.
        var citasDelDia = await _citaRepository.ObtenerPorMedicoYFechaAsync(
            request.IdMedico, request.Fecha, ct);

        var disponibles = new List<BloqueDisponibleDto>();

        foreach (var horario in horariosDelDia)
        {
            var inicioBloque = horario.HoraInicio;

            while (inicioBloque.Add(DuracionBloque) <= horario.HoraFin)
            {
                var finBloque = inicioBloque.Add(DuracionBloque);

                var ocupado = citasDelDia.Any(c =>
                    inicioBloque < c.HoraFin && c.HoraInicio < finBloque);

                if (!ocupado)
                    disponibles.Add(new BloqueDisponibleDto(inicioBloque, finBloque));

                inicioBloque = finBloque;
            }
        }

        return disponibles.OrderBy(b => b.HoraInicio).ToList();
    }
}
```

> **Cómo funciona el cálculo, paso a paso:**
> 1. Se valida que el médico exista (`404` si no).
> 2. Se convierte `Fecha` a día de la semana (1-5). Sábado/domingo devuelven `[]` directamente — no
>    es un error, simplemente no hay horario configurable esos días en este sistema.
> 3. Se traen los bloques de `HorarioMedico` de ese médico y ese día (puede haber más de uno, ej.
>    un turno mañana y otro tarde).
> 4. Se traen las citas no canceladas de ese médico en esa fecha exacta.
> 5. Por cada bloque de `HorarioMedico`, se avanza de a 30 minutos exactos desde `HoraInicio` hasta
>    que sumar otros 30 minutos superaría `HoraFin` — un bloque de horario de `09:00–09:45` (45
>    min) genera un único slot `09:00–09:30` y descarta los 15 min sobrantes, no un slot incompleto.
> 6. Cada slot candidato se descarta si se superpone con alguna cita ya existente (misma fórmula de
>    `HorarioSuperposicion.Existe`, escrita inline acá porque compara un slot contra una `Cita`, no
>    dos `HorarioMedico`).
>
> El resultado es la lista de bloques realmente disponibles, ordenada por hora — la Fase 10 la va a
> usar del lado del cliente para ofrecer horarios al momento de reservar.

---

## Paso 8 — `HorariosController` en API

Mismo patrón "delgado" que los controllers anteriores: recibe, despacha con `_sender.Send(...)`,
devuelve.

**Concepto nuevo — ruta con override absoluto:** el controller se declara con el prefijo
`api/medicos/{id}/horario`, que cubre 4 de los 5 endpoints. El quinto (`/disponibilidad`) no tiene
el segmento `/horario`, así que su atributo de ruta arranca con `/` (`[HttpGet("/api/medicos/{id}/
disponibilidad")]`): esa barra inicial le dice a ASP.NET Core "ignorá el prefijo del controller,
esta es la ruta completa". Sin la barra, la ruta resultante sería
`api/medicos/{id}/horario/disponibilidad`, que no coincide con la especificación.

Desde `monorepo/backend/src/SistemaCitas.API`:

### `Controllers/HorariosController.cs`

```csharp
using MediatR;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Horarios;
using SistemaCitas.Application.Horarios.Commands.ActualizarHorario;
using SistemaCitas.Application.Horarios.Commands.CrearHorario;
using SistemaCitas.Application.Horarios.Commands.EliminarHorario;
using SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;
using SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

namespace SistemaCitas.API.Controllers;

/// <summary>Body de POST y PUT de /horario: solo los campos editables, sin Id ni IdMedico
/// (ambos vienen de la ruta y el Controller los agrega antes de despachar el Command).</summary>
public sealed record HorarioRequest(int DiaSemana, TimeOnly HoraInicio, TimeOnly HoraFin);

[ApiController]
[Route("api/medicos/{id}/horario")]
public sealed class HorariosController : ControllerBase
{
    private readonly ISender _sender;

    public HorariosController(ISender sender) => _sender = sender;

    [HttpGet]
    public async Task<ActionResult<List<HorarioDto>>> Listar(int id, CancellationToken ct)
        => Ok(await _sender.Send(new ListarHorarioDeMedicoQuery(id), ct));

    [HttpPost]
    public async Task<ActionResult<HorarioDto>> Crear(
        int id, HorarioRequest request, CancellationToken ct)
    {
        var command = new CrearHorarioCommand(
            id, request.DiaSemana, request.HoraInicio, request.HoraFin);
        var resultado = await _sender.Send(command, ct);
        return CreatedAtAction(nameof(Listar), new { id }, resultado);
    }

    [HttpPut("{idHorario}")]
    public async Task<ActionResult<HorarioDto>> Actualizar(
        int id, int idHorario, HorarioRequest request, CancellationToken ct)
    {
        var command = new ActualizarHorarioCommand(
            idHorario, id, request.DiaSemana, request.HoraInicio, request.HoraFin);
        var resultado = await _sender.Send(command, ct);
        return Ok(resultado);
    }

    [HttpDelete("{idHorario}")]
    public async Task<IActionResult> Eliminar(int id, int idHorario, CancellationToken ct)
    {
        await _sender.Send(new EliminarHorarioCommand(idHorario, id), ct);
        return NoContent();
    }

    [HttpGet("/api/medicos/{id}/disponibilidad")]
    public async Task<ActionResult<List<BloqueDisponibleDto>>> Disponibilidad(
        int id, [FromQuery] DateOnly fecha, CancellationToken ct)
        => Ok(await _sender.Send(new ObtenerDisponibilidadQuery(id, fecha), ct));
}
```

> `CreatedAtAction(nameof(Listar), new { id }, resultado)`: a diferencia de `CrearMedico` (Fase 8),
> que apunta a un `GET /{id}` de un único recurso, acá apunta a `Listar` (`GET /horario`, la lista
> completa) porque no existe un `GET /horario/{idHorario}` individual en la especificación — mismo
> criterio que ya se usó en la Fase 5 y la Fase 6 para elegir el destino de `CreatedAtAction`
> cuando no hay un endpoint de detalle disponible.
>
> `[FromQuery] DateOnly fecha`: parámetro obligatorio (no `DateOnly?`), a diferencia de
> `[FromQuery] string? nombre` en `PacientesController` (Fase 7) — acá si falta o el formato no es
> una fecha válida, `[ApiController]` devuelve `400` automáticamente antes de llegar al validator
> de FluentValidation (ver la nota del Paso 7).

---

## Paso 9 — Verificación

Desde `monorepo/backend`:

```bash
dotnet build
```

Debe salir `Build succeeded`.

Luego, con la API corriendo (`dotnet run --project src/SistemaCitas.API`), abrí Swagger y usá el
botón "Authorize" con un token de Administrador y, si ya existe algún médico creado (Fase 8), con
un token de ese Médico y uno de Paciente.

**Casos de éxito para probar:**

1. Login como Administrador → copiar el token.
2. `POST /api/medicos/{id}/horario` (con el `id` de un médico ya creado en la Fase 8) con:
   ```json
   { "diaSemana": 1, "horaInicio": "09:00:00", "horaFin": "12:00:00" }
   ```
   Debe responder `201 Created` con el `HorarioDto` (incluye el `id` del bloque).
3. `POST /api/medicos/{id}/horario` de nuevo, mismo médico, bloque no solapado:
   ```json
   { "diaSemana": 1, "horaInicio": "14:00:00", "horaFin": "17:00:00" }
   ```
   También `201 Created`.
4. `GET /api/medicos/{id}/horario` (con el token de Administrador, o con el token del propio
   médico) → `200 OK` con los 2 bloques del paso 2 y 3.
5. `PUT /api/medicos/{id}/horario/{idHorario}` (con el `idHorario` del paso 2) con:
   ```json
   { "diaSemana": 1, "horaInicio": "08:30:00", "horaFin": "12:00:00" }
   ```
   Debe responder `200 OK` con los datos actualizados.
6. `GET /api/medicos/{id}/disponibilidad?fecha=2026-07-20` (un lunes; con el token de Paciente) →
   `200 OK` con la lista de bloques de 30 min entre `08:30` y `17:00`, salteando el hueco entre
   `12:00` y `14:00` (fuera de ambos bloques de horario).
7. `POST /api/citas` no existe todavía (es la Fase 10) — para probar que un bloque ocupado
   desaparece de la disponibilidad, esa verificación de punta a punta queda pendiente para cuando
   se construya `ReservarCitaCommand`.
8. `DELETE /api/medicos/{id}/horario/{idHorario}` (con el `idHorario` del paso 3) → `204 No
   Content`.

**Casos de error para confirmar que `ValidationBehavior` y `AuthorizationBehavior` ya funcionan:**

- `POST /api/medicos/{id}/horario` con `"diaSemana": 6` → `400 Bad Request` (`ValidationBehavior`,
  no depende del middleware de la Fase 12).
- `POST /api/medicos/{id}/horario` con `"horaFin": "08:00:00"` menor que `"horaInicio":
  "09:00:00"` → `400 Bad Request`.
- `POST /api/medicos/{id}/horario` con un rango que se solapa con un bloque ya existente del mismo
  médico y día (ej. `10:00–11:00` contra el `09:00–12:00` del paso 2) → `500` crudo por ahora
  (`ReglaDeNegocioException`, será `400` en la Fase 12); confirmá que **no** se crea el bloque.
- `GET /api/medicos/{id}/horario` con el token de un Médico **distinto** al `id` de la ruta → `500`
  crudo por ahora (`AccesoDenegadoException`; en la Fase 12 será `403`). Confirmá que la respuesta
  **no** trae el horario ajeno — señal de que `AuthorizationBehavior` cortó por el chequeo de
  `IOwnedRequest` con `RolPropietario = "Medico"`.
- `PUT /api/medicos/{id}/horario/{idHorario}` usando el `id` de un médico distinto al dueño real
  del `idHorario` → `500` crudo por ahora (`NotFoundException`, "no pertenece a ese médico");
  confirmá que **no** se actualiza el bloque de otro médico.
- `GET /api/medicos/{id}/disponibilidad` sin el parámetro `fecha` → `400 Bad Request` automático de
  `[ApiController]` (no depende de `ValidationBehavior` ni del middleware de la Fase 12).
- `GET /api/medicos/{id}/disponibilidad?fecha=2026-07-19` (un domingo) → `200 OK` con `[]` — no es
  un error, es el resultado esperado fuera de Lunes-Viernes.
- `GET /api/medicos/{id}/disponibilidad?fecha=2026-07-20` con el token de un Médico o de
  Administrador → `500` crudo por ahora (rol no permitido; la especificación solo habilita
  Paciente para este endpoint puntual).
- Sin token en cualquiera de los 5 endpoints → `500` crudo por ahora (`AccesoDenegadoException` sin
  capturar).

---

## Resumen de endpoints — `/api/medicos/{id}/horario` y `/api/medicos/{id}/disponibilidad`

| Método | Endpoint | Rol | Ejemplo de respuesta exitosa | Casos de error controlados |
|---|---|---|---|---|
| GET | `/api/medicos/{id}/horario` | Médico (propio), Administrador | `200 OK` → `[ { "id": 1, "idMedico": 3, "diaSemana": 1, "horaInicio": "08:30:00", "horaFin": "12:00:00" } ]` | • `id` de médico no existe → `404 Not Found`<br>• Médico autenticado pide el horario de **otro** médico → `403 Forbidden` (`AccesoDenegadoException`)<br>• Token de Paciente → `403 Forbidden` (rol no permitido)<br>• Médico sin bloques cargados → `200 OK` con `[]` (no es error)<br>• Sin token → `403 Forbidden` |
| POST | `/api/medicos/{id}/horario` | Administrador | Body: `{ "diaSemana": 1, "horaInicio": "09:00:00", "horaFin": "12:00:00" }` → `201 Created` con el `HorarioDto` | • `diaSemana` fuera de 1-5 → `400 Bad Request`<br>• `horaFin` ≤ `horaInicio` → `400 Bad Request`<br>• `id` de médico no existe → `404 Not Found`<br>• Rango solapado con otro bloque del mismo médico y día → `400 Bad Request` (`ReglaDeNegocioException`)<br>• Token de Paciente o Médico → `403 Forbidden`<br>• Sin token → `403 Forbidden` |
| PUT | `/api/medicos/{id}/horario/{idHorario}` | Administrador | Body: `{ "diaSemana": 1, "horaInicio": "08:30:00", "horaFin": "12:00:00" }` → `200 OK` con el `HorarioDto` actualizado | • `diaSemana` fuera de 1-5 → `400 Bad Request`<br>• `horaFin` ≤ `horaInicio` → `400 Bad Request`<br>• `idHorario` no existe → `404 Not Found`<br>• `idHorario` existe pero pertenece a **otro** médico distinto del `id` de la ruta → `404 Not Found`<br>• Rango solapado con otro bloque del mismo médico y día (excluyendo el propio) → `400 Bad Request`<br>• Token de Paciente o Médico → `403 Forbidden`<br>• Sin token → `403 Forbidden` |
| DELETE | `/api/medicos/{id}/horario/{idHorario}` | Administrador | `204 No Content` | • `idHorario` no existe → `404 Not Found`<br>• `idHorario` pertenece a otro médico → `404 Not Found`<br>• Token de Paciente o Médico → `403 Forbidden`<br>• Sin token → `403 Forbidden` |
| GET | `/api/medicos/{id}/disponibilidad?fecha=` | Paciente | `200 OK` → `[ { "horaInicio": "08:30:00", "horaFin": "09:00:00" }, { "horaInicio": "09:00:00", "horaFin": "09:30:00" } ]` | • `id` de médico no existe → `404 Not Found`<br>• `fecha` ausente o con formato inválido → `400 Bad Request` (automático de `[ApiController]`)<br>• `fecha` cae sábado o domingo → `200 OK` con `[]` (no es error)<br>• Médico sin horario configurado ese día, o todos los bloques ocupados → `200 OK` con `[]` (no es error)<br>• Token de Médico o Administrador → `403 Forbidden` (rol no permitido para este endpoint puntual)<br>• Sin token → `403 Forbidden` |

> Recordatorio del Paso 0: hasta que exista el middleware global de la Fase 12, todos los
> `403`/`404` de esta tabla se ven hoy como `500` crudo en Swagger — la tabla describe el
> comportamiento **esperado**, no lo que se ve todavía en pantalla. Los `400` de FluentValidation y
> el `400` automático de `fecha` faltante sí funcionan ya.

---

## Con esto queda completa la Fase 9

En `TODO-backend-sistema-citas.md` podés marcar como hechos:

- [x] `GET /api/medicos/{id}/horario` — Médico (propio), Admin
- [x] `POST /api/medicos/{id}/horario` — Admin
- [x] `PUT /api/medicos/{id}/horario/{idHorario}` — Admin
- [x] `DELETE /api/medicos/{id}/horario/{idHorario}` — Admin
- [x] `GET /api/medicos/{id}/disponibilidad?fecha=` — Paciente. **Lógica clave** (regla de negocio
      #1): tomar `HorarioMedico` del día, partir en bloques de 30 min, descartar los que ya
      existan en `Citas` con estado ≠ `Cancelada`

Adiciones no listadas literalmente en el TODO pero incorporadas en esta fase:

- [x] `HorarioSuperposicion` (Paso 2) — validación de que dos bloques de horario del mismo médico y
      día no se solapen, usada en `Crear` y `Actualizar`; no estaba pedida explícitamente ni en el
      TODO ni en la especificación, pero sin ella la disponibilidad calculada en el Paso 7 podría
      quedar contradictoria
- [x] Validación de "el bloque pertenece a ese médico" en `PUT` y `DELETE` (Pasos 5 y 6) — chequea
      coherencia entre el `{id}` y el `{idHorario}` de la ruta, evitando editar/borrar el bloque de
      un médico usando la URL de otro
- [x] Validación de existencia del médico antes de listar horario, crear un bloque, o calcular
      disponibilidad (Pasos 3, 4 y 7) — distingue `404` de `200` con lista vacía, mismo patrón que
      la Fase 7 y la Fase 8
- [x] Primer módulo del proyecto que ejercita `IOwnedRequest` con `RolPropietario = "Medico"` (Paso
      3) — hasta ahora solo se había usado con `"Paciente"` en la Fase 7
- [x] Primera ruta con override absoluto (`[HttpGet("/api/medicos/{id}/disponibilidad")]`, Paso 8)
      para exponer un endpoint fuera del prefijo de rutas del controller

**Pendientes menores para revisar en la Fase 12 (middleware global de excepciones):**

- La condición de carrera de la superposición de horarios en `POST`/`PUT` (Paso 4), misma familia
  que los pendientes ya anotados en las Fases 5, 6 y 8 para violaciones de unicidad — acá no hay
  índice de base de datos de respaldo, a diferencia de `Citas`, porque no es la condición de
  carrera obligatoria del TODO (esa es específicamente sobre la reserva de citas, Fase 10)
- Hasta que exista el middleware, todos los `403`/`404`/`400` de negocio de este módulo responden
  `500` crudo — comportamiento esperado, documentado en el Paso 0
- Verificación de punta a punta de "un bloque ocupado por una cita desaparece de la disponibilidad"
  (paso 7 del Paso 9) queda pendiente hasta que exista `POST /api/citas` en la Fase 10

---

## Commit sugerido

```
feat(application,api): agrega módulo Horario y Disponibilidad (/api/medicos/{id}/horario, /api/medicos/{id}/disponibilidad)

- Agrega HorarioDto y BloqueDisponibleDto en Application/Horarios
- Agrega HorarioSuperposicion: helper para detectar bloques de horario que se solapan en el tiempo
- Agrega ListarHorarioDeMedicoQuery + Handler + Validator (rol Médico propio, Administrador),
  primer uso de IOwnedRequest con RolPropietario "Medico"
- Agrega CrearHorarioCommand + Handler + Validator (rol Administrador): valida médico existente
  y ausencia de superposición con otros bloques del mismo médico y día
- Agrega ActualizarHorarioCommand + Handler + Validator (rol Administrador): valida que el bloque
  pertenezca al médico de la ruta y ausencia de superposición, excluyéndose a sí mismo
- Agrega EliminarHorarioCommand + Handler (rol Administrador): valida que el bloque pertenezca
  al médico de la ruta
- Agrega ObtenerDisponibilidadQuery + Handler + Validator (rol Paciente): calcula bloques de 30
  min a partir de HorarioMedico del día, descartando los que colisionan con Citas no canceladas
  (regla de negocio #1)
- Agrega HorariosController en API/Controllers con los 5 endpoints de la sección 5.5, incluyendo
  una ruta con override absoluto para GET /api/medicos/{id}/disponibilidad
```
