using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;
using SistemaCitas.Infrastructure.Persistence;
using SistemaCitas.Infrastructure.Persistence.Repositories;
using SistemaCitas.Infrastructure.Security;
using System.Net.Http.Headers;
using SistemaCitas.Infrastructure.Chat;
using SistemaCitas.Mcp.Tools;
namespace SistemaCitas.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<ApplicationDbContext>());

        services.AddScoped<IEspecialidadRepository, EspecialidadRepository>();
        services.AddScoped<IAdministradorRepository, AdministradorRepository>();
        services.AddScoped<IPacienteRepository, PacienteRepository>();
        services.AddScoped<IMedicoRepository, MedicoRepository>();
        services.AddScoped<IHorarioMedicoRepository, HorarioMedicoRepository>();
        services.AddScoped<ICitaRepository, CitaRepository>();

        services.Configure<JwtSettings>(configuration.GetSection("Jwt"));
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IJwtService, JwtService>();


        services.AddScoped<DisponibilidadMcpTools>();

        services.AddMcpServer()
            .WithHttpTransport()
            .WithTools<DisponibilidadMcpTools>();

        services.AddHttpClient<IChatService, OpenRouterChatService>(client =>
        {
            client.BaseAddress = new Uri("https://openrouter.ai/api/v1/");
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", configuration["OpenRouter:ApiKey"]);
        });
        return services;
    }
}