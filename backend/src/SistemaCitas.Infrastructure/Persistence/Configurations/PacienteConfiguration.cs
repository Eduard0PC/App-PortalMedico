using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence.Configurations;

public sealed class PacienteConfiguration : IEntityTypeConfiguration<Paciente>
{
    public void Configure(EntityTypeBuilder<Paciente> builder)
    {
        builder.ToTable("Pacientes");

        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).HasColumnName("id_paciente");

        builder.Property(p => p.Nombre).HasColumnName("nombre").HasMaxLength(100).IsRequired();
        builder.Property(p => p.Apellido).HasColumnName("apellido").HasMaxLength(100).IsRequired();

        builder.Property(p => p.Correo).HasColumnName("correo").HasMaxLength(150).IsRequired();
        builder.HasIndex(p => p.Correo).IsUnique();

        builder.Property(p => p.PasswordHash)
            .HasColumnName("password_hash")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(p => p.Telefono).HasColumnName("telefono").HasMaxLength(20);
        builder.Property(p => p.FechaNacimiento).HasColumnName("fecha_nacimiento");
        builder.Property(p => p.FechaCreacion).HasColumnName("fecha_creacion");
    }
}