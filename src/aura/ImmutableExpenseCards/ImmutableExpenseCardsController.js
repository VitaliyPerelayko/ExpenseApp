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
})