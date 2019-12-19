public class AuthController {

    public static final String NO_SUCH_USER = 'There is no any user with such an username';
    public static final String PASSWORD_DOES_NOT_MACH = 'Password doesn\'t mach';

    //TODO add later password encryption
    @AuraEnabled
    public static String login(String username, String password) {
        List<Contact> contacts = [
                SELECT FirstName, LastName, email, Password__c, Office__c, Admin__c
                FROM Contact
                WHERE email = :username
        ];
        if (contacts.isEmpty()) {
            return NO_SUCH_USER;
        }
        for (Contact c : contacts) {
            if (c.Password__c == password) {
                return generateToken(username);
            } else {
                return PASSWORD_DOES_NOT_MACH;
            }
        }
        return NO_SUCH_USER;
    }

    private static String generateToken(String username) {
        return 'TOKEN&' + username + '&' + Datetime.now();
    }

}