public interface ILogger {

    void addEntry(INebulaCore moduleClass, String message);
    void addEntry(INebulaCore moduleClass, String message, Exception ex);
    void saveLogs();

}