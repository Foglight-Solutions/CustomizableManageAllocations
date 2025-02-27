/**
 * Created by reiswarman on 7/17/20.
 */

public with sharing class FieldSetService {
    @TestVisible
    private static FieldSetService mock;


    public static FieldSetService createService() {
        if (mock != null) {
            return mock;
        } else {
            return new FieldSetService();
        }
    }

    public List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetName, String objectName) {
        Schema.DescribeSObjectResult describeSObjectResultObj  = ((SObject) Type.forName(objectName).newInstance()).getSObjectType().getDescribe();
        Schema.FieldSet fieldSetObj  = describeSObjectResultObj.FieldSets.getMap().get(UTIL_Namespace.getNamespace() + '__' + fieldSetName);
        if(fieldSetObj == null) {
            return null;
        }
        return fieldSetObj.getFields();
    }
}