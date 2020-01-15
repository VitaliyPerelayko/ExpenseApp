@isTest
private class AdminPageControllerTest {

    // TODO deserialize exception
    @isTest
    static void getDataForAdminPageTest() {
        System.debug('========== AdminPageControllerTest.getDataForAdminPageTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        Contact testContactNew = TestDataFactory.createContact('Mayakovsky', 'letter@lila.brig', '12', 'Office 1', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
        List<Date> datesForExpenseCards2 =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2018, 10, 8), Date.newInstance(2019, 3, 12));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        List<Expense_Card__c> expenseCards2 = TestDataFactory.createExpenseCards(testContactNew.Id, datesForExpenseCards2);
        String yarStat = AdminPageController.getDataForAdminPage();
        List<AdminPageDTOS.ExpensesForYearDTO> expensesForYearDTOS = (List<AdminPageDTOS.ExpensesForYearDTO>)
                JSON.deserialize(yarStat, List<AdminPageDTOS.ExpensesForYearDTO>.class);
        System.assertEquals(2018, expensesForYearDTOS[0].yearN);
        System.assertEquals(942.00, expensesForYearDTOS[0].total);
        for (AdminPageDTOS.ExpensesForYearDTO expensesForYear : expensesForYearDTOS) {
            System.debug(expensesForYear.yearN);
            System.debug(expensesForYear.total);
            AdminPageDTOS.OfficesDTO officeDTO = expensesForYear.offices;
                System.debug('--offices: ');
                for (String office : officeDTO.office){
                    System.debug(office);
                }
                System.debug('--totals: ');
                for (String office : officeDTO.totalForAllMonthsByOffice.keySet()){
                    System.debug(officeDTO.totalForAllMonthsByOffice.get(office) + ' in ' + office);
                }
                System.debug('--balanceForYear: ');
                for (String office : officeDTO.balanceForAllYearsByOffice.keySet()){
                    System.debug(officeDTO.balanceForAllYearsByOffice.get(office) + ' in ' + office);
                }
                System.debug('--monthlyAverage: ');
                for (Integer month : officeDTO.monthlyExpense.keySet()) {
                    System.debug('----month:' + month);
                    for (String office : officeDTO.monthlyExpense.get(month).keySet()){
                        System.debug(officeDTO.monthlyExpense.get(month).get(office) + ' in ' + office);
                    }
                }

        }
        System.debug('========== AdminPageControllerTest.getDataForAdminPageTest end test ==========');
    }

    // TODO handle test's exceptions
//    @isTest
//    static void getDataForOfficePageTest() {
//        System.debug('========== AdminPageControllerTest.getDataForOfficePageTest start test ==========');
//        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 1', false);
//        Contact testContactNew = TestDataFactory.createContact('Mayakovsky', 'letter@lila.brig', '12', 'Office 1', false);
//        List<Date> datesForExpenseCards =
//                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 3, 12));
//        List<Date> datesForExpenseCards2 =
//                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2018, 10, 8), Date.newInstance(2019, 3, 12));
//        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
//        List<Expense_Card__c> expenseCards2 = TestDataFactory.createExpenseCards(testContactNew.Id, datesForExpenseCards2);
//        String emptyString = AdminPageController.getDataForOfficePage('Office 2');
//        System.assertEquals('{"office":"Office 2","keeperList":[]}', emptyString);
//        String officeStatistic = AdminPageController.getDataForOfficePage('Office 1');
//        AdminPageDTOS.OfficeDetailDTO officeDetailDTO = (AdminPageDTOS.OfficeDetailDTO)
//                JSON.deserialize(officeStatistic, AdminPageDTOS.OfficeDetailDTO.class);
//        System.debug(officeDetailDTO.office);
//        System.assertEquals(2, officeDetailDTO.keeperList.size());
//        for (AdminPageDTOS.KeeperDTO keeperDTO : officeDetailDTO.keeperList) {
//            System.debug(keeperDTO.keeperId);
//            System.assert((keeperDTO.monthExpenses.size() == 3) || (keeperDTO.monthExpenses.size() == 6));
//            for (ExpensePageDTOS.MonthExpenseDTO monthExpenseDTO : keeperDTO.monthExpenses) {
//                System.debug('--month:' + monthExpenseDTO.numberOfMonth);
//                System.debug('--sum:' + monthExpenseDTO.sumOfExpenses);
//                System.debug('--balance:' + monthExpenseDTO.sumBalance);
//                for (ExpensePageDTOS.ExpenseCardDTO expenseCardDTO : monthExpenseDTO.expenseCards) {
//                    System.debug('-----Id: ' + expenseCardDTO.cardId);
//                    System.debug('----description: ' + expenseCardDTO.description);
//                    System.debug('----amount: ' + expenseCardDTO.amount);
//                    System.debug('----date: ' + expenseCardDTO.dateOfEC);
//                }
//            }
//        }
//        System.debug('========== AdminPageControllerTest.getDataForOfficePageTest end test ==========');
//    }
}