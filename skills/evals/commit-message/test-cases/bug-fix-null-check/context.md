# Conversation Context

**User**: We're getting crashes in production when users try to refund orders. The error logs show "Cannot read property 'token' of null" in the refund handler.

**Assistant**: Let me check the refund handler code. Looking at `src/payment/refund-handler.ts`, I can see the issue. The code assumes `paymentMethodId` always has a corresponding record in the database:

```typescript
const paymentMethod = await this.db.paymentMethods.findById(paymentMethodId);
// No null check here
const result = await this.paymentProvider.refund({
  paymentMethodToken: paymentMethod.token, // crashes if paymentMethod is null
  ...
});
```

**User**: Right, the problem is that users sometimes delete their payment methods after making a purchase. When they request a refund later, the payment method is gone and we crash.

**Assistant**: Got it. So we need to handle the case where the payment method has been deleted. We have a couple of options:
1. Prevent users from deleting payment methods that were used for orders
2. Add a null check and use cached payment data from the order

**User**: Option 2 is better. We cache the payment token on the order when it's created, so we should always have that data available. Users should be able to delete their payment methods whenever they want.

**Assistant**: Makes sense. I'll add a null check and fall back to the cached payment data from the order. This way refunds will work even if the payment method is deleted.

**User**: Perfect. Let's do that. It's important that refunds always complete successfully - we can't have users stuck with failed refunds just because they cleaned up their payment methods.
