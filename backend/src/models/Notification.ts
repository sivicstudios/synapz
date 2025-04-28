import mongoose, { Schema, Document } from 'mongoose';

export interface INotification extends Document {
  user_id: string;
  title: string;
  body: string;
  is_read: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const NotificationSchema: Schema<INotification> = new Schema(
  {
    title: {
      type: String,
      required: [true, 'Notification title is required'],
      trim: true,
      unique: true,
      maxlength: [100, 'Notification title cannot exceed 100 characters'],
    },
    body: {
      type: String,
      required: [true, 'Notification body is required'],
      trim: true,
    },
    is_read: {
      type: Boolean,
      default: true,
    },
    user_id: {
      type: String,
    },
},
{ timestamps: true }
);


export const Notification = mongoose.model<INotification>('Notification', NotificationSchema);
