# Carry Splits — Product Definition v1.0

## Product

Carry Splits is an ultra-fast iPhone expense splitter that lets one person track shared expenses, automatically carry everyone’s running balance forward, and calculate the simplest final settlement without accounts, subscriptions, or unnecessary setup.

## Tagline

**Split it. Carry it. Settle it.**

## Core Problem

Shared expenses accumulate across dinners, trips, roommates, couples, families, road trips, parties, and temporary groups. Carry Splits answers only three questions:

1. Who paid?
2. Who participated?
3. What is the final balance?

## Core Concept: Carry Forward

Balances persist across multiple expenses. Users do not need to settle after every transaction. New expenses continuously adjust the running balance until the group is ready to settle.

## Primary Workflow

1. Create a split.
2. Add people by name.
3. Add an expense.
4. Select the payer.
5. Select participants.
6. Continue adding expenses as needed.
7. View running balances.
8. Tap Settle Up.
9. Mark settlement transfers complete.

## v1.0 Features

### Split Management
- Create a split
- Rename a split
- Archive a split
- Delete a split

### Participants
- Add participants
- Rename participants
- Remove participants when doing so does not invalidate existing expenses

### Expenses
- Add expense
- Edit expense
- Delete expense
- Description
- Amount
- Payer
- Participating people
- Date

### Split Types
- Equal split
- Exact-amount split

### Running Balance
For each participant, calculate:
- Total paid
- Total owed
- Net balance

### Settlement
- Calculate who should pay whom
- Reduce unnecessary transfers where practical
- Mark transfers paid
- Show settled state when all balances reach zero

### Sharing
Use the native iOS Share Sheet to share a simple settlement summary.

### Persistence
All v1.0 data is stored locally on-device. No account or internet connection is required.

## Primary Screens

1. Splits
2. Split Detail
3. Add / Edit Expense
4. Settle Up

## Explicitly Out of Scope for v1.0

- Cloud accounts
- User profiles
- Live group synchronization
- Bank connections
- Payment processing
- Venmo, PayPal, or Cash App integrations
- Receipt OCR
- Receipt photos
- Automatic currency conversion
- Multiple currencies in one split
- Analytics and charts
- Budgets
- Recurring bills
- Push notifications
- Chat or comments
- Social features
- Friend lists
- AI features
- Web app
- Android app
- Apple Watch app
- Subscription infrastructure

## Business Model

**$1.99 one-time App Store purchase**

No advertising, subscription, premium tier, or feature paywall.

## Privacy Position

Carry Splits v1.0 requires no account, email, phone number, contact upload, bank connection, location tracking, or advertising identifier.

Positioning: **Your expenses. Your phone.**

## Product Rule

When considering a feature, ask:

> Does this make splitting and settling expenses faster?

If not, it does not belong in Carry Splits v1.0.
