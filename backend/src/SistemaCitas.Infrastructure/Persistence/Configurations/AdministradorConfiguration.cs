using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence.Configurations;

public sealed class AdministradorConfiguration : IEntityTypeConfiguration<Administrador>
{
    public void Configure(EntityTypeBuilder<Administrador> builder)
    {
        builder.ToTable("Administradores");

        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).HasColumnName("id_administrador");

        builder.Property(a => a.Nombre).HasColumnName("nombre").HasMaxLength(100).IsRequired();

        builder.Property(a => a.Correo).HasColumnName("correo").HasMaxLength(150).IsRequired();
        builder.HasIndex(a => a.Correo).IsUnique();

        builder.Property(a => a.PasswordHash)
            .HasColumnName("password_hash")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(a => a.FechaCreacion).HasColumnName("fecha_creacion");
    }
}