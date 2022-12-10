import express, { NextFunction, Request, Response, Router } from "express";

const router: Router = express.Router();

router.get("/", (req: Request, res: Response, next: NextFunction) => {
    res.render("template", { arguments });
});

export default router;
