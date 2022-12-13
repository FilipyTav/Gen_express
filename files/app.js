import express from "express";

import path, { dirname } from "path";
import { fileURLToPath } from "url";

import index_router from "./routes/index.js";

const app = express();

// This is just so i can use __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

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
