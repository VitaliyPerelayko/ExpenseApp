@isTest
private class ExpensePageControllerTest {

    @isTest
    static void getMonthExpenseTest() {
        System.debug('========== ExpenseCardTriggerTest.getMonthExpenseTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        String monthExpenses = ExpensePageController.getMonthExpense(testContact.Id);
        List<ExpensePageDTOS.MonthExpenseDTO> monthExpenseDTOS = (List<ExpensePageDTOS.MonthExpenseDTO>)
                JSON.deserialize(monthExpenses, List<ExpensePageDTOS.MonthExpenseDTO>.class);
        System.assertEquals(24.00, monthExpenseDTOS[0].sumOfExpenses);
        System.assertEquals(24, monthExpenseDTOS[0].expenseCards.size());
        for (ExpensePageDTOS.MonthExpenseDTO meDTO : monthExpenseDTOS) {
            System.debug(meDTO.numberOfMonth);
            System.debug(meDTO.sumOfExpenses);
            for (ExpensePageDTOS.ExpenseCardDTO expenseCardDTO : meDTO.expenseCards) {
                System.debug('      ' + expenseCardDTO);
            }
        }
        System.debug('========== ExpenseCardTriggerTest.getMonthExpenseTest end test ==========');
    }
}