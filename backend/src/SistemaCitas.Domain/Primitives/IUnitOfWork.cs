namespace SistemaCitas.Domain.Primitives;

/// <summary>
/// Abstrae el "guardar cambios" para que Application no dependa de EF Core.
/// Application.Handlers modifican entidades a través de los repositorios y llaman a
/// SaveChangesAsync una sola vez, al final, para persistir todo junto (patrón Unit of Work).
/// </summary>
public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken ct = default);
}