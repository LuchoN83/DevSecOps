const express = require("express");
const app = express();
app.get("/", (_, res) => res.send("Hello from signed image!"));
app.get("/health", (_, res) => res.status(200).send("ok"));
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening on ${port}`));
