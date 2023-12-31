public with sharing class LogToObject implements ILogWriter {
    public LogToObject() {
    }

    /**
     * Write to the actual Log object from a LoggerMsgList
     * @param  LoggerMsgList from Log Method
     */
    public void write(List<LoggerMsg.Log> loggerMsgList) {
        List<Log__c> logs = new List<Log__c>();
        for (LoggerMsg.Log log : loggerMsgList) {
            logs.add(log.toLogObject());
        }

        if (!logs.isEmpty()) {
            //insert records without enforcing CRUD/FLS/Sharing because this is a system process
            Data.create(logs, false, false, false);
        }
    }
}