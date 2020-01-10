({
    onClick: function (component, event, helper) {
        const id = event.target.dataset.menuItemId;
        console.log(id);
        component.set("v.selected_month", id);
    },
})