import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();

const DB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI as string);
    console.log("MongoDB connected successfully");
  } catch (error) {
    console.error("MongoDB connection error:", error);
    process.exit(1);
  }
};

export default DB;
