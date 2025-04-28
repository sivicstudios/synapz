import { Notification, INotification } from "../models/Notification";
import { NotFoundError, BadRequestError } from "../utils/errors";
import { Types } from "mongoose";

export class NotificationService {
  async createNotification(data: Partial<INotification>): Promise<INotification> {
    try {
      const notification = new Notification(data);
      return await notification.save();
    } catch (error: any) {
        throw new BadRequestError(error);
    }
  }
  async getAllUserNotifications(
    page: number = 1,
    limit: number = 10,
    user_id?: string,
  ): Promise<{ notification: INotification[]; total: number }> {
    const query: any = {};
    if (user_id) {
      query.user_id = user_id;
    }

    const skip = (page - 1) * limit;
    const [notification, total] = await Promise.all([
      Notification.find(query).skip(skip).limit(limit).sort({ createdAt: -1 }),
      Notification.countDocuments(query),
    ]);
    return { notification, total };
}

async getNotificationById(id: string): Promise<INotification> {
  if (!Types.ObjectId.isValid(id)) {
    throw new BadRequestError("Invalid Notification ID");
  }
  const notification = await Notification.findById(id);
  if (!notification) {
    throw new NotFoundError("Notification Not Found");
  }
  return notification;
}
async updateNotification(
    id: string,
    data: Partial<INotification>,
  ): Promise<INotification> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestError("Invalid Notification ID");
    }
    const notification = await Notification.findById(id);
    if (!notification) {
      throw new NotFoundError("Notification Not Found");
    }
    Object.assign(notification, data);
    try {
      return await notification.save();
    } catch (error: any) {
        throw new BadRequestError(error);
    }
  }
  async deleteNotification(id: string): Promise<void> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestError("Invalid Notification ID");
    }
    const notification = await Notification.findById(id);
    if (!notification) {
      throw new NotFoundError("Notification Not Found");
    }
    await notification.deleteOne();
  }
}

