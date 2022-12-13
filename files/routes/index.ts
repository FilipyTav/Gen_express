import express, { NextFunction, Request, Response, Router } from "express";

const router: Router = express.Router();

router.get("/", (req: Request, res: Response, next: NextFunction) => {
    // To render a template, use:
    // res.render("template", { arguments });

    res.send("Main page");
});

export default router;
