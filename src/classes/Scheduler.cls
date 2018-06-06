/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class Scheduler {

    // CRON order - Seconds, Minutes, Hours, Day_of_month, Month, Day_of_week, Optional_year
    private final static String DAILY_CRON  = '0 {0} {1} * * ?';
    private final static String HOURLY_CRON = '0 {0} * * * ?';

    private final Schedulable schedulableClass;

    public Scheduler(Schedulable schedulableClass) {
        this.schedulableClass = schedulableClass;
    }

    public Id scheduleHourly(String jobName, String startingMinuteInHour) {
        String hourlyCron = String.format(HOURLY_CRON, new List<String>{startingMinuteInHour});
        return this.schedule(jobName, hourlyCron);
    }

    public Id scheduleDaily(String jobName, String startingHour, String startingMinute) {
        String dailyCron = String.format(DAILY_CRON, new List<String>{startingHour, startingMinute});
        return this.schedule(jobName, dailyCron);
    }

    public Id schedule(String jobName, String cronExpression) {
        return System.schedule(jobName, cronExpression, this.schedulableClass);
    }

}