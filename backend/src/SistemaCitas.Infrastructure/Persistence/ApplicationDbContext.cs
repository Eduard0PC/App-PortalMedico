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
    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            return await base.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateConcurrencyException)
        {
            throw new ConflictoDeConcurrenciaException(
                "La cita fue modificada por otra petición mientras tanto. Actualizá los datos (volvé a " +
                "hacer GET) e intentá de nuevo.");
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: "23505" })
        {
            throw new ConflictoDeConcurrenciaException(
                "La operación no se pudo completar porque entra en conflicto con un registro existente " +
                "(por ejemplo, un horario que otra persona acaba de reservar). Verificá los datos e " +
                "intentá de nuevo.");
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: "23503" })
        {
            throw new ReglaDeNegocioException(
                "No se puede completar la operación porque el recurso tiene otros registros " +
                "asociados (por ejemplo, médicos que siguen usando esta especialidad).");
        }
    }
}