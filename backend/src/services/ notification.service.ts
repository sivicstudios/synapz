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
