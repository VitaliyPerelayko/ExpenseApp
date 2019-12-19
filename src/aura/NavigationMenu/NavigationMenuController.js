({
    onclick: function (component, event, helper){
        const monthNum = event.target.getAttribute("data-item");
        console.log(monthNum);
        component.set("v.number_of_month", monthNum);
    }
})