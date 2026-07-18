using Microsoft.EntityFrameworkCore;
using Npgsql;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Infrastructure.Persistence;

public sealed class ApplicationDbContext : DbContext, IUnitOfWork
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<Especialidad> Especialidades => Set<Especialidad>();
    public DbSet<Administrador> Administradores => Set<Administrador>();
    public DbSet<Paciente> Pacientes => Set<Paciente>();
    public DbSet<Medico> Medicos => Set<Medico>();
    public DbSet<HorarioMedico> HorariosMedico => Set<HorarioMedico>();
    public DbSet<Cita> Citas => Set<Cita>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }

    /// <summary>
    /// Único punto de todo el proyecto donde EF Core traduce fallos de persistencia a las
    /// excepciones de dominio que Application ya conoce (Fase 1) — así ningún Handler necesita
    /// referenciar EF Core ni Npgsql directamente (ver Paso 4 de Fase 10).
    /// </summary>
    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            return await base.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateConcurrencyException)
        {
            // El RowVersion que el cliente mandó (Paso 3.1) no coincide con el xmin real de la
            // fila: otra petición ya modificó esta misma cita entre el GET y este PATCH.
            throw new ConflictoDeConcurrenciaException(
                "La cita fue modificada por otra petición mientras tanto. Actualizá los datos (volvé a " +
                "hacer GET) e intentá de nuevo.");
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: "23505" })
        {
            // Violación de un índice único filtrado: dos peticiones casi simultáneas (ej. dos
            // pacientes reservando el mismo bloque, Fase 10) pasaron ambas la validación de
            // disponibilidad antes de que ninguna hubiera insertado — la base de datos es la
            // última línea de defensa real contra esta condición de carrera (Fase 2, requisito
            // obligatorio #3 del TODO). El mismo catch también cubre, como beneficio adicional,
            // la condición de carrera de correo duplicado anotada como pendiente en las Fases 5,
            // 6 y 8 — antes esas violaciones llegaban crudas, desde esta fase ya salen como
            // ConflictoDeConcurrenciaException en cualquier módulo del proyecto.
            throw new ConflictoDeConcurrenciaException(
                "La operación no se pudo completar porque entra en conflicto con un registro existente " +
                "(por ejemplo, un horario que otra persona acaba de reservar). Verificá los datos e " +
                "intentá de nuevo.");
        }
    }
}