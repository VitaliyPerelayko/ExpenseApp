({
    init: function (component, event, helper) {
        try {
            const monthNames = ["January", "February", "March", "April", "May", "June",
                "July", "August", "September", "October", "November", "December"
            ];
            component.set("v.months", monthNames);
            const office = component.get("v.pageReference").state.c__office;
            const year = new Date().getFullYear();
            const years = [year - 2, year - 1, year, year + 1];
            component.set("v.year", year);
            component.set("v.office", office);
            component.set("v.years", years);
            helper.getContentForPageForMonth(component, office, year, monthNames, "January");
        } catch (e) {
            console.error(e);
        }
    },

    yearChanged: function (component, event, helper) {
        try {
            const year = event.getSource().get("v.label");
            component.set("v.year", year);
            console.log(year);
            const id = component.get("v.userId");
            const monthNames = component.get("v.months");
            const selectedMonth = component.get("v.selected_month");
            const office = component.get("v.office");
            helper.getContentForPageForMonth(component, office, year, monthNames, selectedMonth);
        } catch (e) {
            console.error(e);
        }
    },

    keeperChanged: function (component, event, helper) {
        try {
            const keeperId = event.getParam("value");
            const keeperName = component.get("v.id_LastName_map").get(keeperId);
            console.log(keeperId + "======" + keeperName);
            const month = component.get("v.selected_month");
            const keeperContent = component.get("v.expense_cards_by_keeper").get(keeperId);
            // set user info
            component.set("v.userLastName", keeperName);
            component.set("v.userId", keeperId);
            // attributes for navigation component
            component.set("v.menu_elements", keeperContent.menuElements);
            component.set("v.total_amount", keeperContent.totalAmount);
            component.set("v.total_income", keeperContent.totalIncome);
            // attributes for content
            component.set("v.expense_cards_by_month", keeperContent.expenseCards);
            component.set("v.month_expense_cards", keeperContent.expenseCards.get(month));
            component.set("v.balance", keeperContent.balance);
        } catch (e) {
            console.error(e);
        }
    },

    monthChanged: function (component, event, helper) {
        const month = component.get("v.selected_month");
        const expenseCards = component.get("v.expense_cards_by_month");
        component.set("v.month_expense_cards", expenseCards.get(month));
    },
})