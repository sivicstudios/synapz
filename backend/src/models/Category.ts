import mongoose, { Schema, Document } from 'mongoose';
import slugify from 'slugify';

export interface ICategory extends Document {
  name: string;
  image: string;
  status: 'active' | 'inactive' | 'archived';
  slug: string;
  createdAt: Date;
  updatedAt: Date;
}

const CategorySchema: Schema<ICategory> = new Schema(
  {
    name: {
      type: String,
      required: [true, 'Category name is required'],
      trim: true,
      unique: true,
      maxlength: [100, 'Category name cannot exceed 100 characters'],
    },
    image: {
      type: String,
      required: [true, 'Category image is required'],
      trim: true,
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'archived'],
      default: 'active',
    },
    slug: {
      type: String,
      unique: true,
      lowercase: true,
    },
  },
  { timestamps: true }
);

// Pre-save hook to generate slug with proper typing
CategorySchema.pre('save', function (this: ICategory, next) {
  if (this.isModified('name')) {
    this.slug = slugify(this.name, { lower: true, strict: true });
  }
  next();
});

export const Category = mongoose.model<ICategory>('Category', CategorySchema);