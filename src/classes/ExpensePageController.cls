public class ExpensePageController {

    public static final String SUCCESS = 'SUCCESS';

    @AuraEnabled
    public static String getMonthExpense(Id keeperId, Integer year) {
        try {
            Date startYear = Date.newInstance(year, 1, 1);
            Date endYear = Date.newInstance(year, 12, 31);
            List<Monthly_Expense__c> monthlyExpenses = new List<Monthly_Expense__c>([
                    SELECT Id, MonthDate__c, SpentAmount__c, Balance__c,
                    (SELECT Id, Amount__c, Description__c, CardDate__c FROM ExpenseCards__r)
                    FROM Monthly_Expense__c
                    WHERE Keeper__c = :keeperId
                    AND MonthDate__c >= :startYear
                    AND MonthDate__c <= :endYear
            ]);
            return JSON.serialize(ExpensePageDTOS.mapToDTOMonthlyExpense(monthlyExpenses));
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String insertNewExpenseCard(Id keeperId, Decimal amount, Date ecDate, String description) {
        try {
            Expense_Card__c ec = new Expense_Card__c(Card_Keeper__c = keeperId, Amount__c = amount,
                    CardDate__c = ecDate, Description__c = description);
            insert ec;
            return SUCCESS;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteExpenseCard(Id ecId) {
        try {
            Expense_Card__c ec = new Expense_Card__c(Id = ecId);
            delete ec;
            return SUCCESS;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}