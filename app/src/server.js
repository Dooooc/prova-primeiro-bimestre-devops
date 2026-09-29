const express = require("express");
const sequelize = require("./database/connection");
const Reserva = require("./models/Reserva");
const reservaRoutes = require("./routes/reservaRoutes");

const app = express();

app.use(express.json());

app.use(reservaRoutes);

app.get("/", (req, res) => {
    res.json({
        message: "API de Reservas funcionando!"
    });
});

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        await sequelize.authenticate();

        console.log("PostgreSQL conectado com sucesso!");

        await Reserva.sync();

        console.log("Tabela reservas sincronizada!");

        app.listen(PORT, () => {
            console.log(`Servidor rodando na porta ${PORT}`);
        });
    } catch (error) {
        console.error("Erro ao iniciar a aplicação:");
        console.error(error);
    }
}

startServer();