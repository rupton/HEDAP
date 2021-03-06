/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group TDTM
* @group-content ../../ApexDocContent/API.htm
* @description Provides methods to call the Trigger Handler class, which in turns calls the classes that need to
* run for each DML action on a set of records, and to retrieve the default HEDA TDTM configuration.
*/
global class TDTM_Global_API {
    
    /*******************************************************************************************************
    * @description Method to be called from each of the triggers (only one per object) that follow the TDTM 
    * design. Figures out which classes need to be called, and calls them.
    * @param isBefore Are we in a before trigger context.
    * @param isAfter Are we in an after trigger context.
    * @param isInsert Did the trigger run in response to an insert operation.
    * @param isUpdate Did the trigger run in response to an update operation.
    * @param isDelete Did the trigger run in response to a delete operation.
    * @param isUnDelete Did the trigger run in response to an undelete operation.
    * @param newList The records that were passed to the trigger as trigger.new.
    * @param oldList The records that were passed to the trigger as trigger.old.
    * @param describeObj The type of SObject the class runs for.
    * @param dao The class that is going to retrieve all the TDTM records.
    * @return void
    */
    global static void run(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
    Boolean isDelete, Boolean isUnDelete, List<SObject> newList, List<SObject> oldList, 
    Schema.DescribeSObjectResult describeObj) {
        
        TDTM_TriggerHandler.run(isBefore, isAfter, isInsert, isUpdate, isDelete, isUnDelete, newList, oldList, describeObj);
    }
    
    /********************************************************************************************************
    * @description Returns the TDTM configuration. If no configuration is currently set, it will return 
    * the default configuration without setting it. The configuration returned has not yet been inserted in the 
    * database. It can be manipulated, if necessary, then set. 
    * If no configuration exists, the application will insert the defaults when any of the triggers run. 
    * @return List<TdtmToken> List of trigger handler tokens with the default values. 
    *********************************************************************************************************/
    global static List<TdtmToken> getTdtmConfig() {
        return TDTM_Config.getTdtmConfig();
    }

    /********************************************************************************************************
    * @description Returns the default TDTM configuration directly as TDTM Tokens.  
    * @return List<TDTM_Global_API.TdtmToken> List of trigger handler tokens with the default values. 
    *********************************************************************************************************/
    global static List<TdtmToken> getDefaultTdtmConfig() {
        return TDTM_Config.getDefaultTdtmConfig();
    }

    /*******************************************************************************************************
    * @description Sets the trigger handlers configuration with the data passed as parameter.
    * @parameter tdtmTokens A list with the defaul trigger handlers configuration.
    * @return void
    *********************************************************************************************************/
    global static void setTdtmConfig(List<TdtmToken> tokens) {
        TDTM_Config.setTdtmConfig(tokens);
    }
    
    /********************************************************************************************************
    * @description Trigger Handler token. It contains information about the code that will run in response to 
    * a database action.
    *********************************************************************************************************/
    global class TdtmToken {
        /********************************************************************************************************
        * @description The name of the class containing the code to run.
        *********************************************************************************************************/
        global String className    { get; set; }
        
        /********************************************************************************************************
        * @description The name of the object that causes the code to run when manipulated.
        *********************************************************************************************************/
        global String targetObject { get; set; }
        
        /********************************************************************************************************
        * @description The trigger actions that cause the code to run. 
        *********************************************************************************************************/
        global String actions      { get; set; }
        
        /********************************************************************************************************
        * @description Whether the code is active or not.
        *********************************************************************************************************/
        global Boolean active      { get; set; }
        
        /********************************************************************************************************
        * @description The order in which the code will run with relation to other active tokens defined for the 
        * same object.
        *********************************************************************************************************/
        global Integer loadOrder   { get; set; }
        
        /********************************************************************************************************
        * @description Whether the dispatched will attempt to run this code asynchronously. WARNING: the code needs
        * to be written in a manner that running asynchronously is suppported.
        *********************************************************************************************************/
        global Boolean async       { get; set; }
        
        /********************************************************************************************************
        * @description The field on the target object to filter records on. Filtered records won't be processed 
        * by the code.
        *********************************************************************************************************/
        global String filterField  { get; set; }
        
        /********************************************************************************************************
        * @description The value of the filter field that, if matched, will cause records to be excluede from 
        * processing.
        *********************************************************************************************************/
        global String filterValue  { get; set; }
        
        /********************************************************************************************************
        * @description Flags a handler as user-managed. If the handler is user-managed, the post-install script
        * won't attempt to modify it in any way.
        *********************************************************************************************************/
        global Boolean userManaged { get; set; }
        
        /********************************************************************************************************
        * @description Constructor. Simpler version. It assumes default values for those properties not passed as
        * parameters.
        * @parameter className The token's class name.
        * @parameter targetObject The token's target object.
        * @parameter actions The token's actions.
        * @parameter loadOrder The token's load order.
        *********************************************************************************************************/
        global TdtmToken(String className, String targetObject, String actions, Integer loadOrder) {
            this.className = className;
            this.targetObject = targetObject;
            this.actions = actions;
            this.loadOrder = loadOrder;
            this.active = true;
            this.async = false;
            this.userManaged = false;
        }
        
        /********************************************************************************************************
        * @description Constructor. Verbose version. Values are provided for all properties.
        * @parameter className The token's class name.
        * @parameter targetObject The token's target object.
        * @parameter actions The token's actions.
        * @parameter loadOrder The token's load order.
        * @parameter active The token's active flag.
        * @parameter async The token's async flag.
        * @parameter filterField The token's filter field.
        * @parameter filterValue The token's filter value.
        * @parameter userManaged The token's user-managed flag.
        *********************************************************************************************************/
        global TdtmToken(String className, String targetObject, String actions, Integer loadOrder, Boolean active,
        Boolean async, String filterField, String filterValue, Boolean userManaged) {
            this.className = className;
            this.targetObject = targetObject;
            this.actions = actions;
            this.active = active;
            this.loadOrder = loadOrder;
            this.async = async;
            this.filterField = filterField;
            this.filterValue = filterValue;
            this.userManaged = userManaged;
        }
    }
}