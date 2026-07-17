using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence;

public static class DbSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        if (!await context.Especialidades.AnyAsync())
        {
            context.Especialidades.AddRange(
                new Especialidad("Pediatría", "Atención médica para niños y adolescentes"),
                new Especialidad("Cardiología", "Diagnóstico y tratamiento de enfermedades del corazón"),
                new Especialidad("Medicina General", "Consulta y control de salud general"));
        }

        if (!await context.Administradores.AnyAsync())
        {
            var passwordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!");
            context.Administradores.Add(
                new Administrador("Administrador General", "admin@sistemacitas.com", passwordHash));
        }

        await context.SaveChangesAsync();
    }
}