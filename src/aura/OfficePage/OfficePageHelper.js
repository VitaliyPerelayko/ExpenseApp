({
    getContentForPage: function (component, office, year) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        const action = component.get("c.getDataForOfficePage");
        action.setParams({
            office: office,
            year: year
        });
        action.setCallback(this, function (response) {
                if (this.validateResponse(response)) {
                    let balance = 0;
                    let menuElements = [];
                    monthNames.forEach(function (month) {
                        menuElements.push({month: month, amount: null, income: null})
                    });
                    let expenseCardsByKeeper = new Map();
                    const officeDetailDTO = JSON.parse(response.getReturnValue());
                    officeDetailDTO.keeperList.forEach(function (keeperDTO) {
                        expenseCardsByKeeper.set(keeperDTO.keeperId,
                            {lastName: keeperDTO.lastName, monthExpenses: keeperDTO.monthExpenses});
                        keeperDTO.monthExpenses.forEach(function (monthExpenseDTO) {

                        });
                        // set menu elements
                        const numOfMonth = monthExpenseDTO.numberOfMonth - 1;
                        menuElements[numOfMonth].amount = monthExpenseDTO.sumOfExpenses;
                        menuElements[numOfMonth].income = monthExpenseDTO.sumBalance;
                        // set expense cards
                        expenseCards.set(menuElements[numOfMonth].month, monthExpenseDTO.expenseCardsByDate);
                        // set balance
                        balance = balance - monthExpenseDTO.sumOfExpenses + monthExpenseDTO.sumBalance;
                    });
                    component.set("v.menu_elements", menuElements);
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