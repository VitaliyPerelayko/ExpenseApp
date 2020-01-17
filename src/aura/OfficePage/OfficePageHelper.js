({
    getContentForPageForMonth: function (component, office, year, monthNames, month) {
        const action = component.get("c.getInfoForOfficePage");
        let startKeeperContent = {};
        let listKeepers = [];
        let idLastNameMap = new Map();
        let expenseCardsByKeeper = new Map();
        action.setParams({
            office: office,
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
                        const officeDetailDTO = JSON.parse(returnValue);
                        console.log(officeDetailDTO);
                        const listKeeperDTOS = officeDetailDTO.keeperList;
                        for (let k = 0; k < listKeeperDTOS.length; k++) {
                            // menu items frame
                            let menuElements = [];
                            monthNames.forEach(function (month) {
                                menuElements.push({month: month, amount: null, income: null})
                            });
                            let totalAmount = 0;
                            let totalIncome = 0;
                            let balance = 0;
                            let expenseCards = new Map();
                            // set list of keepers
                            const keeperDTO = listKeeperDTOS[k];
                            listKeepers.push({label: keeperDTO.lastName, value: keeperDTO.keeperId});
                            idLastNameMap.set(keeperDTO.keeperId, keeperDTO.lastName);
                            // set content start
                            const monthExpensesDTOs = keeperDTO.monthExpenses;
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
                            expenseCardsByKeeper.set(keeperDTO.keeperId,
                                {
                                    totalIncome: totalIncome,
                                    totalAmount: totalAmount,
                                    balance: balance,
                                    menuElements: menuElements,
                                    expenseCards: expenseCards
                                });
                            startKeeperContent = expenseCardsByKeeper.get(listKeepers[0].value);
                            // set content end
                        }
                        // set expense_cards_by_keeper
                        component.set("v.expense_cards_by_keeper", expenseCardsByKeeper);
                        // set user info
                        component.set("v.keepers", listKeepers);
                        component.set("v.id_LastName_map", idLastNameMap);
                        component.set("v.userLastName", listKeepers[0].label);
                        component.set("v.userId", listKeepers[0].value);
                        // attributes for navigation component
                        component.set("v.menu_elements", startKeeperContent.menuElements);
                        component.set("v.total_amount", startKeeperContent.totalAmount);
                        component.set("v.total_income", startKeeperContent.totalIncome);
                        // attributes for content
                        component.set("v.expense_cards_by_month", startKeeperContent.expenseCards);
                        component.set("v.month_expense_cards", startKeeperContent.expenseCards.get(month));
                        component.set("v.balance", startKeeperContent.balance);
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