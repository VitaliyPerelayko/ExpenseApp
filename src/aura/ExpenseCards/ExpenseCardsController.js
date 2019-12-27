({
    init: function (component, event, helper) {
        const columns = [
            {label: 'DESCRIPTION', fieldName: 'description', type: 'text', editable: true},
            {
                label: 'AMOUNT', fieldName: 'amount', type: 'currency', editable: true,
                cellAttributes: {alignment: 'left'},
                typeAttributes: {maximumFractionDigits: 2, currencyCode: 'USD'}
            },
            {
                label: 'ACTION', fieldName: 'action', type: 'button',
                typeAttributes: {label: 'Delete', title: 'Delete this expense card', variant: 'base', name: 'delete'}
            },
        ];
        component.set("v.columns", columns);
    },

    handleSaveEdition: function (component, event, helper) {
        const draftValues = event.getParam('draftValues');
        helper.saveChanges(component, draftValues);
    },

    handleCancelAction: function (component, event, helper) {
    },

    handleRowAction: function (component, event, helper) {
        const action = event.getParam('action');
        const row = event.getParam('row');
        if (action.name === 'delete') {
            helper.deleteExpenseCard(component, row.cardId);
        }
    },

    handleSectionToggle: function (component, event, helper) {
    },
})