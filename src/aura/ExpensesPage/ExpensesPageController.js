({
    init: function (component, event, helper) {
        const id = component.get("v.pageReference").state.c__id;
        const office = component.get("v.pageReference").state.c__office;
        const year = new Date().getFullYear();
        const years = [year - 2, year - 1, year, year + 1];
        component.set("v.year", year);
        component.set("v.userId", id);
        component.set("v.office", office);
        component.set("v.years", years);
        helper.getContentForPage(component, id, year);
    },

    monthChanged: function (component, event, helper) {
    },
})