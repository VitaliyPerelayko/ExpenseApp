public with sharing class ExpenseCardTriggerHelper {

    public static void setMonthlyExpenseToCards(List<Expense_Card__c> expenseCards) {
        List<Monthly_Expense__c> monthlyExpenses = [SELECT Id, MonthDate__c, Keeper__c FROM Monthly_Expense__c];
        // map expenseCard => MonthlyExpense
        Map<Expense_Card__c, Monthly_Expense__c > newMonthlyExpenses = new Map<Expense_Card__c, Monthly_Expense__c>();
        for (Expense_Card__c ec : expenseCards) {
            Id monthlyExpenseId = findMonthlyExpense(monthlyExpenses, ec);
            if (monthlyExpenseId != null) {
                ec.MonthlyExpense__c = monthlyExpenseId;
            } else {
                Monthly_Expense__c monthlyExpense = findMonthlyExpenseInNews(newMonthlyExpenses.values(), ec);
                if (monthlyExpense != null) {
                    newMonthlyExpenses.put(ec, monthlyExpense);
                } else {
                    Monthly_Expense__c newMonthlyExpense = createNewMonthlyExpense(ec);
                    newMonthlyExpenses.put(ec, newMonthlyExpense);
                }
            }
        }
        insert filterMeToInsert(newMonthlyExpenses.values());
        System.debug('New monthly expenses were created:' + newMonthlyExpenses.values());
        for (Expense_Card__c ec : expenseCards) {
            if (newMonthlyExpenses.keySet().contains(ec)) {
                ec.MonthlyExpense__c = newMonthlyExpenses.get(ec).Id;
            }
        }
    }

    private static Monthly_Expense__c createNewMonthlyExpense(Expense_Card__c er) {
        return new Monthly_Expense__c(Keeper__c = er.Card_Keeper__c, MonthDate__c = er.CardDate__c.toStartOfMonth());
    }

    // TODO maybe I can better?
    private static List<Monthly_Expense__c> filterMeToInsert(List<Monthly_Expense__c> monthlyExpenses){
        List<Monthly_Expense__c> filteredList = new List<Monthly_Expense__c>();
        for (Monthly_Expense__c me: monthlyExpenses){
            if (!filteredList.contains(me)){
                filteredList.add(me);
            }
        }
        return filteredList;
    }

    private static Id findMonthlyExpense(List<Monthly_Expense__c> monthlyExpenses, Expense_Card__c er) {
        Date monthDate = er.CardDate__c.toStartOfMonth();
        for (Monthly_Expense__c monthlyExpense : monthlyExpenses) {
            if ((monthlyExpense.Keeper__c == er.Card_Keeper__c) &&
                    (monthlyExpense.MonthDate__c == monthDate)) {
                return monthlyExpense.Id;
            }
        }
        return null;
    }

    private static Monthly_Expense__c findMonthlyExpenseInNews(List<Monthly_Expense__c> newMonthlyExpenses, Expense_Card__c ec) {
        Date monthDate = ec.CardDate__c.toStartOfMonth();
        for (Monthly_Expense__c monthlyExpense : newMonthlyExpenses) {
            if ((monthlyExpense.Keeper__c == ec.Card_Keeper__c) &&
                    (monthlyExpense.MonthDate__c == monthDate)) {
                return monthlyExpense;
            }
        }
        return null;
    }
}