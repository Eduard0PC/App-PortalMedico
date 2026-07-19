using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence.Configurations;

public sealed class CitaConfiguration : IEntityTypeConfiguration<Cita>
{
    public void Configure(EntityTypeBuilder<Cita> builder)
    {
        builder.ToTable("Citas");

        builder.HasKey(c => c.Id);
        builder.Property(c => c.Id).HasColumnName("id_cita");

        builder.Property(c => c.IdPaciente).HasColumnName("id_paciente");
        builder.HasOne(c => c.Paciente)
            .WithMany()
            .HasForeignKey(c => c.IdPaciente)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(c => c.IdMedico).HasColumnName("id_medico");
        builder.HasOne(c => c.Medico)
            .WithMany()
            .HasForeignKey(c => c.IdMedico)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(c => c.Fecha).HasColumnName("fecha");
        builder.Property(c => c.HoraInicio).HasColumnName("hora_inicio");
        builder.Property(c => c.HoraFin).HasColumnName("hora_fin");

        builder.Property(c => c.MotivoConsulta)
            .HasColumnName("motivo_consulta")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(c => c.Estado)
            .HasColumnName("estado")
            .HasConversion<string>()
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(c => c.NotaMedica)
            .HasColumnName("nota_medica")
            .HasColumnType("text");

        builder.Property(c => c.CanceladaPor)
            .HasColumnName("cancelada_por")
            .HasConversion<string>()
            .HasMaxLength(20);

        builder.Property(c => c.FechaCreacion).HasColumnName("fecha_creacion");
        builder.Property(c => c.FechaActualizacion).HasColumnName("fecha_actualizacion");

        builder.Property(c => c.RowVersion).IsRowVersion();

        builder.HasIndex(c => new { c.IdMedico, c.Fecha, c.HoraInicio })
    .IsUnique()
    .HasFilter("estado <> 'Cancelada'")
    .HasDatabaseName("IX_Citas_Medico_Fecha_HoraInicio_Activas");
    }
}