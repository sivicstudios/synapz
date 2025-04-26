import express from "express";
import { body } from "express-validator";
import { createQuetion, deleteQuetion, fetchAllQuestions, getQuetionById, updateQuetion } from "../controllers/questionController";

export const validateAddQuestion = [
  body("game_id").notEmpty().withMessage("game_id is required"),
  body("question").notEmpty().withMessage("question is required"),
  body("answer_type")
    .isIn(["true_or_false", "multi_option", "user_input"])
    .withMessage("answer_type must be one of: true_or_false, multi_option, user_input"),
  body("correct_answer").notEmpty().withMessage("correct_answer is required"),
  body("image_url").notEmpty().withMessage("image_url is required"),
  body("status").notEmpty().withMessage("status is required"),
  body("option_a").optional({ nullable: true }).isString().withMessage("option_a must be a string or null"),
  body("option_b").optional({ nullable: true }).isString().withMessage("option_b must be a string or null"),
  body("option_c").optional({ nullable: true }).isString().withMessage("option_c must be a string or null"),
  body("option_d").optional({ nullable: true }).isString().withMessage("option_d must be a string or null"),
];

export const validateUpdateQuestion = [
  body("game_id").optional({ nullable: true }).isString().withMessage("game_id must be a string"),
  body("question").optional({ nullable: true }).isString().withMessage("question must be a string"),
  body("answer_type")
    .optional({ nullable: true })
    .isIn(["true_or_false", "multi_option", "user_input"])
    .withMessage("answer_type must be one of: true_or_false, multi_option, user_input"),
  body("correct_answer").optional({ nullable: true }).isString().withMessage("correct_answer must be a string"),
  body("image_url").optional({ nullable: true }).isString().withMessage("image_url must be a string"),
  body("status").optional({ nullable: true }).isString().withMessage("status must be a string"),
  body("option_a").optional({ nullable: true }).isString().withMessage("option_a must be a string or null"),
  body("option_b").optional({ nullable: true }).isString().withMessage("option_b must be a string or null"),
  body("option_c").optional({ nullable: true }).isString().withMessage("option_c must be a string or null"),
  body("option_d").optional({ nullable: true }).isString().withMessage("option_d must be a string or null"),
];

const router = express.Router();

router.get(
  "/",
  fetchAllQuestions
);


router.get("/:questionId", getQuetionById);
router.put(
  "/:questionId",
  validateUpdateQuestion,
  updateQuetion,
)
router.post(
  "/add-question",
  validateAddQuestion,
  createQuetion,
);
router.delete(
  "/:questionId",
  deleteQuetion
);



export default router;
