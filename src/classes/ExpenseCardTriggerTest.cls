@isTest
private class ExpenseCardTriggerTest {

    @isTest
    static void insertTestNewDates() {
        System.debug('========== ExpenseCardTriggerTest.insertTestNewDates start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> datesForMonthlyExpenses =
                TestDataFactory.createDateListForMonthlyExpense(Date.newInstance(2019, 1, 1), Date.newInstance(2019, 4, 1));
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 5, 12));
        List<Monthly_Expense__c> monthlyExpenses =
                TestDataFactory.createMonthlyExpenses(testContact.Id, datesForMonthlyExpenses);
        Test.startTest();
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        Test.stopTest();
        List<Monthly_Expense__c> newMonthlyExpenses = [
                SELECT Id, MonthDate__c, Keeper__c
                FROM Monthly_Expense__c
                ORDER BY MonthDate__c ASC
        ];
        Integer lastIndex = newMonthlyExpenses.size() - 1;
        // assert that there was added new Monthly Expense
        System.assertEquals(0, lastIndex - monthlyExpenses.size());
        System.assertEquals(testContact.Id, newMonthlyExpenses[lastIndex].Keeper__c);
        System.assertEquals(Date.newInstance(2019, 5, 1), newMonthlyExpenses[lastIndex].MonthDate__c);
        System.debug('========== ExpenseCardTriggerTest.insertTestNewDates end test ==========');
    }

    @isTest
    static void insertTestNewKeeper() {
        System.debug('========== ExpenseCardTriggerTest.insertTestNewKeeper start test ==========');
        Contact testContactOld = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        Contact testContactNew = TestDataFactory.createContact('Mayakovsky', 'letter@lila.brig', '12', 'Office 1', false);
        List<Date> datesForMonthlyExpenses =
                TestDataFactory.createDateListForMonthlyExpense(Date.newInstance(2019, 1, 1), Date.newInstance(2019, 4, 1));
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
        List<Monthly_Expense__c> monthlyExpenses =
                TestDataFactory.createMonthlyExpenses(testContactOLd.Id, datesForMonthlyExpenses);
        Test.startTest();
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContactNew.Id, datesForExpenseCards);
        Test.stopTest();
        List<Monthly_Expense__c> newMonthlyExpenses = [
                SELECT Id, MonthDate__c, Keeper__c
                FROM Monthly_Expense__c
                WHERE Keeper__c = :testContactNew.Id
        ];
        // assert that there were added three new Monthly Expenses
        System.assertEquals(3, newMonthlyExpenses.size());
        System.debug('========== ExpenseCardTriggerTest.insertTestNewKeeper end test ==========');
    }

    @isTest
    static void updateTestNewKeeper() {
        System.debug('========== ExpenseCardTriggerTest.updateTestNewKeeper start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        Contact testContactNew = TestDataFactory.createContact('Mayakovsky', 'letter@lila.brig', '12', 'Office 1', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        for (Expense_Card__c ec : expenseCards) {
            if (ec.CardDate__c.month() == 3) {
                ec.Card_Keeper__c = testContactNew.Id;
            }
        }
        Integer numOfMonthlyExpenses = [
                SELECT COUNT()
                FROM Monthly_Expense__c
        ];
        // assert that there were added 3 new Monthly Expenses
        System.assertEquals(3, numOfMonthlyExpenses);
        Test.startTest();
        update expenseCards;
        Test.stopTest();
        List<Monthly_Expense__c> newMonthlyExpenses = [
                SELECT Id, MonthDate__c, Keeper__c
                FROM Monthly_Expense__c
                WHERE Keeper__c = :testContactNew.Id
        ];
        // assert that there was added new Monthly Expense
        System.assertEquals(1, newMonthlyExpenses.size());
        System.assertEquals(Date.newInstance(2019, 3, 1), newMonthlyExpenses[0].MonthDate__c);
        System.debug('========== ExpenseCardTriggerTest.updateTestNewKeeper end test ==========');
    }

    @isTest
    static void updateTestNewDates() {
        System.debug('========== ExpenseCardTriggerTest.updateTestNewDates start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        Integer numOfMonthlyExpenses = [
                SELECT COUNT()
                FROM Monthly_Expense__c
        ];
        // assert that there were added 3 new Monthly Expenses
        System.assertEquals(3, numOfMonthlyExpenses);
        expenseCards[1].CardDate__c = Date.newInstance(2019, 4, 17);
        Test.startTest();
        update expenseCards;
        Test.stopTest();
        List<Monthly_Expense__c> newMonthlyExpenses = [
                SELECT Id, MonthDate__c, Keeper__c
                FROM Monthly_Expense__c
                ORDER BY MonthDate__c ASC
        ];
        // assert that there was added new Monthly Expense
        System.assertEquals(4, newMonthlyExpenses.size());
        System.assertEquals(Date.newInstance(2019, 4, 1), newMonthlyExpenses[newMonthlyExpenses.size() - 1].MonthDate__c);
        System.debug('========== ExpenseCardTriggerTest.updateTestNewDates end test ==========');
    }
}