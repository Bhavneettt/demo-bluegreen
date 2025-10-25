const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;
const COLOR = process.env.COLOR || "unknown";
app.get("/", (req, res) => res.send(`Hello from ${COLOR}!`));
app.get("/health", (req, res) => res.status(200).send("OK"));
app.listen(PORT, () => console.log(`Running ${COLOR} on ${PORT}`));
