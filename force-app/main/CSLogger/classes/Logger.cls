public with sharing class Logger {
    public enum Level {
        ERROR,
        WARN,
        DEBUG,
        INFO
    }

    private static Logger LOGGER_INSTANCE = null;

    private Boolean allowMultiple = false;
    private LoggerMsg.LoggerSettings settings;
    private List<LoggerMsg.Log> loggerMsgList;
    private List<LogEvent__e> logEvents;

    /**
     * Private constructor that sets the allowing of multiple logs, and gets the settings
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     */
    private Logger(Boolean inMultiple) {
        this.allowMultiple = inMultiple;
        this.logEvents = new List<LogEvent__e>();
        this.settings = new LoggerMsg.LoggerSettings(false);
        this.loggerMsgList = new List<LoggerMsg.Log>();
    }

    /**
     * Private constructor same as above - added platformEvent parameter to pass it to LoggerSettings
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     *         platformEvent  TRUE to bypass Platform Event for unit testing
     */
    private Logger(Boolean inMultiple, Boolean platformEvent) {
        this.allowMultiple = inMultiple;
        this.logEvents = new List<LogEvent__e>();
        this.settings = new LoggerMsg.LoggerSettings(platformEvent);
        this.loggerMsgList = new List<LoggerMsg.Log>();
    }

    /**
     * Public getter of an instance. Really used to get the same instance across multiple classes like triggers
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     * @return            A Logger instance
     */
    public static Logger getInstance(Boolean inMultiple) {
        if (LOGGER_INSTANCE == null) {
            LOGGER_INSTANCE = new Logger(inMultiple);
        }
        return LOGGER_INSTANCE;
    }

    /**
     * Public getter of an instance same as above. Really used to get the same instance across multiple classes like triggers
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     *         platformEvent  TRUE to bypass Platform Event for unit testing
     * @return            A Logger instance
     */
    public static Logger getInstance(Boolean inMultiple, Boolean platformEvent) {
        if (LOGGER_INSTANCE == null) {
            LOGGER_INSTANCE = new Logger(inMultiple, platformEvent);
        }
        return LOGGER_INSTANCE;
    }
    public static Logger getInstance() {
        return Logger.getInstance(false);
    }

    /**
     * Creates a Log Platform Event if bypass Platform event is false and logging is enabled, that will then create a Log object outside of the current process or
     * create a LoggerMsg Object if bypass Platform event is true and logging is enabled, that will then create a Log object within current process
     * @param  className    Class Name (where this action happened)
     * @param  level        Level enum (ERROR, WARN, DEBUG, INFO)
     * @param  objectName   Object Name (if we are doing DML statements)
     * @param  objectIdList List of Object IDs Affected
     * @param  message      Message
     * @param  stackTrace   Exception Stack Trace
     * @param  inJSON       JSON From API
     */
    public void log(
        String className,
        Level level,
        String objectName,
        List<Id> objectIdList,
        String message,
        String stackTrace,
        String inJSON
    ) {
        String objectIds;
        if ((objectIdList != null) && (!objectIdList.isEmpty())) {
            objectIds = String.join(objectIdList, ',');
        }

        LoggerMsg.Log loggerMsg = new LoggerMsg.Log(
            className,
            level.name(),
            objectName,
            objectIds,
            message,
            stackTrace,
            inJson,
            userInfo.getUserId()
        );

        if (settings.logToSystemDebug) {
            System.debug(JSON.serialize(loggerMsg));
        }

        if (settings.enableLogging) {
            if (settings.bypassPlatformEvents) {
                if (this.allowMultiple) {
                    loggerMsgList.add(loggerMsg);
                } else {
                    List<LoggerMsg.Log> logList = new List<LoggerMsg.Log>{ loggerMsg };
                    write(logList);
                }
            } else {
                LogEvent__e le = loggerMsg.toPlatformEvent();

                if (this.allowMultiple) {
                    logEvents.add(le);
                } else {
                    EventBus.publish(le);
                }
            }
        }
    }

    /**
     * Called at the end of an execution context to bulkify the publishing of log events/LoggerMsg in the case of allowMultiple = TRUE
     */
    public void finalize() {
        if (this.allowMultiple) {
            if (!logEvents.isEmpty()) {
                EventBus.publish(logEvents);
            }
            if (!loggerMsgList.isEmpty()) {
                write(loggerMsgList);
            }
        }
    }

    // Overrides
    public void log(String className, String message) {
        log(className, Level.ERROR, null, null, message, null, null);
    }
    public void log(String className, Level level, String message) {
        log(className, level, null, null, message, null, null);
    }
    public void log(String className, String message, String inJSON) {
        log(className, Level.ERROR, null, null, message, null, inJSON);
    }
    public void log(String className, Level level, String message, String inJSON) {
        log(className, level, null, null, message, null, inJSON);
    }
    public void log(String className, String objectName, List<Id> objectIdList, String message) {
        log(className, Level.ERROR, objectName, objectIdList, message, null, null);
    }
    public void log(String className, String objectName, Set<Id> objectIdSet, String message) {
        List<Id> objectIdList;
        if (objectIdSet != null) {
            objectIdList = new List<Id>(objectIdSet);
        }
        log(className, Level.ERROR, objectName, objectIdList, message, null, null);
    }
    public void log(String className, Level level, String objectName, List<Id> objectIdList, String message) {
        log(className, level, objectName, objectIdList, message, null, null);
    }
    public void log(String className, Level level, String objectName, Set<Id> objectIdSet, String message) {
        List<Id> objectIdList;
        if (objectIdSet != null) {
            objectIdList = new List<Id>(objectIdSet);
        }
        log(className, level, objectName, objectIdList, message, null, null);
    }

    // Exception handling
    public void log(String className, Exception e) {
        log(className, Level.ERROR, null, null, e.getMessage(), e.getStackTraceString(), null);
    }
    public void log(String className, Exception e, String inJSON) {
        log(className, Level.ERROR, null, null, e.getMessage(), e.getStackTraceString(), inJSON);
    }
    public void log(String className, String objectName, Exception e) {
        log(className, Level.ERROR, objectName, null, e.getMessage(), e.getStackTraceString(), null);
    }
    public void log(String className, String objectName, Exception e, String inJSON) {
        log(className, Level.ERROR, objectName, null, e.getMessage(), e.getStackTraceString(), inJSON);
    }

    // DML Error Handling
    public Boolean log(String className, String objectName, List<Database.SaveResult> results) {
        Boolean result = true;
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : sr.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                log(className, Level.ERROR, objectName, null, errorMsg, null, null);
                result = false;
            }
        }
        return result;
    }
    public Boolean log(String className, String objectName, List<Database.UpsertResult> results) {
        Boolean result = true;
        for (Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : sr.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                log(className, Level.ERROR, objectName, null, errorMsg, null, null);
                result = false;
            }
        }
        return result;
    }

    /**
     * Check the custom metadata type if pruning is enabled to prevent org limits
     */
    public void pruneLogs() {
        Log__c firstLogToPrune;

        // If it's off, end here
        if (!settings.enablePruning) {
            return;
        }

        Integer logCount = Data.countQuery(
            'SELECT COUNT() FROM Log__c LIMIT :maxLogs',
            new Map<String, Object>{ 'maxLogs' => settings.maxLogs },
            false,
            false,
            false
        );
        // If it's less than the max, end here
        if (logCount < settings.maxLogs) {
            return;
        }

        // Get the CreatedDate of the first log to prune
        try {
            String query =
                'SELECT CreatedDate FROM Log__c ORDER BY CreatedDate DESC LIMIT 1 OFFSET ' + settings.maxLogs;

            //run query without enforcing CRUD/FLS/Sharing because this is a system process
            firstLogToPrune = (Log__c) Data.read(query, new Map<String, Object>(), false, false, false)[0];
        } catch (Exception e) {
            // If this throws an exception, then there's a mismatch or some other race condition. Just exit and it'll correct
            // itself on the next run.
            return;
        }

        // Seed the Queueable and queue it up
        LogPruneQueueable lpq = new LogPruneQueueable(firstLogToPrune.CreatedDate);
        System.enqueueJob(lpq);
    }

    /**
     * Check the custom metadata type for the interfaced classes and call them in order
     * @param  LoggerMsgList updated from Log method
     */
    public void write(List<loggerMsg.Log> loggerMsgList) {
        if (loggerMsgList.size() > 0) {
            List<String> values = settings.classOrder.split(',');

            for (String v : values) {
                try {
                    ILogWriter customType = (ILogWriter) Type.forName(v).newInstance();
                    customType.write(loggerMsgList);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }
    }
}