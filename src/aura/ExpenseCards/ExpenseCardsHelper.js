({
    deleteExpenseCard: function (component, cardId) {
        const action = component.get("c.deleteExpenseCard");
        action.setParams({ecId: cardId});
        action.setCallback(this, function (response) {
            if (this.validateResponse(response)) {
                component.set("v.is_data_changed", true);
            }
        });
        $A.enqueueAction(action);

    },

    saveChanges: function (component, draftValues) {
        console.log(draftValues);
        let changedECDTOs = [];
        draftValues.forEach(function (row) {
            const ecDTO = {
                cardId: row.cardId,
                description: row.description,
                amount: row.amount
            };
            changedECDTOs.push(ecDTO);
        });
        console.log('===Expense card dataTable changed records===');
        console.log(changedECDTOs);
        let action = component.get("c.updateExpenseCards");
        action.setParams({changedExpenseCards: JSON.stringify(changedECDTOs)});
        console.log(JSON.stringify(changedECDTOs));
        action.setCallback(this, function (response) {
            if (this.validateResponse(response)) {
                component.set("v.is_data_changed", true);
            }
        });
        $A.enqueueAction(action);
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
    },

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
    },
})