/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class Scheduler_Tests {

    private static final String SCHEDULABLE_JOB_ID = '7';
    private static final String DAILY_CRON_EXP = '0 {0} {1} * * ?';
    private final static String HOURLY_CRON = '0 {0} * * * ?';

    private class TestSchedulable implements Schedulable {
        public void execute(SchedulableContext sc) {}
    }

    @isTest
    static void it_should_successfully_schedule_hourly() {
        Integer startingMinuteInHour = 59;

        String jobId = new Scheduler(new TestSchedulable()).scheduleHourly(SCHEDULABLE_JOB_ID, startingMinuteInHour);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(String.format(HOURLY_CRON, new List<String>{String.valueOf(startingMinuteInHour)}), ct.CronExpression);
    }

    @isTest
    static void it_should_successfully_schedule_daily() {
        Integer startingHour         = 8;
        Integer startingMinuteInHour = 23;

        String jobId = new Scheduler(new TestSchedulable()).scheduleDaily(SCHEDULABLE_JOB_ID, startingHour, startingMinuteInHour);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(String.format(DAILY_CRON_EXP, new List<String>{String.valueOf(startingHour), String.valueOf(startingMinuteInHour)}), ct.CronExpression);
    }

}