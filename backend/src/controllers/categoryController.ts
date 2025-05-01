import { Request, Response, NextFunction } from 'express';
import { CategoryService } from '../services/category.service';
import { asyncHandler } from '../utils/asyncHandler';

const categoryService = new CategoryService();

export class CategoryController {
  createCategory = asyncHandler(async (req: Request, res: Response) => {
    const category = await categoryService.createCategory(req.body);
    res.status(201).json({
      success: true,
      data: category,
    });
  });

  getAllCategories = asyncHandler(async (req: Request, res: Response) => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const status = req.query.status as string;

    const { categories, total } = await categoryService.getAllCategories(page, limit, status);
    res.status(200).json({
      success: true,
      data: categories,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    });
  });

  getCategoryById = asyncHandler(async (req: Request, res: Response) => {
    const category = await categoryService.getCategoryById(req.params.id);
    res.status(200).json({
      success: true,
      data: category,
    });
  });

  getCategoryBySlug = asyncHandler(async (req: Request, res: Response) => {
    const category = await categoryService.getCategoryBySlug(req.params.slug);
    res.status(200).json({
      success: true,
      data: category,
    });
  });

  updateCategory = asyncHandler(async (req: Request, res: Response) => {
    const category = await categoryService.updateCategory(req.params.id, req.body);
    res.status(200).json({
      success: true,
      data: category,
    });
  });

  deleteCategory = asyncHandler(async (req: Request, res: Response) => {
    await categoryService.deleteCategory(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Category deleted successfully',
    });
  });
}