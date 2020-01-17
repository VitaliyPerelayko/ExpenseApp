public class AdminPageController {

    public static final String NO_DATA = 'NO_DATA';

    @AuraEnabled
    public static String getDataForAdminPage() {
        try {
            List<Monthly_Expense__c> monthlyExpenses = [
                    SELECT Id, MonthDate__c, SpentAmount__c, Balance__c, Keeper__c, Reminder__c
                    FROM Monthly_Expense__c
                    ORDER BY MonthDate__c ASC
            ];
            return JSON.serialize(AdminPageDTOS.createExpensesForYear(monthlyExpenses));
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String getInfoForOfficePage(String office, Integer year) {
        try {
            Date startYear = Date.newInstance(year, 1, 1);
            Date endYear = Date.newInstance(year, 12, 31);
            // list of contactIds from this office
            List<Id> keeperIds = new List<Id>();
            Map<Id, String> keepersLastNames = new Map<Id, String>();
            Map<Id, Contact> contactMap = UtilMethods.contactsOfficeMap();
            for (Id cId : contactMap.keySet()) {
                if (contactMap.get(cId).Office__c == office) {
                    keeperIds.add(cId);
                    keepersLastNames.put(cId, contactMap.get(cId).LastName);
                }
            }
            List<Monthly_Expense__c> monthlyExpenses = new List<Monthly_Expense__c>([
                    SELECT Id, MonthDate__c, SpentAmount__c, Balance__c, Keeper__c, (SELECT Id, Amount__c, Description__c, CardDate__c FROM ExpenseCards__r)
                    FROM Monthly_Expense__c
                    WHERE Keeper__c IN :keeperIds
                    AND MonthDate__c >= :startYear
                    AND MonthDate__c <= :endYear
            ]);
            System.debug(monthlyExpenses);
            if (monthlyExpenses.isEmpty()) {
                return NO_DATA;
            } else {
                return JSON.serialize(AdminPageDTOS.mapOfficeDetailDTO(office, year, monthlyExpenses, keepersLastNames));
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}