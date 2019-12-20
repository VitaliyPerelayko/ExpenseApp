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

    onclick: function (component, event, helper) {
        const action = component.get("c.login");
        const userN = component.get("v.username");
        const pass = component.get("v.password");
        action.setParams({
            username: userN,
            password: pass
        });
        action.setCallback(this, function (response) {
                if (helper.validateResponse(response)) {
                    const rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    component.set("v.authToken", rtnValue);
                    if (rtnValue.startsWith('TOKEN')) {
                        helper.navigateToUrl(component, event, rtnValue);
                    } else {
                        component.set("v.is_login_disabled", true);
                        component.set("v.is_hide_error", false);
                        component.set("v.error_message", rtnValue);
                    }
                }
            }
        );
        $A.enqueueAction(action);
    }
})