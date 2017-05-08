/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class DML implements IDML {
    public virtual SObject doInsert(SObject record) { return this.doInsert(new List<SObject>{record})[0];}
    public virtual List<SObject> doInsert(List<SObject> records) {
        Database.insert(records);
        return records;
    }

    public virtual SObject doUpdate(SObject record) { return this.doUpdate(new List<SObject>{record})[0]; }
    public virtual List<SObject> doUpdate(List<SObject> records) {
        Database.update(records);
        return records;
    }

    public virtual SObject doUpsert(SObject record) {
        //Salesforce will only allow upsert calls for SObjects if a declared-type list is passed in.
        //This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
        //the only way to successfully perform the upsert is to dynamically spin up a list of the SObject's type
        String listType = 'List<' + record.getSObjectType() + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.add(record);
        return this.doUpsert(castRecords)[0];
    }

    public virtual List<SObject> doUpsert(List<SObject> records) {
        Database.upsert(records);
        return records;
    }

    public virtual SObject doUndelete(SObject record) { return this.doUnDelete(new List<SObject>{record})[0]; }
    public virtual List<SObject> doUndelete(List<SObject> records) {
        Database.undelete(records);
        return records;
    }

    public virtual void doDelete(SObject record) { this.doDelete(new List<SObject>{record}); }
    public virtual void doDelete(List<SObject> records) {
        if(records.isEmpty() == false) {
            Database.delete(records);
        }
    }

    public virtual void doHardDelete(SObject record) { this.doHardDelete(new List<SObject>{record}); }
    public virtual void doHardDelete(List<SObject> records) {
        this.doDelete(records);
        if(records.isEmpty() == false) {
            Database.emptyRecycleBin(records);
        }
    }
}