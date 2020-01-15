({
    init: function (component, event, helper) {
        const office = component.get("v.pageReference").state.c__office;
        const year = new Date().getFullYear();
        const years = [year - 2, year - 1, year, year + 1];
        component.set("v.year", year);
        // component.set("v.userId", id);
        component.set("v.office", office);
        component.set("v.years", years);
        helper.getContentForPageForMonth(component, office, year);
    },

    monthChanged: function (component, event, helper) {
        const month = component.get("v.selected_month");
        const expenseCards = component.get("v.expense_cards");
        component.set("v.month_expense_cards", expenseCards.get(month));
    },
})