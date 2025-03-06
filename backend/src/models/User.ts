import mongoose, { Document, Schema } from "mongoose";
import bcrypt from "bcryptjs";

export interface IUser extends Document {
  username: string;
  email: string;
  password: string;
  comparePassword(userPassword: string): Promise<boolean>;
}

const userSchema: Schema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

// Hash password before saving
userSchema.pre<IUser>("save", async function (next) {
  if (this.isModified("password")) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function (
  userPassword: string,
): Promise<boolean> {
  return bcrypt.compare(userPassword, this.password);
};

const User = mongoose.model<IUser>("User", userSchema);
export default User;
