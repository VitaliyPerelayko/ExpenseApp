@isTest
private class AuthControllerTest {

    @isTest
    static void loginTest() {
        System.debug('========== AuthControllerTest.loginTest start test ==========');
        Id userId = TestDataFactory.createContact('Foo', 'foo@foo.bar', 'password', 'Office 1', false).Id;
        String token = AuthController.login('foo@foo.bar', 'password');
        String [] tokenItems = token.split('&');
        System.assertEquals(userId, tokenItems[1]);
        System.assertEquals('false', tokenItems[2]);
        System.assertEquals('Office 1', tokenItems[3]);
        System.debug('========== AuthControllerTest.loginTest end test ==========');
    }

    @isTest
    static void loginTestNoSuchUser() {
        System.debug('========== AuthControllerTest.loginTestNoSuchUser start test ==========');
        String token = AuthController.login('foo@foo.bar', 'password');
        System.assertEquals(AuthController.NO_SUCH_USER, token);
        System.debug('========== AuthControllerTest.loginTestNoSuchUser end test ==========');
    }

    @isTest
    static void loginTestIncorrectPassword() {
        System.debug('========== AuthControllerTest.loginTestIncorrectPassword start test ==========');
        TestDataFactory.createContact('Foo', 'foo@foo.bar', 'password', 'Office 1', false);
        String token = AuthController.login('foo@foo.bar', 'incorrect password');
        System.assertEquals(AuthController.PASSWORD_DOES_NOT_MACH, token);
        System.debug('========== AuthControllerTest.loginTestIncorrectPassword end test ==========');
    }
}