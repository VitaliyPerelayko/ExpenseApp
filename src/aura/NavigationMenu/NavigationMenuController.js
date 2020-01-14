({
    onClick: function (component, event, helper) {
        try {
            // remove highlighting from previous month
            const prevElement = document.getElementsByClassName("active");
            prevElement[0].className = "";
            // change selected month and add highlighting to it's menu element
            let element = event.target;
            while (element.tagName !== 'TR') {
                element = element.parentElement;
            }
            const id = element.dataset.menuItemId;
            console.log(id);
            component.set("v.selected_month", id);
            element.className += " active";
        } catch (e) {
            console.error(e);
        }
    },
})