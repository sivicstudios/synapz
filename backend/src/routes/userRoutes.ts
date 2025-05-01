import express from "express";
import { body } from "express-validator";
import { register, login } from "../controllers/userController";

const router = express.Router();

router.post(
  "/register",
  [body("username").notEmpty(), body("password").isLength({ min: 6 })],
  register,
);

router.post("/login", login);

export default router;
