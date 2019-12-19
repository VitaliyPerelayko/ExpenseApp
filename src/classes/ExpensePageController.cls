public class ExpensePageController {

    public static final String SUCCESS = 'SUCCESS';

    // TODO catch exceptions
    @AuraEnabled
    public static String getMonthExpense(Id keeperId) {
        Map<Id, Monthly_Expense__c> monthlyExpenses = new Map<Id, Monthly_Expense__c>([
                SELECT Id, MonthDate__c, SpentAmount__c, Balance__c
                FROM Monthly_Expense__c
                WHERE Keeper__c = :keeperId
        ]);
        List<Expense_Card__c> expenseCards = [
                SELECT Id, Amount__c, Description__c, CardDate__c, MonthlyExpense__c
                FROM Expense_Card__c
                WHERE Card_Keeper__c = :keeperId
        ];
        return JSON.serialize(ExpensePageDTOS.mapToDTOMonthlyExpense(monthlyExpenses, expenseCards));
    }

    @AuraEnabled
    public static String insertNewExpenseCard(Id keeperId, Decimal amount, Date ecDate, String description) {
        try {
            Expense_Card__c ec = new Expense_Card__c(Card_Keeper__c = keeperId, Amount__c = amount,
                    CardDate__c = ecDate, Description__c = description);
            insert ec;
            return SUCCESS;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String deleteExpenseCard(Id ecId) {
        try {
            Expense_Card__c ec = new Expense_Card__c(Id = ecId);
            delete ec;
            return SUCCESS;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}