@isTest
private class PostUninstallHandler_Tests {

    @isTest
    static void onUninstall() {
        PostUninstallHandler postUninstall = new PostUninstallHandler();
        Test.testUninstall(postUninstall);
    }

}