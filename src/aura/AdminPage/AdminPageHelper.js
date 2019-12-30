({
    setInitData: function (component, response, year) {
        console.log(response.getReturnValue());
        let yearOptions = [];
        // year => expense details
        let expensesByYear = new Map();
        // year => sumExpenses by month
        let sumExpenseBYMonthMap = new Map();
        // temp map to store balance
        let balanceMap = new Map();
        const expensesForYearDTOList = JSON.parse(response.getReturnValue());
        console.log(expensesForYearDTOList);
        // iteration though years
        for (let k = 0; k < expensesForYearDTOList.length; k++) {
            const expForYearDTO = expensesForYearDTOList[k];
            let sumExpensesForYearByMonth = [];
            const yearN = expForYearDTO.yearN;
            const yearOption = {'label': "Regional Expense " + yearN, 'value': yearN};
            yearOptions.push(yearOption);
            // iteration though offices
            for (let a = 0; a < expForYearDTO.offices.length; a++) {
                const office = expForYearDTO.offices[a];
                let sumByMonth = [];
                for (let i = 1; i <= 12; i++) {
                    const sumExpense = office.sumByMonth[i];
                    if (sumExpense === undefined) {
                        sumByMonth.push(0);
                    } else {
                        sumByMonth.push(sumExpense);
                    }
                }
                const officeName = office.office;
                let balance = balanceMap.get(officeName);
                if (balance === undefined) {
                    balance = office.balanceForYear;
                    balanceMap.set(officeName, balance);
                } else {
                    balance = balance + office.balanceForYear;
                    balanceMap.set(officeName, balance);
                }
                office.balanceForYear = balance;
                office.sumByMonth = sumByMonth;
                sumExpensesForYearByMonth =
                    this.getSumExpensesForYearByMonth(sumExpensesForYearByMonth, sumByMonth);
            }
            const expenseForYear = {
                total: expForYearDTO.total,
                officesDTO: expForYearDTO.offices
            };
            sumExpenseBYMonthMap.set(yearN, sumExpensesForYearByMonth);
            expensesByYear.set(yearN, expenseForYear);
        }
        component.set("v.year_options", yearOptions);
        component.set("v.expenses_by_year", expensesByYear);
        component.set("v.expense_for_year_by_office", expensesByYear.get(year).officesDTO);
        component.set("v.total_for_year", expensesByYear.get(year).total);
        component.set("v.sum_expenses_by_month_map", sumExpenseBYMonthMap);
        component.set("v.sum_expenses_for_year_by_month", sumExpenseBYMonthMap.get(year));
    },

    getSumExpensesForYearByMonth: function (sumExpensesForYearByMonth, sumByMonth) {
        for (let i = 0; i < 12; i++) {
            let sum = sumExpensesForYearByMonth[i];
            if (sum === undefined) {
                sumExpensesForYearByMonth[i] = sumByMonth[i];
            } else {
                sumExpensesForYearByMonth[i] = sum + sumByMonth[i];
            }
        }
        return sumExpensesForYearByMonth;
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