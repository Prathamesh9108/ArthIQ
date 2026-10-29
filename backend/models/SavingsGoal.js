const mongoose = require('mongoose');

const SavingsGoalSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Please provide goal title'],
      trim: true,
    },
    targetAmount: {
      type: Number,
      required: true,
    },
    currentAmount: {
      type: Number,
      default: 0,
    },
    category: {
      type: String,
      default: 'General',
    },
    targetDate: {
      type: Date,
    },
    isAutoSaveEnabled: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (doc, ret) => {
        ret.id = ret._id.toString();
        delete ret.__v;
        return ret;
      },
    },
  }
);

module.exports = mongoose.model('SavingsGoal', SavingsGoalSchema);
