import { Request, Response, NextFunction } from 'express';
import { NotificationService } from '../services/notification.service';
import { asyncHandler } from '../utils/asyncHandler';

const notificationService = new NotificationService();

export class NotificationController {
  createNotification = asyncHandler(async (req: Request, res: Response) => {
    const notification = await notificationService.createNotification(req.body);
    res.status(201).json({
      success: true,
      data: notification,
    });
  });

  getAllUserNotifications = asyncHandler(async (req: Request, res: Response) => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const user_id = req.query.user_id as string;

    const { notification, total } = await notificationService.getAllUserNotifications(page, limit, user_id);
    res.status(200).json({
      success: true,
      data: notification,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    });
  });

  getNotificationById = asyncHandler(async (req: Request, res: Response) => {
    const notification = await notificationService.getNotificationById(req.params.id);
    res.status(200).json({
      success: true,
      data: notification,
    });
  });

  updateNotification = asyncHandler(async (req: Request, res: Response) => {
    const notification = await notificationService.updateNotification(req.params.id, req.body);
    res.status(200).json({
      success: true,
      data: notification,
    });
  });

  deleteNotification = asyncHandler(async (req: Request, res: Response) => {
    await notificationService.deleteNotification(req.params.id);
    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  });
}