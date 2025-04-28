import { Question, IQuestion } from '../models/Question';
import { Types } from 'mongoose';
import { BadRequestError, NotFoundError } from '../utils/errors';


export class QuestionService {

  // create question
  async createQuestion(data: Partial<IQuestion>): Promise<IQuestion> {
    try {
      const question = new Question(data);
      return await question.save();
    } catch (error: any) {
      if (error.code === 11000) {
        throw new BadRequestError('Fail to create Question');
      }
      throw error;
    }
  }


// update Question
  async updateQuestion(questionId: string, data: Partial<IQuestion>): Promise<IQuestion> {
    if (!Types.ObjectId.isValid(questionId)) {
      throw new BadRequestError('Invalid Question ID');
    }
    const question = await this.getQuestionById(questionId);

    Object.assign(question, data);
    try {
      return await question.save();
    } catch (error: any) {
      if (error.code === 11000) {
        throw new BadRequestError('Failed to update Question');
      }
      throw error;
    }
  }

  // get question By Id
    async getQuestionById(questionId: string): Promise<IQuestion> {
    if (!Types.ObjectId.isValid(questionId)) {
      throw new BadRequestError('Invalid Question ID');
    }
    const question = await Question.findById(questionId);
    if (!question) {
      throw new NotFoundError('Question not found');
    }
    return question;
  }

  // delete question 
    async deleteQuestion(questionId: string): Promise<void> {
    if (!Types.ObjectId.isValid(questionId)) {
      throw new BadRequestError('Invalid Question ID');
    }
    const question = await this.getQuestionById(questionId)
    await question.deleteOne();
  }

  // paginated list of questions
  async fetchAllPaginatedQuestions(
    page: number = 1,
    limit: number = 10,
    status?: string
  ): Promise<{ questions: IQuestion[]; total: number }> {
    const query: any = {};
    if (status) {
      query.status = status;
    }

    const skip = (page - 1) * limit;
    const [questions, total,] = await Promise.all([
      Question.find(query).skip(skip).limit(limit).sort({ createdAt: -1 }),
      Question.countDocuments(query),
    ]);

    return { questions, total };
  }


}