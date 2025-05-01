import { Request, Response } from "express";
import { validationResult } from "express-validator";
import jwt from "jsonwebtoken";
import User from "../models/User";
import dotenv from "dotenv";

dotenv.config();

// Register
export const register = async (req: Request, res: Response): Promise<void> => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
  }

  try {
    const { username, password } = req.body;

    // Check if user already exists
    let user = await User.findOne({ username });
    if (user) {
      res.status(400).json({ message: "User already exists" });
    }

    // Create new user
    user = new User({ username, password });
    await user.save();

    // Generate JWT
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET as string,
      {
        expiresIn: "1h",
      },
    );

    res.status(201).json({ token });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// Login
export const login = async (req: Request, res: Response): Promise<void> => {
  const { username, password } = req.body;

  try {
    // Find user by username
    const user = await User.findOne({ username });
    if (!user) {
      res.status(400).json({ message: "Invalid credentials" });
    }

    // Compare passwords
    const isMatch = await user?.comparePassword(password);
    if (!isMatch) {
      res.status(400).json({ message: "Invalid credentials" });
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user?._id },
      process.env.JWT_SECRET as string,
      {
        expiresIn: "1h",
      },
    );

    res.json({ token });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};
