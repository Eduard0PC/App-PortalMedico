using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Infrastructure.Persistence.Configurations;

public sealed class HorarioMedicoConfiguration : IEntityTypeConfiguration<HorarioMedico>
{
    public void Configure(EntityTypeBuilder<HorarioMedico> builder)
    {
        builder.ToTable("HorarioMedico");

        builder.HasKey(h => h.Id);
        builder.Property(h => h.Id).HasColumnName("id_horario");

        builder.Property(h => h.IdMedico).HasColumnName("id_medico");
        builder.HasOne(h => h.Medico)
            .WithMany()
            .HasForeignKey(h => h.IdMedico)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(h => h.DiaSemana).HasColumnName("dia_semana");
        builder.Property(h => h.HoraInicio).HasColumnName("hora_inicio");
        builder.Property(h => h.HoraFin).HasColumnName("hora_fin");
    }
}