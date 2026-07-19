using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;
using SistemaCitas.Infrastructure.Persistence;

#nullable disable

namespace SistemaCitas.Infrastructure.Migrations
{
    [DbContext(typeof(ApplicationDbContext))]
    partial class ApplicationDbContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "10.0.10")
                .HasAnnotation("Relational:MaxIdentifierLength", 63);

            NpgsqlModelBuilderExtensions.UseIdentityByDefaultColumns(modelBuilder);

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Administrador", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id_administrador");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<string>("Correo")
                        .IsRequired()
                        .HasMaxLength(150)
                        .HasColumnType("character varying(150)")
                        .HasColumnName("correo");

                    b.Property<DateTime>("FechaCreacion")
                        .HasColumnType("timestamptz")
                        .HasColumnName("fecha_creacion");

                    b.Property<string>("Nombre")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("character varying(100)")
                        .HasColumnName("nombre");

                    b.Property<string>("PasswordHash")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("character varying(255)")
                        .HasColumnName("password_hash");

                    b.HasKey("Id");

                    b.HasIndex("Correo")
                        .IsUnique();

                    b.ToTable("Administradores", (string)null);
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Cita", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id_cita");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<string>("CanceladaPor")
                        .HasMaxLength(20)
                        .HasColumnType("character varying(20)")
                        .HasColumnName("cancelada_por");

                    b.Property<string>("Estado")
                        .IsRequired()
                        .HasMaxLength(20)
                        .HasColumnType("character varying(20)")
                        .HasColumnName("estado");

                    b.Property<DateOnly>("Fecha")
                        .HasColumnType("date")
                        .HasColumnName("fecha");

                    b.Property<DateTime>("FechaActualizacion")
                        .HasColumnType("timestamptz")
                        .HasColumnName("fecha_actualizacion");

                    b.Property<DateTime>("FechaCreacion")
                        .HasColumnType("timestamptz")
                        .HasColumnName("fecha_creacion");

                    b.Property<TimeOnly>("HoraFin")
                        .HasColumnType("time without time zone")
                        .HasColumnName("hora_fin");

                    b.Property<TimeOnly>("HoraInicio")
                        .HasColumnType("time without time zone")
                        .HasColumnName("hora_inicio");

                    b.Property<int>("IdMedico")
                        .HasColumnType("integer")
                        .HasColumnName("id_medico");

                    b.Property<int>("IdPaciente")
                        .HasColumnType("integer")
                        .HasColumnName("id_paciente");

                    b.Property<string>("MotivoConsulta")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("character varying(255)")
                        .HasColumnName("motivo_consulta");

                    b.Property<string>("NotaMedica")
                        .HasColumnType("text")
                        .HasColumnName("nota_medica");

                    b.Property<uint>("RowVersion")
                        .IsConcurrencyToken()
                        .ValueGeneratedOnAddOrUpdate()
                        .HasColumnType("xid")
                        .HasColumnName("xmin");

                    b.HasKey("Id");

                    b.HasIndex("IdPaciente");

                    b.HasIndex("IdMedico", "Fecha", "HoraInicio")
                        .IsUnique()
                        .HasDatabaseName("IX_Citas_Medico_Fecha_HoraInicio_Activas")
                        .HasFilter("estado <> 'Cancelada'");

                    b.ToTable("Citas", (string)null);
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Especialidad", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id_especialidad");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<string>("Descripcion")
                        .HasMaxLength(255)
                        .HasColumnType("character varying(255)")
                        .HasColumnName("descripcion");

                    b.Property<string>("Nombre")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("character varying(100)")
                        .HasColumnName("nombre");

                    b.HasKey("Id");

                    b.ToTable("Especialidades", (string)null);
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.HorarioMedico", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id_horario");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<int>("DiaSemana")
                        .HasColumnType("integer")
                        .HasColumnName("dia_semana");

                    b.Property<TimeOnly>("HoraFin")
                        .HasColumnType("time without time zone")
                        .HasColumnName("hora_fin");

                    b.Property<TimeOnly>("HoraInicio")
                        .HasColumnType("time without time zone")
                        .HasColumnName("hora_inicio");

                    b.Property<int>("IdMedico")
                        .HasColumnType("integer")
                        .HasColumnName("id_medico");

                    b.HasKey("Id");

                    b.HasIndex("IdMedico");

                    b.ToTable("HorarioMedico", (string)null);
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Medico", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id_medico");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<bool>("Activo")
                        .HasColumnType("boolean")
                        .HasColumnName("activo");

                    b.Property<string>("Apellido")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("character varying(100)")
                        .HasColumnName("apellido");

                    b.Property<string>("Correo")
                        .IsRequired()
                        .HasMaxLength(150)
                        .HasColumnType("character varying(150)")
                        .HasColumnName("correo");

                    b.Property<DateTime>("FechaCreacion")
                        .HasColumnType("timestamptz")
                        .HasColumnName("fecha_creacion");

                    b.Property<int>("IdEspecialidad")
                        .HasColumnType("integer")
                        .HasColumnName("id_especialidad");

                    b.Property<string>("Nombre")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("character varying(100)")
                        .HasColumnName("nombre");

                    b.Property<string>("PasswordHash")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("character varying(255)")
                        .HasColumnName("password_hash");

                    b.Property<string>("Telefono")
                        .HasMaxLength(20)
                        .HasColumnType("character varying(20)")
                        .HasColumnName("telefono");

                    b.HasKey("Id");

                    b.HasIndex("Correo")
                        .IsUnique();

                    b.HasIndex("IdEspecialidad");

                    b.ToTable("Medicos", (string)null);
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Paciente", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id_paciente");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<string>("Apellido")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("character varying(100)")
                        .HasColumnName("apellido");

                    b.Property<string>("Correo")
                        .IsRequired()
                        .HasMaxLength(150)
                        .HasColumnType("character varying(150)")
                        .HasColumnName("correo");

                    b.Property<DateTime>("FechaCreacion")
                        .HasColumnType("timestamptz")
                        .HasColumnName("fecha_creacion");

                    b.Property<DateOnly?>("FechaNacimiento")
                        .HasColumnType("date")
                        .HasColumnName("fecha_nacimiento");

                    b.Property<string>("Nombre")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("character varying(100)")
                        .HasColumnName("nombre");

                    b.Property<string>("PasswordHash")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("character varying(255)")
                        .HasColumnName("password_hash");

                    b.Property<string>("Telefono")
                        .HasMaxLength(20)
                        .HasColumnType("character varying(20)")
                        .HasColumnName("telefono");

                    b.HasKey("Id");

                    b.HasIndex("Correo")
                        .IsUnique();

                    b.ToTable("Pacientes", (string)null);
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Cita", b =>
                {
                    b.HasOne("SistemaCitas.Domain.Entities.Medico", "Medico")
                        .WithMany()
                        .HasForeignKey("IdMedico")
                        .OnDelete(DeleteBehavior.Restrict)
                        .IsRequired();

                    b.HasOne("SistemaCitas.Domain.Entities.Paciente", "Paciente")
                        .WithMany()
                        .HasForeignKey("IdPaciente")
                        .OnDelete(DeleteBehavior.Restrict)
                        .IsRequired();

                    b.Navigation("Medico");

                    b.Navigation("Paciente");
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.HorarioMedico", b =>
                {
                    b.HasOne("SistemaCitas.Domain.Entities.Medico", "Medico")
                        .WithMany()
                        .HasForeignKey("IdMedico")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("Medico");
                });

            modelBuilder.Entity("SistemaCitas.Domain.Entities.Medico", b =>
                {
                    b.HasOne("SistemaCitas.Domain.Entities.Especialidad", "Especialidad")
                        .WithMany()
                        .HasForeignKey("IdEspecialidad")
                        .OnDelete(DeleteBehavior.Restrict)
                        .IsRequired();

                    b.Navigation("Especialidad");
                });
#pragma warning restore 612, 618
        }
    }
}
