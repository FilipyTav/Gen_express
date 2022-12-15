import express, { NextFunction, Request, Response, Router } from "express";

const router: Router = express.Router();

router.get("/", (req: Request, res: Response, next: NextFunction) => {
    // To render a template, use:
    // res.render("template", { arguments });

    // Refers to the template name, without the extension
    res.render("index", { title: "Main" });
});

export default router;
