public abstract class QuickSchedulable implements Schedulable {

    private final static String DAILY_CRON_EXPRESSION  = '0 {0} {1} * * ?';
    private final static String HOURLY_CRON_EXPRESSION = '0 {0} * * * ?';

    public void scheduleDailyJob(String scheduledJobName, Integer hour, Integer minute) {
        if(scheduledJobName == null) throw new ParameterException('Scheduled job name is required');
        System.schedule(scheduledJobName, this.generateDailyCronExpression(hour, minute), this);
    }

    public void scheduleHourlyJob(String scheduledJobName, Integer startingMinute) {
        if(String.isBlank(scheduledJobName)) throw new ParameterException('Scheduled job name is required');
        System.schedule(scheduledJobName, this.generateHourlyCronExpression(startingMinute), this);
    }

    private String generateDailyCronExpression(Integer startingHour, Integer startingMinute) {
        if(startingHour == null || startingMinute == null) throw new ParameterException('Hour and minute are required');
        return this.formatIntegers(DAILY_CRON_EXPRESSION, new List<Integer>{startingMinute, startingHour});
    }

    private String generateHourlyCronExpression(Integer startingMinute) {
        if(startingMinute == null) throw new ParameterException('Starting minute is required');
        return this.formatIntegers(HOURLY_CRON_EXPRESSION, new List<Integer>{startingMinute});
    }

    private String formatIntegers(String pattern, List<Integer> integerList) {
        List<String> stringList = new List<String>();
        for(Integer i : integerList) stringList.add(String.valueOf(i));

        return String.format(pattern, stringList);
    }

    private class ParameterException extends Exception {}

}