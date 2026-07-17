using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaCitas.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Administradores",
                columns: table => new
                {
                    id_administrador = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    nombre = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    correo = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    password_hash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    fecha_creacion = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Administradores", x => x.id_administrador);
                });

            migrationBuilder.CreateTable(
                name: "Especialidades",
                columns: table => new
                {
                    id_especialidad = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    nombre = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    descripcion = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Especialidades", x => x.id_especialidad);
                });

            migrationBuilder.CreateTable(
                name: "Pacientes",
                columns: table => new
                {
                    id_paciente = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    nombre = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    apellido = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    correo = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    password_hash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    telefono = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    fecha_nacimiento = table.Column<DateOnly>(type: "date", nullable: true),
                    fecha_creacion = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Pacientes", x => x.id_paciente);
                });

            migrationBuilder.CreateTable(
                name: "Medicos",
                columns: table => new
                {
                    id_medico = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    nombre = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    apellido = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    correo = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    password_hash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    id_especialidad = table.Column<int>(type: "int", nullable: false),
                    telefono = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    activo = table.Column<bool>(type: "bit", nullable: false),
                    fecha_creacion = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Medicos", x => x.id_medico);
                    table.ForeignKey(
                        name: "FK_Medicos_Especialidades_id_especialidad",
                        column: x => x.id_especialidad,
                        principalTable: "Especialidades",
                        principalColumn: "id_especialidad",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Citas",
                columns: table => new
                {
                    id_cita = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    id_paciente = table.Column<int>(type: "int", nullable: false),
                    id_medico = table.Column<int>(type: "int", nullable: false),
                    fecha = table.Column<DateOnly>(type: "date", nullable: false),
                    hora_inicio = table.Column<TimeOnly>(type: "time", nullable: false),
                    hora_fin = table.Column<TimeOnly>(type: "time", nullable: false),
                    motivo_consulta = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    estado = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    nota_medica = table.Column<string>(type: "text", nullable: true),
                    cancelada_por = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    fecha_creacion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    fecha_actualizacion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RowVersion = table.Column<byte[]>(type: "rowversion", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Citas", x => x.id_cita);
                    table.ForeignKey(
                        name: "FK_Citas_Medicos_id_medico",
                        column: x => x.id_medico,
                        principalTable: "Medicos",
                        principalColumn: "id_medico",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Citas_Pacientes_id_paciente",
                        column: x => x.id_paciente,
                        principalTable: "Pacientes",
                        principalColumn: "id_paciente",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "HorarioMedico",
                columns: table => new
                {
                    id_horario = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    id_medico = table.Column<int>(type: "int", nullable: false),
                    dia_semana = table.Column<int>(type: "int", nullable: false),
                    hora_inicio = table.Column<TimeOnly>(type: "time", nullable: false),
                    hora_fin = table.Column<TimeOnly>(type: "time", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HorarioMedico", x => x.id_horario);
                    table.ForeignKey(
                        name: "FK_HorarioMedico_Medicos_id_medico",
                        column: x => x.id_medico,
                        principalTable: "Medicos",
                        principalColumn: "id_medico",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Administradores_correo",
                table: "Administradores",
                column: "correo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Citas_id_paciente",
                table: "Citas",
                column: "id_paciente");

            migrationBuilder.CreateIndex(
                name: "IX_Citas_Medico_Fecha_HoraInicio_Activas",
                table: "Citas",
                columns: new[] { "id_medico", "fecha", "hora_inicio" },
                unique: true,
                filter: "[estado] <> 'Cancelada'");

            migrationBuilder.CreateIndex(
                name: "IX_HorarioMedico_id_medico",
                table: "HorarioMedico",
                column: "id_medico");

            migrationBuilder.CreateIndex(
                name: "IX_Medicos_correo",
                table: "Medicos",
                column: "correo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Medicos_id_especialidad",
                table: "Medicos",
                column: "id_especialidad");

            migrationBuilder.CreateIndex(
                name: "IX_Pacientes_correo",
                table: "Pacientes",
                column: "correo",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Administradores");

            migrationBuilder.DropTable(
                name: "Citas");

            migrationBuilder.DropTable(
                name: "HorarioMedico");

            migrationBuilder.DropTable(
                name: "Pacientes");

            migrationBuilder.DropTable(
                name: "Medicos");

            migrationBuilder.DropTable(
                name: "Especialidades");
        }
    }
}
