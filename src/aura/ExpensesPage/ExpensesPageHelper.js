({
    getContentForPage: function (component, userId, year) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        const action = component.get("c.getMonthExpense");
        action.setParams({
            keeperId: userId,
            year: year
        });
        action.setCallback(this, function (response) {
                if (this.validateResponse(response)) {
                    console.log("============");
                    let totalAmount = 0;
                    let totalIncome = 0;
                    let balance = 0;
                    let menuElements = [];
                    monthNames.forEach(function (month) {
                        menuElements.push({month: month, amount: null, income: null})
                    });
                    let expenseCards = new Map();
                    const monthExpensesDTOs = JSON.parse(response.getReturnValue());
                    monthExpensesDTOs.forEach(function (monthExpenseDTO) {
                        console.log("============");
                        // set menu elements
                        const numOfMonth = monthExpenseDTO.numberOfMonth - 1;
                        menuElements[numOfMonth].amount = monthExpenseDTO.sumOfExpenses;
                        menuElements[numOfMonth].income = monthExpenseDTO.sumBalance;
                        // set expense cards
                        expenseCards.set(menuElements[numOfMonth].month, monthExpenseDTO.expenseCardsByDate);
                        // set balance
                        balance = balance - monthExpenseDTO.sumOfExpenses + monthExpenseDTO.sumBalance;
                        // set total
                        console.log("============");
                        totalIncome += menuElements[numOfMonth].income;
                        console.log(totalIncome);
                        totalAmount += menuElements[numOfMonth].amount;
                    });
                    // attributes for navigation component
                    component.set("v.menu_elements", menuElements);
                    component.set("v.total_amount", totalAmount);
                    component.set("v.total_income", totalIncome);
                    // attributes for content
                    component.set("v.expense_cards", expenseCards);
                    component.set("v.month_expense_cards", expenseCards.get("January"));
                    component.set("v.balance", balance);
                }
            }
        );
        $A.enqueueAction(action);
    },

    validateResponse: function (resp) {
        let flag = true;
        const state = resp.getState();
        console.log(state);
        if (state === 'SUCCESS') {
            return flag;
        } else if (state === 'ERROR') {
            flag = false;
            const errors = resp.getError();
            let errorMessage = "Unknown error"; //default error message
            if (errors && errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
            console.error(errorMessage);
            this.toastErrors(errorMessage);
            return flag;
        } else {
            console.error('something went wrong');
            this.toastErrors('something went wrong please try again');
        }
        return flag;
    },

    toastErrors: function (errorMessage) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: errorMessage,
            type: "error"
        };
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
})