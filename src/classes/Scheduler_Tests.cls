/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class Scheduler_Tests {

    private static final String SCHEDULABLE_JOB_ID = '7';
    private static final String DAILY_CRON_EXP = '0 59 23 * * ?';

    private class TestSchedulable implements Schedulable {
        public void execute(SchedulableContext sc) {}
    }

    @isTest
    static void it_should_successfully_schedule_daily() {
        String jobId = new Scheduler(new TestSchedulable()).scheduleDaily(SCHEDULABLE_JOB_ID, '59', '23');
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(DAILY_CRON_EXP, ct.CronExpression);
    }

    @isTest
    static void it_should_successfully_schedule_hourly() {
        String jobId = new Scheduler(new TestSchedulable()).scheduleHourly(SCHEDULABLE_JOB_ID, '59');
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(String.format(HOURLY_CRON, new List<String>{'59'}), ct.CronExpression);
    }

}