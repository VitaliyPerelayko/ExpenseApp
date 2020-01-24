public class AuthController {

    public static final String NO_SUCH_USER = 'There is no any user with such an username';
    public static final String PASSWORD_DOES_NOT_MACH = 'Password doesn\'t mach';

    @AuraEnabled
    public static String login(String username, String password) {
        List<Contact> contacts = [
                SELECT Id, email, Password__c, Office__c, Admin__c
                FROM Contact
                WHERE email = :username
        ];
        if (contacts.isEmpty()) {
            return NO_SUCH_USER;
        }
        for (Contact c : contacts) {
            if (c.Password__c == password) {
                return generateToken(c.Id, c.Admin__c, c.Office__c);
            } else {
                return PASSWORD_DOES_NOT_MACH;
            }
        }
        return NO_SUCH_USER;
    }

    private static String generateToken(Id userId, Boolean isAdmin, String office) {
        List<Object> formattingArguments = new List<Object>();
        formattingArguments.add(userId);
        formattingArguments.add(isAdmin);
        formattingArguments.add(office);
        formattingArguments.add(Datetime.now());
        return String.format('TOKEN&{0}&{1}&{2}&{3}', formattingArguments);
    }

}