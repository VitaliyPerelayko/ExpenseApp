trigger ExpenseCardTrigger on Expense_Card__c (before insert, before update) {
    ExpenseCardTriggerHelper.setMonthlyExpenseToCards(Trigger.new);
}