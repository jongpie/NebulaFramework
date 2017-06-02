/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class NebulaCore implements INebulaCore {

    public static final String TRANSACTION_ID;
    public static String INITIAL_CLASS {public get; private set;}
    public static Module INITIAL_MODULE {public get; private set;}

    static {
        NebulaCore.TRANSACTION_ID = new UUID().getValue();
        System.debug('NebulaCore.TRANSACTION_ID=' + NebulaCore.TRANSACTION_ID);
    }

    public enum Module { RECORD_TYPES, REPOSITORY, SETTINGS, TRIGGER_HANDLER }

    protected final Module currentModule;

    protected NebulaCore() {
        if(NebulaCore.INITIAL_CLASS == null) NebulaCore.INITIAL_CLASS = this.getClassName();
        if(NebulaCore.INITIAL_MODULE == null) NebulaCore.INITIAL_MODULE = this.getClassModule();
    }

    public String getClassName() {
        return String.valueOf(this).split(':')[0];
    }

    public NebulaCore.Module getClassModule() {
        return this.currentModule;
    }

}