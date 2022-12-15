import express from "express";

const router = express.Router();

router.get("/", (req, res, next) => {
    // To render a template, use:
    // res.render("template", { arguments });

    // Refers to the template name, without the extension
    res.render("index", { title: "Main" });
});

export default router;
