public class AdminPageDTOS {

    public class ExpensesForYearDTO {
        public Integer yearN { get; set; }
        public OfficesDTO offices { get; set; }
        public Decimal total { get; set; }
    }

    public class OfficesDTO {
        public List<String> office { get; set; }
        public Map<String, Decimal> balanceForAllYearsByOffice { get; set; }
        public Map<String, Decimal> monthlyAverageByOffice { get; set; }
        public Map<String, Decimal> totalForAllMonthsByOffice { get; set; }
        // map number of month => list by office month's sum
        public Map<Integer, Map<String, Decimal>> monthlyExpense { get; set; }
    }

    public class OfficeDetailDTO {
        public String office { get; set; }
        public Integer year { get; set; }
        public List<KeeperDTO> keeperList { get; set; }
    }

    public class KeeperDTO {
        public Id keeperId { get; set; }
        public String lastName { get; set; }
        public List<ExpensePageDTOS.MonthExpenseDTO> monthExpenses { get; set; }
    }

    public static OfficeDetailDTO mapOfficeDetailDTO(String office, Integer year,
            List<Monthly_Expense__c> monthlyExpenses, Map<Id, String> keeperLastNames) {
        OfficeDetailDTO officeDetail = new OfficeDetailDTO();
        officeDetail.office = office;
        officeDetail.year = year;
        List<KeeperDTO> listOfKeeperDTOs = new List<AdminPageDTOS.KeeperDTO>();
        // map userId  =>  List<Monthly_Expense__c>
        Map<Id, List<Monthly_Expense__c>> monthlyExpenseMap = new Map<Id, List<Monthly_Expense__c>>();
        // sort monthly expense by keeper
        for (Monthly_Expense__c me : monthlyExpenses) {
            Id keeperId = me.Keeper__c;
            List<Monthly_Expense__c> monthlyExpensesOfKeeper = monthlyExpenseMap.get(keeperId);
            if (monthlyExpensesOfKeeper == null) {
                monthlyExpensesOfKeeper = new List<Monthly_Expense__c>();
                monthlyExpensesOfKeeper.add(me);
                monthlyExpenseMap.put(keeperId, monthlyExpensesOfKeeper);
            } else {
                monthlyExpensesOfKeeper.add(me);
            }
        }
        for (Id keeperId : monthlyExpenseMap.keySet()) {
            String lastName = keeperLastNames.get(keeperId);
            listOfKeeperDTOs.add(createKeeperDTO(keeperId, lastName, monthlyExpenseMap.get(keeperId)));
        }
        officeDetail.keeperList = listOfKeeperDTOs;
        return officeDetail;
    }

    public static List<ExpensesForYearDTO> createExpensesForYear(
            List<Monthly_Expense__c> monthlyExpenses) {
        Map<Id, Contact> contactsOfficeMap = UtilMethods.contactsOfficeMap();
        Map<Integer, ExpensesForYearDTO> expensesForYearDTOMap = new Map<Integer, AdminPageDTOS.ExpensesForYearDTO>();
        // ExpensesForYearDTO.offices.balanceForAllYearsByOffice is calculated only for current year
        // and I have to update balanceForAllYearsByOffice after taking into account previous years
        for (Monthly_Expense__c me : monthlyExpenses) {
            // get data to sorting
            Integer year = me.MonthDate__c.year();
            String office = contactsOfficeMap.get(me.Keeper__c).Office__c;
            Integer month = me.MonthDate__c.month();
            Decimal spentAmount = me.SpentAmount__c;
            ExpensesForYearDTO expensesForYearDTO = expensesForYearDTOMap.get(year);
            if (expensesForYearDTO == null) {
                expensesForYearDTO = new ExpensesForYearDTO();
                expensesForYearDTO.yearN = year;
                expensesForYearDTO.total = spentAmount;
                expensesForYearDTO.offices = createOfficesDTOs(spentAmount, me.Reminder__c, office, month);
                expensesForYearDTOMap.put(year, expensesForYearDTO);
            } else {
                expensesForYearDTO.total += spentAmount;
                updateOfficesDTOs(expensesForYearDTO.offices, office, month, spentAmount, me.Reminder__c);
            }
        }
        // now I update balanceForAllYearsByOffice taking into account previous years:
        // sort years just in case
        List<Integer> years = new List<Integer>(expensesForYearDTOMap.keySet());
        years.sort();
        // create temporary map to store data
        Map<String, Decimal> tempMap = new Map<String, Decimal>();
        Map<String, Decimal> mapB = expensesForYearDTOMap.get(years[0]).offices.balanceForAllYearsByOffice;
        for (String office : mapB.keySet()) {
            tempMap.put(office, mapB.get(office));
        }
        if (years.size() > 1) {
            for (Integer i = 1; i < years.size(); i++) {
                Map<String, Decimal> mapOfBalances = expensesForYearDTOMap.get(years[i]).offices.balanceForAllYearsByOffice;
                for (String office : mapOfBalances.keySet()) {
                    Decimal balance = 0;
                    if (mapOfBalances.get(office) != null){
                        balance = mapOfBalances.get(office);
                    }
                    if (tempMap.get(office) != null){
                        balance += tempMap.get(office);
                    }
                    tempMap.put(office, balance);
                    mapOfBalances.put(office, balance);
                }
            }
        }
        return expensesForYearDTOMap.values();
    }

