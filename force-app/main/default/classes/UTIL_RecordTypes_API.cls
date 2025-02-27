/*
    Copyright (c) 2014, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

/**
* @author Salesforce.org
* @date 2014
* @group API
* @group-content ../../ApexDocContent/API.htm
* @description API class that exposes Record Type utility methods.
*/
global with sharing class UTIL_RecordTypes_API {

    /*******************************************************************************************************
    * @description Provides the Id of the Record Type with an specific name in an specific Object.
    * @param objectName The name of the Object.
    * @param  recordTypeName The name of the Record Type.
    * @return Id The Id of the Record Type.
    */
    global static Id GetRecordTypeId(String objectName, String recordTypeName) {
        return UTIL_RecordTypes.GetRecordTypeId(getSObjectTypeForName(objectName), recordTypeName);
    }

    /*******************************************************************************************************
    * @description Provides the name of the Record Type with a specific Id in an specific Object.
    * @param objectName The name of the Object.
    * @param  recordTypId The Id of the Record Type.
    * @return String The name of the Record Type.
    */
    global static String GetRecordTypeName(String objectName, String recordTypeId) {
        return UTIL_RecordTypes.GetRecordTypeName(getSObjectTypeForName(objectName), recordTypeId);
    }

    /*******************************************************************************************************
    * @description Provides the Ids of the Record Types with specific names in an specific Object.
    * @param objectName The name of the Object.
    * @param  recordTypeNameSet The names of the Record Types.
    * @return Set<Id> The Ids of the Record Types.
    */
    global static Set<Id> GetRecordTypeIdSet(String objectName, Set<String> recordTypeNameSet) {
        return UTIL_RecordTypes.GetRecordTypeIdSet(getSObjectTypeForName(objectName), recordTypeNameSet);
    }

    private static sObjectType getSObjectTypeForName(String objectName) {
        return Schema.describeSObjects(new List<String>{objectName}).get(0).getSObjectType();
    }
}