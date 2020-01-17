@isTest
private class AdminPageControllerTest {

    @isTest
    static void getDataForAdminPageTest() {
        System.debug('========== AdminPageControllerTest.getDataForAdminPageTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 2', false);
        Contact testContactNew = TestDataFactory.createContact('Mayakovsky', 'letter@lila.brig', '12', 'Office 1', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 2, 12));
        List<Date> datesForExpenseCards2 =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2018, 12, 8), Date.newInstance(2019, 2, 12));
        List<Expense_Card__c> expenseCards = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        List<Expense_Card__c> expenseCards2 = TestDataFactory.createExpenseCards(testContactNew.Id, datesForExpenseCards2);
        String pageContent = AdminPageController.getDataForAdminPage();
        List<AdminPageDTOS.ExpensesForYearDTO> expensesForYearDTOS = (List<AdminPageDTOS.ExpensesForYearDTO>)
                JSON.deserialize(pageContent, List<AdminPageDTOS.ExpensesForYearDTO>.class);
        System.assertEquals(2018, expensesForYearDTOS[0].yearN);
        System.assertEquals(288.00, expensesForYearDTOS[0].total);
        List<String> expectedOffices = new List<String>{
                'Office 2', 'Office 1'
        };
        System.assertEquals(expectedOffices, expensesForYearDTOS[1].offices.office);
        System.assertEquals(expensesForYearDTOS[0].offices.totalForAllMonthsByOffice.get('Office 1') +
                expensesForYearDTOS[1].offices.totalForAllMonthsByOffice.get('Office 1'),
                0 - expensesForYearDTOS[1].offices.balanceForAllYearsByOffice.get('Office 1'));
        for (AdminPageDTOS.ExpensesForYearDTO expensesForYear : expensesForYearDTOS) {
            System.debug(expensesForYear.yearN);
            System.debug(expensesForYear.total);
            AdminPageDTOS.OfficesDTO officeDTO = expensesForYear.offices;
            System.debug('--offices: ');
            for (String office : officeDTO.office) {
                System.debug(office);
            }
            System.debug('--totals: ');
            for (String office : officeDTO.totalForAllMonthsByOffice.keySet()) {
                System.debug(officeDTO.totalForAllMonthsByOffice.get(office) + ' in ' + office);
            }
            System.debug('--balance: ');
            for (String office : officeDTO.balanceForAllYearsByOffice.keySet()) {
                System.debug(officeDTO.balanceForAllYearsByOffice.get(office) + ' in ' + office);
            }
            System.debug('--monthlyAverage: ');
            for (String office : officeDTO.monthlyAverageByOffice.keySet()) {
                System.debug(officeDTO.monthlyAverageByOffice.get(office) + ' in ' + office);
            }
            for (Integer month : officeDTO.monthlyExpense.keySet()) {
                System.debug('----month:' + month);
                for (String office : officeDTO.monthlyExpense.get(month).keySet()) {
                    System.debug(officeDTO.monthlyExpense.get(month).get(office) + ' in ' + office);
                }
            }
        }
        System.debug('========== AdminPageControllerTest.getDataForAdminPageTest end test ==========');
    }

    @isTest
    static void getDataForOfficePageTest() {
        System.debug('========== AdminPageControllerTest.getDataForOfficePageTest start test ==========');
        Contact testContact = TestDataFactory.createContact('Block', 'night@light.pharmacy', '11', 'Office 1', false);
        Contact testContactNew = TestDataFactory.createContact('Mayakovsky', 'letter@lila.brig', '12', 'Office 1', false);
        List<Date> datesForExpenseCards =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 1, 8), Date.newInstance(2019, 2, 12));
        List<Date> datesForExpenseCards2 =
                TestDataFactory.createDateListForExpenseCards(Date.newInstance(2019, 2, 8), Date.newInstance(2019, 4, 12));
        List<Expense_Card__c> expenseCards1 = TestDataFactory.createExpenseCards(testContact.Id, datesForExpenseCards);
        List<Expense_Card__c> expenseCards2 = TestDataFactory.createExpenseCards(testContactNew.Id, datesForExpenseCards2);
        String officeStatistic = AdminPageController.getInfoForOfficePage('Office 1', 2019);
        AdminPageDTOS.OfficeDetailDTO officeDetailDTO = (AdminPageDTOS.OfficeDetailDTO)
                JSON.deserialize(officeStatistic, AdminPageDTOS.OfficeDetailDTO.class);
        System.debug(officeDetailDTO.office);
        System.assertEquals(2, officeDetailDTO.keeperList.size());
        for (AdminPageDTOS.KeeperDTO keeperDTO : officeDetailDTO.keeperList) {
            System.debug(keeperDTO.keeperId);
            System.assert((keeperDTO.monthExpenses.size() == 2) || (keeperDTO.monthExpenses.size() == 3));
            for (ExpensePageDTOS.MonthExpenseDTO monthExpenseDTO : keeperDTO.monthExpenses) {
                System.debug('--month:' + monthExpenseDTO.numberOfMonth);
                System.debug('--sum:' + monthExpenseDTO.sumOfExpenses);
                System.debug('--balance:' + monthExpenseDTO.sumBalance);
                for (ExpensePageDTOS.ListExpenseCardsByDateDTO listExpenseCardDTO : monthExpenseDTO.expenseCardsByDate) {
                    System.debug('-----date: ' + listExpenseCardDTO.dateOfEC);
                    System.debug('-----totalAmount: ' + listExpenseCardDTO.totalAmount);
                    for (ExpensePageDTOS.ExpenseCardDTO ecDTO : listExpenseCardDTO.expenseCards) {
                        System.debug('------Id: ' + ecDTO.cardId);
                        System.debug('------description: ' + ecDTO.description);
                        System.debug('------amount: ' + ecDTO.amount);
                        System.debug('------date: ' + ecDTO.dateOfEC);
                    }
                }
            }
        }
        System.debug('========== AdminPageControllerTest.getDataForOfficePageTest end test ==========');
    }

    @isTest
    static void getDataForOfficePageTestNoData() {
        System.debug('========== AdminPageControllerTest.getDataForOfficePageTestNoData start test ==========');
        String pageContent = AdminPageController.getInfoForOfficePage('Office 1', 2019);
        System.assertEquals('NO_DATA', pageContent);
        System.debug('========== AdminPageControllerTest.getDataForOfficePageTestNoData end test ==========');
    }

    @isTest
    static void getDataForOfficePageTestError() {
        System.debug('========== AdminPageControllerTest.getDataForOfficePageTestError start test ==========');
        Test.startTest();
        try {
            AdminPageController.getInfoForOfficePage('Illegal office name', 2019);
        } catch (Exception ex){
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        Test.stopTest();
        System.debug('========== AdminPageControllerTest.getDataForOfficePageTestError end test ==========');
    }
}