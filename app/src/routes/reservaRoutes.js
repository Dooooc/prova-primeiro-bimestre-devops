const express = require("express");

const {
    criarReserva,
    listarReservas,
    buscarReserva,
    atualizarReserva,
    deletarReserva
} = require("../controllers/reservaController");

const router = express.Router();

router.post("/reservas", criarReserva);
router.get("/reservas", listarReservas);
router.get("/reservas/:id", buscarReserva);
router.put("/reservas/:id", atualizarReserva);
router.delete("/reservas/:id", deletarReserva);

module.exports = router;