@RestResource(urlMapping='/telegram/*')
global with sharing class RestControllerForTelegramBot {

    @HttpPost
    global static String handlePost(String body){
        System.debug('==body ' + body);
        String requestUri = RestContext.request.requestURI;
        String caseName = requestUri.substring(
                requestUri.lastIndexOf('/')+1);
        System.debug('==caseName ' + caseName);
        switch on caseName {
            when 'username' {
                return validateUsername(body);
            }
            when 'password' {
                return validatePassword(body);
            }
        }
        return 'unhandled request';
    }

    private static String validateUsername (String username){
        System.debug('================' + username);
        Integer num = [SELECT COUNT() FROM Contact WHERE email = :username];
        if (num >0){
            return 'SUCCESS';
        } else {
            return AuthController.NO_SUCH_USER;
        }
    }

    private static String validatePassword (String body) {
        List<String> credentials = body.split(' # ');
        System.debug('==credentials ' + credentials);
        return AuthController.login(credentials[0], credentials[1]);
    }

}