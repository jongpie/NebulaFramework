/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class Scheduler {

    // CRON order - Seconds, Minutes, Hours, Day_of_month, Month, Day_of_week, Optional_year
    public final static String DAILY_CRON  = '0 {0} {1} * * ?';
    public final static String HOURLY_CRON = '0 {0} * * * ?';

    public static Id scheduleHourly(Schedulable schedulableClass, Integer startingMinuteInHour) {
        String jobName = getSchedulableClassName(schedulableClass) + ': Hourly at minute ' + startingMinuteInHour;
        return scheduleHourly(schedulableClass, jobName, startingMinuteInHour);
    }

    public static Id scheduleHourly(Schedulable schedulableClass, String jobName, Integer startingMinuteInHour) {
        String hourlyCRON = String.format(HOURLY_CRON, new List<String>{String.valueOf(startingMinuteInHour)});
        return schedule(schedulableClass, jobName, hourlyCRON);
    }

    public static Id scheduleDaily(Schedulable schedulableClass, Integer startingHour, Integer startingMinute) {
        String jobName = getSchedulableClassName(schedulableClass) + ': Daily at ' + startingHour + ':' + startingMinute;
        return scheduleDaily(schedulableClass, jobName, startingHour, startingMinute);
    }

    public static Id scheduleDaily(Schedulable schedulableClass, String jobName, Integer startingHour, Integer startingMinute) {
        String dailyCRON = String.format(DAILY_CRON, new List<String>{String.valueOf(startingHour), String.valueOf(startingMinute)});
        return schedule(schedulableClass, jobName, dailyCRON);
    }

    public static Id schedule(Schedulable schedulableClass, String cronExpression) {
        return schedule(schedulableClass, getSchedulableClassName(schedulableClass), cronExpression);
    }

    public static Id schedule(Schedulable schedulableClass, String jobName, String cronExpression) {
        return System.schedule(jobName, cronExpression, schedulableClass);
    }

    private static String getSchedulableClassName(Schedulable schedulableClass) {
        return String.valueOf(schedulableClass).split(':')[0];
    }

}