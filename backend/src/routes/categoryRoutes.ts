import { Router } from "express";
import { CategoryController } from "../controllers/categoryController";

const router = Router();
const categoryController = new CategoryController();

router
  .route("/")
  .post(categoryController.createCategory)
  .get(categoryController.getAllCategories);

router
  .route("/:id")
  .get(categoryController.getCategoryById)
  .put(categoryController.updateCategory)
  .delete(categoryController.deleteCategory);

router.get("/slug/:slug", categoryController.getCategoryBySlug);

export default router;
