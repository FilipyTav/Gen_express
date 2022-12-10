import express from "express";

import path from "path";

import index_router from "./routes/index";

const app = express();

// Allows access to form content
app.use(
    express.urlencoded({
        extended: true,
    }),
);

const port = 3000;

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});

// View engine setup
app.set("views", path.join(__dirname, "./mvc/views"));
app.set("view engine", "<----VIEW ENGINE PLACEHOLDER---->");

// Setup static directory
app.use(express.static(path.join(__dirname, "/../dist")));

app.use("/", index_router);
