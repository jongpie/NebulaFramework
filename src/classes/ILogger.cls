public interface ILogger {

    //void addMessage(ICore moduleClass, String message);
    void addEntry(ICore moduleClass, String message);
    void addEntry(ICore moduleClass, String message, Exception ex);
    /*void addLog(String message, Logger.Debug debug);
    void addLog(String message, Exception ex, Logger.Debug debug);*/
    void saveLogs();

}