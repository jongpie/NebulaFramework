public abstract class Core implements ICore {

    public static final String TRANSACTION_ID;
    public static String INITIAL_CLASS {public get; private set;}
    public static Module INITIAL_MODULE {public get; private set;}

    static {
        Core.TRANSACTION_ID = new UUID().getValue();
        System.debug('Core.TRANSACTION_ID=' + Core.TRANSACTION_ID);
    }

    public enum Module { RECORD_TYPES, REPOSITORY, TRIGGER_HANDLER }

    protected final Module currentModule;
    private final ILogger logger;

    protected Core() {
        this.logger = new Logger();
        if(Core.INITIAL_CLASS == null) Core.INITIAL_CLASS = this.getClassName();
        if(Core.INITIAL_MODULE == null) Core.INITIAL_MODULE = this.getClassModule();
    }

    public String getClassName() {
        return String.valueOf(this).split(':')[0];
    }

    public Core.Module getClassModule() {
        return this.getModule();
    }

    public Core.Module getModule() {
        return this.currentModule;
    }

    protected void addLogEntry(String message) {
        this.logger.addEntry(this, message);

    }

    protected void saveLogs() {
        // Don't waste a save call if a query was executed & a trigger started the transaction
        // Trigger handlers already savethe logs at the end of their execution
        if(this.getClassModule() == Module.REPOSITORY && INITIAL_MODULE == Module.TRIGGER_HANDLER) return;

        this.logger.saveLogs();
    }

}