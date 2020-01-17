({
    getContentForPageForMonth: function (component, userId, year, monthNames, month) {
        const action = component.get("c.getMonthExpense");
        let menuElements = [];
        monthNames.forEach(function (month) {
            menuElements.push({month: month, amount: null, income: null})
        });
        action.setParams({
            keeperId: userId,
            year: year
        });
        action.setCallback(this, function (response) {
                if (this.validateResponse(response)) {
                    const returnValue = response.getReturnValue();
                    if (returnValue === "NO_DATA") {
                        const infoMessage = "There is no data for this year. Try to select another one";
                        console.warn(infoMessage);
                        this.toastMessage(infoMessage);
                    } else {
                        let totalAmount = 0;
                        let totalIncome = 0;
                        let balance = 0;
                        let expenseCards = new Map();
                        const monthExpensesDTOs = JSON.parse(returnValue);
                        monthExpensesDTOs.forEach(function (monthExpenseDTO) {
                            // set menu elements
                            const numOfMonth = monthExpenseDTO.numberOfMonth - 1;
                            menuElements[numOfMonth].amount = monthExpenseDTO.sumOfExpenses;
                            menuElements[numOfMonth].income = monthExpenseDTO.sumBalance;
                            // set expense cards
                            expenseCards.set(menuElements[numOfMonth].month, monthExpenseDTO.expenseCardsByDate);
                            // set balance
                            balance = balance - monthExpenseDTO.sumOfExpenses + monthExpenseDTO.sumBalance;
                            // set total
                            totalIncome += menuElements[numOfMonth].income;
                            totalAmount += menuElements[numOfMonth].amount;
                        });
                        component.set("v.is_data_changed", false);
                        // attributes for navigation component
                        component.set("v.menu_elements", menuElements);
                        component.set("v.total_amount", totalAmount);
                        component.set("v.total_income", totalIncome);
                        // attributes for content
                        component.set("v.expense_cards", expenseCards);
                        component.set("v.month_expense_cards", expenseCards.get(month));
                        component.set("v.balance", balance);
                    }
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

    toastMessage: function (infoMessage) {
        let toastParams = {
            message: infoMessage,
            type: "info"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
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