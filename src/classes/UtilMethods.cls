public class UtilMethods {


    // return map contact Id => Contact
    public static Map<Id, Contact> contactsOfficeMap() {
        List<String> listOfOffices = getListOfOffices();
        return new Map<Id, Contact>(
        [
                SELECT Id, Office__c, LastName
                FROM Contact
                WHERE Office__c IN :listOfOffices AND Admin__c = false
        ]);
    }

    public static List<String> getListOfOffices() {
        List<String> officeList = new List<String>();
        List<PicklistEntry> offices =
                Contact.SObjectType.getDescribe().
                        fields.getMap().get('Office__c').getDescribe().getPicklistValues();
        for (PicklistEntry pl : offices) {
            officeList.add(pl.value);
        }
        return officeList;
    }

}