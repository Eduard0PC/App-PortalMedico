using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence.Configurations;

public sealed class MedicoConfiguration : IEntityTypeConfiguration<Medico>
{
    public void Configure(EntityTypeBuilder<Medico> builder)
    {
        builder.ToTable("Medicos");

        builder.HasKey(m => m.Id);
        builder.Property(m => m.Id).HasColumnName("id_medico");

        builder.Property(m => m.Nombre).HasColumnName("nombre").HasMaxLength(100).IsRequired();
        builder.Property(m => m.Apellido).HasColumnName("apellido").HasMaxLength(100).IsRequired();

        builder.Property(m => m.Correo).HasColumnName("correo").HasMaxLength(150).IsRequired();
        builder.HasIndex(m => m.Correo).IsUnique();

        builder.Property(m => m.PasswordHash)
            .HasColumnName("password_hash")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(m => m.IdEspecialidad).HasColumnName("id_especialidad");
        builder.HasOne(m => m.Especialidad)
            .WithMany()
            .HasForeignKey(m => m.IdEspecialidad)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(m => m.Telefono).HasColumnName("telefono").HasMaxLength(20);
        builder.Property(m => m.Activo).HasColumnName("activo");
        builder.Property(m => m.FechaCreacion).HasColumnName("fecha_creacion");
    }
}