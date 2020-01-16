({
    init: function (component, event, helper) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        component.set("v.months", monthNames);
        let action = component.get("c.getDataForAdminPage");
        action.setCallback(this, function (response) {
            if (helper.validateResponse(response)) {
                helper.setInitData(component, response, monthNames);
            }
        });
        $A.enqueueAction(action);
    },

    yearChanged: function (component, event, helper) {
        try {
            const year = event.getParam("value");
            console.log(year);
            component.set("v.year", year);
            // change total for year
            const expensesByYear = component.get("v.expenses_for_year_dto_map");
            component.set("v.total_for_year", expensesByYear.get(parseInt(year)));
            // console.log(expensesByYear.get(parseInt(year)));
            // change offices
            const officesMap = component.get("v.offices_map");
            component.set("v.offices", officesMap.get(parseInt(year)));
            // console.log(officesMap.get(parseInt(year)));
            // change balance
            const balanceMap = component.get("v.balance_for_all_years_by_office_map");
            component.set("v.balance_for_all_years_by_office", balanceMap.get(parseInt(year)));
            // console.log(balanceMap.get(parseInt(year)));
            // change monthly average
            const monthlyAverageMap = component.get("v.monthly_average_by_office_map");
            component.set("v.monthly_average_by_office", monthlyAverageMap.get(parseInt(year)));
            // console.log(monthlyAverageMap.get(parseInt(year)));
            // change total by offices
            const totalByOfficeMap = component.get("v.total_for_all_months_by_office_map");
            component.set("v.total_for_all_months_by_office", totalByOfficeMap.get(parseInt(year)));
            // console.log(totalByOfficeMap.get(parseInt(year)));
            // change monthlyExpenses
            const monthlyExpensesMap = component.get("v.monthly_expense_map");
            component.set("v.monthly_expense", monthlyExpensesMap.get(parseInt(year)));
            // console.log(monthlyExpensesMap.get(parseInt(year)));
        } catch (e) {
            console.error(e);
        }
    },

    navigateToOffice: function (component, event, helper) {
        const nav = component.find("adminNavService");
        const office = event.target.dataset.menuItemId;
        console.log('Navigate to expense cards of ' + office);
        const pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__OfficePage'
            },
            state: {
                "c__office": office,
            }
        };
        event.preventDefault();
        console.log('preventDefault');
        nav.navigate(pageReference);
    },
})