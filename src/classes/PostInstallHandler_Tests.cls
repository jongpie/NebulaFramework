@isTest
private class PostInstallHandler_Tests {

    @isTest
    static void onInstall() {
        PostInstallHandler postinstall = new PostInstallHandler();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
    }

}