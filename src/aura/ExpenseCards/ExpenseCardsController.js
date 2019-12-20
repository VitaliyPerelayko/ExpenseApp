({
    init: function (component, event, helper) {
        const columns = [
            {label: 'DESCRIPTION', fieldName: 'description', type: 'text', editable: true},
            {
                label: 'AMOUNT', fieldName: 'amount', type: 'currency', editable: true,
                cellAttributes: {alignment: 'left'},
                typeAttributes: {maximumFractionDigits: 2, currencyCode: 'USD'}
            },
            {label: 'ACTION', fieldName: 'action', type: 'text'},
        ];
        component.set("v.columns", columns);
    },
})