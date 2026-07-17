using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;
using SistemaCitas.Infrastructure.Persistence;
using SistemaCitas.Infrastructure.Persistence.Repositories;

namespace SistemaCitas.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<ApplicationDbContext>());

        services.AddScoped<IEspecialidadRepository, EspecialidadRepository>();
        services.AddScoped<IAdministradorRepository, AdministradorRepository>();
        services.AddScoped<IPacienteRepository, PacienteRepository>();
        services.AddScoped<IMedicoRepository, MedicoRepository>();
        services.AddScoped<IHorarioMedicoRepository, HorarioMedicoRepository>();
        services.AddScoped<ICitaRepository, CitaRepository>();

        return services;
    }
}