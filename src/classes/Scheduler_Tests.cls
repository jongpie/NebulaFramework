/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
global class Scheduler_Tests {
    private static final String SCHEDULABLE_JOB_ID_STRING = '7';

    global class TestSchedulable implements Schedulable {
        global void execute(SchedulableContext sc) {}
    }

    @isTest
    static void it_should_successfully_schedule_daily() {
        String CRON_EXP = '0 59 23 * * ?';
        String jobId = new Scheduler(new TestSchedulable()).scheduleDaily(SCHEDULABLE_JOB_ID_STRING, '59', '23');
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger Where Id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }

    @isTest
    static void it_should_successfully_schedule_hourly() {
        String jobId = new Scheduler(new TestSchedulable()).scheduleHourly(SCHEDULABLE_JOB_ID_STRING, '59');
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger Where Id = :jobId];
        System.assertEquals(String.format(Scheduler.HOURLY_CRON,new List<String>{'59'}), ct.CronExpression);
    }
}