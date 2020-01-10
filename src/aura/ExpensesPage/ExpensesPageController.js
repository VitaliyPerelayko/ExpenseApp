({
    init: function (component, event, helper) {
        console.log("============ init start");
        const id = component.get("v.pageReference").state.c__id;
        const office = component.get("v.pageReference").state.c__office;
        const year = new Date().getFullYear();
        const years = [year - 2, year - 1, year, year + 1];
        component.set("v.year", year);
        component.set("v.userId", id);
        component.set("v.office", office);
        component.set("v.years", years);
        component.set("v.is_data_changed", false);
        console.log("============ before helper");
        helper.getContentForPage(component, id, year);
    },

    yearChanged: function (component, event, helper) {
        const year = event.getSource().get("v.label");
        component.set("v.year", year);
        console.log(year);
        helper.getContentForPage(component, component.get("v.userId"), year);
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
    }
})