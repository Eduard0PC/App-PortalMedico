namespace SistemaCitas.Application.Horarios;

public sealed record HorarioDto(
    int Id,
    int IdMedico,
    int DiaSemana,
    TimeOnly HoraInicio,
    TimeOnly HoraFin);