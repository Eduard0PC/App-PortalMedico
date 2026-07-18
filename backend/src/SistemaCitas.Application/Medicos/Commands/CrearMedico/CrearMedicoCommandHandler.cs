using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Medicos.Commands.CrearMedico;

public sealed class CrearMedicoCommandHandler : IRequestHandler<CrearMedicoCommand, MedicoDto>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IEspecialidadRepository _especialidadRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IUnitOfWork _unitOfWork;

    public CrearMedicoCommandHandler(
        IMedicoRepository medicoRepository,
        IEspecialidadRepository especialidadRepository,
        IPasswordHasher passwordHasher,
        IUnitOfWork unitOfWork)
    {
        _medicoRepository = medicoRepository;
        _especialidadRepository = especialidadRepository;
        _passwordHasher = passwordHasher;
        _unitOfWork = unitOfWork;
    }

    public async Task<MedicoDto> Handle(CrearMedicoCommand request, CancellationToken ct)
    {
        if (await _medicoRepository.ExisteCorreoAsync(request.Correo, ct))
            throw new ReglaDeNegocioException("Ya existe un médico registrado con ese correo.");

        var especialidad = await _especialidadRepository.ObtenerPorIdAsync(request.IdEspecialidad, ct)
            ?? throw new NotFoundException(
                $"No existe una especialidad con id {request.IdEspecialidad}.");

        var passwordHash = _passwordHasher.Hash(request.Password);

        var medico = new Medico(
            request.Nombre,
            request.Apellido,
            request.Correo,
            passwordHash,
            request.IdEspecialidad,
            request.Telefono);

        _medicoRepository.Agregar(medico);
        await _unitOfWork.SaveChangesAsync(ct);

        return new MedicoDto(
            medico.Id, medico.Nombre, medico.Apellido, medico.Correo, medico.IdEspecialidad,
            especialidad.Nombre, medico.Telefono, medico.Activo, medico.FechaCreacion);
    }
}