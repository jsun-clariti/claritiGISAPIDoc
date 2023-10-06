public with sharing class LogPruneQueueable implements Queueable {
    private Datetime pruneStartDate;
    private Integer maxToDeleteInTransaction = 200;

    public LogPruneQueueable(Datetime inDate) {
        this.pruneStartDate = inDate;
    }

    public void execute(QueueableContext context) {
        String query = 'SELECT Id FROM Log__c WHERE CreatedDate <= :pruneStartDate LIMIT :maxToDeleteInTransaction';
        Map<String, Object> queryArgs = new Map<String, Object>{
            'pruneStartDate' => this.pruneStartDate,
            'maxToDeleteInTransaction' => this.maxToDeleteInTransaction
        };

        List<Log__c> logsToPrune = Data.read(query, queryArgs, false, false, false);

        // Get the count here before we delete them
        Integer pruneCount = logsToPrune.size();

        //delete records without enforcing CRUD/FLS/Sharing because this is a system process
        Data.remove(logsToPrune, false, false, false);

        // If the number of logs we deleted is equal to the max to delete in a transaction, queue up a new instance of the queueable
        // with the same parameters. Eventually it will be less than this number and the loop will exit.
        if (pruneCount == this.maxToDeleteInTransaction) {
            LogPruneQueueable lpq = new LogPruneQueueable(this.pruneStartDate);
            if (!Test.isRunningTest()) {
                System.enqueueJob(lpq);
            }
        }
    }
}