import mongoose, {Document, Schema} from "mongoose";

export interface IQuestion extends Document {
  game_id: string;
  question: string;
  answer_type: 'true_or_false' | 'multi_option' | 'user_input';
  correct_answer: string;
  image_url: string;
  status: string;
  option_a: string | null;
  option_b: string | null;
  option_c: string | null;
  option_d: string | null;
}

const QuestionSchema: Schema = new mongoose.Schema({
  game_id: {
    type: String,
    required: true,
  },
  question: {
    type: String,
    required: true,
  },
  answer_type: {
    type: String,
    enum: ['true_or_false', 'multi_option', 'user_input'],
    required: true,
  },
  correct_answer: {
    type: String,
    required: true,
  },
  image_url: {
    type: String,
    default: null,
  },
  status: {
    type: String,
    required: true,
  },
  option_a: {
    type: String,
    default: null,
  },
  option_b: {
    type: String,
    default: null,
  },
  option_c: {
    type: String,
    default: null,
  },
  option_d: {
    type: String,
    default: null,
  },
}, {
  timestamps: true,
});

// const User = mongoose.model<IUser>("User", userSchema);
// export default User;

export const Question = mongoose.model<IQuestion>("Question", QuestionSchema);
