public class AdminPageController {

    @AuraEnabled
    public static String getDataForAdminPage() {
        try {
            List<Monthly_Expense__c> monthlyExpenses = [
                    SELECT Id, MonthDate__c, SpentAmount__c, Balance__c, Keeper__c, Reminder__c
                    FROM Monthly_Expense__c
                    ORDER BY MonthDate__c ASC
            ];
            return JSON.serialize(AdminPageDTOS.mapToExpensesForYearDTO(monthlyExpenses));
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String getDataForOfficePage(String office) {
        // list of contactIds from this office
        List<Id> userIds = new List<Id>();
        Map<Id, Contact> contactMap = UtilMethods.contactsOfficeMap();
        for (Id cId : contactMap.keySet()) {
            if (contactMap.get(cId).Office__c == office) {
                userIds.add(cId);
            }
        }
        List<Monthly_Expense__c> monthlyExpenses = [
                SELECT Id, MonthDate__c, SpentAmount__c, Balance__c, Keeper__c, Reminder__c
                FROM Monthly_Expense__c
                WHERE Keeper__c IN :userIds
                ORDER BY MonthDate__c ASC
        ];
        List<Expense_Card__c> expenseCards = [
                SELECT Id, CardDate__c, Card_Keeper__c, Description__c, Amount__c, MonthlyExpense__c
                FROM Expense_Card__c
                WHERE Card_Keeper__c IN :userIds
                ORDER BY CardDate__c ASC
        ];
        return JSON.serialize(AdminPageDTOS.mapOfficeDetailDTO(office, monthlyExpenses, expenseCards));
    }

    @AuraEnabled
    public static String deleteExpenseCard(Id ecId) {
        try {
            Expense_Card__c ec = new Expense_Card__c(Id = ecId);
            delete ec;
            return 'SUCCESS';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
}