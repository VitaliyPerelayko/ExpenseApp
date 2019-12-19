({
    validate: function (component, event, helper) {
        let allValid = component.find('inputF').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            component.set("v.is_login_disabled", false);
        } else {
            component.set("v.is_login_disabled", true);
        }
    },

    // TODO handle bad responses
    onclick: function (component, event, helper) {
        const action = component.get("c.login");
        const userN = component.get("v.username");
        const pass = component.get("v.password");
        action.setParams({
            username: userN,
            password: pass
        });
        action.setCallback(this, function (response) {
            const rtnValue = response.getReturnValue();
            console.log(rtnValue);
            component.set("v.authToken", rtnValue);
            if (rtnValue.startsWith('TOKEN')) {
                const urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    'url': '/lightning/n/ExpensesPage'
                });
                urlEvent.fire();
            } else {
                component.set("v.is_login_disabled", true);
                component.set("v.is_hide_error", false);
                component.set("v.error_message", rtnValue);
            }
        });
        $A.enqueueAction(action);
    }
})