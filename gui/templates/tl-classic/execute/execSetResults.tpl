{*
TestLink Open Source Project - http://testlink.sourceforge.net/

@filesource	execSetResults.tpl
*}
{$attachment_model=$cfg->exec_cfg->att_model}
{$title_sep=$smarty.const.TITLE_SEP}
{$title_sep_type3=$smarty.const.TITLE_SEP_TYPE3}

{$input_enabled_disabled="disabled"}
{$att_download_only=true}
{$enable_custom_fields=false}
{$draw_submit_button=false}

{$show_current_build=0}
{lang_get s='build' var='build_title'}

{lang_get 
  var='labels'
  s='created_by,saveStepsForPartialExec,partialExecNoAttachmentsWarning,
  edit_notes,build_is_closed,test_cases_cannot_be_executed,test_exec_notes,test_exec_result,btn_next,
	th_testsuite,details,warning_delete_execution,title_test_case,th_test_case_id,keywords,design,execution,partialExecNothingToSave,
	version,has_no_assignment,assigned_to,execution_history,exec_notes,step_actions,add_link_to_tlexec,
	execution_type_short_descr,expected_results,testcase_customfields,builds_notes,
  estimated_execution_duration,version,btn_save_and_exit,test_plan_notes,bug_copy_from_latest_exec,btn_next_tcase,
	last_execution,exec_any_build,date_time_run,test_exec_by,build,exec_status,
	test_status_not_run,tc_not_tested_yet,last_execution,exec_current_build,
  bulk_tc_status_management,access_test_steps_exec,assign_exec_task_to_me,
	attachment_mgmt,bug_mgmt,delete,closed_build,alt_notes,alt_attachment_mgmt,
	img_title_bug_mgmt,img_title_delete_execution,test_exec_summary,title_t_r_on_build,
	execution_type_manual,execution_type_auto,run_mode,or_unassigned_test_cases,
	no_data_available,import_xml_results,btn_save_all_tests_results,execution_type,
	testcaseversion,btn_print,execute_and_save_results,warning,warning_nothing_will_be_saved,
	test_exec_steps,test_exec_expected_r,btn_save_tc_exec_results,only_test_cases_assigned_to,
	deleted_user,click_to_open,reqs,requirement,show_tcase_spec,edit_execution, 
	btn_save_exec_and_movetonext,step_number,btn_export,btn_export_testcases,bug_summary,bug_description,
  bug_link_tl_to_bts,bug_create_into_bts,execution_duration,execution_duration_short,
  issueType,issuePriority,artifactVersion,artifactComponent,
  add_issue_note,bug_add_note,preconditions,platform,platform_description,exec_not_run_result_note,remoteExecFeeback,create_issue_feedback'}



{$cfg_section=$smarty.template|basename|replace:".tpl":""}
{config_load file="input_dimensions.conf" section=$cfg_section}

{$exportAction="lib/execute/execExport.php?tplan_id="}

{include file="inc_head.tpl" popup='yes' openHead='yes' jsValidate="yes" editorType=$gui->editorType}
<script language="JavaScript" src="gui/javascript/radio_utils.js" type="text/javascript"></script>
<script language="JavaScript" src="gui/javascript/expandAndCollapseFunctions.js" type="text/javascript"></script>

{if #ROUND_EXEC_HISTORY# || #ROUND_TC_TITLE# || #ROUND_TC_SPEC#}
  {$round_enabled=1}
  <script language="JavaScript" src="{$basehref}gui/niftycube/niftycube.js" type="text/javascript"></script>
{/if}

<script language="JavaScript" type="text/javascript">
var msg="{$labels.warning_delete_execution}";
var import_xml_results="{$labels.import_xml_results}";
</script>

{include file="inc_del_onclick.tpl"}

<script language="JavaScript" type="text/javascript">
function load_notes(panel,exec_id) {
  // solved ONLY for  $webeditorType == 'none'
  var url2load=fRoot+'lib/execute/getExecNotes.php?readonly=1&exec_id=' + exec_id;
  panel.load({ url:url2load });
}

/*
Set value for a group of combo (have same prefix).
*/
function set_combo_group(formid,combo_id_prefix,value_to_assign) {
	var f=document.getElementById(formid);
	var all_comboboxes = f.getElementsByTagName('select');
	var input_element;
	var idx=0;
		
	for(idx = 0; idx < all_comboboxes.length; idx++) {
		input_element=all_comboboxes[idx];
		if( input_element.type == "select-one" && 
		    input_element.id.indexOf(combo_id_prefix)==0 &&
		   !input_element.disabled) {
			input_element.value=value_to_assign;
		}	
	}
}

// Escape all messages (string)
var alert_box_title="{$labels.warning|escape:'javascript'}";
var warning_nothing_will_be_saved="{$labels.warning_nothing_will_be_saved|escape:'javascript'}";

/**
 *
 */
function validateForm(f) {
  var status_ok = true;


  if( status_ok ) {
    status_ok = checkCustomFields(f);
  }

  if( status_ok && saveStepsPartialExecClicked ) {
    var msg="{$labels.partialExecNothingToSave}";
    status_ok = checkStepsHaveContent(msg);
  }

  return status_ok;
}







/**
 * 
 * IMPORTANT DEVELOPMENT NOTICE
 * ATTENTION args is a GLOBAL Javascript variable, then be CAREFULL
 */
function openExportTestCases(windows_title,tsuite_id,tproject_id,tplan_id,build_id,platform_id,tcversion_set) 
{
  wargs = "tsuiteID=" + tsuite_id + "&tprojectID=" + tproject_id + "&tplanID=" + tplan_id; 
  wargs += "&buildID=" + build_id + "&platformID=" + platform_id;
  wargs += "&tcversionSet=" + tcversion_set;
	wref = window.open(fRoot+"lib/execute/execExport.php?"+wargs,
	                   windows_title,"menubar=no,width=650,height=500,toolbar=no,scrollbars=yes");
	wref.focus();
}


{* 
  Initialize note panels. The array panel_init_functions is filled with init
  functions from inc_exec_show_tc_exec.tpl and executed from onReady below 
*}
panel_init_functions = new Array();
Ext.onReady(function() {
	for(var i=0;i<panel_init_functions.length;i++) {
		panel_init_functions[i]();
	}
});

/**
 * Be Carefull this TRUST on existence of $gui->delAttachmentURL
 */
function jsCallDeleteFile(btn, text, o_id) { 
  if( btn == 'yes' ) {
    var windowCfg="width=510,height=150,resizable=yes,dependent=yes";
    window.open(fRoot+"lib/attachments/attachmentdelete.php?id="+o_id,
                "Delete",windowCfg);
  }
}        
</script>

<script src="third_party/clipboard/clipboard.min.js"></script>

<link rel="stylesheet" href="gui/icons/font-awesome-4.5.0/css/font-awesome.min.css">
{include file="bootstrap.inc.tpl"}

</head>
{*
IMPORTANT: if you change value, you need to chang init_args() logic on execSetResults.php
*}
{$tplan_notes_view_memory_id="tpn_view_status"}
{$build_notes_view_memory_id="bn_view_status"}
{$bulk_controls_view_memory_id="bc_view_status"}
{$platform_notes_view_memory_id="platform_notes_view_status"}

<body onLoad="show_hide('tplan_notes','{$tplan_notes_view_memory_id}',{$gui->tpn_view_status});
              show_hide('build_notes','{$build_notes_view_memory_id}',{$gui->bn_view_status});
              show_hide('bulk_controls','{$bulk_controls_view_memory_id}',{$gui->bc_view_status});
              show_hide('platform_notes','{$platform_notes_view_memory_id}',{$gui->platform_notes_view_status});

              {if $tsuite_info != null}
                multiple_show_hide('{$tsd_div_id_list}','{$tsd_hidden_id_list}',
                                   '{$tsd_val_for_hidden_list}');
              {/if}

              {if $round_enabled}Nifty('div.exec_additional_info');{/if}
              {if #ROUND_TC_SPEC#}Nifty('div.exec_test_spec');{/if}
              {if #ROUND_EXEC_HISTORY#}Nifty('div.exec_history');{/if}
              {if #ROUND_TC_TITLE#}Nifty('div.exec_tc_title');{/if}"
      onUnload="storeWindowSize('TCExecPopup')">

<h1 class="title">{$labels.title_t_r_on_build} {$title_sep} {$gui->testplan_div_title} > {$gui->build_name|escape}
	{if $gui->platform_info.name != ""}
	  {$title_sep_type3}{$labels.platform}{$title_sep}{$gui->platform_info.name|escape}
	{/if}
</h1>

{if $gui->ownerDisplayName != ""}
  <h1 class="title">
    {$labels.only_test_cases_assigned_to}{$title_sep}
	  {foreach from=$gui->ownerDisplayName item=assignedUser}
	    {$assignedUser|escape}
	  {/foreach}
	  {if $gui->include_unassigned}
	    <br />{$labels.or_unassigned_test_cases}
	  {/if}
  </h1>
{/if}

<div id="main_content" class="workBack">
	{if $gui->user_feedback != ''}
		<div class="error">{$gui->user_feedback}</div>
	{/if}
  {if $gui->build_is_open == 0}
  <div class="messages" style="align:center;">
     {$labels.build_is_closed}<br />
     {$labels.test_cases_cannot_be_executed}
  </div>
  <br />
  {/if}


<form method="post" id="execSetResults" name="execSetResults" 
      enctype="multipart/form-data"
      onSubmit="javascript:return validateForm(this);">

  <input type="hidden" id="save_button_clicked"  name="save_button_clicked" value="0" />
  <input type="hidden" id="do_delete"  name="do_delete" value="0" />
  <input type="hidden" id="exec_to_delete"  name="exec_to_delete" value="0" />
  <input type="hidden" id="form_token"  name="form_token" value="{$gui->treeFormToken}" />
  <input type="hidden" id="refresh_tree"  name="refresh_tree" value="{$gui->refreshTree}" />
  <input type="hidden" id="{$gui->history_status_btn_name}" name="{$gui->history_status_btn_name}" value="1" />

  {$bulkExec = $cfg->exec_cfg->show_testsuite_contents && 
               $gui->can_use_bulk_op }
  {$singleExec = !$bulkExec}

  {if $singleExec}
    <div class="groupBtn">
      <input type="hidden" id="history_on" name="history_on" value="{$gui->history_on}" />
      
      {$tlImages.toggle_direct_link} &nbsp;
      <div class="direct_link" style='display:none'>
      <img class="clip" src="{$tlImages.clipboard}" title="eye" 
           data-clipboard-text="{$gui->direct_link}">
      <a href="{$gui->direct_link}" target="_blank">
      {$gui->direct_link}</a></div>

      
      <button type="button" class="btn btn-default btn-xs" name="print" id="print" onclick="javascript:window.print();" >
        <i class="fa fa-print"></i> {$labels.btn_print}
      </button>  

      <button class="btn btn-default btn-xs" id="toggle_history_on_off"  name="{$gui->history_status_btn_name}"
             value="" 
             onclick="javascript:toogleRequiredOnShowHide('bug_summary');
                      javascript:toogleRequiredOnShowHide('artifactVersion');
                      javascript:toogleRequiredOnShowHide('artifactComponent');
                      execSetResults.submit();">
         <i class="fa fa-eye"></i> {lang_get s=$gui->history_status_btn_name}
      </button>

      {if $gui->grants->execute}
      <button type="button"  class="btn btn-default btn-xs" id="pop_up_import_button" name="import_xml_button"
             onclick="javascript: openImportResult('import_xml_results',{$gui->tproject_id},
                                                   {$gui->tplan_id},{$gui->build_id},{$gui->platform_id});">
         <i class="fa fa-file-code-o"></i> {$labels.import_xml_results}
      </button>
          
      {/if}

      
      {if $tlCfg->exec_cfg->enable_test_automation}
        <input type="submit" id="execute_cases" name="execute_cases"
                 value="{$labels.execute_and_save_results}"/>
      {/if}
    </div>
  {/if}

  {if $gui->plugins.EVENT_TESTRUN_DISPLAY}
    <div id="plugin_display">
      {foreach from=$gui->plugins.EVENT_TESTRUN_DISPLAY item=testrun_item}
        {$testrun_item}
        <br />
      {/foreach}
    </div>
  {/if}

  {* ------------------------------------ *}
  {* Test Plan notes show/hide management *}
  {* ------------------------------------ *}
  {$div_id='tplan_notes'}
  {$memstatus_id=$tplan_notes_view_memory_id}
  {include file="inc_show_hide_mgmt.tpl"
           show_hide_container_title=$gui->testplan_div_title
           show_hide_container_id=$div_id
           show_hide_container_draw=false
           show_hide_container_class='exec_additional_info'
           show_hide_container_view_status_id=$memstatus_id}

  <div id="{$div_id}" class="exec_additional_info">
    {if $gui->testPlanEditorType == 'none'}{$gui->testplan_notes|nl2br}{else}{$gui->testplan_notes}{/if}
    {if $gui->testplan_cfields neq ''} <div id="cfields_testplan" class="custom_field_container">{$gui->testplan_cfields}</div>{/if}
  </div>
  {* ---------------------------------------------------------------- *}

  {* ---------------------------------------------------------------- *}
  {* Platforms notes show/hide management *}
  {* ---------------------------------------------------------------- *}
  {if $gui->platform_info.id > 0}
    {$div_id='platform_notes'}
    {$memstatus_id=$platform_notes_view_memory_id}
	{if $gui->platformEditorType == 'none'}{$content=$gui->platform_info.notes|nl2br}{else}{$content=$gui->platform_info.notes}{/if}

    {include file="inc_show_hide_mgmt.tpl"
             show_hide_container_title=$gui->platform_div_title
             show_hide_container_id=$div_id
             show_hide_container_view_status_id=$memstatus_id
             show_hide_container_draw=true
             show_hide_container_class='exec_additional_info'
             show_hide_container_html=$content}
  {/if}         
  {* ------------------------------------------------------- *}

  {* ------------------------------------------------------- *}
  {* Build notes show/hide management                        *}
  {* ------------------------------------------------------- *}
  {$div_id='build_notes'}
  {$memstatus_id=$build_notes_view_memory_id}
  {include file="inc_show_hide_mgmt.tpl"
           show_hide_container_title=$gui->build_div_title
           show_hide_container_id=$div_id
           show_hide_container_view_status_id=$memstatus_id
           show_hide_container_draw=false
           show_hide_container_class='exec_additional_info'}

  <div id="{$div_id}" class="exec_additional_info">
    {if $gui->buildEditorType == 'none'}{$gui->build_notes|nl2br}{else}{$gui->build_notes}{/if}
    {if $gui->build_cfields != ''} <div id="cfields_build" class="custom_field_container">{$gui->build_cfields}</div>{/if}
  </div>

  {* ------------------------------------------------------- *}
  {if $gui->map_last_exec eq ""}
     <div class="messages" style="text-align:center"> {$labels.no_data_available}</div>
  {else}
      {if $gui->grants->execute == 1 and $gui->build_is_open == 1}
        {$input_enabled_disabled=""}
        {$att_download_only=false}
        {$enable_custom_fields=true}
        {$draw_submit_button=true}

        {if $bulkExec}
            {$div_id='bulk_controls'}
            {$memstatus_id="$bulk_controls_view_memory_id"}
            {include file="inc_show_hide_mgmt.tpl"
                     show_hide_container_title=$labels.bulk_tc_status_management
                     show_hide_container_id=$div_id
                     show_hide_container_draw=false
                     show_hide_container_class='exec_additional_info'
                     show_hide_container_view_status_id=$memstatus_id}

            <div id="{$div_id}" name="{$div_id}">
              {include file="execute/{$tplConfig.inc_exec_controls}"
                       args_save_type='bulk'
                       args_input_enable_mgmt=$input_enabled_disabled
                       args_tcversion_id='bulk'
                       args_webeditor=$gui->bulk_exec_notes_editor
                       args_execution_time_cfields=$gui->execution_time_cfields
                       args_draw_save_and_exit=$gui->draw_save_and_exit
                       args_labels=$labels}
            </div>
        {/if}
    	{/if}
	{/if}

  {* ------------------------------------------------------- *}
  {* Test Details Block                                    *}
  {* ------------------------------------------------------- *}
  {if $bulkExec}
    {include file="execute/execSetResultsBulk.inc.tpl"}
  {/if}

  {if $singleExec}
  	{if $tlCfg->exec_cfg->enable_test_automation && 
        $gui->remoteExecFeedback != ''}
      {include file="execute/execSetResultsRemoteExec.inc.tpl"}
  	{/if}

    {include file="execute/inc_exec_show_tc_exec.tpl"}
    {if isset($gui->refreshTree) && $gui->refreshTree}
      {include file="inc_refreshTreeWithFilters.tpl"}
    {/if}
  {/if}
  
</form>
</div>

<script>
jQuery( document ).ready(function() {
  clipboard = new Clipboard('.clip');
});
</script>
<script language="JavaScript" src="gui/javascript/execSetResults.js" type="text/javascript"></script>
</body>
</html>
