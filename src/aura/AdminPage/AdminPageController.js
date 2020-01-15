({
    init: function (component, event, helper) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        component.set("v.months", monthNames);
        let action = component.get("c.getDataForAdminPage");
        action.setCallback(this, function (response) {
            if (helper.validateResponse(response)){
                helper.setInitData(component, response);
            }
        });
        $A.enqueueAction(action);
    },

    yearChanged: function (component, event, helper) {
        try {
            const year = event.getParam("value");
            console.log(year);
            component.set("v.year", year);
            const expensesByYear = component.get("v.expenses_by_year");
            console.log(expensesByYear.get(2019));
            component.set("v.expense_for_year_by_office", expensesByYear.get(year).officesDTO);
            component.set("v.total_for_year", expensesByYear.get(year).total);
            const sumExpenseBYMonthMap = component.get("v.sum_expenses_by_month_map");
            component.set("v.sum_expenses_for_year_by_month", sumExpenseBYMonthMap.get(year));
        } catch (e) {
            console.error(e);
        }
    },

    navigateToOffice: function (component, event, helper) {
        const nav = component.find("adminNavService");
        const office = event.getSource().get("v.label");
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