/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Asynchronous Apex
*
* @description TODO
*/
public class Scheduler {

    //CRON order - Seconds, Minutes, Hours, Day_of_month, Month, Day_of_week, Optional_year
    public final static String DAILY_CRON = '0 {0} {1} * * ?';
    public final static String HOURLY_CRON = '0 {0} * * * ?';
    private final Schedulable scheduledClass;

    public Scheduler (Schedulable scheduledClass)  {
        this.scheduledClass = scheduledClass;
    }

    public String scheduleHourly(String jobName, String startingMinuteInHour) {
        String hourlyCRON = String.format(HOURLY_CRON, new List<String>{startingMinuteInHour});
        return this.schedule(jobName, hourlyCRON);
    }

    public String scheduleDaily(String jobName, String startingHour, String startingMinute) {
        String dailyCRON = String.format(DAILY_CRON, new List<String>{startingHour, startingMinute});
        return this.schedule(jobName, dailyCRON);
    }

    public String schedule(String jobName, String cronExpression) {
        return System.schedule(jobName, cronExpression, this.scheduledClass);
    }

}