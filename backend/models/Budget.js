const mongoose = require('mongoose');

const BudgetSchema = new mongoose.Schema(
  {
    category: {
      type: String,
      required: [true, 'Please provide category name'],
      unique: true,
      trim: true,
    },
    limit: {
      type: Number,
      required: true,
      default: 0,
    },
    spent: {
      type: Number,
      default: 0,
    },
    period: {
      type: String,
      default: 'monthly',
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

module.exports = mongoose.model('Budget', BudgetSchema);
