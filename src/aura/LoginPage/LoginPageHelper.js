({
    navigateToUrl: function (component, event, rtnValue) {
        const tokenInfo = rtnValue.split("&");
        const userInfo = {id: tokenInfo[1], isAdmin: tokenInfo[2], office: tokenInfo[3], loginTime: tokenInfo[4]};
        const nav = component.find("navService");
        let pageReference = {};
        if (userInfo.isAdmin === "true") {
            pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__AdminPage'
                }
            };
        } else {
            pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__ExpensesPage'
                },
                state: {
                    "c__id": userInfo.id,
                    "c__office": userInfo.office
                }
            };
        }
        event.preventDefault();
        nav.navigate(pageReference);
    },

    validateResponse: function (resp) {
        let flag = true;
        const state = resp.getState();
        console.log(state);
        if (state === 'SUCCESS') {
            return flag;
        } else if (state === 'ERROR') {
            flag = false;
            const errors = resp.getError();
            let errorMessage = "Unknown error"; //default error message
            if (errors && errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
            console.error(errorMessage);
            this.toastErrors(errorMessage);
            return flag;
        } else {
            console.error('something went wrong');
            this.toastErrors('something went wrong please try again');
        }
        return flag;
    }
    ,

    toastErrors: function (errorMessage) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: errorMessage,
            type: "error"
        };
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
    ,
})