    private static OfficesDTO createOfficesDTOs(Decimal spentAmount, Decimal moneyLeft, String office, Integer month) {
        OfficesDTO offices = new OfficesDTO();
        // init officesDTO
        offices.totalForAllMonthsByOffice = new Map<String, Decimal>{
                office => spentAmount
        };
        offices.balanceForAllYearsByOffice = new Map<String, Decimal>{
                office => moneyLeft
        };
        offices.monthlyAverageByOffice = new Map<String, Decimal>{
                office => spentAmount / 12
        };
        offices.office = new List<String>();
        offices.office.add(office);
        offices.monthlyExpense =
                new Map<Integer, Map<String, Decimal>>{
                        month => new Map<String, Decimal>{
                                office => spentAmount
                        }
                };
        return offices;
    }

    private static void updateOfficesDTOs(OfficesDTO offices, String office, Integer month,
            Decimal spentAmount, Decimal moneyLeft) {
        // update office names
        if (!offices.office.contains(office)) {
            offices.office.add(office);
        }
        // update totalForAllMonthsByOffice
        Decimal totalForAllMonthsByOffice = offices.totalForAllMonthsByOffice.get(office);
        if (totalForAllMonthsByOffice == null) {
            offices.totalForAllMonthsByOffice.put(office, spentAmount);
        } else {
            totalForAllMonthsByOffice += spentAmount;
            offices.totalForAllMonthsByOffice.put(office, totalForAllMonthsByOffice);
        }
        // update monthlyAverageByOffice
        Decimal monthlyAverageByOffice = offices.monthlyAverageByOffice.get(office);
        if (monthlyAverageByOffice == null) {
            offices.monthlyAverageByOffice.put(office, spentAmount / 12);
        } else {
            monthlyAverageByOffice += spentAmount / 12;
            offices.monthlyAverageByOffice.put(office, monthlyAverageByOffice);
        }
        // update balanceForAllYearsByOffice
        Decimal balanceForAllYearsByOffice = offices.balanceForAllYearsByOffice.get(office);
        if (balanceForAllYearsByOffice == null) {
            offices.balanceForAllYearsByOffice.put(office, moneyLeft);
        } else {
            balanceForAllYearsByOffice += moneyLeft;
            offices.balanceForAllYearsByOffice.put(office, balanceForAllYearsByOffice);
        }
        // update monthlyExpense
        Map<String, Decimal> monthlyExpense = offices.monthlyExpense.get(month);
        if (monthlyExpense == null) {
            monthlyExpense = new Map<String, Decimal>();
            monthlyExpense.put(office, spentAmount);
            offices.monthlyExpense.put(month, monthlyExpense);
        } else {
            monthlyExpense.put(office, spentAmount);
        }
    }

    private static KeeperDTO createKeeperDTO(Id keeperId, String lastName,
            List<Monthly_Expense__c> monthlyExpensesOfKeeper) {
        KeeperDTO keeperDTO = new KeeperDTO();
        keeperDTO.keeperId = keeperId;
        keeperDTO.lastName = lastName;
        keeperDTO.monthExpenses = ExpensePageDTOS.mapToDTOMonthlyExpense(monthlyExpensesOfKeeper);
        return keeperDTO;
    }
}