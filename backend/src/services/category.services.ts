import { Category, ICategory } from '../models/Category';
import { NotFoundError, BadRequestError } from '../utils/errors';
import { Types } from 'mongoose';

export class CategoryService {
  async createCategory(data: Partial<ICategory>): Promise<ICategory> {
    try {
      const category = new Category(data);
      return await category.save();
    } catch (error: any) {
      if (error.code === 11000) {
        throw new BadRequestError('Category name or slug already exists');
      }
      throw error;
    }
  }

  async getAllCategories(
    page: number = 1,
    limit: number = 10,
    status?: string
  ): Promise<{ categories: ICategory[]; total: number }> {
    const query: any = {};
    if (status) {
      query.status = status;
    }

    const skip = (page - 1) * limit;
    const [categories, total] = await Promise.all([
      Category.find(query).skip(skip).limit(limit).sort({ createdAt: -1 }),
      Category.countDocuments(query),
    ]);

    return { categories, total };
  }

  async getCategoryById(id: string): Promise<ICategory> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestError('Invalid category ID');
    }
    const category = await Category.findById(id);
    if (!category) {
      throw new NotFoundError('Category not found');
    }
    return category;
  }

  async getCategoryBySlug(slug: string): Promise<ICategory> {
    const category = await Category.findOne({ slug });
    if (!category) {
      throw new NotFoundError('Category not found');
    }
    return category;
  }

  async updateCategory(id: string, data: Partial<ICategory>): Promise<ICategory> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestError('Invalid category ID');
    }
    const category = await Category.findById(id);
    if (!category) {
      throw new NotFoundError('Category not found');
    }

    Object.assign(category, data);
    try {
      return await category.save();
    } catch (error: any) {
      if (error.code === 11000) {
        throw new BadRequestError('Category name or slug already exists');
      }
      throw error;
    }
  }

  async deleteCategory(id: string): Promise<void> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestError('Invalid category ID');
    }
    const category = await Category.findById(id);
    if (!category) {
      throw new NotFoundError('Category not found');
    }
    await category.deleteOne();
  }
}