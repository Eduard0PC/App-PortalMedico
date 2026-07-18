namespace SistemaCitas.Application.Especialidades;

/// <summary>
/// Forma de salida común a los 4 endpoints de /api/especialidades. Nunca se devuelve la entidad
/// Especialidad de Domain directamente — este DTO es el único contrato que la API expone.
/// </summary>
public sealed record EspecialidadDto(int Id, string Nombre, string? Descripcion);