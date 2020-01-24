@isTest
private class ExpensePageControllerTest {

    // get Data for page
    @isTest
    static void getMonthExpenseTest() {
        System.debug('========== ExpensePageControllerTest.getMonthExpenseTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        String monthExpenses = ExpensePageController.getMonthExpense(testContact.Id, 2019);
        List<ExpensePageDTOS.MonthExpenseDTO> monthExpenseDTOS = (List<ExpensePageDTOS.MonthExpenseDTO>)
                JSON.deserialize(monthExpenses, List<ExpensePageDTOS.MonthExpenseDTO>.class);
        System.assertEquals(24.00, monthExpenseDTOS[0].sumOfExpenses);
        System.assertEquals(24, monthExpenseDTOS[0].expenseCardsByDate.size());
        for (ExpensePageDTOS.MonthExpenseDTO meDTO : monthExpenseDTOS) {
            System.debug(meDTO.numberOfMonth);
            System.debug(meDTO.sumOfExpenses);
            for (ExpensePageDTOS.ListExpenseCardsByDateDTO listExpenseCardsByDateDTO : meDTO.expenseCardsByDate) {
                System.debug(listExpenseCardsByDateDTO.dateOfEC);
                for (ExpensePageDTOS.ExpenseCardDTO expenseCardDTO : listExpenseCardsByDateDTO.expenseCards) {
                    System.debug('======' + expenseCardDTO);
                }
            }
        }
        System.debug('========== ExpensePageControllerTest.getMonthExpenseTest end test ==========');
    }

    @isTest
    static void getMonthExpenseTestNoData() {
        System.debug('========== ExpensePageControllerTest.getMonthExpenseTestNoData start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        String monthExpenses = ExpensePageController.getMonthExpense(testContact.Id, 2019);
        System.assertEquals(ExpensePageController.NO_DATA, monthExpenses);
        System.debug('========== ExpensePageControllerTest.getMonthExpenseTestNoData end test ==========');
    }

    @isTest
    static void getMonthExpenseTestError() {
        System.debug('========== ExpensePageControllerTest.getMonthExpenseTestError start test ==========');
        Test.startTest();
        try {
            ExpensePageController.getMonthExpense(TestDataFactory.BAD_USER_ID, 2019);
        } catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        Test.stopTest();
        System.debug('========== ExpensePageControllerTest.getMonthExpenseTestError end test ==========');
    }

    // insert new expense card
    @isTest
    static void insertNewExpenseCardTest() {
        System.debug('========== ExpensePageControllerTest.insertNewExpenseCardTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        ExpensePageController.insertNewExpenseCard(testContact.Id, 23.1, Date.newInstance(2019, 10, 11), 'present for birthday');
        Integer numOfExpenseCards = [SELECT COUNT() FROM Expense_Card__c];
        System.assertEquals(1, numOfExpenseCards);
        System.debug('========== ExpensePageControllerTest.insertNewExpenseCardTest end test ==========');
    }

    @isTest
    static void insertNewExpenseCardTestExceptionOccurred() {
        System.debug('========== ExpensePageControllerTest.insertNewExpenseCardTestExceptionOccurred start test ==========');
        Test.startTest();
        try {
            ExpensePageController.insertNewExpenseCard(TestDataFactory.BAD_USER_ID, 23.1, Date.newInstance(2019, 10, 11), 'present for birthday');
        } catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        Test.stopTest();
        Integer numOfExpenseCards = [SELECT COUNT() FROM Expense_Card__c];
        System.assertEquals(0, numOfExpenseCards);
        System.debug('========== ExpensePageControllerTest.insertNewExpenseCardTestExceptionOccurred end test ==========');
    }

    // update ExpenseCards
    @isTest
    static void updateExpenseCardsTest() {
        System.debug('========== ExpensePageControllerTest.updateExpenseCardsTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 1, 15));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        Id cardId1 = expenseCards[0].Id;
        Id cardId2 = expenseCards[1].Id;
        String expenseCardsDTOJson = '[{"cardId":"' + cardId1 +
                '","description":"pumpkin and candles"},{"cardId":"' + cardId2 + '","amount":"13.13"}]';
        System.debug(expenseCardsDTOJson);
        ExpensePageController.updateExpenseCards(expenseCardsDTOJson);
        Map<Id, Expense_Card__c> expenseCardsFromDB = new Map<Id, Expense_Card__c>([
                SELECT Id, Description__c, Amount__c, CardDate__c
                FROM Expense_Card__c
        ]);
        System.assertEquals(8, expenseCardsFromDB.size());
        System.assertEquals(expenseCards[0].Amount__c, expenseCardsFromDB.get(cardId1).Amount__c);
        System.assertEquals(13.13, expenseCardsFromDB.get(cardId2).Amount__c);
        System.assertEquals('pumpkin and candles', expenseCardsFromDB.get(cardId1).Description__c);
        System.assertEquals(expenseCards[1].Description__c, expenseCardsFromDB.get(cardId2).Description__c);
        System.debug('========== ExpensePageControllerTest.updateExpenseCardsTest end test ==========');
    }

    @isTest
    static void updateExpenseCardsTestError() {
        System.debug('========== ExpensePageControllerTest.updateExpenseCardsTestError start test ==========');
        String expenseCardsDTOJson = '[{cardId:"ffff' +
                '","description":"pumpkin and candles"},{"cardId":fffff,"amount":"13.13"}]';
        try {
            ExpensePageController.updateExpenseCards(expenseCardsDTOJson);
        } catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        System.debug('========== ExpensePageControllerTest.updateExpenseCardsTestError end test ==========');
    }

    // top up balance of monthly expense
    @isTest
    static void topUpBalanceTestUpdate() {
        System.debug('========== ExpensePageControllerTest.topUpBalanceTestUpdate start test ==========');
        Date testDate = Date.newInstance(2019, 3, 1);
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> dateForMonthExpense =
                TestDataFactory.createDateListForMonthlyExpense(testDate, testDate);
        TestDataFactory.createMonthlyExpenses(testContact.Id, dateForMonthExpense);
        ExpensePageController.topUpBalance(2019, 3, 12.6, testContact.Id);
        List<Monthly_Expense__c> me = [SELECT Id, Balance__c FROM Monthly_Expense__c];
        System.assertEquals(1, me.size());
        System.assertEquals(2019 + 12.6, me[0].Balance__c);
        System.debug('========== ExpensePageControllerTest.topUpBalanceTestUpdate end test ==========');
    }

    @isTest
    static void topUpBalanceTestInsert() {
        System.debug('========== ExpensePageControllerTest.topUpBalanceTestInsert start test ==========');
        Date testDate = Date.newInstance(2019, 3, 1);
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        ExpensePageController.topUpBalance(2019, 3, 12.6, testContact.Id);
        List<Monthly_Expense__c> me = [SELECT Id, Balance__c FROM Monthly_Expense__c];
        System.assertEquals(1, me.size());
        System.assertEquals(12.60, me[0].Balance__c);
        System.debug('========== ExpensePageControllerTest.topUpBalanceTestInsert end test ==========');
    }

    @isTest
    static void topUpBalanceTestExceptionOccurred() {
        System.debug('========== ExpensePageControllerTest.topUpBalanceTestExceptionOccurred start test ==========');
        Test.startTest();
        try {
            ExpensePageController.topUpBalance(2019, 3, 12.6, TestDataFactory.BAD_USER_ID);
        } catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        Test.stopTest();
        Integer numOfMonthlyExpenses = [SELECT COUNT() FROM Monthly_Expense__c];
        System.assertEquals(0, numOfMonthlyExpenses);
        System.debug('========== ExpensePageControllerTest.topUpBalanceTestExceptionOccurred end test ==========');
    }

    // delete ExpenseCard
    @isTest
    static void deleteExpenseCardTest() {
        System.debug('========== ExpensePageControllerTest.deleteExpenseCardTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 1, 15));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        Id cardId1 = expenseCards[0].Id;
        ExpensePageController.deleteExpenseCard(cardId1);
        Integer numberExpenseCards = [SELECT COUNT() FROM Expense_Card__c];
        System.assertEquals(7, numberExpenseCards);
        System.debug('========== ExpensePageControllerTest.deleteExpenseCardTest end test ==========');
    }
}