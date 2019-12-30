({
    init: function (component, event, helper) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        component.set("v.months", monthNames);
        const year = new Date().getFullYear();
        component.set("v.year", year);
        let action = component.get("c.getDataForAdminPage");
        action.setCallback(this, function (response) {
            if (helper.validateResponse(response)){
                helper.setInitData(component, response, year);
            }
        });
        $A.enqueueAction(action);
    },

    yearChanged: function (component, event, helper) {
        const year = event.getParam("value");
        console.log(year);
        component.set("v.year", year);
    },

    navigateToOffice: function (component, event, helper) {
        const nav = component.find("navService");
        const office = event.getSource().get("v.label");
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
        nav.navigate(pageReference);
    },
})