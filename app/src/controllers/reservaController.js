const Reserva = require("../models/Reserva");

async function criarReserva(req, res) {
    try {
        const { nome, email, data, horario, quantidade_pessoas } = req.body;

        const reserva = await Reserva.create({
            nome,
            email,
            data,
            horario,
            quantidade_pessoas
        });

        return res.status(201).json(reserva);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            error: "Erro ao criar reserva"
        });
    }
}

async function listarReservas(req, res) {
    try {
        const reservas = await Reserva.findAll();

        return res.status(200).json(reservas);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            error: "Erro ao listar reservas"
        });
    }
}

module.exports = {
    criarReserva,
    listarReservas,
    buscarReserva,
    atualizarReserva,
    deletarReserva
};

async function buscarReserva(req, res) {
    try {
        const { id } = req.params;

        const reserva = await Reserva.findByPk(id);

        if (!reserva) {
            return res.status(404).json({
                error: "Reserva não encontrada"
            });
        }

        return res.status(200).json(reserva);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            error: "Erro ao buscar reserva"
        });
    }
}

async function atualizarReserva(req, res) {
    try {
        const { id } = req.params;

        const reserva = await Reserva.findByPk(id);

        if (!reserva) {
            return res.status(404).json({
                error: "Reserva não encontrada"
            });
        }

        const {
            nome,
            email,
            data,
            horario,
            quantidade_pessoas
        } = req.body;

        await reserva.update({
            nome,
            email,
            data,
            horario,
            quantidade_pessoas
        });

        return res.status(200).json(reserva);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            error: "Erro ao atualizar reserva"
        });
    }
}

async function deletarReserva(req, res) {
    try {
        const { id } = req.params;

        const reserva = await Reserva.findByPk(id);

        if (!reserva) {
            return res.status(404).json({
                error: "Reserva não encontrada"
            });
        }

        await reserva.destroy();

        return res.status(200).json({
            message: "Reserva excluída com sucesso"
        });
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            error: "Erro ao excluir reserva"
        });
    }
}