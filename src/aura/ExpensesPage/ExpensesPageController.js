({
    init: function (component, event, helper) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        component.set("v.months", monthNames);
        const id = component.get("v.pageReference").state.c__id;
        const office = component.get("v.pageReference").state.c__office;
        const year = new Date().getFullYear();
        const years = [year - 2, year - 1, year, year + 1];
        component.set("v.year", year);
        component.set("v.userId", id);
        component.set("v.office", office);
        component.set("v.years", years);
        helper.getContentForPage(component, id, year, monthNames);
    },

    yearChanged: function (component, event, helper) {
        try {
            const year = event.getSource().get("v.label");
            component.set("v.year", year);
            console.log(year);
            const id = component.get("v.userId");
            const monthNames = component.get("v.months");
            console.log("=========menuElements=======");
            console.log(monthNames);
            helper.getContentForPage(component, id, year, monthNames);
        } catch (e) {
            console.error(e);
        }
    },

    monthChanged: function (component, event, helper) {
        const month = component.get("v.selected_month");
        const expenseCards = component.get("v.expense_cards");
        component.set("v.month_expense_cards", expenseCards.get(month));
    },

    newExpenseCard: function (component, event, helper) {
        component.set("v.is_save_shown", true);
    },

    addMoney: function (component, event, helper) {
        component.set("v.is_top_up_shown", true);
    },

    rerender: function (component, event, helper) {
        const id = component.get("v.userId");
        const year = component.get("v.year");
        const monthNames = component.get("v.months");
        helper.getContentForPage(component, id, year, monthNames);
    },
})