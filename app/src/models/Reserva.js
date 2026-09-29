const { DataTypes } = require("sequelize");
const sequelize = require("../database/connection");

const Reserva = sequelize.define(
    "Reserva",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },

        nome: {
            type: DataTypes.STRING,
            allowNull: false
        },

        email: {
            type: DataTypes.STRING,
            allowNull: false
        },

        data: {
            type: DataTypes.DATEONLY,
            allowNull: false
        },

        horario: {
            type: DataTypes.TIME,
            allowNull: false
        },

        quantidade_pessoas: {
            type: DataTypes.INTEGER,
            allowNull: false
        }
    },
    {
        tableName: "reservas",
        timestamps: true
    }
);

module.exports = Reserva;