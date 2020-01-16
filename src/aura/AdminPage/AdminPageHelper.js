({
    setInitData: function (component, response, monthNames) {
        try {
            let year = 0;
            let yearOptions = [];
            // year => total for year
            let totalsForYear = new Map();
            // year => list of offices
            let officesMap = new Map();
            // year => List of balances
            let balancesMap = new Map();
            // year => List of monthly averages
            let monthlyAverageMap = new Map();
            // year => List of offices' total expenses
            let totalForAllMonths = new Map();
            // year => List<Object>
            // Object : {monthName, List<Decimal> monthly expenses by office, total for all offices
            let monthlyExpenses = new Map();

            const expensesForYearDTOList = JSON.parse(response.getReturnValue());
            console.log(expensesForYearDTOList);

            //iteration though years
            for (let k = 0; k < expensesForYearDTOList.length; k++) {
                const expForYearDTO = expensesForYearDTOList[k];
                const offisesDTO = expForYearDTO.offices;
                // set year options
                year = expForYearDTO.yearN;
                const yearOption = {'label': year, 'value': year};
                yearOptions.push(yearOption);
                // set totals for year
                totalsForYear.set(year, expForYearDTO.total);
                // set offices
                const officesList = offisesDTO.office;
                officesMap.set(year, officesList);
                // TODO check order in List, and if it will be wrong sort data using Object.entries()
                // set balance
                balancesMap.set(year, Object.values(offisesDTO.balanceForAllYearsByOffice));
                // set monthly average
                monthlyAverageMap.set(year, Object.values(offisesDTO.monthlyAverageByOffice));
                // set total by office
                totalForAllMonths.set(year, Object.values(offisesDTO.totalForAllMonthsByOffice));
                // set monthly expenses
                let monthlyExp = [];
                const monthlyExpDTOMap = new Map(Object.entries(offisesDTO.monthlyExpense));
                for (let m = 1; m <= monthNames.length; m++) {
                    let expensesByOffice = [];
                    let totalForOffices = 0;
                    const meDTO = monthlyExpDTOMap.get(m.toString());
                    if (meDTO === undefined) {
                        for (let o = 0; o < officesList.length; o++){
                            expensesByOffice.push(0);
                        }
                    } else {
                        const expensesMap = new Map(Object.entries(meDTO));
                        for (let o = 0; o < officesList.length; o++){
                            const officeName = officesList[o];
                            const officeExpense = expensesMap.get(officeName);
                            if (officeExpense === undefined){
                                expensesByOffice.push(0);
                            } else {
                                expensesByOffice.push(officeExpense);
                                totalForOffices += officeExpense;
                            }
                        }
                    }
                    monthlyExp.push({
                        monthName: monthNames[m-1],
                        expenses: expensesByOffice,
                        totalForAllOffices: totalForOffices
                    });
                }
                monthlyExpenses.set(year, monthlyExp);
            }
            // set year options
            component.set("v.year", year);
            component.set("v.year_options", yearOptions);
            // set total for years
            component.set("v.expenses_for_year_dto_map", totalsForYear);
            component.set("v.total_for_year", totalsForYear.get(year));
            // set offices
            component.set("v.offices_map", officesMap);
            component.set("v.offices", officesMap.get(year));
            // set balance
            component.set("v.balance_for_all_years_by_office_map", balancesMap);
            component.set("v.balance_for_all_years_by_office", balancesMap.get(year));
            // set monthly average
            component.set("v.monthly_average_by_office_map", monthlyAverageMap);
            component.set("v.monthly_average_by_office", monthlyAverageMap.get(year));
            //set total by office
            component.set("v.total_for_all_months_by_office_map", totalForAllMonths);
            component.set("v.total_for_all_months_by_office", totalForAllMonths.get(year));
            // set monthly expenses
            component.set("v.monthly_expense_map", monthlyExpenses);
            component.set("v.monthly_expense", monthlyExpenses.get(year));
        } catch (e) {
            console.error(e);
        }
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