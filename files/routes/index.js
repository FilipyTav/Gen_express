import express from "express";

const router = express.Router();

router.get("/", (req, res, next) => {
    // To render a template, use:
    // res.render("template", { arguments });

    res.send("Main page")
});

export default router;
