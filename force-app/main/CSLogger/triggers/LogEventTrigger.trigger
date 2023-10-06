trigger LogEventTrigger on LogEvent__e(after insert) {
    Logger logInstance = Logger.getInstance();
    List<LoggerMsg.Log> loggerMsgList = new List<LoggerMsg.Log>();
    for (LogEvent__e le : Trigger.new) {
        LoggerMsg.Log loggerMsg = new LoggerMsg.Log(le);
        loggerMsgList.add(loggerMsg);
    }
    logInstance.write(loggerMsgList);
}