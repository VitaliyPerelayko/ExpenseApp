public class AdminPageDTOS {

    public class ExpensesForYearDTO {
        public Integer yearN { get; set; }
        public List<OfficeDTO> offices { get; set; }
        // map number of month => sum by month
        public Map<Integer, Decimal> sumByMonth { get; set; }
        public Decimal total { get; set; }
    }

    // balanceForYear get sum of Reminder__c only for this year
    public class OfficeDTO {
        public String office { get; set; }
        public Decimal balanceForYear { get; set; }
        public Decimal monthlyAverage { get; set; }
        public Decimal total { get; set; }
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

    public static List<AdminPageDTOS.ExpensesForYearDTO> mapToExpensesForYearDTO(
            List<Monthly_Expense__c> monthlyExpenses) {
        Map<Id, Contact> contactsOfficeMap = UtilMethods.contactsOfficeMap();
        List<ExpensesForYearDTO> expensesForYearDTOS = new List<AdminPageDTOS.ExpensesForYearDTO>();
        // sort Monthly expenses by year
        Map<Integer, List<Monthly_Expense__c>> monthlyExpenseMap = new Map<Integer, List<Monthly_Expense__c>>();
        for (Monthly_Expense__c monthlyExpense : monthlyExpenses) {
            Integer yearN = monthlyExpense.MonthDate__c.year();
            List<Monthly_Expense__c> monthlyExpensesYear = monthlyExpenseMap.get(yearN);
            if (monthlyExpensesYear == null) {
                monthlyExpensesYear = new List<Monthly_Expense__c>();
                monthlyExpensesYear.add(monthlyExpense);
                monthlyExpenseMap.put(yearN, monthlyExpensesYear);
            } else {
                monthlyExpensesYear.add(monthlyExpense);
            }
        }
        for (Integer yearN : monthlyExpenseMap.keySet()) {
            expensesForYearDTOS.add(createExpenseForYear(yearN, monthlyExpenseMap.get(yearN), contactsOfficeMap));
        }
        return expensesForYearDTOS;
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
            listOfKeeperDTOs.add(createKeeperDTO(keeperId, lastName ,monthlyExpenseMap.get(keeperId)));
        }
        officeDetail.keeperList = listOfKeeperDTOs;
        return officeDetail;
    }

    // create ExpenseForYearDTO
    private static ExpensesForYearDTO createExpenseForYear(Integer yearN, List<Monthly_Expense__c> monthlyExpenses,
            Map<Id, Contact> contactsOfficeMap) {
        ExpensesForYearDTO expensesForYearDTO = new ExpensesForYearDTO();
        Map<Integer, Decimal> sumByMonth = new Map<Integer, Decimal>();
        Decimal total = 0;
        expensesForYearDTO.yearN = yearN;
        // sort Monthly expenses by office
        Map<String, List<Monthly_Expense__c>> officeMonthlyExpenses = new Map<String, List<Monthly_Expense__c>>();
        for (Monthly_Expense__c monthlyExpense : monthlyExpenses) {
            // sort by office
            String office = contactsOfficeMap.get(monthlyExpense.Keeper__c).Office__c;
            List<Monthly_Expense__c> meList = officeMonthlyExpenses.get(office);
            if (meList == null) {
                meList = new List<Monthly_Expense__c>();
                meList.add(monthlyExpense);
                officeMonthlyExpenses.put(office, meList);
            } else {
                meList.add(monthlyExpense);
            }
            // set Sum
            Integer month = monthlyExpense.MonthDate__c.month();
            Decimal sum = sumByMonth.get(month);
            if (sum == null) {
                sumByMonth.put(month, monthlyExpense.SpentAmount__c);
            } else {
                sum = sum + monthlyExpense.SpentAmount__c;
                sumByMonth.put(month, sum);
            }
            total = total + monthlyExpense.SpentAmount__c;
        }
        expensesForYearDTO.offices = generateOfficesDTOs(officeMonthlyExpenses);
        expensesForYearDTO.sumByMonth = sumByMonth;
        expensesForYearDTO.total = total;
        //setDataToExpensesForYearDTO(expensesForYearDTO, monthlyExpenses, contactsOfficeMap);
        return expensesForYearDTO;
    }

    private static List<OfficeDTO> generateOfficesDTOs(Map<String, List<Monthly_Expense__c>> officeMonthlyExpenses) {
        List<OfficeDTO> officeDTOS = new List<AdminPageDTOS.OfficeDTO>();
        for (String office : officeMonthlyExpenses.keySet()) {
            OfficeDTO officeDTO = new OfficeDTO();
            officeDTO.office = office;
            Decimal balanceForYear = 0;
            Decimal total = 0;
            for (Monthly_Expense__c me : officeMonthlyExpenses.get(office)) {
                balanceForYear = balanceForYear + me.Reminder__c;
                total = total + me.SpentAmount__c;
            }
            officeDTO.total = total;
            officeDTO.balanceForYear = balanceForYear;
            officeDTO.monthlyAverage = total / 12;
            officeDTOS.add(officeDTO);
        }
        return officeDTOS;
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