using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
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
}