({
    submitClicked: function (component, event, helper) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        const action = component.get("c.topUpBalance");
        const keeperId = component.get("v.keeperId");
        const addMoney = component.get("v.addMoney");
        // create date
        const chosenMonth = component.get("v.chosenMonth");
        const month = monthNames.indexOf(chosenMonth, 0) + 1;
        const year = component.get("v.year");
        action.setParams({
            year: year,
            month: month,
            addMoney: addMoney,
            keeperId: keeperId
        });
        action.setCallback(this, function (response) {
            if (helper.validateResponse(response)){
                component.set("v.is_shown", false);
                component.set("v.is_data_changed", true);
            }
        });
        $A.enqueueAction(action);
    },

    hideMe: function (component, event, helper) {
        component.set("v.is_shown", false);
    },
})