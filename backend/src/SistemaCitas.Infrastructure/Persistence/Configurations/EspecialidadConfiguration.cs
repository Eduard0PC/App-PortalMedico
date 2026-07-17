using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence.Configurations;

public sealed class EspecialidadConfiguration : IEntityTypeConfiguration<Especialidad>
{
    public void Configure(EntityTypeBuilder<Especialidad> builder)
    {
        builder.ToTable("Especialidades");

        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).HasColumnName("id_especialidad");

        builder.Property(e => e.Nombre)
            .HasColumnName("nombre")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(e => e.Descripcion)
            .HasColumnName("descripcion")
            .HasMaxLength(255);
    }
}