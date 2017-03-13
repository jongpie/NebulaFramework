/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ILogger {

    void addEntry(INebulaCore moduleClass, String message);
    void addEntry(INebulaCore moduleClass, String message, Exception ex);
    void saveLogs();

}