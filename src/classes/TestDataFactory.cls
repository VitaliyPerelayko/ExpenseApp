@isTest
public class TestDataFactory {

    public static Contact createContact(String cLastName, String cEmail,
            String password, String office, Boolean isAdmin) {
        Contact newContact = new Contact(LastName = cLastName,
                Email = cEmail,
                Password__c = password,
                Office__c = office,
                Admin__c = isAdmin
        );
        insert newContact;
        return newContact;
    }

    public static List<Monthly_Expense__c> createMonthlyExpenses(Id contactId, List<Date> mDates) {
        List<Monthly_Expense__c> monthlyExpenses = new List<Monthly_Expense__c>();
        for (Date d : mDates) {
            monthlyExpenses.add(new Monthly_Expense__c(
                    Keeper__c = contactId,
                    MonthDate__c = d,
                    Balance__c = d.year()
            ));
        }
        insert monthlyExpenses;
        return monthlyExpenses;
    }

    public static List<Expense_Card__c> createExpenseCards(Id contactId, List<Date> cardDates) {
        List<Expense_Card__c> expenseCards = new List<Expense_Card__c>();
        for (Date cd : cardDates) {
            expenseCards.add(new Expense_Card__c(
                    Card_Keeper__c = contactId,
                    Amount__c = cd.month(),
                    CardDate__c = cd,
                    Description__c = 'description' + cd
            ));
        }
        insert expenseCards;
        return expenseCards;
    }

    public static List<Date> createDateListForExpenseCards(Date startDate, Date endDate) {
        List<Date> dates = new List<Date>();
        Date justDate = startDate;
        while (justDate <= endDate) {
            dates.add(justDate);
            justDate = justDate.addDays(1);
        }
        return dates;
    }

    public static List<Date> createDateListForMonthlyExpense(Date startDate, Date endDate) {
        List<Date> dates = new List<Date>();
        Date justDate = startDate;
        while (justDate <= endDate) {
            dates.add(justDate);
            justDate = justDate.addMonths(1);
        }
        return dates;
    }
}