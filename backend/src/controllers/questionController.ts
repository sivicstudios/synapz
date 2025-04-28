import { Request, Response } from "express";
import { validationResult } from "express-validator";
import { IQuestion, Question } from "../models/Question";
import { QuestionService } from '../services/question.service'

const questionService = new QuestionService();

export const createQuetion = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
  }
  try {
    const question = await questionService.createQuestion(req.body);
    res.status(201).json({ question });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};


export const getQuetionById = async (req: Request, res: Response) => {
  const { questionId } = req.params;
  try {
    const question = await questionService.getQuestionById(questionId);
    res.status(200).json({ question });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

 export const fetchAllQuestions = async (req: Request, res: Response) => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

  try {
      const { questions, total } = await questionService.fetchAllPaginatedQuestions(page, limit);
     res.status(200).json({
      success: true,
      data: questions,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
     res.status(500).json({ message: "Server error" });
   }
  };

  export const updateQuetion = async (req: Request, res: Response) => {
  const { questionId } = req.params;
  try {
    const question = await questionService.updateQuestion(questionId, req.body);
    res.status(200).json({ question });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

export const deleteQuetion = async (req: Request, res: Response) => {
  const { questionId } = req.params;
  try {
    const question = await questionService.deleteQuestion(questionId);
    res.status(200).json({ data: {} });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};
