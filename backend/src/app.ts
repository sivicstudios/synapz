import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";

// Routes
import userRoutes from './routes/userRoutes';
import questionRoutes from './routes/questionRoutes';

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan("combined"));
app.use(express.json());

// Routes
app.get("/", (req: Request, res: Response) => {
  res.send("Welcome to the Synapz Backend!");
});

app.use('/api/users', userRoutes);
app.use('/api/questions', questionRoutes);

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something went wrong!" });
});

export default app;
