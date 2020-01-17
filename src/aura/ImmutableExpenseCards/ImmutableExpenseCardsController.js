({
    init: function (component, event, helper) {
        const columns = [
            {label: 'DESCRIPTION', fieldName: 'description', type: 'text', editable: true},
            {
                label: 'AMOUNT', fieldName: 'amount', type: 'currency', editable: true,
                cellAttributes: {alignment: 'left'},
                typeAttributes: {maximumFractionDigits: 2, currencyCode: 'USD'}
            },
        ];
        component.set("v.columns", columns);
    },
})