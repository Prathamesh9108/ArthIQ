const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Please provide transaction title'],
      trim: true,
    },
    amount: {
      type: Number,
      required: [true, 'Please provide amount'],
      min: [0, 'Amount must be positive'],
    },
    type: {
      type: String,
      enum: ['expense', 'income'],
      required: [true, 'Transaction type must be expense or income'],
    },
    category: {
      type: String,
      required: [true, 'Please provide category'],
      trim: true,
    },
    date: {
      type: Date,
      default: Date.now,
    },
    paymentMethod: {
      type: String,
      default: 'UPI',
    },
    receiptPath: {
      type: String,
      default: null,
    },
    note: {
      type: String,
      default: '',
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

module.exports = mongoose.model('Transaction', TransactionSchema);
