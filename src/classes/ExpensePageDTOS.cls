public class ExpensePageDTOS {

    public class MonthExpenseDTO {
        public Integer numberOfMonth { get; set; }
        public Decimal sumOfExpenses { get; set; }
        public Decimal sumBalance { get; set; }
        public List<ListExpenseCardsByDateDTO> expenseCardsByDate { get; set; }
    }

    public class ListExpenseCardsByDateDTO {
        public Date dateOfEC { get; set; }
        public List<ExpenseCardDTO> expenseCards { get; set; }
        public Decimal totalAmount;
    }

    public class ExpenseCardDTO {
        public Id cardId { get; set; }
        public Date dateOfEC { get; set; }
        public String description { get; set; }
        public Decimal amount { get; set; }
    }

    public static MonthExpenseDTO mapMonthExpense(Monthly_Expense__c me,
            List<ListExpenseCardsByDateDTO> expenseCardsByDate) {
        MonthExpenseDTO monthExpenseDTO = new MonthExpenseDTO();
        monthExpenseDTO.expenseCardsByDate = expenseCardsByDate;
        monthExpenseDTO.numberOfMonth = me.MonthDate__c.month();
        monthExpenseDTO.sumOfExpenses = me.SpentAmount__c;
        monthExpenseDTO.sumBalance = me.Balance__c;
        return monthExpenseDTO;
    }

    public static List<ListExpenseCardsByDateDTO> mapListExpenseCardsByDateDTO(
            Map<Date, List<ExpenseCardDTO>> expenseCardsByDatesMap) {
        List<ListExpenseCardsByDateDTO> listExpenseCardsByDateDTOS =
                new List<ExpensePageDTOS.ListExpenseCardsByDateDTO>();
        for (Date d: expenseCardsByDatesMap.keySet()){
            ListExpenseCardsByDateDTO listExpenseCardsByDateDTO = new ListExpenseCardsByDateDTO();
            listExpenseCardsByDateDTO.dateOfEC = d;
            listExpenseCardsByDateDTO.expenseCards = expenseCardsByDatesMap.get(d);
            listExpenseCardsByDateDTO.totalAmount = getTotalForDate(listExpenseCardsByDateDTO.expenseCards);
            listExpenseCardsByDateDTOS.add(listExpenseCardsByDateDTO);
        }
        return listExpenseCardsByDateDTOS;
    }

    public static ExpenseCardDTO mapExpenseCard(Expense_Card__c ec) {
        ExpenseCardDTO expenseCardDTO = new ExpenseCardDTO();
        expenseCardDTO.cardId = ec.Id;
        expenseCardDTO.dateOfEC = ec.CardDate__c;
        expenseCardDTO.description = ec.Description__c;
        expenseCardDTO.amount = ec.Amount__c;
        return expenseCardDTO;
    }

    public static List<ExpensePageDTOS.MonthExpenseDTO> mapToDTOMonthlyExpense(
            List<Monthly_Expense__c> monthlyExpenses) {
        // list to return
        List<ExpensePageDTOS.MonthExpenseDTO> monthExpenseDTOS = new List<ExpensePageDTOS.MonthExpenseDTO>();
        for (Monthly_Expense__c me : monthlyExpenses) {
            Map<Date, List<ExpenseCardDTO>> expenseCardsByDatesMap =
                    new Map<Date, List<ExpensePageDTOS.ExpenseCardDTO>>();
            for (Expense_Card__c ec : me.ExpenseCards__r) {
                ExpenseCardDTO ecDTO = mapExpenseCard(ec);
                Date ecDate = ecDTO.dateOfEC;
                List<ExpenseCardDTO> expenseCardDTOS = expenseCardsByDatesMap.get(ecDate);
                if (expenseCardDTOS == null) {
                    expenseCardDTOS = new List<ExpensePageDTOS.ExpenseCardDTO>();
                    expenseCardDTOS.add(ecDTO);
                    expenseCardsByDatesMap.put(ecDate, expenseCardDTOS);
                } else {
                    expenseCardDTOS.add(ecDTO);
                }
            }
            List<ExpensePageDTOS.ListExpenseCardsByDateDTO> expenseCardsByDate =
                    mapListExpenseCardsByDateDTO(expenseCardsByDatesMap);
            monthExpenseDTOS.add(ExpensePageDTOS.mapMonthExpense(me, expenseCardsByDate));
        }
        return monthExpenseDTOS;
    }

    private static Decimal getTotalForDate(List<ExpenseCardDTO> listExpenseCardDTOS){
        Decimal total = 0.0;
        for (ExpenseCardDTO ecDTO: listExpenseCardDTOS){
            total += ecDTO.amount;
        }
        return total;
    }
}