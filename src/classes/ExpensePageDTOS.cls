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
            Map<Id, Monthly_Expense__c> monthlyExpenses, List<Expense_Card__c> expenseCards) {
        // list to return
        List<ExpensePageDTOS.MonthExpenseDTO> monthExpenseDTOS = new List<ExpensePageDTOS.MonthExpenseDTO>();
        // temp map month expense Id => List<ExpenseCardDTO>
        Map<Id, List<ExpensePageDTOS.ExpenseCardDTO>> tempMap = new Map<Id, List<ExpensePageDTOS.ExpenseCardDTO>>();
        for (Expense_Card__c ec : expenseCards) {
            Id meId = ec.MonthlyExpense__c;
            List<ExpensePageDTOS.ExpenseCardDTO> expenseCardDTOS = tempMap.get(meId);
            if (expenseCardDTOS == null) {
                expenseCardDTOS = new List<ExpensePageDTOS.ExpenseCardDTO>();
                expenseCardDTOS.add(ExpensePageDTOS.mapExpenseCard(ec));
                tempMap.put(meId, expenseCardDTOS);
            } else {
                expenseCardDTOS.add(ExpensePageDTOS.mapExpenseCard(ec));
            }
        }
        for (Id meId : monthlyExpenses.keySet()) {
            monthExpenseDTOS.add(ExpensePageDTOS.mapMonthExpense(monthlyExpenses.get(meId), tempMap.get(meId)));
        }
        return monthExpenseDTOS;
    }
}