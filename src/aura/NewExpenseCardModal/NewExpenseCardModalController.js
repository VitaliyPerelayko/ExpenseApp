({
    onChange: function (component, event, helper) {
        helper.validate(component);
    },

    hideMe: function (component, event, helper) {
        component.set("v.is_shown", false);
    },

    saveClicked: function (component, event, helper) {
        const action = component.get("c.insertNewExpenseCard");
        const userId = component.get("v.user_id");
        const amount = component.get("v.amount");
        const ecDate = component.get("v.ec_date");
        const description = component.get("v.description");
        action.setParams({
            keeperId: userId,
            amount: amount,
            ecDate: ecDate,
            description: description
        });
        action.setCallback(this, function (response) {
            if (helper.validateResponse(response)){
                component.set("v.is_shown", false);
                component.set("v.is_changed", true);
            }
        });
        $A.enqueueAction(action);
    },
})