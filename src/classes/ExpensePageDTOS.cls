public class ExpensePageDTOS {

    public class MonthExpenseDTO {
        public Integer numberOfMonth { get; set; }
        public Decimal sumOfExpenses { get; set; }
        public Decimal sumBalance { get; set; }
        public List<ExpenseCardDTO> expenseCards { get; set; }
    }

    public class ExpenseCardDTO {
        public Id cardId { get; set; }
        public Date dateOfEC { get; set; }
        public String description { get; set; }
        public Decimal amount { get; set; }
    }

    public static MonthExpenseDTO mapMonthExpense(Monthly_Expense__c me, List<ExpenseCardDTO> expenseCards) {
        MonthExpenseDTO monthExpenseDTO = new MonthExpenseDTO();
        monthExpenseDTO.expenseCards = expenseCards;
        monthExpenseDTO.numberOfMonth = me.MonthDate__c.month();
        monthExpenseDTO.sumOfExpenses = me.SpentAmount__c;
        monthExpenseDTO.sumBalance = me.Balance__c;
        return monthExpenseDTO;
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
            List<ExpensePageDTOS.ExpenseCardDTO> expenseCardDTOS = new List<ExpensePageDTOS.ExpenseCardDTO>();
            for (Expense_Card__c ec : me.ExpenseCards__r) {
                expenseCardDTOS.add(mapExpenseCard(ec));
            }
            monthExpenseDTOS.add(ExpensePageDTOS.mapMonthExpense(me, expenseCardDTOS));
        }
        return monthExpenseDTOS;
    }
}