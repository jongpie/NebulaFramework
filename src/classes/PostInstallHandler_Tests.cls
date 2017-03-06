@isTest
private class PostInstallHandler_Tests {

    @isTest
    static void onInstall() {
        PostInstallHandler postInstall = new PostInstallHandler();
        Test.testInstall(postInstall, null);
        Test.testInstall(postInstall, new Version(1,0), true);
    }

}