*&---------------------------------------------------------------------*
*& Report  ZTESTE_LFM                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

*REPORT                                .
program ZDOWNLOAD.
*-----------------------------------------------------------------------
*  SAP Tables
*-----------------------------------------------------------------------
tables: trdir, seoclass, tfdir, enlfdir, dd02l.

*-----------------------------------------------------------------------
*  Types
*-----------------------------------------------------------------------
* text element structure
types: ttexttable like textpool.
* GUI titles
types: tguititle like d347t.

* Message classes
types: begin of tmessage,
         arbgb like t100-arbgb,
         stext like t100a-stext,
         msgnr like t100-msgnr,
         text  like t100-text,
       end of tmessage.

* Screen flow.
types: begin of tscreenflow,
         screen like d020s-dnum,
         code like d022s-line,
       end of tscreenflow.

* Holds a table\structure definition
types: begin of tdicttablestructure,
         fieldname like dd03l-fieldname,
         position  like dd03l-position,
         keyflag   like dd03l-keyflag,
         rollname  like dd03l-rollname,
         domname   like dd03l-domname,
         datatype  like dd03l-datatype,
         leng      like dd03l-leng,
         ddtext    like dd04t-ddtext,
       end of tdicttablestructure.

* Holds a tables attributes + its definition
types: begin of tdicttable,
         tablename    like dd03l-tabname,
         tabletitle   like dd02t-ddtext,
         istructure type tdicttablestructure occurs 0,
       end of tdicttable.

* Include program names
types: begin of tinclude,
         includename like trdir-name,
         includetitle like tftit-stext,
       end of tinclude.

* Exception class texts
types: begin of tconcept,
         constname type string,
         concept type sotr_conc,
       end of tconcept.

* Method
types: begin of tmethod,
         cmpname like vseomethod-cmpname,
         descript like vseomethod-descript,
         exposure like vseomethod-exposure,
         methodkey type string,
       end of tmethod.

* Class
types: begin of tclass,
         scanned(1),
         clsname like vseoclass-clsname,
         descript like vseoclass-descript,
         msg_id like vseoclass-msg_id,
         exposure like vseoclass-exposure,
         state like vseoclass-state,
         clsfinal like vseoclass-clsfinal,
         r3release like vseoclass-r3release,
         imethods type tmethod occurs 0,
         idictstruct type tdicttable occurs 0,
         itextelements type ttexttable occurs 0,
         imessages type tmessage occurs 0,
         iconcepts type tconcept occurs 0,
         textelementkey type string,
         publicclasskey type string,
         privateclasskey type string,
         protectedclasskey type string,
         typesclasskey type string,
         exceptionclass type i,
       end of tclass.

* function modules
types: begin of tfunction,
         functionname like tfdir-funcname,
         functiongroup like enlfdir-area,
         includenumber like tfdir-include,
         functionmaininclude like tfdir-funcname,
         functiontitle like tftit-stext,
         topincludename like tfdir-funcname,
         progname like tfdir-pname,
         programlinkname like tfdir-pname,
         messageclass like t100-arbgb,
         itextelements type ttexttable occurs 0,
         iselectiontexts type ttexttable occurs 0,
         imessages type tmessage occurs 0,
         iincludes type tinclude occurs 0,
         idictstruct type tdicttable occurs 0,
         iguititle type tguititle occurs 0,
         iscreenflow type tscreenflow occurs 0,
       end of tfunction.

types: begin of tprogram,
         progname like trdir-name,
         programtitle like tftit-stext,
         subc like trdir-subc,
         messageclass like t100-arbgb,
         imessages type tmessage occurs 0,
         itextelements type ttexttable occurs 0,
         iselectiontexts type ttexttable occurs 0,
         iguititle type tguititle occurs 0,
         iscreenflow type tscreenflow occurs 0,
         iincludes type tinclude occurs 0,
         idictstruct type tdicttable occurs 0,
       end of tprogram.

*-----------------------------------------------------------------------
*  Internal tables
*-----------------------------------------------------------------------
*  Dictionary object
data: idictionary type standard table of tdicttable with header line.
* Function modules.
data: ifunctions type standard table of tfunction with header line.
* Tree display structure.
data: itreedisplay type standard table of snodetext with header line.
* Message class data
data: imessages type standard table of tmessage with header line.
* Holds a single message class an all of its messages
data: isinglemessageclass type standard table of tmessage with header
line.
* Holds program related data
data: iprograms type standard table of tprogram with header line.
* Classes
data: iclasses type standard table of tclass with header line.
* Table of paths created on the SAP server
data: iserverpaths type standard table of string with header line.

*-----------------------------------------------------------------------
*  Table prototypes
*-----------------------------------------------------------------------
data: dumidictstructure type standard table of tdicttablestructure.
data: dumitexttab type standard table of ttexttable.
data: dumiincludes type standard table of tinclude.
data: dumihtml type standard table of string.
data: dumiheader type standard table of string .
data: dumiscreen type standard table of tscreenflow .
data: dumiguititle type standard table of tguititle.
data: dumimethods type standard table of tmethod.
data: dumiconcepts type standard table of tconcept.

*-----------------------------------------------------------------------
*   Global objects
*-----------------------------------------------------------------------
data: objfile type ref to cl_gui_frontend_services.
data: objruntimeerror type ref to cx_root.

*-----------------------------------------------------------------------
*  Constants
*-----------------------------------------------------------------------
constants: versionno type string value '1.3.1'.
constants: tables type string value 'TABLES'.
constants: table type string value 'TABLE'.
constants: like type string value 'LIKE'.
constants: type type string value 'TYPE'.
constants: typerefto type string value 'TYPE REF TO'.
constants: structure type string value 'STRUCTURE'.
constants: lowstructure type string value 'structure'.
constants: occurs type string value 'OCCURS'.
constants: function type string value 'FUNCTION'.
constants: callfunction type string value ' CALL FUNCTION'.
constants: message type string  value 'MESSAGE'.
constants: include type string value 'INCLUDE'.
constants: lowinclude type string value 'include'.
constants: destination type string value 'DESTINATION'.
constants: is_table type string value 'T'.
constants: is_program type string value 'P'.
constants: is_screen type string value 'S'.
constants: is_guititle type string value 'G'.
constants: is_documentation type string value 'D'.
constants: is_messageclass type string value 'MC'.
constants: is_function type string value 'F'.
constants: is_class type string value 'C'.
constants: is_method type string value 'M'.
constants: asterix type string value '*'.
constants: comma type string value ','.
constants: period type string value '.'.
constants: dash type string value '-'.
constants: true type i value 1.
constants: false type i value 0.
constants: lt type string value '&lt;'.
constants: gt type string value '&gt;'.
constants: unix type string value 'UNIX'.
constants: non_unix type string value 'not UNIX'.
constants: background_colour type string value '#FFFFE0'.
constants: colour_white type string value '#FFFFFF'.
constants: colour_black type string value '#000000'.
constants: colour_yellow type string value '#FFFF00'.
constants: comment_colour type string value '#0000FF'.
constants: htmlextension type string value 'html'.
constants: textextension type string value 'txt'.

*-----------------------------------------------------------------------
*  Global variables
*-----------------------------------------------------------------------
data: statusbarmessage(100).
data: forcedexit type i value 0.
data: starttime like sy-uzeit.
data: runtime like sy-uzeit.
data: downloadfileextension type string.
data: downloadfolder type string.
data: serverslashseparator type string.
data: frontendslashseparator type string.
data: slashseparatortouse type string.
data: serverfilesystem type filesys_d.
data: serverfolder type string.
data: frontendopsystem type string.
data: serveropsystem type string.
data: customernamespace type string.
ranges: soprogramname for trdir-name.
ranges: soauthor for usr02-bname.
ranges: sotablenames for dd02l-tabname.
ranges: sofunctionname  for tfdir-funcname.
ranges: soclassname for vseoclass-clsname.
ranges: sofunctiongroup for enlfdir-area.
field-symbols: <wadictstruct> type tdicttable.

*-----------------------------------------------------------------------
*  Selection screen declaration
*-----------------------------------------------------------------------
* Author
selection-screen: begin of block b1 with frame title tblock1.
selection-screen begin of line.
selection-screen comment 5(23) tauth.
parameters: pauth like usr02-bname memory id mauth.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 5(36) tpmod.
parameters: pmod as checkbox.
selection-screen end of line.

* Local objects
selection-screen begin of line.
selection-screen comment 5(36) t$tmp.
parameters: p$tmp as checkbox default ''.
selection-screen end of line.
selection-screen: end of block b1.

selection-screen begin of block b2 with frame title tblock2.
* Tables
selection-screen begin of line.
parameters: rtable radiobutton group r1.
selection-screen comment 5(15) trtable.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(15) tptable.
select-options: sotable for dd02l-tabname.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(79) ttnote.
selection-screen end of line.

* Message classes
selection-screen begin of line.
parameters: rmess radiobutton group r1.
selection-screen comment 5(18) tpmes.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(18) tmname.
parameters: pmname like t100-arbgb memory id mmname.
selection-screen end of line.

* Function modules
selection-screen begin of line.
parameters: rfunc radiobutton group r1.
selection-screen comment 5(30) trfunc.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(15) tpfname.
select-options: sofname for tfdir-funcname.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(15) tfgroup.
select-options: sofgroup for enlfdir-area.
selection-screen end of line.

* Classes
selection-screen begin of line.
parameters: rclass radiobutton group r1.
selection-screen comment 5(30) trclass.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(15) tpcname.
select-options: soclass for seoclass-clsname.
selection-screen end of line.

* Programs / includes
selection-screen begin of line.
parameters: rprog radiobutton group r1 default 'X'.
selection-screen comment 5(18) tprog.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 10(15) trpname.
select-options: soprog for trdir-name.
selection-screen end of line.

selection-screen skip.
* Language
selection-screen begin of line.
selection-screen comment 1(18) tmlang.
parameters: pmlang like t100-sprsl default 'EN'.
selection-screen end of line.

* Package
selection-screen begin of line.
selection-screen comment 1(18) tpack.
parameters: ppack like tadiv-devclass memory id mpack.
selection-screen end of line.

* Customer objects
selection-screen begin of line.
selection-screen comment 1(27) tcust.
parameters: pcust as checkbox default 'X'.
selection-screen comment 32(25) tnrange.
parameters: pcname type namespace memory id mnamespace.
selection-screen end of line.
selection-screen: end of block b2.

* Additional things to download.
selection-screen: begin of block b3 with frame title tblock3.
selection-screen begin of line.
selection-screen comment 1(33) tptext.
parameters: ptext as checkbox default 'X' memory id mtext.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tmess.
parameters: pmess as checkbox default 'X' memory id mmess.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tpinc.
parameters: pinc as checkbox default 'X' memory id minc.
selection-screen comment 40(20) trecc.
parameters: preci as checkbox default 'X' memory id mreci.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tpfunc.
parameters: pfunc as checkbox default 'X' memory id mfunc.
selection-screen comment 40(20) trecf.
parameters: precf as checkbox default 'X' memory id mrecf.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tdoc.
parameters: pdoc as checkbox default 'X' memory id mdoc.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tpscr.
parameters: pscr as checkbox default 'X' memory id mscr.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tpdict.
parameters: pdict as checkbox default 'X' memory id mdict.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(33) tsortt.
parameters: psortt as checkbox default ' ' memory id msortt.
selection-screen end of line.
selection-screen: end of block b3.

* File details
selection-screen: begin of block b4 with frame title tblock4.
selection-screen begin of line.
selection-screen comment 1(20) tphtml.
parameters: phtml radiobutton group g1 default 'X'.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 5(29) tcomm.
parameters: pcomm as checkbox default 'X'.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 5(29) tback.
parameters: pback as checkbox default 'X'.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(20) tptxt.
parameters: ptxt radiobutton group g1.
selection-screen end of line.

selection-screen skip.

* Download to SAP server
selection-screen begin of line.
selection-screen comment 1(25) tserv.
parameters: pserv radiobutton group g2.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 8(20) tspath.
parameters: plogical like filename-fileintern memory id mlogical.
selection-screen end of line.
selection-screen comment /28(60) tsdpath.

* Download to PC
selection-screen begin of line.
selection-screen comment 1(25) tpc.
parameters: ppc radiobutton group g2 default 'X'.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 8(20) tppath.
parameters: pfolder like rlgrap-filename memory id mfolder.
selection-screen end of line.
selection-screen: end of block b4.

* Display options
selection-screen: begin of block b5 with frame title tblock5.
* Display final report
selection-screen begin of line.
selection-screen comment 1(33) trep.
parameters: prep as checkbox default 'X'.
selection-screen end of line.
* Display progress messages
selection-screen begin of line.
selection-screen comment 1(33) tpromess.
parameters: ppromess as checkbox default 'X'.
selection-screen end of line.
selection-screen: end of block b5.

*-----------------------------------------------------------------------
* Display a directory picker window
*-----------------------------------------------------------------------
at selection-screen on value-request for pfolder.

  data: objfile type ref to cl_gui_frontend_services.
  data: pickedfolder type string.
  data: initialfolder type string.

  if sy-batch is initial.
    create object objfile.

    if not pfolder is initial.
      initialfolder = pfolder.
    else.
      objfile->get_temp_directory( changing temp_dir = initialfolder
                                   exceptions cntl_error = 1
                                             error_no_gui = 2
                                             not_supported_by_gui = 3 ).
    endif.

    objfile->directory_browse( exporting initial_folder = initialfolder
                               changing selected_folder = pickedfolder
                               exceptions cntl_error = 1
                                          error_no_gui = 2
                                          not_supported_by_gui = 3 ).

    if sy-subrc = 0.
      pfolder = pickedfolder.
    else.
      write: / 'An error has occured picking a folder'.
    endif.
  endif.

*-----------------------------------------------------------------------
at selection-screen.
*-----------------------------------------------------------------------
  case 'X'.
    when ppc.
      if pfolder is initial.
*       User must enter a path to save to
        message e000(oo) with 'You must enter a file path'.
      endif.

    when pserv.
      if plogical is initial.
*       User must enter a logical path to save to
        message e000(oo) with 'You must enter a logical file name'.
      endif.
  endcase.

*-----------------------------------------------------------------------
at selection-screen on plogical.
*-----------------------------------------------------------------------

  if not pserv is initial.
    call function 'FILE_GET_NAME'
      exporting
        logical_filename = plogical
      importing
        file_name        = serverfolder
      exceptions
        file_not_found   = 1
        others           = 2.
    if sy-subrc = 0.
      if serverfolder is initial.
        message e000(oo) with 'No file path returned from logical filename'.
      else.
*       Path to display on the selection screen
        tsdpath = serverfolder.
*       Remove the trailing slash off the path as the subroutine
*buildFilename will add an extra one
        shift serverfolder right deleting trailing serverslashseparator.
        shift serverfolder left deleting leading space.
      endif.
    else.
      message e000(oo) with 'Logical filename does not exist'.
    endif.
  endif.

*
at selection-screen on value-request for soprog-low.
*
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type           = 'PROG'
      object_name           = soprog-low
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    importing
      object_name_selected  = soprog-low
    exceptions
      cancel                = 1.

*
at selection-screen on value-request for soprog-high.
*
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type           = 'PROG'
      object_name           = soprog-high
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    importing
      object_name_selected  = soprog-high
    exceptions
      cancel                = 1.

*
at selection-screen on value-request for soclass-low.
*
  call function 'F4_DD_ALLTYPES'
    exporting
      object               = soclass-low
      suppress_selection   = 'X'
      display_only         = ''
      only_types_for_clifs = 'X'
    importing
      result               = soclass-low.

*
at selection-screen on value-request for soclass-high.
*
  call function 'F4_DD_ALLTYPES'
    exporting
      object               = soclass-high
      suppress_selection   = 'X'
      display_only         = ''
      only_types_for_clifs = 'X'
    importing
      result               = soclass-high.

*-----------------------------------------------------------------------
at selection-screen on value-request for sofname-low.
*-----------------------------------------------------------------------
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type           = 'FUNC'
      object_name           = sofname-low
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    importing
      object_name_selected  = sofname-low
    exceptions
      cancel                = 1.

*-----------------------------------------------------------------------
at selection-screen on value-request for sofname-high.
*-----------------------------------------------------------------------
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type           = 'FUNC'
      object_name           = sofname-high
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    importing
      object_name_selected  = sofname-high
    exceptions
      cancel                = 1.

*-----------------------------------------------------------------------
at selection-screen on value-request for sofgroup-low.
*-----------------------------------------------------------------------
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type           = 'FUGR'
      object_name           = sofgroup-low
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    importing
      object_name_selected  = sofgroup-low
    exceptions
      cancel                = 1.

*-----------------------------------------------------------------------
at selection-screen on value-request for sofgroup-high.
*-----------------------------------------------------------------------
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type           = 'FUGR'
      object_name           = sofgroup-high
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    importing
      object_name_selected  = sofgroup-high
    exceptions
      cancel                = 1.

*-----------------------------------------------------------------------
* initialisation
*-----------------------------------------------------------------------
initialization.
* Parameter screen texts.
  tblock1 = 'Author (Optional)'.
  t$tmp   = 'Programs only: include local objects'.
  tblock2 = 'Objects to download'.
  tblock3 = 'Additional downloads for programs, function modules and classes'.
  tblock4 = 'Download parameters'.
  tblock5 = 'Display options'.
  tauth   = 'Author name'.
  tpmod   = 'Include programs modified by author'.
  tcust   = 'Only customer objects'.
  tnrange = 'Alt customer name range'.
  trtable = 'Tables / Structures'.
  tptable = 'Table name'.
  ttnote  = 'Note: tables are stored under the username of the last person who modified them'.
  trfunc  = 'Function modules'.
  tpfname = 'Function name'.
  tfgroup = 'Function group'.
  trclass  = 'Classes'.
  tpcname = 'Class name'.
  tmess   = 'Message class'.
  tmname  = 'Class name'.
  tmlang  = 'Language'.
  tprog   = 'Programs'.
  trpname = 'Program name'.
  tpack   = 'Package'.
  tptxt   = 'Text document'.
  tphtml  = 'HTML document'.
  tcomm   = 'Highlight comments'.
  tback   = 'Include background colour'.
  tptext  = 'Text elements'.
  tpinc   = 'Include programs'.
  trecc   = 'Recursive search'.
  tppath  = 'File path'.
  tspath  = 'Logical file name'.
  tpmes   = 'Message classes'.
  tpfunc  = 'Function modules'.
  tdoc    = 'Function module documentation'.
  trecf   = 'Recursive search'.
  tpscr   = 'Screens'.
  tpdict  = 'Dictionary structures'.
  tsortt  = 'Sort table fields alphabetically'.
  tserv   = 'Download to server'.
  tpc     = 'Download to PC'.
  trep    = 'Display download report'.
  tpromess  = 'Display progress messages'.

* Determine the frontend operating system type.
  if sy-batch is initial.
    perform determinefrontendopsystem using frontendslashseparator
frontendopsystem.
  endif.
  perform determineserveropsystem using serverslashseparator
serverfilesystem serveropsystem.

* Determine if the external command exists.  If it doesn't then disable
* the server input field
  perform findexternalcommand.

*-----------------------------------------------------------------------
* start-of-selection.
*-----------------------------------------------------------------------
start-of-selection.

  perform checkcomboboxes.
  perform fillselectionranges.
  starttime = sy-uzeit.

* Don't display status messages if we are running in the background
  if not sy-batch is initial.
    ppromess = ''.
  endif.

* Fool the HTML routines to stop them hyperlinking anything with a space
* in them
  if pcname is initial.
    customernamespace  = '^'.
  else.
    customernamespace = pcname.
  endif.

* Determine which operating slash and download directory to use
  case 'X'.
    when ppc.
      slashseparatortouse = frontendslashseparator.
      downloadfolder = pfolder.
    when pserv.
      slashseparatortouse = serverslashseparator.
      downloadfolder = serverfolder.
  endcase.

* Main program flow.
  case 'X'.
*   Select tables
    when rtable.
      perform retrievetables using idictionary[]
                                   sotablenames[]
                                   soauthor[].

*   Select message classes tables
    when rmess.
      perform retrievemessageclass using imessages[]
                                         soauthor[]      "Author
                               pmname          "Message class name
                               pmlang          "Message class language
                               pmod.           "Modified by author

*   Select function modules
    when rfunc.
      perform retrievefunctions using sofunctionname[]   "Function name
                                      sofunctiongroup[]  "Function group
                                 ifunctions[]       "Found functions
                                 soauthor[]         "Author
                                 ptext              "Get texte Elements
                                 pscr               "Get screens
                                 pcust              "Customer data
                                 customernamespace. "Customer name
      "range


      loop at ifunctions.
*       Find Dict structures, messages, functions, includes etc.
        perform scanforadditionalfuncstuff using ifunctions[]
                                                 preci
 "Search for includes recursively
                                                 precf
 "Search for functions recursively
                                                 pinc
 "Search for includes
                                                 pfunc
 "Search for functions
                                                 pdict
 "search for dictionary objects
                                                 pmess
 "Search for messages
                                                 pcust
 "Customer data only
                                                 customernamespace.
        "Customer name range
      endloop.

*   Select Classes
    when rclass.
      perform retrieveclasses using iclasses[]
                                    ifunctions[]
                                    soclassname[]       "Class name
                                    soauthor[]          "Author
                                    customernamespace   "Customer name
                                    pmod                "Also modified
                                    pcust               "Customer object
                                    pmess               "Find messages
                                    ptext               "Text Elements
                                    pdict               "Dictionary
                                    pfunc               "Get functions
                                    pinc                "Get includes
                                    precf               "Search
                                    preci               "Search
                                    'X'                 "Search
                                    pmlang.             "Language

      loop at ifunctions.
*       Find Dict structures, messages, functions, includes etc.
        perform scanforadditionalfuncstuff using ifunctions[]
                                                 preci
 "Search for includes recursively
                                                 precf
 "Search for functions recursively
                                                 pinc
 "Search for includes
                                                 pfunc
 "Search for functions
                                                 pdict
 "search for dictionary objects
                                                 pmess
 "Search for messages
                                                 pcust
 "Customer data only
                                                 customernamespace.
        "Customer name range
      endloop.

*   Select programs
    when rprog.
      perform retrieveprograms using iprograms[]
                                     ifunctions[]
                                     soprogramname[]    "Program name
                                     soauthor[]         "Author
                                     customernamespace  "Customer name
                                     pmod               "Also modified
                                     pcust              "Customer object
                                     pmess              "Find messages
                                     ptext              "Text Elements
                                     pdict              "Dictionay
                                     pfunc              "Get functions
                                     pinc               "Get includes
                                     pscr               "Get screens
                                     precf              "Search
                                     preci              "Search
                                     p$tmp              "local objects
                                     ppack.             "Package
  endcase.

*-----------------------------------------------------------------------
* end-of-selection
*-----------------------------------------------------------------------
end-of-selection.

  if forcedexit = 0.
*   Set the file extension and output type of the file
    if ptxt is initial.
      downloadfileextension = htmlextension.
    else.
      downloadfileextension = textextension.
    endif.

*   Decide what to download
    case 'X'.
*     Download tables
      when rtable.
        if not ( idictionary[] is initial ).
          perform downloadddstructures using idictionary[]
                                             downloadfolder
                                             htmlextension
                                             space
                                             psortt
                                             slashseparatortouse
                                             pserv
                                             ppromess.

*         Free up any memory used for caching HTML versions of tables
          loop at idictionary.
            free memory id idictionary-tablename.
          endloop.

*         Display donwload report
          if not prep is initial.
            get time.
            runtime = sy-uzeit - starttime.
            perform filltreenodetables using idictionary[]
                                             itreedisplay[]
                                             runtime.
          endif.

          clear idictionary[].
        endif.

*     Download message class
      when rmess.
        if not ( imessages[] is initial ).
          sort imessages ascending by arbgb msgnr.
          loop at imessages.
            append imessages to isinglemessageclass.
            at end of arbgb.
              perform downloadmessageclass using isinglemessageclass[]
                                                 imessages-arbgb
                                                 downloadfolder
                                                 downloadfileextension
                                                 phtml
                                                 space
                                                 pcomm
                                                 customernamespace
                                                 pinc
                                                 pdict
                                                 pmess
                                                 slashseparatortouse
                                                 pserv
                                                 ppromess.
              clear isinglemessageclass[].
            endat.
          endloop.

*         Display download report
          if not prep is initial.
            get time.
            runtime = sy-uzeit - starttime.
            perform filltreenodemessages using imessages[]
                                               itreedisplay[]
                                               runtime.
          endif.

          clear imessages[].
        endif.

*     Download functions
      when rfunc.
        if not ( ifunctions[] is initial ).
          perform downloadfunctions using ifunctions[]
                                          downloadfolder
                                          downloadfileextension
                                          space
                                          pdoc
                                          phtml
                                          pcomm
                                          customernamespace
                                          pinc
                                          pdict
                                          textextension
                                          htmlextension
                                          psortt
                                          slashseparatortouse
                                          pserv
                                          ppromess.

*         Free up any memory used for caching HTML versions of tables
          loop at ifunctions.
            loop at ifunctions-idictstruct assigning <wadictstruct>.
              free memory id <wadictstruct>-tablename.
            endloop.
          endloop.

*         Display donwload report
          if not prep is initial.
            get time.
            runtime = sy-uzeit - starttime.
            perform filltreenodefunctions using ifunctions[]
                                                itreedisplay[]
                                                runtime.
          endif.

          clear ifunctions[].
        endif.

*     Download Classes
      when rclass.
        if not ( iclasses[] is initial ).
          perform downloadclasses using iclasses[]
                                        ifunctions[]
                                        downloadfolder
                                        downloadfileextension
                                        htmlextension
                                        textextension
                                        phtml
                                        pcomm
                                        customernamespace
                                        pinc
                                        pdict
                                        pdoc
                                        psortt
                                        slashseparatortouse
                                        pserv
                                        ppromess.

*         Free up any memory used for caching HTML versions of tables
          loop at ifunctions.
            loop at ifunctions-idictstruct assigning <wadictstruct>.
              free memory id <wadictstruct>-tablename.
            endloop.
          endloop.

*         Free up any memory used for caching HTML versions of tables
          loop at iprograms.
            loop at iprograms-idictstruct assigning <wadictstruct>.
              free memory id <wadictstruct>-tablename.
            endloop.
          endloop.

*         Display donwload report
          if not prep is initial.
            get time.
            runtime = sy-uzeit - starttime.
            perform filltreenodeclasses using iclasses[]
                                              ifunctions[]
                                              itreedisplay[]
                                              runtime.
          endif.

          clear iclasses[].
          clear ifunctions[].
        endif.

*     Download programs
      when rprog.
        if not ( iprograms[] is initial ).
          perform downloadprograms using iprograms[]
                                         ifunctions[]
                                         downloadfolder
                                         downloadfileextension
                                         htmlextension
                                         textextension
                                         phtml
                                         pcomm
                                         customernamespace
                                         pinc
                                         pdict
                                         pdoc
                                         psortt
                                         slashseparatortouse
                                         pserv
                                         ppromess.

*         Free up any memory used for caching HTML versions of tables
          loop at ifunctions.
            loop at ifunctions-idictstruct assigning <wadictstruct>.
              free memory id <wadictstruct>-tablename.
            endloop.
          endloop.

*         Free up any memory used for caching HTML versions of tables
          loop at iprograms.
            loop at iprograms-idictstruct assigning <wadictstruct>.
              free memory id <wadictstruct>-tablename.
            endloop.
          endloop.

*         Display donwload report
          if not prep is initial.
            get time.
            runtime = sy-uzeit - starttime.
            perform filltreenodeprograms using iprograms[]
                                               ifunctions[]
                                               itreedisplay[]
                                               runtime.
          endif.

          clear iprograms[].
          clear ifunctions[].
        endif.
    endcase.

    if not prep is initial.
      if not ( itreedisplay[] is initial ).
        perform displaytree using itreedisplay[].
      else.
        statusbarmessage = 'No items found matching selection criteria'.
        perform displaystatus using statusbarmessage 2.
      endif.
    endif.
  endif.

*--- Memory IDs
* User name
  set parameter id 'MAUTH' field pauth.
* Message class
  set parameter id 'MMNAME' field pmname.
* Customer namespace
  set parameter id 'MNAMESPACE' field pcname.
* Folder
  set parameter id 'MFOLDER' field pfolder.
* Logical filepath
  set parameter id 'MLOGICAL' field plogical.
* Package
  set parameter id 'MPACK' field ppack.
* Text element checkbox
  set parameter id 'MTEXT' field ptext.
* Messages checkbox
  set parameter id 'MMESS' field pmess.
* Includes checkbox
  set parameter id 'MINC' field pinc.
* Recursive includes checkbox.
  set parameter id 'MRECI' field preci.
* Functions checkbox
  set parameter id 'MFUNC' field pfunc.
* Recursive functions checkbox
  set parameter id 'MRECF' field precf.
* Function module documntation checkbox
  set parameter id 'MDOC' field pdoc.
* Screens checkbox
  set parameter id 'MSCR' field pscr.
* Dictionary checkbox
  set parameter id 'MDICT' field pdict.
* Sort table ascending checkBox
  set parameter id 'MSORTT' field psortt.

************************************************************************
***********************************************
***************************************************SUBROUTINES**********
***********************************************
************************************************************************
***********************************************

*-----------------------------------------------------------------------
*  checkComboBoxes...  Check input parameters
*-----------------------------------------------------------------------
form checkcomboboxes.

  if pauth is initial.
    case 'X'.
      when rtable.
        if sotable[] is initial.
          statusbarmessage = 'You must enter either a table name or author.'.
        endif.
      when rfunc.
        if ( sofname[] is initial ) and ( sofgroup[] is initial ).
          if sofname[] is initial.
            statusbarmessage = 'You must enter either a function name or author.'.
          else.
            if sofgroup[] is initial.
              statusbarmessage = 'You must enter either a function group, or an author name.'.
            endif.
          endif.
        endif.
      when rprog.
        if soprog[] is initial.
          statusbarmessage = 'You must enter either a program name or author name.'.
        endif.
    endcase.
  else.
*   Check the user name of the person objects are to be downloaded for
    if pauth = 'SAP*' or pauth = 'SAP'.
      statusbarmessage = 'Sorry cannot download all objects for SAP standard user'.
    endif.
  endif.

  if not statusbarmessage is initial.
    perform displaystatus using statusbarmessage 3.
    forcedexit = 1.
    stop.
  endif.
endform.                    "checkComboBoxes
"checkComboBoxes

*-----------------------------------------------------------------------
* fillSelectionRanges...      for selection routines
*-----------------------------------------------------------------------
form fillselectionranges.

  data: strlength type i.

  strlength = strlen( pcname ).

  if not pauth is initial.
    soauthor-sign = 'I'.
    soauthor-option = 'EQ'.
    soauthor-low = pauth.
    append soauthor.
  endif.

* Tables
  if not sotable is initial.
    sotablenames[] = sotable[].
*   Add in the customer namespace if we need to
    if not pcname is initial.
      loop at sotablenames.
        if sotablenames-low+0(strlength) <> pcname.
          concatenate pcname sotablenames-low into sotablenames-low.
        endif.

        if sotablenames-high+0(strlength) <> pcname.
          concatenate pcname sotablenames-high into sotablenames-high.
        endif.

        modify sotablenames.
      endloop.
    endif.
  endif.

* Function names
  if not sofname is initial.
    sofunctionname[] = sofname[].
*   Add in the customer namespace if we need to
    if not pcname is initial.
      loop at sofunctionname.
        if sofunctionname-low+0(strlength) <> pcname.
          concatenate pcname sofunctionname-low into sofunctionname-low.
        endif.

        if sofunctionname-high+0(strlength) <> pcname.
          concatenate pcname sofunctionname-high into
sofunctionname-high.
        endif.

        modify sofunctionname.
      endloop.
    endif.
  endif.

* Function group
  if not sofgroup is initial.
    sofunctiongroup[] = sofgroup[].
*   Add in the customer namespace if we need to
    if not pcname is initial.
      loop at sofunctionname.
        if sofunctiongroup-low+0(strlength) <> pcname.
          concatenate pcname sofunctiongroup-low into
sofunctiongroup-low.
        endif.

        if sofunctiongroup-high+0(strlength) <> pcname.
          concatenate pcname sofunctiongroup-high into
sofunctiongroup-high.
        endif.

        modify sofunctiongroup.
      endloop.
    endif.
  endif.

* Class names
  if not soclass is initial.
    soclassname[] = soclass[].
*   Add in the customer namespace if we need to
    if not pcname is initial.
      loop at soclassname.
        if soclassname-low+0(strlength) <> pcname.
          concatenate pcname soclassname-low into soclassname-low.
        endif.

        if soclassname-high+0(strlength) <> pcname.
          concatenate pcname soclassname-high into soclassname-high.
        endif.

        modify soclassname.
      endloop.
    endif.
  endif.

* Program names
  if not soprog is initial.
    soprogramname[] = soprog[].
*   Add in the customer namespace if we need to
    if not pcname is initial.
      loop at soprogramname.
        if soprogramname-low+0(strlength) <> pcname.
          concatenate pcname soprogramname-low into soprogramname-low.
        endif.

        if soprogramname-high+0(strlength) <> pcname.
          concatenate pcname soprogramname-high into soprogramname-high.
        endif.

        modify soprogramname.
      endloop.
    endif.
  endif.
endform.                    "fillSelectionRanges
" fillSelectionRanges

*-----------------------------------------------------------------------
*  retrieveTables...             Search for tables in dictionary
*-----------------------------------------------------------------------
form retrievetables using ilocdictstructure like idictionary[]
                          sotable like sotable[]
                          soauthor like soauthor[].

  data: wadictstructure type tdicttable.

  select tabname
         from dd02l
         into wadictstructure-tablename
         where tabname in sotable
           and tabclass <> 'CLUSTER'
           and tabclass <> 'POOL'
           and tabclass <> 'VIEW'
           and as4user in soauthor
           and as4local = 'A'.

    perform findtabledescription using wadictstructure-tablename
                                       wadictstructure-tabletitle.

    perform findtabledefinition using wadictstructure-tablename
                                      wadictstructure-istructure[].

    append wadictstructure to ilocdictstructure.
    clear wadictstructure.
  endselect.
endform.                    "retrieveTables
"retrieveTables

*-----------------------------------------------------------------------
*  findTableDescription...  Search for table description in dictionary
*-----------------------------------------------------------------------
form findtabledescription using value(tablename)
                                      tabledescription.

  select single ddtext
                from dd02t
                into tabledescription
                where tabname = tablename
                 and ddlanguage = sy-langu.
endform.                    "findTableDescription
"findTableDescription

*-----------------------------------------------------------------------
*  findTableDefinition... Find the structure of a table from the SAP
*  database.
*-----------------------------------------------------------------------
form findtabledefinition using value(tablename)
                               idictstruct like dumidictstructure[].

  data gotstate like dcobjif-gotstate.
  data: definition type standard table of dd03p with header line.
  data: wadictstruct type tdicttablestructure.

  call function 'DDIF_TABL_GET'
    exporting
      name          = tablename
      state         = 'A'
      langu         = sy-langu
    importing
      gotstate      = gotstate
    tables
      dd03p_tab     = definition
    exceptions
      illegal_input = 1
      others        = 2.

  if sy-subrc = 0 and gotstate = 'A'.
    loop at definition.
      move-corresponding definition to wadictstruct.
      perform removeleadingzeros changing wadictstruct-position.
      perform removeleadingzeros changing wadictstruct-leng.
      append wadictstruct to idictstruct.
    endloop.
  endif.
endform.                    "findTableDefinition
"findTableDefinition

*-----------------------------------------------------------------------
*  retrieveMessageClass...   Retrieve a message class from the SAP
*  database
*-----------------------------------------------------------------------
form retrievemessageclass using ilocmessages like imessages[]
                                rangeauthor like soauthor[]
                                value(messageclassname)
                                value(messageclasslang)
                                value(modifiedby).

  data: wamessage type tmessage.

  if not messageclassname is initial.
    select * from t100
             appending corresponding fields of table ilocmessages
             where sprsl = messageclasslang
               and arbgb = messageclassname.

    loop at ilocmessages into wamessage.
      select single stext
                    from t100a                         "#EC CI_BUFFJOIN
                    into wamessage-stext
                    where arbgb = wamessage-arbgb.
      modify ilocmessages from wamessage index sy-tabix.
    endloop.
  else.
    if modifiedby is initial.
*     Select by author
      select t100~arbgb                                "#EC CI_BUFFJOIN
             t100~msgnr
             t100~text
             t100a~stext
             appending corresponding fields of table ilocmessages
             from t100
             inner join t100a on t100a~arbgb = t100~arbgb
             where t100a~masterlang = messageclasslang
               and t100a~respuser in rangeauthor[].
    else.
*     Select also by the last person who modified the message class
      select t100~arbgb                                "#EC CI_BUFFJOIN
             t100~msgnr
             t100~text
             t100a~stext
             appending corresponding fields of table ilocmessages
             from t100
             inner join t100a on t100a~arbgb = t100~arbgb
             where t100a~masterlang = messageclasslang
               and t100a~respuser in rangeauthor[]
               and t100a~lastuser in rangeauthor[].
    endif.
  endif.
endform.                    "retrieveMessageClass
"retrieveMessageClass

*-----------------------------------------------------------------------
*  retrieveFunctions...   Retrieve function modules from SAP DB.  May be
*  called in one of two ways
*-----------------------------------------------------------------------
form retrievefunctions using sofname like sofunctionname[]
                             sofgroup like sofunctiongroup[]
                             ilocfunctionnames like ifunctions[]
                             value(solocauthor) like soauthor[]
                             value(gettextelements)
                             value(getscreens)
                             value(customeronly)
                             value(customernamerange).

  ranges: rangefuncname  for tfdir-funcname.
  ranges: rangefuncgroup for enlfdir-area.
  data: wafunctionname type tfunction.
  data: nogroupsfound type i value true.
  data: previousfg type v_fdir-area.

  rangefuncname[] = sofname[].
  rangefuncgroup[] = sofgroup[].

  if not solocauthor[] is initial.
*-- Need to select all function groups by author
    select area
           from tlibv
           into rangefuncgroup-low
           where uname in solocauthor
             and area in sofgroup[].

      rangefuncgroup-sign = 'I'.
      rangefuncgroup-option = 'EQ'.
      append rangefuncgroup.
      nogroupsfound = false.
    endselect.
  else.
    nogroupsfound = false.
  endif.

  if nogroupsfound = false.
*   select by function name and/or function group.
    select funcname area
                    from v_fdir
                    into (wafunctionname-functionname,
                          wafunctionname-functiongroup)
                    where funcname in rangefuncname
                      and area in rangefuncgroup
                      and generated = ''
                      order by area.

      append wafunctionname to ilocfunctionnames.
    endselect.
  endif.

  loop at ilocfunctionnames into wafunctionname.
    perform retrievefunctiondetail using wafunctionname-functionname
                                         wafunctionname-progname
                                         wafunctionname-includenumber
                                         wafunctionname-functiontitle.

    perform findmainfunctioninclude using wafunctionname-progname
                                          wafunctionname-includenumber

wafunctionname-functionmaininclude.

    perform findfunctiontopinclude using wafunctionname-progname
                                         wafunctionname-topincludename.

*   Find all user defined includes within the function group
    perform scanforfunctionincludes using wafunctionname-progname
                                          customeronly
                                          customernamerange
                                          wafunctionname-iincludes[].
*   Find main message class
    perform findmainmessageclass using wafunctionname-progname
                                       wafunctionname-messageclass.

*   Find any screens declared within the main include
    if not getscreens is initial.
      if previousfg is initial or previousfg <>
wafunctionname-functiongroup.
        perform findfunctionscreenflow using wafunctionname.

*       Search for any GUI texts
        perform retrieveguititles using wafunctionname-iguititle[]
                                        wafunctionname-progname.
      endif.
    endif.

    if not gettextelements is initial.
*     Find the program texts from out of the database.
      perform retrieveprogramtexts using
wafunctionname-iselectiontexts[]
                                         wafunctionname-itextelements[]
                                         wafunctionname-progname.
    endif.

    previousfg = wafunctionname-functiongroup.
    modify ilocfunctionnames from wafunctionname.
  endloop.
endform.                    "retrieveFunctions
"retrieveFunctions

*-----------------------------------------------------------------------
*  retrieveFunctionDetail...   Retrieve function module details from SAP
*  DB.
*-----------------------------------------------------------------------
form retrievefunctiondetail using value(functionname)
                                        progname
                                        includename
                                        titletext.

  select single pname
                include
                from tfdir
                into (progname, includename)
                where funcname = functionname.

  if sy-subrc = 0.
    select single stext
                  from tftit
                  into titletext
                  where spras = sy-langu
                    and funcname = functionname.
  endif.
endform.                    "retrieveFunctionDetail
"retrieveFunctionDetail

*-----------------------------------------------------------------------
*  findMainFunctionInclude...  Find the main include that contains the
*  source code
*-----------------------------------------------------------------------
form findmainfunctioninclude using value(programname)
                                   value(includeno)
                                         internalincludename.
  data: newincludenumber type string.

  concatenate '%U' includeno into newincludenumber.
  select single include
                from d010inc
                into internalincludename
                where master = programname
                  and include like newincludenumber.
endform.                    "findMainFunctionInclude
"findMainFunctionInclude

*-----------------------------------------------------------------------
*  findFunctionTopInclude...  Find the top include for the function
*  group
*-----------------------------------------------------------------------
form findfunctiontopinclude using value(programname)
                                        topincludename.

  select single include
                from d010inc
                into topincludename
                where master = programname
                  and include like '%TOP'.
endform.                    "findFunctionTopInclude
"findFunctionTopInclude

*-----------------------------------------------------------------------
* scanForAdditionalFuncStuff... Search for additional things relating to
* functions
*-----------------------------------------------------------------------
form scanforadditionalfuncstuff using ilocfunctions like ifunctions[]
                                      value(recursiveincludes)
                                      value(recursivefunctions)
                                      value(searchforincludes)
                                      value(searchforfunctions)
                                      value(searchfordictionary)
                                      value(searchformessages)
                                      value(customeronly)
                                      value(customernamerange).

  data: wafunction type tfunction.
  data: wainclude type tinclude.

  loop at ilocfunctions into wafunction.
    if not searchforincludes is initial.
*     Search in the main include
      perform scanforincludeprograms using
 wafunction-functionmaininclude
                                           recursiveincludes
                                           customeronly
                                           customernamerange
                                           wafunction-iincludes[].

*     Search in the top include
      perform scanforincludeprograms using wafunction-topincludename
                                           recursiveincludes
                                           customeronly
                                           customernamerange
                                           wafunction-iincludes[].
    endif.

    if not searchforfunctions is initial.
      perform scanforfunctions using wafunction-functionmaininclude
                                     wafunction-programlinkname
                                     recursiveincludes
                                     recursivefunctions
                                     customeronly
                                     customernamerange
                                     ilocfunctions[].
    endif.

    modify ilocfunctions from wafunction.
  endloop.

* Now we have everthing perhaps we had better find all the dictionary
* structures
  if not searchfordictionary is initial.
    loop at ilocfunctions into wafunction.
      perform scanfortables using wafunction-progname
                                  customeronly
                                  customernamerange
                                  wafunction-idictstruct[].

      perform scanforlikeortype using wafunction-progname
                                      customeronly
                                      customernamerange
                                      wafunction-idictstruct[].

      loop at wafunction-iincludes into wainclude.
        perform scanfortables using wainclude-includename
                                    customeronly
                                    customernamerange
                                    wafunction-idictstruct[].

        perform scanforlikeortype using wainclude-includename
                                        customeronly
                                        customernamerange
                                        wafunction-idictstruct[].
      endloop.

      modify ilocfunctions from wafunction.
    endloop.
  endif.

* Now search for all messages
  if not searchformessages is initial.
    loop at ilocfunctions into wafunction.
      perform scanformessages using wafunction-progname
                                    wafunction-messageclass
                                    wafunction-imessages[].
      modify ilocfunctions from wafunction.
    endloop.
  endif.
endform.                    "scanForAdditionalFuncStuff
"scanForAdditionalFuncStuff

*-----------------------------------------------------------------------
* scanForClasses... Search each class or method for other classes
*-----------------------------------------------------------------------
form scanforclasses using value(classname)
                          value(classlinkname)
                          value(customeronly)
                          value(customernamerange)
                                ilocclasses like iclasses[].

  data ilines type standard table of string with header line.
  data: head type string.
  data: tail type string.
  data: linelength type i value 0.
  data: waline type string.
  data: waclass type tclass.
  data: castclassname type program.
  data: exceptioncustomernamerange type string.

* Build the name of the possible cusotmer exception classes
  concatenate customernamerange 'CX_' into  exceptioncustomernamerange.

* Read the program code from the textpool.
  castclassname = classname.
  read report castclassname into ilines.

  loop at ilines into waline.
*   Find custom tables.
    linelength = strlen( waline ).
    if linelength > 0.
      if waline(1) = asterix.
        continue.
      endif.

      translate waline to upper case.

      find typerefto in waline ignoring case.
      if sy-subrc = 0.
*       Have found a reference to another class
        split waline at type into head tail.
        shift tail left deleting leading space.
        split tail at 'REF' into head tail.
        shift tail left deleting leading space.
        split tail at 'TO' into head tail.
        shift tail left deleting leading space.
        if tail cs period.
          split tail at period into head tail.
        else.
          if tail cs comma.
            split tail at comma into head tail.
          endif.
        endif.
      else.
*   Try and find classes which are only referenced through static mehods
        find '=>' in waline match offset sy-fdpos.
        if sy-subrc = 0.
          head = waline+0(sy-fdpos).
          shift head left deleting leading space.
          condense head.
          find 'call method' in head ignoring case.
          if sy-subrc = 0.
            shift head left deleting leading space.
            split head at space into head tail.
            split tail at space into head tail.
*           Should have the class name here
            head = tail.
          else.
*        Still have a class name even though it does not have the
*        words call method in front
            if waline cs '='.
              split waline at '=' into tail head.
              shift head left deleting leading space.
              split head at '=' into head tail.
            endif.
            sy-subrc = 0.
          endif.
        endif.
      endif.

      if sy-subrc = 0.
        try.
            if head+0(1) = 'Y' or head+0(1) = 'Z' or head cs
  customernamerange.
*           We have found a class best append it to our class table if
* we do not already have it.
              read table ilocclasses into waclass with key clsname = head.
              if sy-subrc <> 0.
                if head+0(3) = 'CX_'
                   or head+0(4) = 'ZCX_'
                   or head+0(4) = 'YCX_'
                   or head cs exceptioncustomernamerange.

                  waclass-exceptionclass = true.
                endif.

                waclass-clsname = head.
                append waclass to ilocclasses.
              endif.
            endif.
          catch cx_sy_range_out_of_bounds.
        endtry.
      endif.
    endif.
  endloop.
endform.                    "scanForClasses
"scanForClasses

*-----------------------------------------------------------------------
* scanForIncludePrograms... Search each program for include programs
*-----------------------------------------------------------------------
form scanforincludeprograms using value(programname)
                                  value(recursiveincludes)
                                  value(customeronly)
                                  value(customernamerange)
                                        ilocincludes like dumiincludes[]
.

  data: iincludelines type standard table of string with header line.
  data: itokens type standard table of stokes with header line.
  data: ikeywords type standard table of text20 with header line.
  data: istatements type standard table of sstmnt with header line.
  data: watokens type stokes.
  data: wainclude type tinclude.
  data: waincludeexists type tinclude.
  data: maxlines type i.
  data: nextline type i.
  data: castprogramname type program.

* Read the program code from the textpool.
  castprogramname = programname.
  read report castprogramname into iincludelines.

  append include to ikeywords.
  scan abap-source iincludelines tokens into itokens with includes statements into istatements keywords from ikeywords.

  clear iincludelines[].

  maxlines = lines( itokens ).
  loop at itokens where str = include and type = 'I'.
    nextline = sy-tabix + 1.
    if nextline <= maxlines.
      read table itokens index nextline into watokens.

*      Are we only to find customer includes?
      if not customeronly is initial.
        try.
            if watokens-str+0(1) = 'Y' or watokens-str+0(1) = 'Z'
               or watokens-str cs customernamerange
               or watokens-str+0(2) = 'MZ' or watokens-str+0(2) = 'MY'.

            else.
              continue.
            endif.
          catch cx_sy_range_out_of_bounds into objruntimeerror.
        endtry.
      endif.

      wainclude-includename = watokens-str.

*      Best find the program title text as well.
      perform findprogramorincludetitle using wainclude-includename
                                              wainclude-includetitle.

*      Don't append the include if we already have it listed
      read table ilocincludes into waincludeexists with key includename
= wainclude-includename.
      if sy-subrc <> 0.
        append wainclude to ilocincludes.

        if not recursiveincludes is initial.
*          Do a recursive search for other includes
          perform scanforincludeprograms using wainclude-includename
                                               recursiveincludes
                                               customeronly
                                               customernamerange
                                               ilocincludes[].
        endif.
      endif.
    endif.
  endloop.
endform.                    "scanForIncludePrograms
"scanForIncludePrograms

*-----------------------------------------------------------------------
* scanForFunctions... Search each program for function modules
*-----------------------------------------------------------------------
form scanforfunctions using value(programname)
                            value(programlinkname)
                            value(recursiveincludes)
                            value(recursivefunctions)
                            value(customeronly)
                            value(customernamerange)
                                  ilocfunctions like ifunctions[].

  data: iincludelines type standard table of string with header line.
  data: itokens type standard table of stokes with header line.
  data: istatements type standard table of sstmnt with header line.
  data: watokens type stokes.
  data: wafunction type tfunction.
  data: wafunctioncomparison type tfunction.
  data: maxlines type i.
  data: nextline type i.
  data: castprogramname type program.
  data: skipthisloop type i.

* Read the program code from the textpool.
  castprogramname = programname.
  read report castprogramname into iincludelines.
  scan abap-source iincludelines tokens into itokens with includes
statements into istatements.
  clear iincludelines[].

  maxlines = lines( itokens ).
  loop at itokens where str = function and type = 'I'.

    nextline = sy-tabix + 1.
    if nextline <= maxlines.
      read table itokens index nextline into watokens.

*      Are we only to find customer functions
      skipthisloop = false.
      if not customeronly is initial.
        try.
            if watokens-str+1(1) = 'Y' or watokens-str+1(1) = 'Z' or
 watokens-str cs customernamerange.
            else.
              skipthisloop = true.
            endif.
          catch cx_sy_range_out_of_bounds into objruntimeerror.
          cleanup.
            skipthisloop = true.
        endtry.
      endif.

      if skipthisloop = false.
        wafunction-functionname = watokens-str.
        replace all occurrences of '''' in wafunction-functionname with
' '.
        condense wafunction-functionname.

*        Don't add a function if we alread have it listed.
        read table ilocfunctions with key functionname =
wafunction-functionname into wafunctioncomparison.
        if sy-subrc <> 0.
*          Add in the link name if the function is linked to a program
          wafunction-programlinkname = programlinkname.

*          Don't download functions which are called through an RFC
* destination
          nextline = sy-tabix + 2.
          read table itokens index nextline into watokens.
          if watokens-str <> destination.

*            Find the function group
            select single area from v_fdir into
wafunction-functiongroup where funcname = wafunction-functionname.

            if sy-subrc = 0.
*              Best find the function number as well.
              perform retrievefunctiondetail using
wafunction-functionname
                                                   wafunction-progname

wafunction-includenumber

wafunction-functiontitle.

              perform findmainfunctioninclude using wafunction-progname

wafunction-includenumber

wafunction-functionmaininclude.

              perform findfunctiontopinclude using wafunction-progname

wafunction-topincludename.

*              Find main message class
              perform findmainmessageclass using wafunction-progname

wafunction-messageclass.

              append wafunction to ilocfunctions.

*              Now lets search a little bit deeper and do a recursive
* search for other includes
              if not recursiveincludes is initial.
                perform scanforincludeprograms using
wafunction-functionmaininclude
                                                     recursiveincludes
                                                     customeronly
                                                     customernamerange

wafunction-iincludes[].
              endif.

*              Now lets search a little bit deeper and do a recursive
* search for other functions
              if not recursivefunctions is initial.
                perform scanforfunctions using
wafunction-functionmaininclude
                                               space
                                               recursiveincludes
                                               recursivefunctions
                                               customeronly
                                               customernamerange
                                               ilocfunctions[].
              endif.
              clear wafunction.
            endif.
          endif.
        endif.

        clear wafunction.
      endif.
    endif.
  endloop.
endform.                    "scanForFunctions
"scanForFunctions

*-----------------------------------------------------------------------
*  scanForFunctionIncludes... Find all user defined includes within the
*  function group
*-----------------------------------------------------------------------
form scanforfunctionincludes using poolname
                                   value(customeronly)
                                   value(customernamerange)
                                   ilocincludes like dumiincludes[].

  data: iincludelines type standard table of string with header line.
  data: itokens type standard table of stokes with header line.
  data: ikeywords type standard table of text20 with header line.
  data: istatements type standard table of sstmnt with header line.
  data: watokens type stokes.
  data: wainclude type tinclude.
  data: waincludeexists type tinclude.
  data: maxlines type i.
  data: nextline type i.
  data: castprogramname type program.

* Read the program code from the textpool.
  castprogramname = poolname.
  read report castprogramname into iincludelines.

  append include to ikeywords.
  scan abap-source iincludelines tokens into itokens with includes
statements into istatements keywords from ikeywords.

  clear iincludelines[].

  maxlines = lines( itokens ).
  loop at itokens where str = include and type = 'I'.
    nextline = sy-tabix + 1.
    if nextline <= maxlines.
      read table itokens index nextline into watokens.

      if watokens-str cp '*F++'.
*        Are we only to find customer includes?
        if not customeronly is initial.
          try.
              if watokens-str+0(2) = 'LY' or watokens-str+0(2) = 'LZ' or
 watokens-str cs customernamerange.
              else.
                continue.
              endif.
            catch cx_sy_range_out_of_bounds into objruntimeerror.
          endtry.
        endif.

        wainclude-includename = watokens-str.

*        Best find the program title text as well.
        perform findprogramorincludetitle using wainclude-includename
                                                wainclude-includetitle.

*        Don't append the include if we already have it listed
        read table ilocincludes into waincludeexists with key
includename = wainclude-includename.
        if sy-subrc <> 0.
          append wainclude to ilocincludes.
        endif.
      endif.
    endif.
  endloop.
endform.                    "scanForFunctionIncludes
"scanForFunctionIncludes

*-----------------------------------------------------------------------
*  findProgramOrIncludeTitle...   Finds the title text of a program.
*-----------------------------------------------------------------------
form findprogramorincludetitle using value(programname)
                                           titletext.

  select single text
                from trdirt
                into titletext
                where name = programname
                  and sprsl = sy-langu.
endform.                    "findProgramOrIncludeTitle
"findProgramOrIncludeTitle

*-----------------------------------------------------------------------
* retrievePrograms...    find programs and sub objects from SAP DB
*-----------------------------------------------------------------------
form retrieveprograms using ilocprogram like iprograms[]
                            ilocfunctions like ifunctions[]
                            rangeprogram like soprogramname[]
                            rangeauthor like soauthor[]
                            value(custnamerange)
                            value(alsomodifiedbyauthor)
                            value(customerprogsonly)
                            value(getmessages)
                            value(gettextelements)
                            value(getcustdictstructures)
                            value(getfunctions)
                            value(getincludes)
                            value(getscreens)
                            value(recursivefuncsearch)
                            value(recursiveincludesearch)
                            value(getlocalobjects)
                            value(package).

  data: warangeprogram like line of rangeprogram.

  if rangeprogram[] is initial.
*   We are finding all programs by an author
    perform findallprogramsforauthor using ilocprogram[]
                                           rangeprogram[]
                                           rangeauthor[]
                                           custnamerange
                                           alsomodifiedbyauthor
                                           customerprogsonly
                                           getlocalobjects
                                           package.
  else.
    read table rangeprogram index 1 into warangeprogram.
    if warangeprogram-low cs asterix.
      perform findprogramsbywildcard using ilocprogram[]
                                           rangeprogram[]
                                           rangeauthor[]
                                           custnamerange
                                           customerprogsonly
                                           getlocalobjects
                                           package.
    else.
      perform checkprogramdoesexist using ilocprogram[]
                                          rangeprogram[].
    endif.
  endif.

* Find extra items
  perform scanforadditionalprogstuff using ilocprogram[]
                                           ilocfunctions[]
                                           gettextelements
                                           getmessages
                                           getscreens
                                           getcustdictstructures
                                           getfunctions
                                           getincludes
                                           customerprogsonly
                                           custnamerange
                                           recursiveincludesearch
                                           recursivefuncsearch.
endform.                    "retrievePrograms
"retrievePrograms

*-----------------------------------------------------------------------
*  scanForAdditionalProgStuff...
*-----------------------------------------------------------------------
form scanforadditionalprogstuff using ilocprogram like iprograms[]
                                      ilocfunctions like ifunctions[]
                                      value(gettextelements)
                                      value(getmessages)
                                      value(getscreens)
                                      value(getcustdictstructures)
                                      value(getfunctions)
                                      value(getincludes)
                                      value(customeronly)
                                      value(customernamerange)
                                      value(recursiveincludesearch)
                                      value(recursivefuncsearch).

  data: waprogram type tprogram.
  data: wainclude type tinclude.
  data: mytabix type sytabix.

* Best to find all the includes used in a program first
  if not getincludes is initial.
    loop at ilocprogram into waprogram.
      mytabix = sy-tabix.
      perform scanforincludeprograms using waprogram-progname
                                           recursiveincludesearch
                                           customeronly
                                           customernamerange
                                           waprogram-iincludes[].

      modify ilocprogram from waprogram index mytabix.
    endloop.
  endif.

* Once we have a list of all the includes we need to loop round them an
* select all the other objects
  loop at ilocprogram into waprogram.
    mytabix = sy-tabix.
    perform findprogramdetails using waprogram-progname
                                     waprogram-subc
                                     waprogram-programtitle
                                     waprogram
                                     gettextelements
                                     getmessages
                                     getscreens
                                     getcustdictstructures
                                     customeronly
                                     customernamerange.

*   Find any screens
    if not getscreens is initial.
      perform findprogramscreenflow using waprogram.
    endif.

    loop at waprogram-iincludes into wainclude.
      perform findprogramdetails using wainclude-includename
                                       'I'
                                       wainclude-includetitle
                                       waprogram
                                       gettextelements
                                       getmessages
                                       getscreens
                                       getcustdictstructures
                                       customeronly
                                       customernamerange.
    endloop.

    modify ilocprogram from waprogram index mytabix.
  endloop.

* Now we have all the program includes and details we need to find extra
* functions
  if not getfunctions is initial.
    loop at ilocprogram into waprogram.
*     Find any functions defined in the code
      perform scanforfunctions using waprogram-progname
                                     waprogram-progname
                                     space
                                     space
                                     customeronly
                                     customernamerange
                                     ilocfunctions[].
    endloop.
  endif.

* We have a list of all the functions so lets go and find details and
* other function calls
  perform scanforadditionalfuncstuff using ilocfunctions[]
                                           recursiveincludesearch
                                           recursivefuncsearch
                                           getincludes
                                           getfunctions
                                           getcustdictstructures
                                           getmessages
                                           customeronly
                                           customernamerange.
endform.                    "scanForAdditionalProgStuff
"scanForAdditionalProgStuff

*-----------------------------------------------------------------------
*  findProgramDetails...
*-----------------------------------------------------------------------
form findprogramdetails using value(programname)
                              value(programtype)
                                    programtitle
                                    waprogram type tprogram
                              value(gettextelements)
                              value(getmessages)
                              value(getscreens)
                              value(getcustdictstructures)
                              value(customeronly)
                              value(customernamerange).

  perform findprogramorincludetitle using programname
                                          programtitle.

  if not gettextelements is initial.
*   Find the program texts from out of the database.
    perform retrieveprogramtexts using waprogram-iselectiontexts[]
                                       waprogram-itextelements[]
                                       programname.
  endif.

* Search for any GUI texts
  if not getscreens is initial and ( programtype = 'M' or programtype =
'1' ).
    perform retrieveguititles using waprogram-iguititle[]
                                    programname.
  endif.

* Find individual messages
  if not getmessages is initial.
    if programtype = 'M' or programtype = '1'.
      perform findmainmessageclass using programname
                                         waprogram-messageclass.
    endif.

    perform scanformessages using programname
                                  waprogram-messageclass
                                  waprogram-imessages[].
  endif.

  if not getcustdictstructures is initial.
    perform scanfortables using programname
                                customeronly
                                customernamerange
                                waprogram-idictstruct[].

    perform scanforlikeortype using programname
                                    customeronly
                                    customernamerange
                                    waprogram-idictstruct[].
  endif.
endform.                    "findProgramDetails
"findProgramDetails

*-----------------------------------------------------------------------
*  findAllProgramsForAuthor...
*-----------------------------------------------------------------------
form findallprogramsforauthor using ilocprogram like iprograms[]
                                    rangeprogram like soprogramname[]
                                    rangeauthor like soauthor[]
                                    value(custnamerange)
                                    value(alsomodifiedbyauthor)
                                    value(customerprogsonly)
                                    value(getlocalobjects)
                                    value(package).

  data: altcustomernamerange type string.
  field-symbols: <waprogram> type tprogram.
  data: genflag type genflag.

* build up the customer name range used for select statements
  concatenate custnamerange '%' into altcustomernamerange.

* select by name and author
  if not alsomodifiedbyauthor is initial.
*   Programs modified by author
*   Program to search for is an executable program
    if customerprogsonly is initial.
*     Select all programs
      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname in rangeprogram
               and cnam in rangeauthor
               and ( subc = '1' or subc = 'M' or subc = 'S' ).

    else.
*     Select only customer specific programs
      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname  in rangeprogram
               and ( progname like altcustomernamerange
                     or progname like 'Z%'
                     or progname like 'Y%'
                     or progname like 'SAPMZ%'
                     or progname like 'SAPMY%')
               and cnam in rangeauthor
               and ( subc = '1' or subc = 'M' or subc = 'S' ).
    endif.
  else.

*   Programs created by author
    if customerprogsonly is initial.
*     Select all programs
      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname in rangeprogram
               and ( subc = '1' or subc = 'M' or subc = 'S' )
               and ( cnam in rangeauthor or unam in rangeauthor ).
    else.
*     Select only customer specific programs
      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname in rangeprogram
               and ( progname like altcustomernamerange
                     or progname like 'Z%'
                     or progname like 'Y%'
                     or progname like 'SAPMZ%'
                     or progname like 'SAPMY%')
               and ( subc = '1' or subc = 'M' or subc = 'S' )
               and ( cnam in rangeauthor or unam in rangeauthor ).
    endif.
  endif.

* Delete any programs which are local objects
  if getlocalobjects is initial.
    loop at ilocprogram assigning <waprogram>.
      select single genflag
                    from tadiv
                    into genflag
                    where pgmid = 'R3TR'
                      and object = 'PROG'
                      and obj_name = <waprogram>-progname
                      and devclass = '$TMP'.
      if sy-subrc = 0.
        delete ilocprogram.
      endif.
    endloop.
  endif.

* Delete any programs which are not in the specified package
  if not package is initial.
    if package cs '*'.
      translate package using '*%'.
    endif.

    loop at ilocprogram assigning <waprogram>.
      select single genflag
                    from tadiv
                    into genflag
                    where pgmid = 'R3TR'
                      and object = 'PROG'
                      and obj_name = <waprogram>-progname
                      and devclass like package.
      if sy-subrc <> 0.
        delete ilocprogram.
      endif.
    endloop.
  endif.
endform.                    "findAllProgramsForAuthor
"findAllProgramsForAuthor

*-----------------------------------------------------------------------
*  checkProgramDoesExist...
*-----------------------------------------------------------------------
form checkprogramdoesexist using ilocprogram like iprograms[]
                                 rangeprogram like soprogramname[].

  data: waprogram type tprogram.

*  Check to see if the program is an executable program
  select single progname
                subc
                into (waprogram-progname, waprogram-subc)
                from reposrc
                where progname in rangeprogram
                  and ( subc = '1' or
                        subc = 'I' or
                        subc = 'M' or
                        subc = 'S' ).

  if not waprogram-progname is initial.
    append waprogram to ilocprogram.
  endif.
endform.                    "checkProgramDoesExist
"checkProgramDoesExist

*-----------------------------------------------------------------------
*  findProgramsByWildcard.. Search in the system for programs
*-----------------------------------------------------------------------
form findprogramsbywildcard using ilocprogram like iprograms[]
                                  value(rangeprogram) like
soprogramname[]
                                  value(rangeauthor) like soauthor[]
                                  value(custnamerange)
                                  value(customerprogsonly)
                                  value(getlocalobjects)
                                  value(package).

  data: altcustomernamerange type string.
  field-symbols: <waprogram> type tprogram.
  data: genflag type genflag.

  if customerprogsonly is initial.
*   build up the customer name range used for select statements
    if custnamerange <> '^'.
      concatenate custnamerange '%' into altcustomernamerange.

      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname  in rangeprogram
               and progname like altcustomernamerange
               and ( subc = '1' or subc = 'M' or subc = 'S' )
               and ( cnam in rangeauthor or unam in rangeauthor ).
    else.
      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname  in rangeprogram
               and ( subc = '1' or subc = 'M' or subc = 'S' )
               and ( cnam in rangeauthor or unam in rangeauthor ).
    endif.
  else.
*   Only customer programs
    if custnamerange <> '^'.
      concatenate custnamerange '%' into altcustomernamerange.

      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname  in rangeprogram
               and ( progname like altcustomernamerange
                     or progname like 'Z%'
                     or progname like 'Y%'
                     or progname like 'SAPMZ%'
                     or progname like 'SAPMY%')
               and ( subc = '1' or subc = 'M' or subc = 'S' )
               and ( cnam in rangeauthor or unam in rangeauthor ).
    else.
      select progname
             subc
             from reposrc
             appending corresponding fields of table ilocprogram
             where progname  in rangeprogram
             and ( progname like 'Z%'
                   or progname like 'Y%'
                   or progname like 'SAPMZ%'
                   or progname like 'SAPMY%')
             and ( subc = '1' or subc = 'M' or subc = 'S' )
             and ( cnam in rangeauthor or unam in rangeauthor ).
    endif.
  endif.

* Delete any programs which are local objects
  if getlocalobjects is initial.
    loop at ilocprogram assigning <waprogram>.
      select single genflag
                    from tadiv
                    into genflag
                    where pgmid = 'R3TR'
                      and object = 'PROG'
                      and obj_name = <waprogram>-progname
                      and devclass = '$TMP'.
      if sy-subrc = 0.
        delete ilocprogram.
      endif.
    endloop.
  endif.

* Delete any programs which are not in the specified package
  if not package is initial.
    loop at ilocprogram assigning <waprogram>.
      select single genflag
                    from tadiv
                    into genflag
                    where pgmid = 'R3TR'
                      and object = 'PROG'
                      and obj_name = <waprogram>-progname
                      and devclass <> package.
      if sy-subrc = 0.
        delete ilocprogram.
      endif.
    endloop.
  endif.
endform.                    "findProgramsByWildcard
"findProgramsByWildcard

*-----------------------------------------------------------------------
*  retrieveProgramTexts... Find the text elements and selection texts
*  for a program
*-----------------------------------------------------------------------
form retrieveprogramtexts using ilocselectiontexts like dumitexttab[]
                                iloctextelements like dumitexttab[]
                                value(programname).

  data: itexttable type standard table of ttexttable with header line.
  data: watexts type ttexttable.
  data: castprogramname(50).

  move programname to castprogramname.

  read textpool castprogramname into itexttable language sy-langu.
  delete itexttable where key = 'R'.

* Selection texts.
  loop at itexttable where id = 'S'.
    move itexttable-key to watexts-key.
    move itexttable-entry to watexts-entry.
    append watexts to ilocselectiontexts.
    clear watexts.
  endloop.

* Text elements.
  delete itexttable where key = 'S'.
  loop at itexttable where id = 'I'.
    move itexttable-key to watexts-key.
    move itexttable-entry to watexts-entry.
    append watexts to iloctextelements.
  endloop.
endform.                    "retrieveProgramTexts
"retrieveProgramTexts

*-----------------------------------------------------------------------
*  retrieveGUITitles...  Search for any GUI texts
*-----------------------------------------------------------------------
form retrieveguititles using ilocguititle like dumiguititle[]
                             value(programname).

  select obj_code
         text
         from d347t
         appending corresponding fields of table ilocguititle
         where progname = programname.
endform.                    "retrieveGUITitles
"retrieveGUITitles

*-----------------------------------------------------------------------
*   findMainMessageClass... find the message class stated at the top of
*   program.
*-----------------------------------------------------------------------
form findmainmessageclass using value(programname)
                                      messageclass.

  select single msgid
                from trdire into messageclass
                where report = programname.
endform.                    "findMainMessageClass
"findMainMessageClass

*-----------------------------------------------------------------------
* retrieveClasses...    find classes and sub objects from SAP DB
*-----------------------------------------------------------------------
form retrieveclasses using ilocclasses like iclasses[]
                           ilocfunctions like ifunctions[]
                           rangeclass like soclassname[]
                           rangeauthor like soauthor[]
                           value(custnamerange)
                           value(alsomodifiedbyauthor)
                           value(customerprogsonly)
                           value(getmessages)
                           value(gettextelements)
                           value(getcustdictstructures)
                           value(getfunctions)
                           value(getincludes)
                           value(recursivefuncsearch)
                           value(recursiveincludesearch)
                           value(recursiveclasssearch)
                           value(language).

  data: warangeclass like line of rangeclass.

  if rangeclass[] is initial.
*   We are finding all programs by an author
    perform findallclassesforauthor using ilocclasses[]
                                           rangeclass[]
                                           rangeauthor[]
                                           custnamerange
                                           alsomodifiedbyauthor
                                           customerprogsonly
                                           language.
  else.
    read table rangeclass index 1 into warangeclass.
    if warangeclass-low cs asterix.
      perform findclassesbywildcard using ilocclasses[]
                                          rangeclass[]
                                          rangeauthor[]
                                          custnamerange
                                          customerprogsonly
                                          language.
    else.
      perform checkclassdoesexist using ilocclasses[]
                                        rangeclass[].
    endif.
  endif.

* Find extra items
  if not ilocclasses[] is initial.
    perform scanforadditionalclassstuff using ilocclasses[]
                                              ilocfunctions[]
                                              gettextelements
                                              getmessages
                                              getcustdictstructures
                                              getfunctions
                                              getincludes
                                              customerprogsonly
                                              custnamerange
                                              recursiveincludesearch
                                              recursivefuncsearch
                                              recursiveclasssearch.
  endif.
endform.                    "retrieveClasses
"retrieveClasses

*-----------------------------------------------------------------------
*  findAllClassesForAuthor...
*-----------------------------------------------------------------------
form findallclassesforauthor using ilocclass like iclasses[]
                                   rangeclass like soclassname[]
                                   rangeauthor like soauthor[]
                                   value(custnamerange)
                                   value(alsomodifiedbyauthor)
                                   value(customerclassesonly)
                                   value(language).

  data: altcustomernamerange(2).

* build up the customer name range used for select statements
  concatenate custnamerange '%' into altcustomernamerange.

* select by name and author
  if not alsomodifiedbyauthor is initial.
*   Classes modified by author
    if customerclassesonly is initial.
*     Select all classes
      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and langu = language
               and ( author in rangeauthor or changedby in rangeauthor )
               and version = '1'
               and ( state = '0' or state = '1' ).

      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
               and langu = language
                 and ( author in rangeauthor or changedby in rangeauthor
 )
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    else.
*     Select only customer specific classes
      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and ( clsname like altcustomernamerange
                     or clsname like 'Z%'
                     or clsname like 'Y%')
               and langu = language
               and ( author in rangeauthor or changedby in rangeauthor )
               and version = '1'
               and ( state = '0' or state = '1' ).

      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and ( clsname like altcustomernamerange
                       or clsname like 'Z%'
                       or clsname like 'Y%')
                 and langu = language
                 and ( author in rangeauthor or changedby in rangeauthor
 )
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    endif.
  else.
*   Programs created by author
    if customerclassesonly is initial.
*     Select all classes
      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and langu = language
               and author in rangeauthor
               and version = '1'
               and ( state = '0' or state = '1' ).

      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and langu = language
                 and author in rangeauthor
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    else.
*     Select only customer specific classes
      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and ( clsname like altcustomernamerange
                     or clsname like 'Z%'
                     or clsname like 'Y%')
               and langu = language
               and author in rangeauthor
               and version = '1'
               and ( state = '0' or state = '1' ).

      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and ( clsname like altcustomernamerange
                       or clsname like 'Z%'
                       or clsname like 'Y%')
                 and langu = language
                 and author in rangeauthor
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    endif.
  endif.
endform.                    "findAllClassesForAuthor
"findAllClassesForAuthor

*-----------------------------------------------------------------------
*  findClassesByWildcard...  Find classes using a wildcard search
*-----------------------------------------------------------------------
form findclassesbywildcard using ilocclass like iclasses[]
                                 rangeclass like soclassname[]
                                 value(rangeauthor) like soauthor[]
                                 value(custnamerange)
                                 value(customerclassesonly)
                                 value(language).

  data: altcustomernamerange(2).

  if customerclassesonly is initial.
*   Searching for customer and SAP classes
    if custnamerange <> '^'.
*     build up the customer name range used for select statements
      concatenate custnamerange '%' into altcustomernamerange.

      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and clsname like custnamerange
               and langu = language
               and ( author in rangeauthor or changedby in rangeauthor )
               and version = '1'
               and ( state = '0' or state = '1' ).
      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and clsname like custnamerange
                 and langu = language
                 and ( author in rangeauthor or changedby in rangeauthor
 )
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    else.
*     Searching using normal name ranges
      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and langu = language
               and ( author in rangeauthor or changedby in rangeauthor )
               and version = '1'
               and ( state = '0' or state = '1' ).
      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and langu = language
                 and ( author in rangeauthor or changedby in rangeauthor
 )
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    endif.
  else.
*   searching for only customer classes
    if custnamerange <> '^'.
*     build up the customer name range used for select statements
      concatenate custnamerange '%' into altcustomernamerange.

      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and clsname like custnamerange
               and langu = language
               and ( clsname like 'ZC%' or clsname like 'YC%' )
               and ( author in rangeauthor or changedby in rangeauthor )
               and version = '1'
               and ( state = '0' or state = '1' ).
      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and langu = language
                 and ( clsname like 'ZC%' or clsname like 'YC%' )
                 and ( author in rangeauthor or changedby in rangeauthor
 )
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    else.
*     Searching using normal name ranges
      select clsname descript msg_id
             from vseoclass
             appending corresponding fields of table ilocclass
             where clsname in rangeclass
               and ( clsname like 'ZC%' or clsname like 'YC%' )
               and ( author in rangeauthor or changedby in rangeauthor )
               and version = '1'
               and ( state = '0' or state = '1' ).
      if sy-subrc <> 0.
        select clsname descript msg_id
               from vseoclass
               appending corresponding fields of table ilocclass
               where clsname in rangeclass
                 and ( clsname like 'ZC%' or clsname like 'YC%' )
                 and ( author in rangeauthor or changedby in rangeauthor
 )
                 and version = '0'
                 and ( state = '0' or state = '1' ).
      endif.
    endif.
  endif.
endform.                    "findClassesByWildcard
"findClassesByWildcard

*-----------------------------------------------------------------------
*  checkClassDoesExist...
*-----------------------------------------------------------------------
form checkclassdoesexist using ilocclass like iclasses[]
                               rangeclass like soclassname[].

  data: waclass type tclass.

  select single clsname descript msg_id
         from vseoclass
         into corresponding fields of waclass
         where clsname in rangeclass
           and version = '1'
           and ( state = '0' or state = '1' ).

  if sy-subrc <> 0.
    select single clsname descript msg_id
         from vseoclass
         into corresponding fields of waclass
         where clsname in rangeclass
           and version = '0'
           and ( state = '0' or state = '1' ).
  endif.

  if not waclass-clsname is initial.
    append waclass to ilocclass.
  endif.
endform.                    "checkClassDoesExist
"checkClassDoesExist

*-----------------------------------------------------------------------
*  scanForAdditionalClassStuff...
*-----------------------------------------------------------------------
form scanforadditionalclassstuff using ilocclasses like iclasses[]
                                       ilocfunctions like ifunctions[]
                                       value(gettextelements)
                                       value(getmessages)
                                       value(getcustdictstructures)
                                       value(getfunctions)
                                       value(getincludes)
                                       value(customeronly)
                                       value(customernamerange)
                                       value(recursiveincludesearch)
                                       value(recursivefuncsearch)
                                       value(recursiveclasssearch).

  data: waclass type tclass.
  data: wamethod type tmethod.
  data: mytabix type sytabix.
  data: scanningforclasses type i value false.
  data: classnewlines type i value 0.
  data: classcurrentlines type i value 0.

  loop at ilocclasses into waclass where scanned is initial.
*  Once we have a list of all the classes we need to loop round them an
*  select all the other objects
    mytabix = sy-tabix.
    perform findclassdetails using waclass-clsname
                                   waclass
                                   ilocfunctions[]
                                   gettextelements
                                   getmessages
                                   getfunctions
                                   getcustdictstructures
                                   customeronly
                                   customernamerange.

*   Set the scanned class so we do not check them again when running
*   recursively.
    waclass-scanned = 'X'.
    modify ilocclasses from waclass index mytabix.
  endloop.

* Now we have all the classes and details we need to find extra classes
  if not recursiveclasssearch is initial.
    classcurrentlines = lines( ilocclasses ).
    loop at ilocclasses into waclass.
*     Don't try and find any other details for an exception class
      if ( waclass-clsname ns 'ZCX_' or waclass-clsname ns 'CX_'  ).
*       Find any classes defined in the main class definition
        perform scanforclasses using waclass-privateclasskey
                                     waclass-clsname
                                     customeronly
                                     customernamerange
                                     ilocclasses[].

        perform scanforclasses using waclass-publicclasskey
                                     waclass-clsname
                                     customeronly
                                     customernamerange
                                     ilocclasses[].

        perform scanforclasses using waclass-protectedclasskey
                                     waclass-clsname
                                     customeronly
                                     customernamerange
                                     ilocclasses[].

        loop at waclass-imethods into wamethod.
*         Find any classes defined in any of the methods
          perform scanforclasses using wamethod-methodkey
                                       waclass-clsname
                                       customeronly
                                       customernamerange
                                       ilocclasses[].
        endloop.
      endif.
    endloop.

*   We have a list of all the classes so lets go and find their details
    classnewlines = lines( ilocclasses ).
    if classnewlines > classcurrentlines.
      perform scanforadditionalclassstuff using ilocclasses[]
                                                ilocfunctions[]
                                                gettextelements
                                                getmessages
                                                getcustdictstructures
                                                getfunctions
                                                getincludes
                                                customeronly
                                                customernamerange
                                                recursiveincludesearch
                                                recursivefuncsearch
                                                recursiveclasssearch.
    endif.
  endif.
endform.                    "scanForAdditionalClassStuff
"scanForAdditionalClassStuff

*-----------------------------------------------------------------------
*  findClassDetails...
*-----------------------------------------------------------------------
form findclassdetails using value(classname)
                                  waclass type tclass
                              ilocfunctions like ifunctions[]
                              value(gettextelements)
                              value(getmessages)
                              value(getfunctions)
                              value(getcustdictstructures)
                              value(customeronly)
                              value(customernamerange).

  data: iemptyselectiontexts type standard table of ttexttable.
  data: mytabix type sytabix.
  data: wamethod type tmethod.

* Build up the keys we will use for finding data
  perform buildclasskeys using waclass.

  if waclass-descript is initial.
    perform findclassdescription using classname
                                       waclass-descript.
  endif.

* Find the class attributes.
  select single exposure msg_id state clsfinal r3release
                from vseoclass
                into (waclass-exposure, waclass-msg_id, waclass-state,
                      waclass-clsfinal, waclass-r3release)
                where clsname = waclass-clsname.

* Don't try and find any other details for an exception class
  if ( waclass-clsname cs 'ZCX_' or waclass-clsname cs 'CX_'  ).
*   Exception texts
    perform findexceptiontexts using waclass-publicclasskey
                                     waclass-iconcepts[].
    waclass-scanned = 'X'.
  else.
    if not gettextelements is initial.
*     Find the class texts from out of the database.
      perform retrieveprogramtexts using iemptyselectiontexts[]
                                         waclass-itextelements[]
                                         waclass-textelementkey.
    endif.

*   Find any declared dictionary structures
    if not getcustdictstructures is initial.
      perform scanfortables using waclass-privateclasskey
                                  customeronly
                                  customernamerange
                                  waclass-idictstruct[].

      perform scanfortables using waclass-publicclasskey
                                  customeronly
                                  customernamerange
                                  waclass-idictstruct[].

      perform scanfortables using waclass-protectedclasskey
                                  customeronly
                                  customernamerange
                                  waclass-idictstruct[].

      perform scanfortables using waclass-typesclasskey
                                  customeronly
                                  customernamerange
                                  waclass-idictstruct[].

      perform scanforlikeortype using waclass-privateclasskey
                                      customeronly
                                      customernamerange
                                      waclass-idictstruct[].

      perform scanforlikeortype using waclass-publicclasskey
                                      customeronly
                                      customernamerange
                                      waclass-idictstruct[].

      perform scanforlikeortype using waclass-protectedclasskey
                                      customeronly
                                      customernamerange
                                      waclass-idictstruct[].

      perform scanforlikeortype using waclass-typesclasskey
                                      customeronly
                                      customernamerange
                                      waclass-idictstruct[].
    endif.


*   Methods
*   Find all the methods for this class
    perform findclassmethods using classname
                                   waclass-imethods[].

    loop at waclass-imethods[] into wamethod.
      mytabix = sy-tabix.
*     Find individual messages
      if not getmessages is initial.
        perform scanformessages using wamethod-methodkey
                                      waclass-msg_id
                                      waclass-imessages[].
      endif.

      if not getcustdictstructures is initial.
*       Find any declared dictionary structures
        perform scanfortables using wamethod-methodkey
                                    customeronly
                                    customernamerange
                                    waclass-idictstruct[].

        perform scanforlikeortype using wamethod-methodkey
                                        customeronly
                                        customernamerange
                                        waclass-idictstruct[].
      endif.

      if not getfunctions is initial.
        perform scanforfunctions using wamethod-methodkey
                                       waclass-clsname
                                       space
                                       space
                                       customeronly
                                       customernamerange
                                       ilocfunctions[].
      endif.

      modify waclass-imethods from wamethod index mytabix.
    endloop.
  endif.
endform.                    "findClassDetails
"findClassDetails

*-----------------------------------------------------------------------
*  buildClassKeys...   Finds the title text of a class.
*-----------------------------------------------------------------------
form buildclasskeys using waclass type tclass.

  data: classnamelength type i.
  data: loops type i.

  classnamelength = strlen( waclass-clsname ).

  cl_oo_classname_service=>get_pubsec_name( exporting clsname =
waclass-clsname
                                            receiving result =
waclass-publicclasskey ).

  cl_oo_classname_service=>get_prisec_name( exporting clsname =
waclass-clsname
                                            receiving result =
waclass-privateclasskey ).

  cl_oo_classname_service=>get_prosec_name( exporting clsname =
waclass-clsname
                                            receiving result =
waclass-protectedclasskey ).


* Text element key - length of text element key has to be 32 characters.
  loops = 30 - classnamelength.
  waclass-textelementkey = waclass-clsname.
  do loops times.
    concatenate waclass-textelementkey '=' into waclass-textelementkey.
  enddo.
* Save this for later.
  concatenate waclass-textelementkey 'CP' into waclass-textelementkey.

* Types Class key - length of class name has to be 32 characters.
  loops = 30 - classnamelength.
  waclass-typesclasskey = waclass-clsname.
  do loops times.
    concatenate waclass-typesclasskey '=' into waclass-typesclasskey.
  enddo.
* Save this for later
  concatenate waclass-typesclasskey 'CT' into waclass-typesclasskey.
endform.                    "buildClassKeys
"buildClassKeys

*-----------------------------------------------------------------------
*  findClassDescription...   Finds the title text of a class.
*-----------------------------------------------------------------------
form findclassdescription using value(classname)
                                      titletext.

  select single descript
                from vseoclass
                into titletext
                where clsname = classname
                  and langu = sy-langu.
  if sy-subrc <> 0.
    select single descript
                  from vseoclass
                  into titletext
                  where clsname = classname.
  endif.
endform.                    "findClassDescription
"findClassDescription

*-----------------------------------------------------------------------
*  findExceptionTexts...   Fiond the texts of an exception class.
*-----------------------------------------------------------------------
form findexceptiontexts using publicclasskey
                              iconcepts like dumiconcepts[].

  data: castclassname type program.
  data: itemplines type standard table of string with header line.
  data: itokens type standard table of stokes with header line.
  data: ikeywords type standard table of text20 with header line.
  data: istatements type standard table of sstmnt with header line.
  data: watokens type stokes.
  data: wacurrenttoken type stokes.
  data: waconcept like line of iconcepts.
  data: tokenlength type i.
  data: myrow type i.

  castclassname = publicclasskey.
  read report castclassname into itemplines.

  append 'CONSTANTS' to ikeywords.
  scan abap-source itemplines tokens into itokens statements into
istatements keywords from ikeywords.

  delete itokens where str = 'CONSTANTS'.
  delete itokens where str = 'VALUE'.
  delete itokens where str = 'TYPE'.

  loop at itokens into watokens where str = 'SOTR_CONC'.
*   The loop before holds the constant name
    myrow = sy-tabix - 1.
    read table itokens index myrow into wacurrenttoken.
    waconcept-constname = wacurrenttoken-str.

*   The loop after holds the constant name
    myrow = myrow + 2.
    read table itokens index myrow into wacurrenttoken.
    tokenlength = strlen( wacurrenttoken-str ).
    if tokenlength = 34.
*     Most likely an exception text.
      replace all occurrences of '''' in wacurrenttoken-str with ' ' .
      waconcept-concept = wacurrenttoken-str.
      append waconcept to iconcepts.
    endif.
  endloop.
endform.                    "findExceptionTexts

*-----------------------------------------------------------------------
*  findClassMethods...   Finds the methods of a class.
*-----------------------------------------------------------------------
form findclassmethods using value(classname)
                            ilocmethods like dumimethods[].

  data: imethods type standard table of tmethod with header line.

  select cmpname descript exposure
         from vseomethod
         into corresponding fields of table imethods
           where clsname = classname
             and version = '1'
             and langu = sy-langu
             and ( state = '0' or state = '1' ).

  if sy-subrc <> 0.
    select cmpname descript exposure
           from vseomethod
           into corresponding fields of table imethods
           where clsname = classname
             and version = '0'
             and langu = sy-langu
             and ( state = '0' or state = '1' ).
  endif.

* Find the method key so that we can acces the source code later
  loop at imethods.
    perform findmethodkey using classname
                                imethods-cmpname
                                imethods-methodkey.
    modify imethods.
  endloop.

  ilocmethods[] = imethods[].
endform.                    "findClassMethods
"findClassMethods

*-----------------------------------------------------------------------
* findMethodKey... find the unique key which identifes this method
*-----------------------------------------------------------------------
form findmethodkey using value(classname)
                         value(methodname)
                               methodkey.

  data: methodid type seocpdkey.
  data: locmethodkey type program.

  methodid-clsname = classname.
  methodid-cpdname = methodname.

  cl_oo_classname_service=>get_method_include( exporting mtdkey =
methodid
                                               receiving result =
locmethodkey
                                               exceptions
 class_not_existing = 1

 method_not_existing = 2 ).

  methodkey = locmethodkey.
endform.                    "findMethodKey
"findMethodKey

*-----------------------------------------------------------------------
* scanForMessages... Search each program for messages
*-----------------------------------------------------------------------
form scanformessages using value(programname)
                           value(mainmessageclass)
                                 ilocmessages like imessages[].

  data: iincludelines type standard table of string with header line.
  data: itokens type standard table of stokes with header line.
  data: istatements type standard table of sstmnt with header line.
  data: ikeywords type standard table of text20 with header line.
  data: wamessage type tmessage.
  data: wamessagecomparison type tmessage.
  data: watokens type stokes.
  data: nextline type i.
  data: stringlength type i value 0.
  data: workingonmessage type i value false.
  data: castprogramname type program.

* Read the program code from the textpool.
  castprogramname = programname.
  read report castprogramname into iincludelines.

  append message to ikeywords.
  scan abap-source iincludelines tokens into itokens with includes
statements into istatements keywords from ikeywords.

  clear iincludelines[].

  loop at itokens.
    if itokens-str = message.
      workingonmessage = true.
      continue.
    endif.

    if workingonmessage = true.
      stringlength = strlen( itokens-str ).

*     Message declaration 1
      if stringlength = 4 and itokens-str+0(1) ca sy-abcde.
        wamessage-msgnr = itokens-str+1(3).
        wamessage-arbgb = mainmessageclass.
      else.
        if itokens-str cs '''' or itokens-str cs '`'.
*         Message declaration 2
          translate itokens-str using ''' '.
          translate itokens-str using '` '.
          condense itokens-str.
          shift itokens-str left deleting leading space.
          wamessage-text = itokens-str.
          wamessage-arbgb = 'Hard coded'.
        else.
          if itokens-str = 'ID'.
*           Message declaration 3
            nextline = sy-tabix + 1.
            read table itokens index nextline into watokens.
            translate watokens-str using ''' '.
            condense itokens-str.
            shift watokens-str left deleting leading space.
            if not watokens-str = 'SY-MSGID'.
              wamessage-arbgb = watokens-str.

              nextline = nextline + 4.
              read table itokens index nextline into watokens.
              translate watokens-str using ''' '.
              condense watokens-str.
              shift watokens-str left deleting leading space.
              wamessage-msgnr = watokens-str.
            else.
              workingonmessage = false.
            endif.
          else.
            if stringlength >= 5 and itokens-str+4(1) = '('.
*              Message declaration 4
              wamessage-msgnr = itokens-str+1(3).
              shift itokens-str left up to '('.
              replace '(' into itokens-str with space.
              replace ')' into itokens-str with space.
              condense itokens-str.
              wamessage-arbgb = itokens-str.
            endif.
          endif.
        endif.
      endif.

*      find the message text
      if not wamessage-arbgb is initial and not wamessage-msgnr is
initial and wamessage-text is initial.
        select single text
                      from t100
                      into wamessage-text
                      where sprsl = sy-langu
                        and arbgb = wamessage-arbgb
                        and msgnr = wamessage-msgnr.
      endif.

*      Append the message
      if not wamessage is initial.
*        Don't append the message if we already have it listed
        read table ilocmessages with key arbgb = wamessage-arbgb
                                         msgnr = wamessage-msgnr
                                         into wamessagecomparison.
        if sy-subrc <> 0.
          append wamessage to ilocmessages.
        endif.
        clear wamessage.
        workingonmessage = false.
      endif.
    endif.
  endloop.
endform.                    "scanForMessages
"scanForMessages

*-----------------------------------------------------------------------
* scanForTables... Search each program for dictionary tables
*-----------------------------------------------------------------------
form scanfortables using value(programname)
                         value(customeronly)
                         value(customernamerange)
                               ilocdictionary like idictionary[].

  data: iincludelines type standard table of string with header line.
  data: itokens type standard table of stokes with header line.
  data: istatements type standard table of sstmnt with header line.
  data: ikeywords type standard table of text20 with header line.
  data: wadictionary type tdicttable.
  data: wadictionarycomparison type tdicttable.
  data: castprogramname type program.

* Read the program code from the textpool.
  castprogramname = programname.
  read report castprogramname into iincludelines.

  append tables to ikeywords.

  scan abap-source iincludelines tokens into itokens with includes
statements into istatements keywords from ikeywords.
  clear iincludelines[].

  sort itokens ascending by str.
  delete itokens where str = tables.

  loop at itokens.
    if not customeronly is initial.
      try.
          if ( itokens-str+0(1) <> 'Y' or itokens-str+0(1) <> 'Z' or
  itokens-str ns customernamerange ).
            continue.
          endif.
        catch cx_sy_range_out_of_bounds into objruntimeerror.
      endtry.
    endif.

    wadictionary-tablename = itokens-str.
*   Don't append the object if we already have it listed
    read table ilocdictionary into wadictionarycomparison with key
tablename = wadictionary-tablename.
    if sy-subrc <> 0.
      perform findtabledescription using wadictionary-tablename
                                         wadictionary-tabletitle.

      perform findtabledefinition using wadictionary-tablename
                                        wadictionary-istructure[].

      append wadictionary to ilocdictionary.
    endif.
  endloop.
endform.                    "scanForTables
"scanForTables

*-----------------------------------------------------------------------
*  findProgramScreenFlow...
*-----------------------------------------------------------------------
form findprogramscreenflow using waprogram type tprogram.

  data: iflow type standard table of tscreenflow with header line.

  call function 'DYNPRO_PROCESSINGLOGIC'
    exporting
      rep_name  = waprogram-progname
    tables
      scr_logic = iflow.

  sort iflow ascending by screen.
  delete adjacent duplicates from iflow comparing screen.
  if waprogram-subc <> 'M'.
    delete iflow where screen >= '1000' and screen <= '1099'.
  endif.

  loop at iflow.
    append iflow to waprogram-iscreenflow.
  endloop.
endform.                    "findProgramScreenFlow
"findProgramScreenFlow

*-----------------------------------------------------------------------
*  findFunctionScreenFlow...
*-----------------------------------------------------------------------
form findfunctionscreenflow using wafunction type tfunction.

  data: iflow type standard table of tscreenflow with header line.

  call function 'DYNPRO_PROCESSINGLOGIC'
    exporting
      rep_name  = wafunction-progname
    tables
      scr_logic = iflow.

  sort iflow ascending by screen.
  delete adjacent duplicates from iflow comparing screen.

  loop at iflow.
    append iflow to wafunction-iscreenflow.
  endloop.
endform.                    "findFunctionScreenFlow
"findFunctionScreenFlow

*-----------------------------------------------------------------------
* scanForLikeOrType... Look for any dictionary objects referenced by a
* like or type statement
*-----------------------------------------------------------------------
form scanforlikeortype using value(programname)
                             value(customeronly)
                             value(customernamerange)
                             ilocdictionary like idictionary[].

  data ilines type standard table of string with header line.
  data: head type string.
  data: tail type string.
  data: junk type string.
  data: linetype type string.
  data: linelength type i value 0.
  data: endofline type i value true.
  data: wadictionary type tdicttable.
  data: wadictionarycomparison type tdicttable.
  data: waline type string.
  data: castprogramname type program.

* Read the program code from the textpool.
  castprogramname = programname.
  read report castprogramname into ilines.

  loop at ilines into waline.
*   Find custom tables.
    linelength = strlen( waline ).
    if linelength > 0.
      if waline(1) = asterix.
        continue.
      endif.

      translate waline to upper case.

*   Determine the lineType.
      if endofline = true.
        shift waline up to like.
        if sy-subrc = 0.
          linetype = like.
        else.
          shift waline up to type.
          if sy-subrc = 0.
            find 'BEGIN OF' in waline.
            if sy-subrc <> 0.
              find 'END OF' in waline.
              if sy-subrc <> 0.
                find 'VALUE' in waline.
                if sy-subrc <> 0.
                  linetype = type.
                endif.
              endif.
            endif.
          else.
            shift waline up to include.
            if sy-subrc = 0.
              split waline at space into junk ilines.
            endif.

            shift waline up to structure.
            if sy-subrc = 0.
              linetype = structure.
            else.
              continue.
            endif.
          endif.
        endif.
      else.
        linetype = comma.
      endif.

      case linetype.
        when like or type or structure.
*         Work on the appropriate lineType
          shift waline up to space.
          shift waline left deleting leading space.
          if waline cs table.
            split waline at table into head tail.
            split tail at 'OF' into head tail.
            waline = tail.
            shift waline left deleting leading space.
          endif.

*         Are we only to download SAP dictionary structures.
          if not customeronly is initial.
            try.
                if waline+0(1) = 'Y' or waline+0(1) = 'Z' or waline cs
  customernamerange.
                else.
                  linetype = ''.
                  continue.
                endif.
              catch cx_sy_range_out_of_bounds into objruntimeerror.
            endtry.
          endif.

          if waline cs comma.
            split waline at comma into head tail.
            if waline cs dash.
              split head at dash into head tail.
            endif.
            if waline cs occurs.
              split waline at space into head tail.
            endif.
          else.
            if waline cs period.
              split waline at period into head tail.
              if waline cs dash.
                split head at dash into head tail.
              endif.
              if waline cs occurs.
                split waline at space into head tail.
              endif.
            else.
              split waline at space into head tail.
              if waline cs dash.
                split head at dash into head tail.
              endif.
            endif.
          endif.

          if not head is initial.
            wadictionary-tablename = head.
*           Don't append the object if we already have it listed
            read table ilocdictionary into wadictionarycomparison
                                      with key tablename =
wadictionary-tablename.
            if sy-subrc <> 0.
              perform findtabledescription using wadictionary-tablename
                                                 wadictionary-tabletitle
.

              perform findtabledefinition using wadictionary-tablename

wadictionary-istructure[].

*             Only append if the item is a table and not a structure or
* data element
              if not wadictionary-istructure[] is initial.
                append wadictionary to ilocdictionary.
              endif.
            endif.
            clear wadictionary.
          endif.

          linetype = ''.
      endcase.
    endif.
  endloop.
endform.                    "scanForLikeOrType
"scanForLikeOrType

*-----------------------------------------------------------------------
*  displayStatus...
*-----------------------------------------------------------------------
form displaystatus using value(message)
                         value(delay).

  call function 'SAPGUI_PROGRESS_INDICATOR'
    exporting
      percentage = 0
      text       = message
    exceptions
      others     = 1.

  if delay > 0.
    wait up to delay seconds.
  endif.
endform.                    "displayStatus
"displayStatus

*-----------------------------------------------------------------------
*  removeLeadingZeros...
*-----------------------------------------------------------------------
form removeleadingzeros changing myvalue.

  call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
    exporting
      input  = myvalue
    importing
      output = myvalue
    exceptions
      others = 1.
endform.                    "removeLeadingZeros
"removeLeadingZeros

*-----------------------------------------------------------------------
* determineFrontendOPSystem.... Determine the frontend operating system
* type.
*-----------------------------------------------------------------------
form determinefrontendopsystem using separator
                                     operatingsystem.

  data: platformid type i value 0.

  create object objfile.

  call method objfile->get_platform
    receiving
      platform             = platformid
    exceptions
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3.
  case platformid.
    when objfile->platform_windows95
         or objfile->platform_windows98
         or objfile->platform_nt351
         or objfile->platform_nt40
         or objfile->platform_nt50
         or objfile->platform_mac
         or objfile->platform_os2
         or 14.      "XP
      separator = '\'.
      operatingsystem = non_unix.
    when others.
      separator = '/'.
      operatingsystem = unix.
  endcase.
endform.                    "determineFrontendOPSystem
"determineFrontendOpSystem

*-----------------------------------------------------------------------
* determineServerOPSystem.... Determine the server operating system type
.
*-----------------------------------------------------------------------
form determineserveropsystem using separator
                                   serverfilesystem
                                   serveropsystem.

* Find the file system
  select single filesys
                from opsystem
                into serverfilesystem
                where opsys = sy-opsys.

  find 'WINDOWS' in serverfilesystem ignoring case.
  if sy-subrc = 0.
    separator = '\'.
    serveropsystem = non_unix.
  else.
    find 'DOS' in serverfilesystem ignoring case.
    if sy-subrc = 0.
      separator = '\'.
      serveropsystem = non_unix.
    else.
      separator = '/'.
      serveropsystem = unix.
    endif.
  endif.
endform.                    "determineServerOPSystem
"determineServerOpSystem

*-----------------------------------------------------------------------
* findExternalCommand.... Determine if the external command exists.  If
* it doesn't then disable the
*                         server input field
*-----------------------------------------------------------------------
form findexternalcommand.

  call function 'SXPG_COMMAND_CHECK'
    exporting
      commandname       = 'ZMKDIR'
      operatingsystem   = sy-opsys
    exceptions
      command_not_found = 1
      others            = 0.

  if sy-subrc <> 0.
    loop at screen.
      if screen-name = 'PLOGICAL'.
        screen-input = 0.
        modify screen.
      endif.

      if screen-name = 'PSERV'.
        screen-input = 0.
        modify screen.
      endif.

      if screen-name = 'PPC'.
        screen-input = 0.
        modify screen.
      endif.
    endloop.

    message s000(oo) with 'Download to server disabled,' 'external command ZMKDIR not defined.'.
  endif.
endform.                    "findExternalCommand

********************************************************************************************************
*****************************************DOWNLOAD*ROUTINES**********************************************
********************************************************************************************************

*-----------------------------------------------------------------------
* downloadDDStructures... download database objects to file
*-----------------------------------------------------------------------
form downloadddstructures using ilocdictionary like idictionary[]
                                value(pathname)
                                value(htmlfileextension)
                                value(subdir)
                                value(sorttablesasc)
                                value(slashseparator)
                                value(savetoserver)
                                value(displayprogressmessage).

  field-symbols: <wadictionary> type tdicttable.
  data: tablefilename type string.
  data: tablefilenamewithpath type string.
  data: ihtmltable type standard table of string with header line.
  data: newsubdirectory type string.
  data: completesavepath type string.

  loop at ilocdictionary assigning <wadictionary>.
    perform buildfilename using pathname
                                subdir
                                <wadictionary>-tablename
                                space
                                space
                                htmlfileextension
                                is_table
                                savetoserver
                                slashseparator
                                tablefilenamewithpath
                                tablefilename
                                newsubdirectory
                                completesavepath.

*   Try and import a converted table to memory as it will be much
* quicker than converting it again
    import ihtmltable from memory id <wadictionary>-tablename.
    if sy-subrc <> 0.
      concatenate 'Converting table' <wadictionary>-tablename 'to html'
into statusbarmessage separated by space.
      perform displaystatus using statusbarmessage 0.

      perform convertddtohtml using <wadictionary>-istructure[]
                                    ihtmltable[]
                                    <wadictionary>-tablename
                                    <wadictionary>-tabletitle
                                    sorttablesasc.

      export ihtmltable to memory id <wadictionary>-tablename.
    endif.

    if savetoserver is initial.
      perform savefiletopc using ihtmltable[]
                                 tablefilenamewithpath
                                 tablefilename
                                 space
                                 space
                                 displayprogressmessage.
    else.
      perform savefiletoserver using ihtmltable[]
                                     tablefilenamewithpath
                                     tablefilename
                                     completesavepath
                                     displayprogressmessage.
    endif.

    clear ihtmltable[].
  endloop.
endform.                    "downloadDDStructures
"downloadDDStructures

*-----------------------------------------------------------------------
* downloadMessageClass...
*-----------------------------------------------------------------------
form downloadmessageclass using ilocmessages like imessages[]
                                value(messageclassname)
                                value(userfilepath)
                                value(fileextension)
                                value(htmlfileflag)
                                      subdir
                                value(syntaxhighlightcomments)
                                value(customernamerange)
                                value(getincludes)
                                value(getdictstructures)
                                value(userhasselectedmessageclasses)
                                value(slashseparator)
                                value(savetoserver)
                                value(displayprogressmessage).

  data: htmlpagename type string.
  data: newfilenameonly type string.
  data: newfilenamewithpath type string.
  data: ihtmltable type standard table of string with header line.
  data: newsubdirectory type string.
  data: completesavepath type string.

  perform appendmessagestofile using ilocmessages[]
                                     ihtmltable[]
                                     userhasselectedmessageclasses.


  concatenate `message class ` messageclassname into htmlpagename.

  if htmlfileflag is initial.
    append '' to ihtmltable.
    append
'----------------------------------------------------------------------------------' to ihtmltable.

    perform buildfootermessage using 'TEXT'
                                     ihtmltable.
    append ihtmltable.
  else.
    perform convertcodetohtml using ihtmltable[]
                                    htmlpagename
                                    space
                                    is_messageclass
                                    ''
                                    false
                                    syntaxhighlightcomments
                                    fileextension
                                    customernamerange
                                    getincludes
                                    getdictstructures.
  endif.

  perform buildfilename using userfilepath
                              subdir
                              messageclassname
                              space
                              space
                              fileextension
                              is_messageclass
                              savetoserver
                              slashseparator
                              newfilenamewithpath
                              newfilenameonly
                              newsubdirectory
                              completesavepath.

  if savetoserver is initial.
    perform savefiletopc using ihtmltable[]
                               newfilenamewithpath
                               newfilenameonly
                               space
                               space
                               displayprogressmessage.
  else.
*     Save the file to the SAP server
    perform savefiletoserver using ihtmltable[]
                                   newfilenamewithpath
                                   newfilenameonly
                                   completesavepath
                                   displayprogressmessage.
  endif.
endform.                    "downloadMessageClass
"downloadMessageClass

*-----------------------------------------------------------------------
*  appendMessagesToFile
*-----------------------------------------------------------------------
form appendmessagestofile using ilocmessages like imessages[]
                                ilochtml like dumihtml[]
                                value(userhasselectedmessageclasses).

  data: previousmessageid like imessages-arbgb.
  field-symbols: <wamessage> type tmessage.
  data: wahtml type string.

  sort ilocmessages ascending by arbgb msgnr.

  if not ilocmessages[] is initial.
    if userhasselectedmessageclasses is initial.
*     Only add these extra lines if we are actually appending them to
* the end of some program code
      append wahtml to ilochtml.
      append wahtml to ilochtml.

      append '*Messages' to ilochtml.
      append
 '*----------------------------------------------------------' to
ilochtml.
    endif.

    loop at ilocmessages assigning <wamessage>.
      if ( <wamessage>-arbgb <> previousmessageid ).

        if userhasselectedmessageclasses is initial.
*         Only add this extra lines if we are actually appending them to
* the end of some program code
          append '*' to ilochtml.
          concatenate `* Message class: ` <wamessage>-arbgb into wahtml.
          append wahtml to ilochtml.
        endif.

        previousmessageid = <wamessage>-arbgb.
        clear wahtml.
      endif.

      if userhasselectedmessageclasses is initial.
*       Only add this extra lines if we are actually appending them to
* the end of some program code
        concatenate '*' <wamessage>-msgnr `   ` <wamessage>-text into
wahtml.
      else.
        concatenate <wamessage>-msgnr `   ` <wamessage>-text into wahtml
.
      endif.

      append wahtml to ilochtml.
    endloop.
  endif.
endform.                    "appendMessagesToFile
"appendMessagesToFile

*-----------------------------------------------------------------------
*  downloadFunctions...       Download function modules to file.
*-----------------------------------------------------------------------
form downloadfunctions using ilocfunctions like ifunctions[]
                             value(userfilepath)
                             value(fileextension)
                             value(subdir)
                             value(downloaddocumentation)
                             value(converttohtml)
                             value(syntaxhighlightcomments)
                             value(customernamerange)
                             value(getincludes)
                             value(getdictstruct)
                             value(textfileextension)
                             value(htmlfileextension)
                             value(sorttablesasc)
                             value(slashseparator)
                             value(savetoserver)
                             value(displayprogressmessage).

  data: mainsubdir type string.
  data: incsubdir type string.
  field-symbols: <wafunction> type tfunction.
  field-symbols: <wainclude> type tinclude.
  data: iemptytextelements type standard table of ttexttable.
  data: iemptyselectiontexts type standard table of ttexttable.
  data: iemptymessages type standard table of tmessage.
  data: iemptyguititles type standard table of tguititle.
  data: functiondocumentationexists type i value false.

  loop at ilocfunctions assigning <wafunction>.
    if subdir is initial.
      incsubdir = <wafunction>-functionname.
      mainsubdir = ''.
    else.
      concatenate subdir <wafunction>-functionname into incsubdir
separated by slashseparator.
      mainsubdir = subdir.
    endif.

    if not downloaddocumentation is initial.
      perform downloadfunctiondocs using <wafunction>-functionname
                                         <wafunction>-functiontitle
                                         userfilepath
                                         fileextension
                                         converttohtml
                                         slashseparator
                                         savetoserver
                                         displayprogressmessage
                                         mainsubdir
                                         functiondocumentationexists.
    endif.

*   Download main source code
    perform readfunctionanddownload using <wafunction>-itextelements[]
                                          <wafunction>-iselectiontexts[]
                                          <wafunction>-imessages[]
                                          <wafunction>-functionname

<wafunction>-functionmaininclude
                                          <wafunction>-functiontitle
                                          userfilepath
                                          fileextension
                                          mainsubdir
                                          converttohtml
                                          functiondocumentationexists
                                          syntaxhighlightcomments
                                          customernamerange
                                          getincludes
                                          getdictstruct
                                          slashseparator
                                          savetoserver
                                          displayprogressmessage.

*   Download top include
    perform readincludeanddownload using iemptytextelements[]
                                         iemptyselectiontexts[]
                                         iemptymessages[]
                                         iemptyguititles[]
                                         <wafunction>-topincludename
                                         <wafunction>-functionname
                                         <wafunction>-functiontitle
                                         is_function
                                         userfilepath
                                         fileextension
                                         mainsubdir
                                         converttohtml
                                         syntaxhighlightcomments
                                         customernamerange
                                         getincludes
                                         getdictstruct
                                         slashseparator
                                         savetoserver
                                         displayprogressmessage.

*   Download screens.
    if not <wafunction>-iscreenflow[] is initial.
      perform downloadscreens using <wafunction>-iscreenflow[]
                                    <wafunction>-progname
                                    userfilepath
                                    textfileextension
                                    mainsubdir
                                    slashseparator
                                    savetoserver
                                    displayprogressmessage.
    endif.

*   Download GUI titles
    if not <wafunction>-iguititle[] is initial.
      perform downloadguititles using <wafunction>-iguititle
                                      userfilepath
                                      textfileextension
                                      mainsubdir
                                      slashseparator
                                      savetoserver
                                      displayprogressmessage.
    endif.

*   Download all other includes
    loop at <wafunction>-iincludes assigning <wainclude>.
      perform readincludeanddownload using iemptytextelements[]
                                           iemptyselectiontexts[]
                                           iemptymessages[]
                                           iemptyguititles[]
                                           <wainclude>-includename
                                           space
                                           <wainclude>-includetitle
                                           is_program
                                           userfilepath
                                           fileextension
                                           incsubdir
                                           converttohtml
                                           syntaxhighlightcomments
                                           customernamerange
                                           getincludes
                                           getdictstruct
                                           slashseparator
                                           savetoserver
                                           displayprogressmessage.

    endloop.

*   Download all dictionary structures
    if not <wafunction>-idictstruct[] is initial.
      perform downloadddstructures using <wafunction>-idictstruct[]
                                         userfilepath
                                         htmlfileextension
                                         incsubdir
                                         sorttablesasc
                                         slashseparator
                                         savetoserver
                                         displayprogressmessage.
    endif.
  endloop.
endform.                    "downloadFunctions
"downloadFunctions

*-----------------------------------------------------------------------
*   readIcludeAndDownload...
*-----------------------------------------------------------------------
form readincludeanddownload using iloctextelements like dumitexttab[]
                                  ilocselectiontexts like dumitexttab[]
                                  ilocmessages like imessages[]
                                  ilocguititles like dumiguititle[]
                                  value(programname)
                                  value(functionname)
                                  value(shorttext)
                                  value(overideprogtype)
                                  value(userfilepath)
                                  value(fileextension)
                                  value(additionalsubdir)
                                  value(converttohtml)
                                  value(syntaxhighlightcomments)
                                  value(customernamerange)
                                  value(getincludes)
                                  value(getdictstructures)
                                  value(slashseparator)
                                  value(savetoserver)
                                  value(displayprogressmessage).

  data: ilines type standard table of string with header line.
  data: localfilenamewithpath type string.
  data: localfilenameonly type string.
  data: newsubdirectory type string.
  data: objectname type string.
  data: completesavepath type string.

  read report programname into ilines.

* Download GUI titles for main program
  if not ilocguititles[] is initial.
    perform appendguititles using ilocguititles[]
                                  ilines[].
  endif.

* Download text elements for main program
  if not iloctextelements[] is initial.
    perform appendtextelements using iloctextelements[]
                                     ilines[].
  endif.

* Download selection texts for main program
  if not ilocselectiontexts[] is initial.
    perform appendselectiontexts using ilocselectiontexts[]
                                       ilines[].
  endif.

* Download messages classes for main program.
  if not ilocmessages[] is initial.
    perform appendmessagestofile using ilocmessages[]
                                       ilines[]
                                       space.
  endif.

  if converttohtml is initial.
    append '' to ilines.
    append
'----------------------------------------------------------------------------------' to ilines.
    perform buildfootermessage using 'TEXT'
                                     ilines.
    append ilines.
  else.
    perform convertcodetohtml using ilines[]
                                    programname
                                    shorttext
                                    overideprogtype
                                    space
                                    space
                                    syntaxhighlightcomments
                                    fileextension
                                    customernamerange
                                    getincludes
                                    getdictstructures.
  endif.

  if functionname is initial.
    objectname = programname.
  else.
    objectname = functionname.
  endif.

  perform buildfilename using userfilepath
                              additionalsubdir
                              objectname
                              space
                              programname
                              fileextension
                              overideprogtype
                              savetoserver
                              slashseparator
                              localfilenamewithpath
                              localfilenameonly
                              newsubdirectory
                              completesavepath.

  if savetoserver is initial.
    perform savefiletopc using ilines[]
                               localfilenamewithpath
                               localfilenameonly
                               space
                               space
                               displayprogressmessage.
  else.
    perform savefiletoserver using ilines[]
                                   localfilenamewithpath
                                   localfilenameonly
                                   completesavepath
                                   displayprogressmessage.
  endif.
endform.                    "readIncludeAndDownload
"readIncludeAndDownload

*-----------------------------------------------------------------------
*   readClassAndDownload...
*-----------------------------------------------------------------------
form readclassanddownload using walocclass type tclass
                                value(classname)
                                value(functionname)
                                value(overideprogtype)
                                value(userfilepath)
                                value(fileextension)
                                value(additionalsubdir)
                                value(converttohtml)
                                value(syntaxhighlightcomments)
                                value(customernamerange)
                                value(getincludes)
                                value(getdictstructures)
                                value(slashseparator)
                                value(savetoserver)
                                value(displayprogressmessage).

  data: itemplines type standard table of string with header line.
  data: ilines type standard table of string with header line.
  data: localfilenamewithpath type string.
  data: localfilenameonly type string.
  data: newsubdirectory type string.
  data: objectname type string.
  data: castclassname type program.
  data: completesavepath type string.

* Build up attribute comments
  append
'***********************************************************************' to ilines.
  append '*   Class attributes.           *' to ilines.
  append
'***********************************************************************' to ilines.
  case walocclass-exposure.
    when 0.
      append `Instantiation: Private` to ilines.
    when 1.
      append `Instantiation: Protected` to ilines.
    when 2.
      append `Instantiation: Public` to ilines.
  endcase.
  concatenate `Message class: ` walocclass-msg_id into ilines.
  append ilines.
  case walocclass-state.
    when 0.
      append `State: Only Modelled` to ilines.
    when 1.
      append `State: Implemented` to ilines.
  endcase.
  concatenate `Final Indicator: ` walocclass-clsfinal into ilines.
  append ilines.
  concatenate `R/3 Release: ` walocclass-r3release into ilines.
  append ilines.
  clear ilines.
  append ilines.

  castclassname = walocclass-publicclasskey.
  read report castclassname into itemplines.
  if sy-subrc = 0.
    perform reformatclasscode using itemplines[].

    append
'***********************************************************************' to ilines.
    append '*   Public section of class.             *' to ilines.
    append
'***********************************************************************' to ilines.
    loop at itemplines.
      append itemplines to ilines.
    endloop.
  endif.

  castclassname = walocclass-privateclasskey.
  read report castclassname into itemplines.
  if sy-subrc = 0.
    perform reformatclasscode using itemplines[].

    append ilines.
    append
'***********************************************************************' to ilines.
    append '*   Private section of class.             *' to ilines.
    append
'***********************************************************************' to ilines.
    loop at itemplines.
      append itemplines to ilines.
    endloop.
  endif.

  castclassname = walocclass-protectedclasskey.
  read report castclassname into itemplines.
  if sy-subrc = 0.
    perform reformatclasscode using itemplines[].

    append ilines.
    append
'***********************************************************************' to ilines.
    append '*   Protected section of class.             *' to ilines.
    append
'***********************************************************************' to ilines.
    loop at itemplines.
      append itemplines to ilines.
    endloop.
  endif.

  castclassname = walocclass-typesclasskey.
  read report castclassname into itemplines.
  if sy-subrc = 0.
    append ilines.
    append
'***********************************************************************' to ilines.
    append '*   Types section of class.             *' to ilines.
    append
'***********************************************************************' to ilines.
    loop at itemplines.
      append itemplines to ilines.
    endloop.
  endif.

* Download text elements for this class
  if not walocclass-itextelements[] is initial.
    perform appendtextelements using walocclass-itextelements[]
                                     ilines[].
  endif.

* Download messages classes for this class.
  if not walocclass-imessages[] is initial.
    perform appendmessagestofile using walocclass-imessages[]
                                       ilines[]
                                       space.
  endif.

* Download exception texts for this class
  if not walocclass-iconcepts[] is initial.
    perform appendexceptiontexts using walocclass-iconcepts[]
                                       ilines[].
  endif.


  if converttohtml is initial.
    append '' to ilines.
    append
'----------------------------------------------------------------------------------' to ilines.
    perform buildfootermessage using 'TEXT'
                                     ilines.
    append ilines.
  else.
    perform convertclasstohtml using ilines[]
                                    classname
                                    walocclass-descript
                                    overideprogtype
                                    syntaxhighlightcomments
                                    fileextension
                                    customernamerange
                                    getdictstructures.
  endif.

  if functionname is initial.
    objectname = classname.
  else.
    objectname = functionname.
  endif.

  perform buildfilename using userfilepath
                              additionalsubdir
                              objectname
                              space
                              classname
                              fileextension
                              overideprogtype
                              savetoserver
                              slashseparator
                              localfilenamewithpath
                              localfilenameonly
                              newsubdirectory
                              completesavepath.

  if savetoserver is initial.
    perform savefiletopc using ilines[]
                               localfilenamewithpath
                               localfilenameonly
                               space
                               space
                               displayprogressmessage.
  else.
    perform savefiletoserver using ilines[]
                                   localfilenamewithpath
                                   localfilenameonly
                                   completesavepath
                                   displayprogressmessage.
  endif.
endform.                    "readClassAndDownload
"readClassAndDownload

*-----------------------------------------------------------------------
*   readMethodAndDownload...
*-----------------------------------------------------------------------
form readmethodanddownload using walocmethod type tmethod
                                value(methodname)
                                value(methodkey)
                                value(functionname)
                                value(overideprogtype)
                                value(userfilepath)
                                value(fileextension)
                                value(additionalsubdir)
                                value(converttohtml)
                                value(syntaxhighlightcomments)
                                value(customernamerange)
                                value(getincludes)
                                value(getdictstructures)
                                value(slashseparator)
                                value(savetoserver)
                                value(displayprogressmessage).

  data: ilines type standard table of string with header line.
  data: itemplines type standard table of string with header line.
  data: localfilenamewithpath type string.
  data: localfilenameonly type string.
  data: newsubdirectory type string.
  data: objectname type string.
  data: castmethodkey type program.
  data: completesavepath type string.

* Add the method scope to the downloaded file
  append
'***********************************************************************' to ilines.
  append '*   Method attributes.           *' to ilines.
  append
'***********************************************************************' to ilines.
  case walocmethod-exposure.
    when 0.
      append `Instantiation: Private` to ilines.
    when 1.
      append `Instantiation: Protected` to ilines.
    when 2.
      append `Instantiation: Public` to ilines.
  endcase.
  append
'***********************************************************************' to ilines.
  append '' to ilines.

  castmethodkey = walocmethod-methodkey.
  read report castmethodkey into itemplines.
  loop at itemplines.
    append itemplines to ilines.
  endloop.

  if converttohtml is initial.
    append '' to ilines.
    append
'----------------------------------------------------------------------------------' to ilines.
    perform buildfootermessage using 'TEXT'
                                     ilines.
    append ilines.
  else.
    perform convertcodetohtml using ilines[]
                                    methodname
                                    walocmethod-descript
                                    overideprogtype
                                    space
                                    space
                                    syntaxhighlightcomments
                                    fileextension
                                    customernamerange
                                    getincludes

                                    getdictstructures.
  endif.

  if functionname is initial.
    objectname = methodname.
  else.
    objectname = functionname.
  endif.

  perform buildfilename using userfilepath
                              additionalsubdir
                              objectname
                              space
                              methodname
                              fileextension
                              overideprogtype
                              savetoserver
                              slashseparator
                              localfilenamewithpath
                              localfilenameonly
                              newsubdirectory
                              completesavepath.

  if savetoserver is initial.
    perform savefiletopc using ilines[]
                               localfilenamewithpath
                               localfilenameonly
                               space
                               space
                               displayprogressmessage.
  else.
    perform savefiletoserver using ilines[]
                                   localfilenamewithpath
                                   localfilenameonly
                                   completesavepath
                                   displayprogressmessage.
  endif.
endform.                    "readMethodAndDownload
"readMethodAndDownload

*-----------------------------------------------------------------------
*   readFunctionAndDownload...
*-----------------------------------------------------------------------
form readfunctionanddownload using iloctextelements like dumitexttab[]
                                   ilocselectiontexts like dumitexttab[]
                                   ilocmessages like imessages[]
                                   value(functionname)
                                   value(functioninternalname)
                                   value(shorttext)
                                   value(userfilepath)
                                   value(fileextension)
                                   value(subdir)
                                   value(converttohtml)
                                   value(functiondocumentationexists)
                                   value(syntaxhighlightcomments)
                                   value(customernamerange)
                                   value(getincludes)
                                   value(getdictstructures)
                                   value(slashseparator)
                                   value(savetoserver)
                                   value(displayprogressmessage).

  data: ilines type standard table of string with header line.
  data: localfilenamewithpath type string.
  data: localfilenameonly type string.
  data: newsubdirectory type string.
  data: completesavepath type string.

  read report functioninternalname into ilines.

* If we found any text elements for this function then we ought to
* append them to the main include.
  if not iloctextelements[] is initial.
    perform appendtextelements using iloctextelements[]
                                     ilines[].
  endif.

* If we found any message classes for this function then we ought to
* append them to the main include.
  if not ilocmessages[] is initial.
    perform appendmessagestofile using ilocmessages[]
                                       ilines[]
                                       space.
  endif.

  if converttohtml is initial.
    append '' to ilines.
    append
'----------------------------------------------------------------------------------' to ilines.
    perform buildfootermessage using 'TEXT'
                                     ilines.
    append ilines.
  else.
    perform convertfunctiontohtml using ilines[]
                                        functionname
                                        shorttext
                                        is_function
                                        functiondocumentationexists
                                        true
                                        syntaxhighlightcomments
                                        fileextension
                                        customernamerange
                                        getincludes
                                        getdictstructures.
  endif.

  perform buildfilename using userfilepath
                              subdir
                              functionname
                              space
                              space
                              fileextension
                              is_function
                              savetoserver
                              slashseparator
                              localfilenamewithpath
                              localfilenameonly
                              newsubdirectory
                              completesavepath.

  if savetoserver is initial.
    perform savefiletopc using ilines[]
                               localfilenamewithpath
                               localfilenameonly
                               space
                               space
                               displayprogressmessage.
  else.
    perform savefiletoserver using ilines[]
                                   localfilenamewithpath
                                   localfilenameonly
                                   completesavepath
                                   displayprogressmessage.
  endif.
endform.                    "readFunctionAndDownload
"readFunctionAndDownload

*-----------------------------------------------------------------------
*  buildFilename...
*-----------------------------------------------------------------------
form buildfilename using value(userpath)
                         value(additionalsubdirectory)
                         value(objectname)
                         value(mainfunctionno)
                         value(includename)
                         value(fileextension)
                         value(downloadtype)
                         value(downloadtoserver)
                         value(slashseparator)
                               newfilenamewithpath
                               newfilenameonly
                               newsubdirectory
                               completepath.

* If we are running on a non UNIX environment we will need to remove
* forward slashes from the additional path.
  if downloadtoserver is initial.
    if frontendopsystem = non_unix.
      if not additionalsubdirectory is initial.
        translate additionalsubdirectory using '/_'.
        if additionalsubdirectory+0(1) = '_'.
          shift additionalsubdirectory left by 1 places.
        endif.
      endif.
    endif.
  else.
    if serveropsystem = non_unix.
      if not additionalsubdirectory is initial.
        translate additionalsubdirectory using '/_'.
        if additionalsubdirectory+0(1) = '_'.
          shift additionalsubdirectory left by 1 places.
        endif.
      endif.
    endif.
  endif.

  case downloadtype.
*   Programs
    when is_program.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator objectname period
fileextension into newfilenamewithpath.
        concatenate userpath slashseparator into completepath.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator objectname period
fileextension into newfilenamewithpath.
        concatenate userpath slashseparator additionalsubdirectory into
completepath.
      endif.

*   Function Modules
    when is_function.
      if additionalsubdirectory is initial.
        find 'top' in includename ignoring case.
        if sy-subrc = 0.
          concatenate userpath slashseparator objectname
                               slashseparator 'Global-' objectname
                               period fileextension
                               into newfilenamewithpath.
        else.
          if includename cs mainfunctionno and not mainfunctionno is
initial.
            concatenate userpath slashseparator objectname
                                 slashseparator objectname
                                 period fileextension
                                 into newfilenamewithpath.
          else.
            concatenate userpath slashseparator objectname
                                 slashseparator objectname
                                 period fileextension
                                 into newfilenamewithpath.
          endif.
        endif.
        newsubdirectory = objectname.
        concatenate userpath slashseparator into completepath.
      else.
        find 'top' in includename ignoring case.
        if sy-subrc = 0.
          concatenate userpath slashseparator additionalsubdirectory
                               slashseparator objectname
                               slashseparator 'Global-' objectname
                               period fileextension
                               into newfilenamewithpath.
        else.
          if includename cs mainfunctionno and not mainfunctionno is
initial.
            concatenate userpath slashseparator additionalsubdirectory
                                 slashseparator objectname
                                 slashseparator objectname
                                 period fileextension
                                 into newfilenamewithpath.
          else.
            concatenate userpath slashseparator additionalsubdirectory
                                 slashseparator objectname
                                 slashseparator objectname
                                 period fileextension
                                 into newfilenamewithpath.
          endif.
        endif.
        concatenate additionalsubdirectory slashseparator objectname
into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into completepath.
      endif.

*   Table definition
    when is_table.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator objectname
                             slashseparator 'Dictionary-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator objectname into
newsubdirectory.
        concatenate userpath slashseparator objectname into completepath
.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator objectname
                             slashseparator 'Dictionary-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into completepath.
      endif.

*   Program & Function documentation
    when is_documentation.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator objectname
                             slashseparator 'Docs-'
                             objectname period
                             fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator objectname into
newsubdirectory.
        concatenate userpath slashseparator objectname into completepath
.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator objectname
                             slashseparator 'Docs-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into completepath.
      endif.

*   Screens
    when is_screen.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator 'Screens'
                             slashseparator 'screen_'
                             objectname period
                             fileextension into newfilenamewithpath.

        concatenate userpath slashseparator 'screens' into
newsubdirectory.
        concatenate userpath slashseparator 'screens' into completepath.

      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator 'Screens'
                             slashseparator 'screen_'
                             objectname period
                             fileextension into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator 'screens' into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator 'screens' into completepath.
      endif.

*   GUI title
    when is_guititle.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator 'Screens'
                             slashseparator 'gui_title_'
                             objectname period
                             fileextension into newfilenamewithpath.

        concatenate userpath slashseparator 'screens' into
newsubdirectory.
        concatenate userpath slashseparator 'screens' into completepath.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator 'Screens'
                             slashseparator 'gui_title_'
                             objectname period
                             fileextension into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator 'Screens' into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator 'Screens' into completepath.
      endif.

*   Message Class
    when is_messageclass.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator objectname
                             slashseparator 'Message class-'
                             objectname period
                             fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator objectname into
newsubdirectory.
        concatenate userpath slashseparator objectname into completepath
.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator objectname
                             slashseparator 'Message class-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into completepath.
      endif.

*   Class definition
    when is_class.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator objectname
                             slashseparator 'Class-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator objectname into
newsubdirectory.
        concatenate userpath slashseparator objectname into completepath
.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator objectname
                             slashseparator 'Class-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into completepath.
      endif.

*   Class definition
    when is_method.
      if additionalsubdirectory is initial.
        concatenate userpath slashseparator 'Method-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator objectname into
newsubdirectory.
        concatenate userpath slashseparator objectname into completepath
.
      else.
        concatenate userpath slashseparator additionalsubdirectory
                             slashseparator 'Method-'
                             objectname period fileextension
                             into newfilenamewithpath.

        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into newsubdirectory.
        concatenate userpath slashseparator additionalsubdirectory
slashseparator objectname into completepath.
      endif.
  endcase.

  translate completepath to lower case.
  concatenate objectname period fileextension into newfilenameonly.
  translate newfilenameonly to lower case.
  translate newfilenamewithpath to lower case.
  translate newsubdirectory to lower case.

* If we are running on a non UNIX environment we will need to remove
* incorrect characters from the filename.
  if downloadtoserver is initial.
    if frontendopsystem = non_unix.
      translate newfilenameonly using '/_'.
      translate newfilenamewithpath using '/_'.
      translate newfilenameonly using '< '.
      translate newfilenamewithpath using '< '.
      translate newfilenameonly using '> '.
      translate newfilenamewithpath using '> '.
      translate newfilenameonly using '? '.
      translate newfilenamewithpath using '? '.
      translate newfilenameonly using '| '.
      translate newfilenamewithpath using '| '.
      condense newfilenameonly no-gaps.
      condense newfilenamewithpath no-gaps.
    endif.
  else.
    if serveropsystem = non_unix.
      translate newfilenameonly using '/_'.
      translate newfilenamewithpath using '/_'.
      translate newfilenameonly using '< '.
      translate newfilenamewithpath using '< '.
      translate newfilenameonly using '> '.
      translate newfilenamewithpath using '> '.
      translate newfilenameonly using '? '.
      translate newfilenamewithpath using '? '.
      translate newfilenameonly using '| '.
      translate newfilenamewithpath using '| '.
      condense newfilenameonly no-gaps.
      condense newfilenamewithpath no-gaps.
    endif.
  endif.
endform.                    "buildFilename
"buildFilename

*-----------------------------------------------------------------------
*  saveFileToPc...    write an internal table to a file on the local PC
*-----------------------------------------------------------------------
form savefiletopc using idownload type standard table
                        value(filenamewithpath)
                        value(filename)
                        value(writefieldseparator)
                        value(truncatetrailingblanks)
                        value(displayprogressmessage).

  data: statusmessage type string.
  data: objfile type ref to cl_gui_frontend_services.
  data: strsubrc type string.

  if not displayprogressmessage is initial.
    concatenate `Downloading: ` filename into statusmessage.
    perform displaystatus using statusmessage 0.
  endif.

  create object objfile.
  call method objfile->gui_download
    exporting
      filename                = filenamewithpath
      filetype                = 'ASC'
      write_field_separator   = writefieldseparator
      trunc_trailing_blanks   = truncatetrailingblanks
    changing
      data_tab                = idownload[]
    exceptions
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23.

  if sy-subrc <> 0.
    strsubrc = sy-subrc.
    concatenate `File save error: ` filename ` sy-subrc: ` strsubrc into statusmessage.
    perform displaystatus using statusmessage 3.
  endif.
endform.                    "saveFileToPc
"saveFileToPc

*-----------------------------------------------------------------------
*  saveFileToServer...    write an internal table to a file on the SAP
* server
*-----------------------------------------------------------------------
form savefiletoserver using idownload type standard table
                            value(filenamewithpath)
                            value(filename)
                            value(path)
                            value(displayprogressmessage).

  data: wadownload type string.
  data: statusmessage type string.

  if not displayprogressmessage is initial.
    concatenate `Downloading: ` filename into statusmessage.
    perform displaystatus using statusmessage 0.
  endif.

  read table iserverpaths with key table_line = path.
  if sy-subrc <> 0.
    perform createserverdirectory using path.
    append path to iserverpaths.
  endif.

  open dataset filenamewithpath for output in text mode encoding default.
  if sy-subrc = 0.
    loop at idownload into wadownload.
      transfer wadownload to filenamewithpath.
      if sy-subrc <> 0.
        message e000(oo) with 'Error transferring data to file'.
      endif.
    endloop.

    close dataset filenamewithpath.
    if sy-subrc <> 0.
      message e000(oo) with 'Error closing file'.
    endif.
  else.
*   Unable to create a file
    message e000(oo) with 'Error creating file on SAP server' 'check permissions'.
  endif.
endform.                    "saveFileToServer
"saveFileToServer

*-----------------------------------------------------------------------
* createServerDirectory...
*-----------------------------------------------------------------------
form createserverdirectory using value(path).

*  Parameters for remove command.
  data: param1 type sxpgcolist-parameters.
*  Return status
  data: funcstatus type extcmdexex-status.
*  Command line listing returned by the function
  data: iserveroutput type standard table of btcxpm.
  data: waserveroutput type btcxpm.
*  Targetsystem type conversion variable.
  data: target type rfcdisplay-rfchost.
* Operating system
  data: operatingsystem type sxpgcolist-opsystem.
*  Head for split command.
  data: head type string..
  data: tail type string.

  param1 = path.
  target = sy-host.
  operatingsystem = sy-opsys.

  call function 'SXPG_COMMAND_EXECUTE'
    exporting
      commandname                   = 'ZMKDIR'
      additional_parameters         = param1
      operatingsystem               = operatingsystem
      targetsystem                  = target
      stdout                        = 'X'
      stderr                        = 'X'
      terminationwait               = 'X'
    importing
      status                        = funcstatus
    tables
      exec_protocol                 = iserveroutput[]
    exceptions
      no_permission                 = 1
      command_not_found             = 2
      parameters_too_long           = 3
      security_risk                 = 4
      wrong_check_call_interface    = 5
      program_start_error           = 6
      program_termination_error     = 7
      x_error                       = 8
      parameter_expected            = 9
      too_many_parameters           = 10
      illegal_command               = 11
      wrong_asynchronous_parameters = 12
      cant_enq_tbtco_entry          = 13
      jobcount_generation_error     = 14
      others                        = 15.

  if sy-subrc = 0.
*   Although the function succeded did the external command actually
* work
    if funcstatus = 'E'.
*     External command returned with an error
      if sy-opsys cs 'Windows NT'.
        read table iserveroutput index 1 into waserveroutput.
        if waserveroutput-message ns 'already exists'.
*         An error occurred creating the directory on the server
          message e000(oo) with 'An error occurred creating a directory'.
        endif.
      else.
        read table iserveroutput index 2 into waserveroutput.
        split waserveroutput-message at space into head tail.
        shift tail left deleting leading space.
        if tail <> 'Do not specify an existing file.'.
*         An error occurred creating the directory on the server
          message e000(oo) with 'An error occurred creating a directory'.
        endif.
      endif.
    endif.
  else.
    case sy-subrc.
      when 1.
*       No permissions to run the command
        message e000(oo) with 'No permissions to run external command ZMKDIR'.
      when 2.
*       External command not found
        message e000(oo) with 'External comand ZMKDIR not found'.

      when others.
*       Unable to create the directory
        message e000(oo) with 'An error occurred creating a directory'
                              ', subrc:'
                              sy-subrc.
    endcase.
  endif.
endform.                    "createServerDirectory
"createServerDirectory

*-----------------------------------------------------------------------
* appendTextElements...
*-----------------------------------------------------------------------
form appendtextelements using iloctextelements like dumitexttab[]
                              iloclines like dumihtml[].

  field-symbols: <watextelement> type ttexttable.
  data: waline type string.

  if lines( iloctextelements ) > 0.
    append '' to iloclines.

    append '*Text elements' to iloclines.
    append '*----------------------------------------------------------'  to  iloclines.
    loop at iloctextelements assigning <watextelement>.
      concatenate '*  ' <watextelement>-key <watextelement>-entry into waline separated by space.
      append waline to iloclines.
    endloop.
  endif.
endform.                    "appendTextElements
"appendTextElements

*-----------------------------------------------------------------------
* appendGUITitles...
*-----------------------------------------------------------------------
form appendguititles using ilocguititles like dumiguititle[]
                           iloclines like dumihtml[].

  field-symbols: <waguititle> type tguititle.
  data: waline type string.

  if lines( ilocguititles ) > 0.
    append '' to iloclines.

    append '*GUI Texts' to iloclines.
    append '*----------------------------------------------------------'  to  iloclines.
    loop at ilocguititles assigning <waguititle>.
      concatenate '*  ' <waguititle>-obj_code '-->' <waguititle>-text into waline separated by space.
      append waline to iloclines.
    endloop.
  endif.
endform.                    "appendGUITitles
"appendGUITitles

*-----------------------------------------------------------------------
* appendSelectionTexts...
*-----------------------------------------------------------------------
form appendselectiontexts using ilocselectiontexts like dumitexttab[]
                                iloclines like dumihtml[].

  field-symbols: <waselectiontext> type ttexttable.
  data: waline type string.

  if lines( ilocselectiontexts ) > 0.
    append '' to iloclines.
    append '' to iloclines.

    append '*Selection texts' to iloclines.
    append '*----------------------------------------------------------' to  iloclines.
    loop at ilocselectiontexts assigning <waselectiontext>.
      concatenate '*  ' <waselectiontext>-key <waselectiontext>-entry into waline separated by space.
      append waline to iloclines.
    endloop.
  endif.
endform.                    "appendSelectionTexts
"appendSelectionTexts

*-----------------------------------------------------------------------
* appendExceptionTexts...
*-----------------------------------------------------------------------
form appendexceptiontexts using iconcepts like dumiconcepts[]
                                iloclines like dumihtml[].

  field-symbols: <waconcept> type tconcept.
  data: waline type string.
  data: concepttext type sotr_txt.

  if lines( iconcepts ) > 0.
    append '' to iloclines.

    append '*Exception texts' to iloclines.
    append '*----------------------------------------------------------'  to  iloclines.
    loop at iconcepts assigning <waconcept>.
*     Find the text for this concept
      call function 'SOTR_GET_TEXT_KEY' exporting concept = <waconcept>-concept
                                                  langu = sy-langu
                                                  search_in_second_langu  = 'X'
*                                                  second_langu = 'DE'
                                        importing e_text = concepttext
                                        exceptions no_entry_found = 1
                                                   parameter_error = 2
                                                   others  = 3.

      if sy-subrc = 0.
        concatenate '*  ' <waconcept>-constname '-' concepttext  into waline separated by space.
        append waline to iloclines.
      endif.
    endloop.
  endif.
endform.                    "appendExceptionTexts
"appendExceptionTexts

*-----------------------------------------------------------------------
* downloadFunctionDocs...
*-----------------------------------------------------------------------
form downloadfunctiondocs using value(functionname)
                                value(functiondescription)
                                value(userfilepath)
                                value(fileextension)
                                value(converttohtml)
                                value(slashseparator)
                                value(savetoserver)
                                value(displayprogressmessage)
                                      subdir
                                      documentationdownloaded.

  data: ilines type standard table of string with header line.
  data: idocumentation type standard table of funct with header line.
  data: iexceptions type standard table of rsexc with header line.
  data: iexport type standard table of rsexp with header line.
  data: iparameter type standard table of rsimp with header line.
  data: itables type standard table of rstbl with header line.
  data: iscriptlines type standard table of tline with header line.
  data: htmlpagename type string.
  data: newfilenamewithpath type string.
  data: newfilenameonly type string.
  data: object like dokhl-object.
  data: stringlength type i value 0.
  data: newsubdirectory type string.
  data: waline(255).
  data: completesavepath type string.

  documentationdownloaded = false.
  object = functionname.

  call function 'FUNCTION_IMPORT_DOKU'
    exporting
      funcname           = functionname
    tables
      dokumentation      = idocumentation
      exception_list     = iexceptions
      export_parameter   = iexport
      import_parameter   = iparameter
      tables_parameter   = itables
    exceptions
      error_message      = 1
      function_not_found = 2
      invalid_name       = 3
      others             = 4.

  call function 'DOCU_GET'
    exporting
      id                     = 'FU'
      langu                  = sy-langu
      object                 = object
      typ                    = 'T'
      version_active_or_last = 'L'
    tables
      line                   = iscriptlines
    exceptions
      no_docu_on_screen      = 1
      no_docu_self_def       = 2
      no_docu_temp           = 3
      ret_code               = 4
      others                 = 5.

  if sy-subrc = 0 and not ( iscriptlines[] is initial ).
    append 'SHORT TEXT' to ilines.
    concatenate space functiondescription into functiondescription separated by space.
    append functiondescription to ilines.
    append space to ilines.
    loop at iscriptlines.
      move iscriptlines-tdline to ilines.
      concatenate space ilines into ilines separated by space.
      while ilines cp '&*' or ilines cp '*&'.
        replace '&' into ilines with space.
        shift ilines left deleting leading space.
      endwhile.
      append ilines.
    endloop.

    clear ilines.
    if not ( idocumentation[] is initial ).
      append ilines.
      append 'PARAMETER DOCUMENTATION' to ilines.
      append '-----------------------' to ilines.
      append ilines.

      describe field idocumentation-parameter length stringlength in character mode.
      stringlength = stringlength + 3.
      loop at idocumentation.
        move idocumentation-parameter to waline.
        move idocumentation-stext to waline+stringlength.
        append waline to ilines.
      endloop.
    endif.

    concatenate `Documentation - ` functionname into htmlpagename.

    if converttohtml is initial.
      append ilines.
      append
'----------------------------------------------------------------------------------' to ilines.
      append ilines.
      perform buildfootermessage using 'TEXT'
                                       ilines.
      append ilines.
    else.
      perform convertcodetohtml using ilines[]
                                      htmlpagename
                                      space
                                      is_documentation
                                      true
                                      space
                                      space
                                      space
                                      space
                                      space
                                      space.
    endif.

    perform buildfilename using userfilepath
                                subdir
                                functionname
                                space
                                space
                                fileextension
                                is_documentation
                                savetoserver
                                slashseparator
                                newfilenamewithpath
                                newfilenameonly
                                newsubdirectory
                                completesavepath.

    if savetoserver is initial.
      perform savefiletopc using ilines[]
                                 newfilenamewithpath
                                 newfilenameonly
                                 space
                                 space
                                 displayprogressmessage.
    else.
      perform savefiletoserver using ilines[]
                                     newfilenamewithpath
                                     newfilenameonly
                                     completesavepath
                                     displayprogressmessage.
    endif.

    documentationdownloaded = true.
  endif.
endform.                    "downloadFunctionDocs
"downloadFunctionDocs

*-----------------------------------------------------------------------
*  downloadScreens...
*-----------------------------------------------------------------------
form downloadscreens using ilocscreenflow like dumiscreen[]
                           value(programname)
                           value(userfilepath)
                           value(textfileextension)
                           value(subdir)
                           value(slashseparator)
                           value(savetoserver)
                           value(displayprogressmessage).


  tables: d020t.
  data: header like d020s.
  data: ifields type standard table of d021s with header line.
  data: iflowlogic type standard table of d022s with header line.
  field-symbols <wascreen> type tscreenflow.
  data: wacharheader type scr_chhead.
  data: iscreenchar type standard table of scr_chfld with header line.
  data: ifieldschar type standard table of scr_chfld with header line.
  data: stars type string value
  '****************************************************************'.
  data: comment1 type string value '*   This file was generated by Direct Download Enterprise.     *'.
  data: comment2 type string value '*   Please do not change it manually.                          *'.
  data: dynprotext type string value '%_DYNPRO'.
  data: headertext type string value '%_HEADER'.
  data: paramstext type string value '%_PARAMS'.
  data: descriptiontext type string value '%_DESCRIPTION'.
  data: fieldstext type string value '%_FIELDS'.
  data: flowlogictext type string value '%_FLOWLOGIC'.
  data: programlength type string.
  data: newsubdirectory type string.
  data: newfilenamewithpath type string.
  data: newfilenameonly type string.
  data: completesavepath type string.

  loop at ilocscreenflow assigning <wascreen>.
    call function 'RS_IMPORT_DYNPRO'
      exporting
        dylang = sy-langu
        dyname = programname
        dynumb = <wascreen>-screen
      importing
        header = header
      tables
        ftab   = ifields
        pltab  = iflowlogic.

    call function 'RS_SCRP_HEADER_RAW_TO_CHAR'
      exporting
        header_int  = header
      importing
        header_char = wacharheader
      exceptions
        others      = 1.

*   Add in the top comments for the file
    append stars to iscreenchar .
    append comment1 to iscreenchar.
    append comment2 to iscreenchar.
    append stars to iscreenchar.

*   Screen identification
    append dynprotext to iscreenchar.
    append wacharheader-prog to iscreenchar.
    append wacharheader-dnum to iscreenchar.
    append sy-saprl to iscreenchar.
    describe field d020t-prog length programlength in character mode.
    concatenate `                ` programlength into iscreenchar.
    append iscreenchar.

*   Header
    append headertext to iscreenchar.
    append wacharheader to iscreenchar.

*   Description text
    append descriptiontext to iscreenchar.
    select single dtxt from d020t into iscreenchar
                       where prog = programname
                             and dynr = <wascreen>-screen
                             and lang = sy-langu.
    append iscreenchar.

*   Fieldlist text
    append fieldstext to iscreenchar.

    call function 'RS_SCRP_FIELDS_RAW_TO_CHAR'
      tables
        fields_int  = ifields[]
        fields_char = ifieldschar[]
      exceptions
        others      = 1.

    loop at ifieldschar.
      move-corresponding ifieldschar to iscreenchar.
      append iscreenchar.
    endloop.

*   Flowlogic text
    append flowlogictext to iscreenchar.
*   Flow logic.
    loop at iflowlogic.
      append iflowlogic to iscreenchar.
    endloop.

    perform buildfilename using userfilepath
                                subdir
                                wacharheader-dnum
                                space
                                space
                                textfileextension
                                is_screen
                                savetoserver
                                slashseparator
                                newfilenamewithpath
                                newfilenameonly
                                newsubdirectory
                                completesavepath.

    if savetoserver is initial.
*     Save the screen to the local computer
      perform savefiletopc using iscreenchar[]
                                 newfilenamewithpath
                                 newfilenameonly
                                 'X'
                                 'X'
                                 displayprogressmessage.
    else.
*     Save the screen to the SAP server
      perform savefiletoserver using iscreenchar[]
                                     newfilenamewithpath
                                     newfilenameonly
                                     completesavepath
                                     displayprogressmessage.
    endif.

    clear header. clear wacharheader.
    clear iscreenchar[].
    clear ifieldschar[].
    clear ifields[].
    clear iflowlogic[].
  endloop.
endform.                    "downloadScreens
"downloadScreens

*-----------------------------------------------------------------------
*  downloadGUITitles..
*-----------------------------------------------------------------------
form downloadguititles using ilocguititles like dumiguititle[]
                             value(userfilepath)
                             value(textfileextension)
                             value(subdir)
                             value(slashseparator)
                             value(savetoserver)
                             value(displayprogressmessage).

  data: ilines type standard table of string with header line.
  field-symbols: <waguititle> type tguititle.
  data: newsubdirectory type string.
  data: newfilenamewithpath type string.
  data: newfilenameonly type string.
  data: completesavepath type string.

  loop at ilocguititles assigning <waguititle>.
    append <waguititle>-text to ilines.

    perform buildfilename using userfilepath
                                subdir
                                <waguititle>-obj_code
                                space
                                space
                                textfileextension
                                is_guititle
                                savetoserver
                                slashseparator
                                newfilenamewithpath
                                newfilenameonly
                                newsubdirectory
                                completesavepath.

    if savetoserver is initial.
      perform savefiletopc using ilines[]
                                 newfilenamewithpath
                                 newfilenameonly
                                 space
                                 space
                                 displayprogressmessage.
    else.
      perform savefiletoserver using ilines[]
                                     newfilenamewithpath
                                     newfilenameonly
                                     completesavepath
                                     displayprogressmessage.
    endif.

    clear ilines[].
  endloop.
endform.                    "downloadGUITitles
"downloadGUITitles

*-----------------------------------------------------------------------
*  downloadPrograms..
*-----------------------------------------------------------------------
form downloadprograms using ilocprogram like iprograms[]
                            ilocfunctions like ifunctions[]
                            value(userfilepath)
                            value(fileextension)
                            value(htmlfileextension)
                            value(textfileextension)
                            value(converttohtml)
                            value(syntaxhighlightcomments)
                            value(customernamerange)
                            value(getincludes)
                            value(getdictstruct)
                            value(downloaddocumentation)
                            value(sorttablesasc)
                            value(slashseparator)
                            value(savetoserver)
                            value(displayprogressmessage).


  data: iprogfunctions type standard table of tfunction with header line.
  field-symbols: <waprogram> type tprogram.
  field-symbols: <wainclude> type tinclude.
  data: iemptytextelements type standard table of ttexttable.
  data: iemptyselectiontexts type standard table of ttexttable.
  data: iemptymessages type standard table of tmessage.
  data: iemptyguititles type standard table of tguititle.
  data: locconverttohtml(1).
  data: locfileextension type string.

  sort ilocprogram ascending by progname.

  loop at ilocprogram assigning <waprogram>.
*   if the program to download is this program then always download as
* text otherwise you will get a rubbish file
    if <waprogram>-progname = sy-cprog.
      locconverttohtml = ''.
      locfileextension = textextension.
    else.
      locconverttohtml = converttohtml.
      locfileextension = fileextension.
    endif.

*   Download the main program
    perform readincludeanddownload using <waprogram>-itextelements[]
                                         <waprogram>-iselectiontexts[]
                                         <waprogram>-imessages[]
                                         <waprogram>-iguititle[]
                                         <waprogram>-progname
                                         space
                                         <waprogram>-programtitle
                                         is_program
                                         userfilepath
                                         locfileextension
                                         <waprogram>-progname
                                         locconverttohtml
                                         syntaxhighlightcomments
                                         customernamerange
                                         getincludes
                                         getdictstruct
                                         slashseparator
                                         savetoserver
                                         displayprogressmessage.

*   Download screens.
    if not <waprogram>-iscreenflow[] is initial.
      perform downloadscreens using <waprogram>-iscreenflow[]
                                    <waprogram>-progname
                                    userfilepath
                                    textfileextension
                                    <waprogram>-progname
                                    slashseparator
                                    savetoserver
                                    displayprogressmessage.
    endif.

*   Download GUI titles
    if not <waprogram>-iguititle[] is initial.
      perform downloadguititles using <waprogram>-iguititle
                                      userfilepath
                                      textfileextension
                                      <waprogram>-progname
                                      slashseparator
                                      savetoserver
                                      displayprogressmessage.
    endif.

*   Download all other includes
    loop at <waprogram>-iincludes assigning <wainclude>.
      perform readincludeanddownload using iemptytextelements[]
                                           iemptyselectiontexts[]
                                           iemptymessages[]
                                           iemptyguititles[]
                                           <wainclude>-includename
                                           space
                                           <wainclude>-includetitle
                                           is_program
                                           userfilepath
                                           fileextension
                                           <waprogram>-progname
                                           converttohtml
                                           syntaxhighlightcomments
                                           customernamerange
                                           getincludes
                                           getdictstruct
                                           slashseparator
                                           savetoserver
                                           displayprogressmessage.

    endloop.

*   Download all dictionary structures
    if not <waprogram>-idictstruct[] is initial.
      perform downloadddstructures using <waprogram>-idictstruct[]
                                         userfilepath
                                         htmlfileextension
                                         <waprogram>-progname
                                         sorttablesasc
                                         slashseparator
                                         savetoserver
                                         displayprogressmessage.
    endif.

*   Download any functions used by these programs
    loop at ilocfunctions into iprogfunctions where programlinkname = <waprogram>-progname.
      append iprogfunctions.
    endloop.

    if not iprogfunctions[] is initial.
      perform downloadfunctions using iprogfunctions[]
                                      userfilepath
                                      fileextension
                                      <waprogram>-progname
                                      downloaddocumentation
                                      converttohtml
                                      syntaxhighlightcomments
                                      customernamerange
                                      getincludes
                                      getdictstruct
                                      textfileextension
                                      htmlfileextension
                                      sorttablesasc
                                      slashseparator
                                      savetoserver
                                      displayprogressmessage.
      clear iprogfunctions[].
    endif.
  endloop.
endform.                    "downloadPrograms
"downloadPrograms

*-----------------------------------------------------------------------
*  downloadClasses..
*-----------------------------------------------------------------------
form downloadclasses using ilocclasses like iclasses[]
                           ilocfunctions like ifunctions[]
                           value(userfilepath)
                           value(fileextension)
                           value(htmlfileextension)
                           value(textfileextension)
                           value(converttohtml)
                           value(syntaxhighlightcomments)
                           value(customernamerange)
                           value(getincludes)
                           value(getdictstruct)
                           value(downloaddocumentation)
                           value(sorttablesasc)
                           value(slashseparator)
                           value(savetoserver)
                           value(displayprogressmessage).


  data: iclassfunctions type standard table of tfunction with header line.
  field-symbols: <waclass> type tclass.
  field-symbols: <wamethod> type tmethod.

  sort ilocclasses ascending by clsname.

  loop at ilocclasses assigning <waclass>.
*   Download the class
    perform readclassanddownload using <waclass>
                                        <waclass>-clsname
                                        space
                                        is_class
                                        userfilepath
                                        fileextension
                                        space
                                        converttohtml
                                        syntaxhighlightcomments
                                        customernamerange
                                        getincludes
                                        getdictstruct
                                        slashseparator
                                        savetoserver
                                        displayprogressmessage.


*   Download all of the methods
    loop at <waclass>-imethods assigning <wamethod>.
      perform readmethodanddownload using <wamethod>
                                          <wamethod>-cmpname
                                          <wamethod>-methodkey
                                          space
                                          is_method
                                          userfilepath
                                          fileextension
                                          <waclass>-clsname
                                          converttohtml
                                          syntaxhighlightcomments
                                          customernamerange
                                          getincludes
                                          getdictstruct
                                          slashseparator
                                          savetoserver
                                          displayprogressmessage.

    endloop.

*   Download all dictionary structures
    if not <waclass>-idictstruct[] is initial.
      perform downloadddstructures using <waclass>-idictstruct[]
                                         userfilepath
                                         htmlfileextension
                                         <waclass>-clsname
                                         sorttablesasc
                                         slashseparator
                                         savetoserver
                                         displayprogressmessage.
    endif.

*   Download any functions used by these programs
    loop at ilocfunctions into iclassfunctions where programlinkname = <waclass>-clsname.
      append iclassfunctions.
    endloop.

    if not iclassfunctions[] is initial.
      perform downloadfunctions using iclassfunctions[]
                                      userfilepath
                                      fileextension
                                      <waclass>-clsname
                                      downloaddocumentation
                                      converttohtml
                                      syntaxhighlightcomments
                                      customernamerange
                                      getincludes
                                      getdictstruct
                                      textfileextension
                                      htmlfileextension
                                      sorttablesasc
                                      slashseparator
                                      savetoserver
                                      displayprogressmessage.
      clear iclassfunctions[].
    endif.
  endloop.
endform.                    "downloadClasses
"downloadClasses

*-----------------------------------------------------------------------
*  reFormatClassCode...   Expand a classes public, private and protected
* section from the 72 characters that the class
*                         builder sets it to back to the wide editor
* mode
*-----------------------------------------------------------------------
form reformatclasscode using itemplines like dumihtml[].

  field-symbols: <waline> type string.
  data: newline type string.
  data: inewtable type standard table of string.
  data: foundone type i value false.

  loop at itemplines assigning <waline>.
    if not <waline> is initial.
      if foundone = false.
        find 'data' in <waline> respecting case.
        if sy-subrc = 0.
          foundone = true.
        endif.

        find 'constants' in <waline> respecting case.
        if sy-subrc = 0.
          foundone = true.
        endif.

        if foundone = true.
          newline = <waline>.

          if ( newline cs '.' or newline cs '*' ).
            replace '!' in <waline> with ''.
            append newline to inewtable.
            clear newline.
            foundone = false.
          endif.
        else.
          replace '!' in <waline> with ''.
          append <waline> to inewtable.
        endif.
      else.
        concatenate newline <waline> into newline separated by space.
        if ( newline cs '.' or newline cs '*' ).
          append newline to inewtable.
          clear newline.
          foundone = false.
        endif.
      endif.
    else.
      replace '!' in <waline> with ''.
      append <waline> to inewtable[].
    endif.
  endloop.

  itemplines[] = inewtable[].
endform.                    "reFormatClassCode
"reFormatClassCode

***********************************************************************************************************************
**********************************************HTML*ROUTINES************************************************************
***********************************************************************************************************************

*-----------------------------------------------------------------------
*  convertDDToHTML...   Convert text description to HTML
*-----------------------------------------------------------------------
form convertddtohtml using ilocdictstructure like dumidictstructure[]
                           ilochtml like dumihtml[]
                           value(tablename)
                           value(tabletitle)
                           value(sorttablesasc).

  data: icolumncaptions type standard table of string with header line.
  data: wadictionary type tdicttablestructure.
  data: wahtml type string.
  data: title type string.

  perform buildcolumnheaders using icolumncaptions[].

* Add a html header to the table
  concatenate 'Dictionary object-' tablename into title separated by space.
  perform addhtmlheader using ilochtml[]
                              title.

  concatenate '<h2>' tablename '</h2>' into wahtml.
  append wahtml to ilochtml.
  append '' to ilochtml.

  concatenate '<h3>' tabletitle '</h3>' into wahtml.
  append wahtml to ilochtml.
  append '' to ilochtml.

* Do we need to sort the fields into alphabetical order
  if not sorttablesasc is initial.
    sort ilocdictstructure ascending by fieldname.
  endif.

  perform convertitabtohtml using icolumncaptions[]
                                  ilocdictstructure[]
                                  ilochtml
                                  'X'
                                  colour_black
                                  ''
                                  colour_yellow
                                  ''
                                  background_colour
                                  'Arial'
                                  'green'
                                  '1'
                                  '1'.

* Add a html footer to the table
  append '<br>' to ilochtml.
  perform addhtmlfooter using ilochtml[].
endform.                    "convertDDToHTML
"convertDDToHTML

*-----------------------------------------------------------------------
*  convertITABtoHtml... produces a html table from an internal table
*-----------------------------------------------------------------------
form convertitabtohtml using ilocheader like dumiheader[]
                             ilocdictstructure like dumidictstructure[]
                             ilochtml like dumihtml[]
                             value(includerowcount)
                             headingbackcolour
                             headingfontname
                             headingfontcolour
                             headingfontsize
                             bodybackcolour
                             bodyfontname
                             bodyfontcolour
                             bodyfontsize
                             bordersize.

* Holds one cell from the internal table
  field-symbols: <fsfield>.
* The value of one cell form the internal table
  data: wtextcell type string.
* work area for putting the CSV value into
  data: wacsvtable type string.
* Have we used any font tags in the html code
  data: usedafontattribute type i value 0.
* Work area for HTML table
  data: wahtml type string.
* Loop counter for adding row numbers onto the output table
  data: loopcounter type string.
* Work area for header table
  field-symbols: <waheader> type string.
  field-symbols: <ilocdictstructure> type tdicttablestructure.

  concatenate '<table border="' bordersize '">' into wahtml.
  append wahtml to ilochtml.

  if not ilocheader[] is initial.
    append '<tr>' to ilochtml.
  endif.

  loop at ilocheader assigning <waheader>.
    if headingbackcolour is initial.
      wahtml = '<th>'.
    else.
      concatenate '<th bgcolor="' headingbackcolour '">' into wahtml.
    endif.

    if not headingfontname is initial or not headingfontcolour is initial or not headingfontsize is initial.
      concatenate wahtml '<font' into wahtml.

*      Add the font name
      if not headingfontname is initial.
        concatenate wahtml ' face ="' into wahtml.
        concatenate wahtml headingfontname '"' into wahtml.
      endif.

*      Add the font colour
      if not headingfontcolour is initial.
        concatenate wahtml ' color ="' into wahtml.
        concatenate wahtml headingfontcolour '"' into wahtml.
      endif.

*      Add the fontsize
      if not headingfontsize is initial.
        concatenate wahtml' size ="' into wahtml.
        concatenate wahtml  headingfontsize '"' into wahtml.
      endif.

      concatenate wahtml '>' into wahtml.
      usedafontattribute = true.
    endif.

*   Add the caption name
    concatenate wahtml <waheader> into wahtml.

    if usedafontattribute = true.
      concatenate wahtml '</font>' into wahtml.
      usedafontattribute = false.
    endif.

    concatenate wahtml '</th>' into wahtml.
    append wahtml to ilochtml.
  endloop.

  append '</tr>' to ilochtml.
  free ilocheader.


*  Line item data
  loop at ilocdictstructure assigning <ilocdictstructure>.

    loopcounter = sy-tabix.

    append '' to ilochtml.
    append '<tr>' to ilochtml.

*   Add the row count
    if not includerowcount is initial.
      if bodybackcolour is initial.
        wahtml = '<td>'.
      else.
        concatenate '<td bgcolor="' bodybackcolour '">' into wahtml.
      endif.

      if not bodyfontname is initial or not bodyfontcolour is initial or not bodyfontsize is initial.
        concatenate wahtml '<font' into wahtml.

*        Add the font name
        if not bodyfontname is initial.
          concatenate wahtml ' face ="' into wahtml.
          concatenate wahtml bodyfontname '"' into wahtml.
        endif.

*        Add the font colour
        if not bodyfontcolour is initial.
          concatenate wahtml ' color ="' into wahtml.
          concatenate wahtml bodyfontcolour '"' into wahtml.
        endif.

*        Add the fontsize
        if not bodyfontsize is initial.
          concatenate wahtml ' size ="' into wahtml.
          concatenate wahtml bodyfontsize '"' into wahtml.
        endif.

        concatenate wahtml '>' into wahtml.
        usedafontattribute = true.
      endif.

*     Add the row number into the table
      concatenate wahtml loopcounter into wahtml.


      if usedafontattribute = true.
        concatenate wahtml '</font>' into wahtml.
        usedafontattribute = false.
      endif.

      concatenate wahtml '</td>' into wahtml.
      append wahtml to ilochtml.
    endif.

    do.
*     Assign each field in the table to the field symbol
      assign component sy-index of structure <ilocdictstructure> to <fsfield>.
      if sy-subrc = 0.
        move <fsfield> to wtextcell.

*       Cell data processing
        if bodybackcolour is initial.
          wahtml = '<td>'.
        else.
          concatenate '<td bgcolor="' bodybackcolour '">' into wahtml.
        endif.

        if not bodyfontname is initial or not bodyfontcolour is initial or not bodyfontsize is initial.
          concatenate wahtml '<font' into wahtml.

*          Add the font name
          if not bodyfontname is initial.
            concatenate wahtml ' face ="' into wahtml.
            concatenate wahtml bodyfontname '"' into wahtml.
          endif.

*          Add the font colour
          if not bodyfontcolour is initial.
            concatenate wahtml ' color ="' into wahtml.
            concatenate wahtml bodyfontcolour '"' into wahtml.
          endif.

*          Add the fontsize
          if not bodyfontsize is initial.
            concatenate wahtml ' size ="' into wahtml.
            concatenate wahtml bodyfontsize '"' into wahtml.
          endif.

          concatenate wahtml '>' into wahtml.
          usedafontattribute = true.
        endif.

*       Add the caption name
        if wtextcell is initial.
          concatenate wahtml '&nbsp;' into wahtml.
        else.
          concatenate wahtml wtextcell into wahtml.
        endif.

        if usedafontattribute = true.
          concatenate wahtml '</font>' into wahtml.
          usedafontattribute = false.
        endif.

        concatenate wahtml '</td>' into wahtml.
        append wahtml to ilochtml.
      else.
        exit.
      endif.
    enddo.

    append '</tr>' to ilochtml.
  endloop.

  append '</table>' to ilochtml.
endform.                    "convertITABtoHtml
"convertITABtoHtml

*-----------------------------------------------------------------------
*  convertCodeToHtml... Builds an HTML table based upon a text table.
*-----------------------------------------------------------------------
form convertcodetohtml using icontents like dumihtml[]
                             value(programname)
                             value(shortdescription)
                             value(sourcecodetype)
                             value(functiondocumentationexists)
                             value(ismainfunctioninclude)
                             value(syntaxhighlightcomments)
                             value(htmlextension)
                             value(customernamerange)
                             value(getincludes)
                             value(getdictstructures).

  data: htmltable type standard table of string with header line.
  data: listingname type string value 'Code listing for:'.
  data: descriptionname type string value `Description: `.
  data: head(255).
  data: tail(255).
  data: mytabix type sytabix.
  data: nextline type sytabix.
  data: hyperlinkname type string.
  data: copyofcurrentline type string.
  data: currentlinelength type i value 0.
  data: copylinelength type i value 0.
  data: ignorefuturelines type i value false.
  data: foundasterix type i value false.
  data: lowercaselink type string.
  data: wanextline type string.
  data: wacontent(255).

* Add a html header to the table
  perform addhtmlheader using htmltable[]
                              programname.

  concatenate listingname programname into listingname separated by space.
  concatenate '<font size="3" face = "Arial" color="' colour_black '"><b>' listingname '</b></font>' into htmltable.
  append htmltable.

  if not shortdescription is initial.
    append '<br>' to htmltable.
    concatenate descriptionname shortdescription into descriptionname separated by space.
    concatenate '<font size="3" face = "Arial" color="' colour_black '"><b>' descriptionname '</b></font>' into htmltable.
    append htmltable.
  endif.

  htmltable = '<hr>'.
  append htmltable.

  htmltable = '<pre width="100">'.
  append htmltable.

  loop at icontents into wacontent.
    mytabix = sy-tabix.

    if not ( icontents is initial ).
      while ( wacontent cs '<' or wacontent cs '>' ).
        replace '<' in wacontent with lt.
        replace '>' in wacontent with gt.
      endwhile.

      if wacontent+0(1) <> asterix.
        currentlinelength = strlen( wacontent ).
        copyofcurrentline = wacontent.

*       Don't hyperlink anything for files of type documentation
        if sourcecodetype <> is_documentation.
*         Check for any functions to highlight
          if ( wacontent cs callfunction ) and ( wacontent <> 'DESTINATION' ).
            nextline = mytabix + 1.
            read table icontents into wanextline index nextline.
            translate wanextline to upper case.
            if wanextline ns 'DESTINATION'.
              shift copyofcurrentline left deleting leading space.

              copylinelength = strlen( copyofcurrentline ).

              split copyofcurrentline at space into head tail.
              split tail at space into head tail.
              split tail at space into head tail.
*             Function name is now in head
              translate head using ''' '.
              shift head left deleting leading space.

              try.
                  if head+0(1) = 'Y' or head+0(1) = 'Z' or head+0(1) = 'y'
                  or head+0(1) = 'z' or head cs customernamerange.
*                 Definately a customer function module
                    hyperlinkname = head.

                    if sourcecodetype = is_function.
                      copyofcurrentline = 'call function <a href ="../'.
                    else.
                      copyofcurrentline = 'call function <a href ="'.
                    endif.

                    lowercaselink = hyperlinkname.
                    translate lowercaselink to lower case.
*                 If we are running on a non UNIX environment we will
* need to remove forward slashes
                    if frontendopsystem = non_unix.
                      translate lowercaselink using '/_'.
                    endif.

                    concatenate copyofcurrentline
                                lowercaselink     "hyperlinkName
                                '/'
                                lowercaselink     "hyperlinkName
                                period htmlextension '">'
                                ''''
                                hyperlinkname
                                ''''
                                '</a>'
                                tail into copyofcurrentline.

*                 Pad the string back out with spaces
                    while copylinelength < currentlinelength.
                      shift copyofcurrentline right by 1 places.
                      copylinelength = copylinelength + 1.
                    endwhile.

                    wacontent = copyofcurrentline.
                  endif.
                catch cx_sy_range_out_of_bounds into objruntimeerror.
              endtry.
            endif.
          endif.
        endif.

*       Check for any customer includes to hyperlink
        if wacontent cs include or wacontent cs lowinclude.
          shift copyofcurrentline left deleting leading space.
          copylinelength = strlen( copyofcurrentline ).

          split copyofcurrentline at space into head tail.
          shift tail left deleting leading space.

          try.
              if ( tail+0(1) = 'Y' or tail+0(1) = 'Z' or tail+0(1) = 'y'
  or tail+0(1) = 'z' or tail cs customernamerange or tail+0(2) = 'mz' or
  tail+0(2) = 'MZ' )
                  and not getincludes is initial and  tail ns structure
  and tail ns lowstructure.

*             Hyperlink for program includes
                clear wacontent.
                shift tail left deleting leading space.
                split tail at period into hyperlinkname tail.
                copyofcurrentline = 'include <a href ="'.

                lowercaselink = hyperlinkname.
                translate lowercaselink to lower case.

*             If we are running on a non UNIX environment we will need
*to remove forward slashes
                if frontendopsystem = non_unix.
                  translate lowercaselink using '/_'.
                endif.

                concatenate copyofcurrentline
                            lowercaselink       "hyperlinkName
                            period htmlextension '">'
                            hyperlinkname
                            '</a>'
                            period tail into copyofcurrentline.

*             Pad the string back out with spaces
                while copylinelength < currentlinelength.
                  shift copyofcurrentline right by 1 places.
                  copylinelength = copylinelength + 1.
                endwhile.
                wacontent = copyofcurrentline.
              else.
                if not getdictstructures is initial.
*              Hyperlink for structure include e.g. "include structure
* zfred."
                  copylinelength = strlen( copyofcurrentline ).
                  split copyofcurrentline at space into head tail.
                  shift tail left deleting leading space.
                  split tail at space into head tail.

                  try.
                      if tail+0(1) = 'Y' or tail+0(1) = 'Z' or tail+0(1) =
     'y' or tail+0(1) = 'z' or tail cs customernamerange.
                        clear wacontent.
                        shift tail left deleting leading space.
                        split tail at period into hyperlinkname tail.
                        copyofcurrentline = 'include structure <a href ='.

                        lowercaselink = hyperlinkname.
                        translate lowercaselink to lower case.
*                  If we are running on a non UNIX environment we will
* need to remove forward slashes
                        if frontendopsystem = non_unix.
                          translate lowercaselink using '/_'.
                        endif.

                        concatenate copyofcurrentline
                                    '"'
                                    lowercaselink    "hyperlinkName
                                    '/'
                                    'dictionary-'
                                    lowercaselink    "hyperlinkName
                                    period htmlextension
                                    '">'
                                    hyperlinkname
                                    '</a>'
                                    period tail into copyofcurrentline.

*                  Pad the string back out with spaces
                        while copylinelength < currentlinelength.
                          shift copyofcurrentline right by 1 places.
                          copylinelength = copylinelength + 1.
                        endwhile.
                        wacontent = copyofcurrentline.
                      endif.
                    catch cx_sy_range_out_of_bounds into objruntimeerror.
                  endtry.
                endif.
              endif.
            catch cx_sy_range_out_of_bounds into objruntimeerror.
          endtry.
        endif.
      else.
        if not syntaxhighlightcomments is initial and wacontent+0(1) =
 asterix.
          concatenate '<font color ="' comment_colour '">' into head.
          concatenate head wacontent '</font>' into tail.
          wacontent = tail.
        endif.
      endif.

      htmltable = wacontent.

    else.
      htmltable = ''.
    endif.
    append htmltable.
  endloop.

  htmltable = '</pre>'.
  append htmltable.

* Add a html footer to the table
  perform addhtmlfooter using htmltable[].

  icontents[] = htmltable[].
endform.                    "convertCodeToHtml
"convertCodeToHtml

*-----------------------------------------------------------------------
*  convertClassToHtml... Builds an HTML table based upon a text table.
*-----------------------------------------------------------------------
form convertclasstohtml using icontents like dumihtml[]
                              value(classname)
                              value(shortdescription)
                              value(sourcecodetype)
                              value(syntaxhighlightcomments)
                              value(htmlextension)
                              value(customernamerange)
                              value(getdictstructures).

  data: htmltable type standard table of string with header line.
  data: listingname type string value 'Code listing for class:'.
  data: descriptionname type string value `Description: `.
  data: mytabix type sytabix.
  data: wacontent(255).
  data: head type string.
  data: tail type string.
  data: hyperlinkname type string.
  data: lowercaselink type string.
  data: copyofcurrentline type string.
  data: currentlinelength type i value 0.
  data: copylinelength type i value 0.

* Add a html header to the table
  perform addhtmlheader using htmltable[]
                              classname.

  concatenate listingname classname into listingname separated by space.
  concatenate '<font size="3" face = "Arial" color="' colour_black
'"><b>' listingname '</b></font>' into htmltable.
  append htmltable.

  if not shortdescription is initial.
    append '<br>' to htmltable.
    concatenate descriptionname shortdescription into descriptionname
separated by space.
    concatenate '<font size="3" face = "Arial" color="' colour_black
'"><b>' descriptionname '</b></font>' into htmltable.
    append htmltable.
  endif.

  htmltable = '<hr>'.
  append htmltable.

  htmltable = '<pre width="100">'.
  append htmltable.

  loop at icontents into wacontent.
    mytabix = sy-tabix.

*   Comments
    if not syntaxhighlightcomments is initial and wacontent+0(1) =
asterix.
      concatenate '<font color ="' comment_colour '">' into head.
      concatenate head wacontent '</font>' into wacontent.
      htmltable = wacontent.
    else.
*     Smaller than, greater than signs
      if not ( icontents is initial ).
        while ( wacontent cs '<' or wacontent cs '>' ).
          replace '<' in wacontent with lt.
          replace '>' in wacontent with gt.
        endwhile.

*       Dictionary structures
        if not getdictstructures is initial.
          find 'class' in wacontent ignoring case.
          if sy-subrc <> 0.
*           Hyperlink for dictionary/structure include
            copylinelength = strlen( wacontent ).
            copyofcurrentline = wacontent.
            split copyofcurrentline at space into head tail.
            shift tail left deleting leading space.
            split tail at space into head tail.

            try.
                if tail+0(1) = 'Y' or tail+0(1) = 'Z' or tail+0(1) = 'y'
  or tail+0(1) = 'z' or tail cs customernamerange.
                  clear wacontent.
                  shift tail left deleting leading space.
                  split tail at period into hyperlinkname tail.
                  copyofcurrentline = 'include structure <a href ='.

                  lowercaselink = hyperlinkname.
                  translate lowercaselink to lower case.
*               If we are running on a non UNIX environment we will need
* to remove forward slashes
                  if frontendopsystem = non_unix.
                    translate lowercaselink using '/_'.
                  endif.

                  concatenate copyofcurrentline
                              '"'
                              lowercaselink    "hyperlinkName
                              '/'
                              'dictionary-'
                              lowercaselink    "hyperlinkName
                              period htmlextension
                              '">'
                              hyperlinkname
                              '</a>'
                              period tail into copyofcurrentline.

*               Pad the string back out with spaces
                  while copylinelength < currentlinelength.
                    shift copyofcurrentline right by 1 places.
                    copylinelength = copylinelength + 1.
                  endwhile.
                  wacontent = copyofcurrentline.
                endif.
              catch cx_sy_range_out_of_bounds into objruntimeerror.
            endtry.
          endif.
        endif.

        htmltable = wacontent.
      else.
        htmltable = ''.
      endif.
    endif.

    append htmltable.
  endloop.

  htmltable = '</pre>'.
  append htmltable.

* Add a html footer to the table
  perform addhtmlfooter using htmltable[].

  icontents[] = htmltable[].
endform.                    "convertClassToHtml
"convertClassToHtml

*-----------------------------------------------------------------------
*  convertFunctionToHtml... Builds an HTML table based upon a text table
*-----------------------------------------------------------------------
form convertfunctiontohtml using icontents like dumihtml[]
                                 value(functionname)
                                 value(shortdescription)
                                 value(sourcecodetype)
                                 value(functiondocumentationexists)
                                 value(ismainfunctioninclude)
                                 value(syntaxhighlightcomments)
                                 value(htmlextension)
                                 value(customernamerange)
                                 value(getincludes)
                                 value(getdictstructures).

  data: htmltable type standard table of string with header line.
  data: listingname type string value 'Code listing for function:'.
  data: descriptionname type string value `Description: `.
  data: head(255).
  data: tail(255).
  data: mytabix type sytabix.
  data: nextline type sytabix.
  data: hyperlinkname type string.
  data: copyofcurrentline type string.
  data: currentlinelength type i value 0.
  data: copylinelength type i value 0.
  data: ignorefuturelines type i value false.
  data: foundasterix type i value false.
  data: lowercaselink type string.
  data: wanextline type string.
  data: wacontent(255).

* Add a html header to the table
  perform addhtmlheader using htmltable[]
                              functionname.

  concatenate listingname functionname into listingname separated by
space.
  concatenate '<font size="3" face = "Arial" color="' colour_black
'"><b>' listingname '</b></font>' into htmltable.
  append htmltable.

  if not shortdescription is initial.
    append '<br>' to htmltable.
    concatenate descriptionname shortdescription into descriptionname
separated by space.
    concatenate '<font size="3" face = "Arial" color="' colour_black
'"><b>' descriptionname '</b></font>' into htmltable.
    append htmltable.
  endif.

  htmltable = '<hr>'.
  append htmltable.

  htmltable = '<pre width="100">'.
  append htmltable.

  loop at icontents into wacontent.
    mytabix = sy-tabix.

*   Extra code for adding global and doc hyperlinks to functions
    if sourcecodetype = is_function and ismainfunctioninclude = true.
      if sy-tabix > 1.
        if wacontent+0(1) = asterix and ignorefuturelines = false.
          foundasterix = true.
        else.
          if foundasterix = true.
*           Lets add our extra HTML lines in here
            append '' to htmltable.

*           Global data hyperlink
            if not syntaxhighlightcomments is initial.
              concatenate '<font color ="' comment_colour '">' into
copyofcurrentline.
            endif.

            concatenate copyofcurrentline '*       <a href ="' into
copyofcurrentline.
            lowercaselink = functionname.
            translate lowercaselink to lower case.
*           If we are running on a non UNIX environment we will need to
*remove forward slashes
            if frontendopsystem = non_unix.
              translate lowercaselink using '/_'.
            endif.

            concatenate copyofcurrentline 'global-' lowercaselink "functionName
                        period htmlextension '">' 'Global data declarations' '</a>' into copyofcurrentline.

            if not syntaxhighlightcomments is initial.
              concatenate copyofcurrentline '</font>' into
copyofcurrentline.
            endif.

            append copyofcurrentline to htmltable.

*           Documentation hyperlink.
            if functiondocumentationexists = true.
              if not syntaxhighlightcomments is initial.
                concatenate '<font color ="' comment_colour '">' into
copyofcurrentline.
              endif.

              concatenate copyofcurrentline '*       <a href ="' into
copyofcurrentline.

              lowercaselink = functionname.
              translate lowercaselink to lower case.
*             If we are running on a non UNIX environment we will need
*to remove forward slashes
              if frontendopsystem = non_unix.
                translate lowercaselink using '/_'.
              endif.

              concatenate copyofcurrentline
                          'docs-'
                          lowercaselink  "functionName
                          period htmlextension '">'
                          'Function module documentation'
                          '</a>'
                          into copyofcurrentline.

              if not pcomm is initial.
                concatenate copyofcurrentline '</font>' into
copyofcurrentline.
              endif.
              append copyofcurrentline to htmltable.
            endif.

            foundasterix = false.
            ignorefuturelines = true.
          endif.
        endif.
      endif.
    endif.

*   Carry on as normal
    if not ( icontents is initial ).
      while ( wacontent cs '<' or wacontent cs '>' ).
        replace '<' in wacontent with lt.
        replace '>' in wacontent with gt.
      endwhile.

      if wacontent+0(1) <> asterix.
        currentlinelength = strlen( wacontent ).

*       Don't hyperlink anything for files of type documentation
        if sourcecodetype <> is_documentation.
*       Check for any functions to highlight
          if ( wacontent cs callfunction ) and ( wacontent <>
'DESTINATION' ).
            nextline = mytabix + 1.
            read table icontents into wanextline index nextline.
            translate wanextline to upper case.
            if wanextline ns 'DESTINATION'.
              copyofcurrentline = wacontent.
              shift copyofcurrentline left deleting leading space.

              copylinelength = strlen( copyofcurrentline ).

              split copyofcurrentline at space into head tail.
              split tail at space into head tail.
              split tail at space into head tail.
*             Function name is now in head
              translate head using ''' '.
              shift head left deleting leading space.

              try.
                  if head+0(1) = 'Y' or head+0(1) = 'Z' or head+0(1) = 'y'
   or head+0(1) = 'z' or head cs customernamerange.

*                 Definately a customer function module
                    hyperlinkname = head.

                    if sourcecodetype = is_function.
                      copyofcurrentline = 'call function <a href ="../'.
                    else.
                      copyofcurrentline = 'call function <a href ="'.
                    endif.

                    lowercaselink = hyperlinkname.
                    translate lowercaselink to lower case.
*                 If we are running on a non UNIX environment we will
*need to remove forward slashes
                    if frontendopsystem = non_unix.
                      translate lowercaselink using '/_'.
                    endif.

                    concatenate copyofcurrentline
                                lowercaselink     "hyperlinkName
                                '/'
                                lowercaselink     "hyperlinkName
                                period htmlextension '">'
                                ''''
                                hyperlinkname
                                ''''
                                '</a>'
                                tail into copyofcurrentline.

*                 Pad the string back out with spaces
                    while copylinelength < currentlinelength.
                      shift copyofcurrentline right by 1 places.
                      copylinelength = copylinelength + 1.
                    endwhile.

                    wacontent = copyofcurrentline.
                  endif.
                catch cx_sy_range_out_of_bounds into objruntimeerror.
              endtry.
            endif.
          endif.
        endif.

*       Check for any customer includes to hyperlink
        if wacontent cs include or wacontent cs lowinclude.
          copyofcurrentline = wacontent.

          shift copyofcurrentline left deleting leading space.
          copylinelength = strlen( copyofcurrentline ).

          split copyofcurrentline at space into head tail.
          shift tail left deleting leading space.

          try.
              if ( tail+0(1) = 'Y' or tail+0(1) = 'Z' or tail+0(1) = 'y'
  or tail+0(1) = 'z'
                   or tail cs customernamerange or tail+0(2) = 'mz' or
  tail+0(2) = 'MZ' ) and not getincludes is initial.

*             Hyperlink for program includes
                clear wacontent.
                shift tail left deleting leading space.
                split tail at period into hyperlinkname tail.
                copyofcurrentline = 'include <a href ="'.

                lowercaselink = hyperlinkname.
                translate lowercaselink to lower case.
*             If we are running on a non UNIX environment we will need
*to remove forward slashes
                if frontendopsystem = non_unix.
                  translate lowercaselink using '/_'.
                endif.

                concatenate copyofcurrentline
                            lowercaselink       "hyperlinkName
                            period htmlextension '">'
                            hyperlinkname
                            '</a>'
                            period tail into copyofcurrentline.

*             Pad the string back out with spaces
                while copylinelength < currentlinelength.
                  shift copyofcurrentline right by 1 places.
                  copylinelength = copylinelength + 1.
                endwhile.
                wacontent = copyofcurrentline.
              else.
                if not getdictstructures is initial.
*               Hyperlink for structure include
                  copylinelength = strlen( copyofcurrentline ).
                  split copyofcurrentline at space into head tail.
                  shift tail left deleting leading space.
                  split tail at space into head tail.

                  try.
                      if tail+0(1) = 'Y' or tail+0(1) = 'Z' or tail+0(1) =
    'y' or tail+0(1) = 'z' or tail cs customernamerange.
                        clear wacontent.
                        shift tail left deleting leading space.
                        split tail at period into hyperlinkname tail.
                        copyofcurrentline = 'include structure <a href ='.

                        lowercaselink = hyperlinkname.
                        translate lowercaselink to lower case.
*                   If we are running on a non UNIX environment we will
*need to remove forward slashes
                        if frontendopsystem = non_unix.
                          translate lowercaselink using '/_'.
                        endif.

                        concatenate copyofcurrentline
                                    '"'
                                    lowercaselink    "hyperlinkName
                                    '/'
                                    'dictionary-'
                                    lowercaselink    "hyperlinkName
                                    period htmlextension
                                    '">'
                                    hyperlinkname
                                    '</a>'
                                    period tail into copyofcurrentline.

*                   Pad the string back out with spaces
                        while copylinelength < currentlinelength.
                          shift copyofcurrentline right by 1 places.
                          copylinelength = copylinelength + 1.
                        endwhile.
                        wacontent = copyofcurrentline.
                      endif.
                    catch cx_sy_range_out_of_bounds into objruntimeerror.
                  endtry.
                endif.
              endif.
            catch cx_sy_range_out_of_bounds into objruntimeerror.
          endtry.
        endif.
      else.
        if not syntaxhighlightcomments is initial and wacontent+0(1) =
 asterix.
          concatenate '<font color ="' comment_colour '">' into head.
          concatenate head wacontent '</font>' into tail.
          wacontent = tail.
        endif.
      endif.

      htmltable = wacontent.

    else.
      htmltable = ''.
    endif.
    append htmltable.
  endloop.

  htmltable = '</pre>'.
  append htmltable.

* Add a html footer to the table
  perform addhtmlfooter using htmltable[].

  icontents[] = htmltable[].
endform.                    "convertFunctionToHtml
"convertFunctionToHtml

*-----------------------------------------------------------------------
*  buildColumnHeaders... build table column names
*-----------------------------------------------------------------------
form buildcolumnheaders using iloccolumncaptions like dumihtml[].

  append 'Row' to iloccolumncaptions.
  append 'Field name' to iloccolumncaptions.
  append 'Position' to iloccolumncaptions.
  append 'Key' to iloccolumncaptions.
  append 'Data element' to iloccolumncaptions.
  append 'Domain' to iloccolumncaptions.
  append 'Datatype' to iloccolumncaptions.
  append 'Length' to iloccolumncaptions.
  append 'Domain text' to iloccolumncaptions.
endform.                    "buildColumnHeaders
"buildColumnHeaders

*-----------------------------------------------------------------------
* addHTMLHeader...  add a html formatted header to our output table
*-----------------------------------------------------------------------
form addhtmlheader using ilocheader like dumihtml[]
                         value(title).

  data: waheader type string.

  append '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">' to
ilocheader.
  append '<html>' to ilocheader.
  append '<head>' to ilocheader.

  concatenate '<title>' title '</title>' into waheader.
  append waheader to ilocheader.

  append '</head>' to ilocheader.

  if not pback is initial.
    concatenate '<body bgcolor="' background_colour '">' into waheader.
  else.
    concatenate '<body bgcolor="' colour_white '">' into waheader.
  endif.

  append waheader to ilocheader.
endform.                    "addHTMLHeader
"addHTMLHeader

*-----------------------------------------------------------------------
* addHTMLFooter...  add a html formatted footer to our output table
*-----------------------------------------------------------------------
form addhtmlfooter using ilocfooter like dumihtml[].

  data: footermessage type string.
  data: wafooter type string.

  perform buildfootermessage using 'HTML'
                                   footermessage.

  append '<hr>' to ilocfooter.
  concatenate '<font size="2" face = "Sans Serif">' footermessage into
wafooter.
  append wafooter to ilocfooter.
  append '</font>' to ilocfooter.
  append '</body>' to ilocfooter.
  append '</html>' to ilocfooter.
endform.                    "addHTMLFooter
"addHTMLFooter

*-----------------------------------------------------------------------
* buildFooterMessage...Returns a footer message based on the output file
* type.
*-----------------------------------------------------------------------
form buildfootermessage using filetype
                              returnmessage.

  if filetype = 'HTML'.
    concatenate `Extracted by Direct Download Enterprise version `
                 versionno ` - Desenvolvedor JCremm Sap Release `
 sy-saprl
                into returnmessage.
  else.
    concatenate `Extracted by Direct Download Enterprise version `
                 versionno ` - Desenvolvedor JCremm Sap Release `
 sy-saprl
                into returnmessage.
  endif.
endform.                    "buildFooterMessage
"buildFooterMessage

************************************************************************
***********************************************
********************************************DISPLAY
*ROUTINES***********************************************************
************************************************************************
***********************************************

*-----------------------------------------------------------------------
*  fillTreeNodeTables...
*-----------------------------------------------------------------------
form filltreenodetables using ilocdictionary like idictionary[]
                              iloctreedisplay like itreedisplay[]
                              value(runtime).

  data: tablelines type i.
  data: watreedisplay like snodetext.
  field-symbols: <wadictionary> type tdicttable.
  data: tablelinesstring type string.
  data: runtimechar(10).
  data: sublevel type string.

  tablelines = lines( ilocdictionary ).
  tablelinesstring = tablelines.

  if tablelines = 1.
    concatenate tablelinesstring 'table downloaded' into
watreedisplay-text2 separated by space.
  else.
    concatenate tablelinesstring 'tables downloaded' into
 watreedisplay-text2 separated by space.
  endif.

  write runtime to runtimechar.
  concatenate watreedisplay-text2 '- runtime' runtimechar into
watreedisplay-text2 separated by space.

* include header display record.
  watreedisplay-tlevel = '1'.
  watreedisplay-tlength2  = 60.
  watreedisplay-tcolor2    = 1.
  append watreedisplay to iloctreedisplay.

  loop at ilocdictionary assigning <wadictionary>.
    watreedisplay-tlevel = '2'.
    watreedisplay-text2 = <wadictionary>-tablename.
    watreedisplay-tcolor2    = 3.
    watreedisplay-tlength3   = 80.
    watreedisplay-tcolor3    = 3.
    watreedisplay-tpos3      = 60.
    concatenate 'Dictionary:' <wadictionary>-tabletitle into
watreedisplay-text3 separated by space.

    append watreedisplay to iloctreedisplay.
  endloop.
endform.                    "fillTreeNodeTables
"fillTreeNodeTables

*-----------------------------------------------------------------------
*  fillTreeNodeMessages...
*-----------------------------------------------------------------------
form filltreenodemessages using ilocmessages like imessages[]
                                iloctreedisplay like itreedisplay[]
                                value(runtime).

  data: tablelines type i.
  data: watreedisplay like snodetext.
  field-symbols: <wamessage> type tmessage.
  data: tablelinesstring type string.
  data: runtimechar(10).

  sort ilocmessages ascending by arbgb.

  loop at ilocmessages assigning <wamessage>.
    at new arbgb.
      tablelines = tablelines + 1.
    endat.
  endloop.
  tablelinesstring = tablelines.

  if tablelines = 1.
    concatenate tablelinesstring 'message class downloaded' into
watreedisplay-text2 separated by space.
  else.
    concatenate tablelinesstring 'message classes downloaded' into
watreedisplay-text2 separated by space.
  endif.

  write runtime to runtimechar.
  concatenate watreedisplay-text2 '- runtime' runtimechar into
watreedisplay-text2 separated by space.

* include header display record.
  watreedisplay-tlevel = '1'.
  watreedisplay-tlength2 = 60.
  watreedisplay-tcolor2 = 1.
  append watreedisplay to iloctreedisplay.

  loop at ilocmessages assigning <wamessage>.
    at new arbgb.
      watreedisplay-tlevel = '2'.
      watreedisplay-text2 = <wamessage>-arbgb.
      watreedisplay-tcolor2    = 5.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 5.
      watreedisplay-tpos3      = 60.
      watreedisplay-text3 = <wamessage>-stext.
      concatenate 'Message class:'  watreedisplay-text3 into
watreedisplay-text3 separated by space.
      append watreedisplay to iloctreedisplay.
    endat.
  endloop.
endform.                    "fillTreeNodeMessages
"fillTreeNodeMessages

*-----------------------------------------------------------------------
*  fillTreeNodeFunctions...
*-----------------------------------------------------------------------
form filltreenodefunctions using ilocfunctions like ifunctions[]
                                 iloctreedisplay like itreedisplay[]
                                 value(runtime).

  data: tablelines type i.
  data: watreedisplay like snodetext.
  field-symbols: <wafunction> type tfunction.
  field-symbols: <wascreen> type tscreenflow.
  field-symbols: <waguititle> type tguititle.
  field-symbols: <wadictionary> type tdicttable.
  field-symbols: <wainclude> type tinclude.
  field-symbols: <wamessage> type tmessage.
  data: tablelinesstring type string.
  data: runtimechar(10).

  sort ilocfunctions ascending by functionname.

  tablelines = lines( ilocfunctions ).
  tablelinesstring = tablelines.

  if tablelines = 1.
    concatenate tablelinesstring ` function downloaded` into
watreedisplay-text2.
  else.
    concatenate tablelinesstring ` functions downloaded` into
watreedisplay-text2.
  endif.

  write runtime to runtimechar.

  concatenate watreedisplay-text2 ` - runtime ` runtimechar into
watreedisplay-text2.
* include header display record.
  watreedisplay-tlevel = '1'.
  watreedisplay-tlength2  = 60.
  watreedisplay-tcolor2    = 1.
  append watreedisplay to iloctreedisplay.

* Lets fill the detail in
  loop at ilocfunctions assigning <wafunction>.
    watreedisplay-tlevel = 2.
    watreedisplay-text2 = <wafunction>-functionname.
    watreedisplay-tcolor2    = 7.
    watreedisplay-tlength3   = 80.
    watreedisplay-tcolor3    = 7.
    watreedisplay-tpos3      = 60.
    concatenate `Function: ` <wafunction>-functionname into
watreedisplay-text3.
    append watreedisplay to iloctreedisplay.

*   Screens.
    loop at <wafunction>-iscreenflow assigning <wascreen>.
      watreedisplay-tlevel = '2'.
      watreedisplay-text2 = <wascreen>-screen.
      watreedisplay-tcolor2    = 6.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 6.
      watreedisplay-tpos3      = 60.
      watreedisplay-text3 = 'Screen'.
      append watreedisplay to itreedisplay.
    endloop.

*   GUI Title.
    loop at <wafunction>-iguititle assigning <waguititle>.
      watreedisplay-tlevel = '2'.
      watreedisplay-text2 = <waguititle>-obj_code.
      watreedisplay-tcolor2    = 6.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 6.
      watreedisplay-tpos3      = 60.
      watreedisplay-text3 = 'GUI Title'.
      append watreedisplay to itreedisplay.
    endloop.

*   Fill in the tree with include information
    loop at <wafunction>-iincludes assigning <wainclude>.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 =  <wainclude>-includename.
      watreedisplay-tcolor2    = 4.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 4.
      watreedisplay-tpos3      = 60.
      concatenate `Include:   ` <wainclude>-includetitle into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.
    endloop.

*   fill in the tree with dictionary information
    loop at <wafunction>-idictstruct assigning <wadictionary>.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 =  <wadictionary>-tablename.
      watreedisplay-tcolor2    = 3.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 3.
      watreedisplay-tpos3      = 60.
      concatenate `Dictionary:` <wadictionary>-tabletitle into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.
    endloop.

*   fill in the tree with message information
    sort <wafunction>-imessages[] ascending by arbgb.
    loop at <wafunction>-imessages assigning <wamessage>.
      at new arbgb.
        watreedisplay-tlevel = 3.
        watreedisplay-text2 = <wamessage>-arbgb.
        watreedisplay-tcolor2    = 5.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 5.
        watreedisplay-tpos3      = 60.

*       Select the message class text if we do not have it already
        if <wamessage>-stext is initial.
          select single stext from t100a
                              into <wamessage>-stext
                              where arbgb = <wamessage>-arbgb.
        endif.

        watreedisplay-text3 = <wamessage>-stext.
        concatenate `Message class: `  watreedisplay-text3 into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endat.
    endloop.
  endloop.
endform.                    "fillTreeNodeFunctions
"fillTreeNodeFunctions

*-----------------------------------------------------------------------
*  fillTreeNodePrograms
*-----------------------------------------------------------------------
form filltreenodeprograms using ilocprograms like iprograms[]
                                ilocfunctions like ifunctions[]
                                iloctreedisplay like itreedisplay[]
                                value(runtime).

  data: tablelines type i.
  data: watreedisplay like snodetext.
  field-symbols: <waprogram> type tprogram.
  field-symbols: <wascreen> type tscreenflow.
  field-symbols: <wafunction> type tfunction.
  field-symbols: <wadictionary> type tdicttable.
  field-symbols: <wainclude> type tinclude.
  field-symbols: <wamessage> type tmessage.
  data: tablelinesstring type string.
  data: runtimechar(10).

  tablelines = lines( ilocprograms ).
  tablelinesstring = tablelines.

  if tablelines = 1.
    concatenate tablelinesstring ` program downloaded` into
watreedisplay-text2.
  else.
    concatenate tablelinesstring ` programs downloaded` into
watreedisplay-text2.
  endif.

  write runtime to runtimechar.

  concatenate watreedisplay-text2 ` - runtime ` runtimechar into
watreedisplay-text2.
* include header display record.
  watreedisplay-tlevel = '1'.
  watreedisplay-tlength2  = 60.
  watreedisplay-tcolor2    = 1.
  append watreedisplay to itreedisplay.

  loop at ilocprograms assigning <waprogram>.
*   Main programs.
    watreedisplay-tlevel = '2'.
    watreedisplay-text2 = <waprogram>-progname.
    watreedisplay-tcolor2    = 1.
*   Description
    watreedisplay-tlength3   = 80.
    watreedisplay-tcolor3    = 1.
    watreedisplay-tpos3      = 60.
    concatenate `Program: ` <waprogram>-programtitle into
 watreedisplay-text3.
    append watreedisplay to itreedisplay.
*   Screens.
    loop at <waprogram>-iscreenflow assigning <wascreen>.
      watreedisplay-tlevel = '3'.
      watreedisplay-text2 = <wascreen>-screen.
      watreedisplay-tcolor2    = 6.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 6.
      watreedisplay-tpos3      = 60.
      watreedisplay-text3 = 'Screen'.
      append watreedisplay to itreedisplay.
    endloop.
*   fill in the tree with message information
    sort <waprogram>-imessages[] ascending by arbgb.
    loop at <waprogram>-imessages assigning <wamessage>.
      at new arbgb.
        watreedisplay-tlevel = 3.
        watreedisplay-text2 = <wamessage>-arbgb.
        watreedisplay-tcolor2    = 5.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 5.
        watreedisplay-tpos3      = 60.

*       Select the message class text if we do not have it already
        if <wamessage>-stext is initial.
          select single stext from t100a
                              into <wamessage>-stext
                              where arbgb = <wamessage>-arbgb.
        endif.

        watreedisplay-text3 = <wamessage>-stext.
        concatenate `Message class: `  watreedisplay-text3 into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endat.
    endloop.
*   Fill in the tree with include information
    loop at <waprogram>-iincludes assigning <wainclude>.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 =  <wainclude>-includename.
      watreedisplay-tcolor2    = 4.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 4.
      watreedisplay-tpos3      = 60.
      concatenate `Include:   ` <wainclude>-includetitle into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.
    endloop.
*   fill in the tree with dictionary information
    loop at <waprogram>-idictstruct assigning <wadictionary>.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 =  <wadictionary>-tablename.
      watreedisplay-tcolor2    = 3.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 3.
      watreedisplay-tpos3      = 60.
      concatenate `Dictionary:    ` <wadictionary>-tabletitle into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.
    endloop.

*   Function Modules
    loop at ilocfunctions assigning <wafunction> where programlinkname =
 <waprogram>-progname.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 = <wafunction>-functionname.
      watreedisplay-tcolor2    = 7.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 7.
      watreedisplay-tpos3      = 60.
      concatenate `Function:      ` <wafunction>-functionname into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.

*     Fill in the tree with include information
      loop at <wafunction>-iincludes assigning <wainclude>.
        watreedisplay-tlevel = 4.
        watreedisplay-text2 =  <wainclude>-includename.
        watreedisplay-tcolor2    = 4.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 4.
        watreedisplay-tpos3      = 60.
        concatenate `Include:       ` <wainclude>-includetitle into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endloop.

*     fill in the tree with dictionary information
      loop at <wafunction>-idictstruct assigning <wadictionary>.
        watreedisplay-tlevel = 4.
        watreedisplay-text2 =  <wadictionary>-tablename.
        watreedisplay-tcolor2    = 3.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 3.
        watreedisplay-tpos3      = 60.
        concatenate `Dictionary:    ` <wadictionary>-tabletitle into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endloop.

*     fill in the tree with message information
      sort <wafunction>-imessages[] ascending by arbgb.
      loop at <wafunction>-imessages assigning <wamessage>.
        at new arbgb.
          watreedisplay-tlevel = 4.
          watreedisplay-text2 = <wamessage>-arbgb.
          watreedisplay-tcolor2    = 5.
          watreedisplay-tlength3   = 80.
          watreedisplay-tcolor3    = 5.
          watreedisplay-tpos3      = 60.

*         Select the message class text if we do not have it already
          if <wamessage>-stext is initial.
            select single stext from t100a
                                into <wamessage>-stext
                                where arbgb = <wamessage>-arbgb.
          endif.

          watreedisplay-text3 = <wamessage>-stext.
          concatenate `Message class:  `  watreedisplay-text3 into
watreedisplay-text3.
          append watreedisplay to iloctreedisplay.
        endat.
      endloop.
    endloop.
  endloop.
endform.                    "fillTreeNodePrograms
"fillTreeNodePrograms

*-----------------------------------------------------------------------
*  fillTreeNodeClasses
*-----------------------------------------------------------------------
form filltreenodeclasses using ilocclasses like iclasses[]
                               ilocfunctions like ifunctions[]
                               iloctreedisplay like itreedisplay[]
                               value(runtime).

  data: tablelines type i.
  data: watreedisplay like snodetext.
  field-symbols: <waclass> type tclass.
  field-symbols: <wamethod> type tmethod.
  field-symbols: <wafunction> type tfunction.
  field-symbols: <wadictionary> type tdicttable.
  field-symbols: <wainclude> type tinclude.
  field-symbols: <wamessage> type tmessage.
  data: tablelinesstring type string.
  data: runtimechar(10).

  tablelines = lines( ilocclasses ).
  tablelinesstring = tablelines.

  if tablelines = 1.
    concatenate tablelinesstring ` class downloaded` into
 watreedisplay-text2.
  else.
    concatenate tablelinesstring ` classes downloaded` into
watreedisplay-text2.
  endif.

  write runtime to runtimechar.

  concatenate watreedisplay-text2 ` - runtime ` runtimechar into
watreedisplay-text2.
* include header display record.
  watreedisplay-tlevel = '1'.
  watreedisplay-tlength2  = 60.
  watreedisplay-tcolor2    = 1.
  append watreedisplay to itreedisplay.

  loop at ilocclasses assigning <waclass>.
*   Main Class.
    watreedisplay-tlevel = '2'.
    watreedisplay-text2 = <waclass>-clsname.
    watreedisplay-tcolor2    = 1.
*   Description
    watreedisplay-tlength3   = 80.
    watreedisplay-tcolor3    = 1.
    watreedisplay-tpos3      = 60.
    concatenate `Class:    ` <waclass>-descript into watreedisplay-text3
.
    append watreedisplay to itreedisplay.

*   fill in the tree with method information
    loop at <waclass>-imethods[] assigning <wamethod>.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 =  <wamethod>-cmpname.
      watreedisplay-tcolor2    = 2.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 2.
      watreedisplay-tpos3      = 60.
      concatenate `Method:   ` <wamethod>-descript into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.
    endloop.

*   fill in the tree with message information
    sort <waclass>-imessages[] ascending by arbgb.
    loop at <waclass>-imessages assigning <wamessage>.
      at new arbgb.
        watreedisplay-tlevel = 3.
        watreedisplay-text2 = <wamessage>-arbgb.
        watreedisplay-tcolor2    = 5.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 5.
        watreedisplay-tpos3      = 60.

*       Select the message class text if we do not have it already
        if <wamessage>-stext is initial.
          select single stext from t100a
                              into <wamessage>-stext
                              where arbgb = <wamessage>-arbgb.
        endif.

        watreedisplay-text3 = <wamessage>-stext.
        concatenate `Message class: `  watreedisplay-text3 into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endat.
    endloop.

*   fill in the tree with dictionary information
    loop at <waclass>-idictstruct assigning <wadictionary>.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 =  <wadictionary>-tablename.
      watreedisplay-tcolor2    = 3.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 3.
      watreedisplay-tpos3      = 60.
      concatenate `Dictionary:    ` <wadictionary>-tabletitle into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.
    endloop.

*   Function Modules
    loop at ilocfunctions assigning <wafunction> where programlinkname =
 <waclass>-clsname.
      watreedisplay-tlevel = 3.
      watreedisplay-text2 = <wafunction>-functionname.
      watreedisplay-tcolor2    = 7.
      watreedisplay-tlength3   = 80.
      watreedisplay-tcolor3    = 7.
      watreedisplay-tpos3      = 60.
      concatenate `Function:      ` <wafunction>-functionname into
watreedisplay-text3.
      append watreedisplay to iloctreedisplay.

*     Fill in the tree with include information
      loop at <wafunction>-iincludes assigning <wainclude>.
        watreedisplay-tlevel = 4.
        watreedisplay-text2 =  <wainclude>-includename.
        watreedisplay-tcolor2    = 4.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 4.
        watreedisplay-tpos3      = 60.
        concatenate `Include:       ` <wainclude>-includetitle into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endloop.

*     fill in the tree with dictionary information
      loop at <wafunction>-idictstruct assigning <wadictionary>.
        watreedisplay-tlevel = 4.
        watreedisplay-text2 =  <wadictionary>-tablename.
        watreedisplay-tcolor2    = 3.
        watreedisplay-tlength3   = 80.
        watreedisplay-tcolor3    = 3.
        watreedisplay-tpos3      = 60.
        concatenate `Dictionary:    ` <wadictionary>-tabletitle into
watreedisplay-text3.
        append watreedisplay to iloctreedisplay.
      endloop.

*     fill in the tree with message information
      sort <wafunction>-imessages[] ascending by arbgb.
      loop at <wafunction>-imessages assigning <wamessage>.
        at new arbgb.
          watreedisplay-tlevel = 4.
          watreedisplay-text2 = <wamessage>-arbgb.
          watreedisplay-tcolor2    = 5.
          watreedisplay-tlength3   = 80.
          watreedisplay-tcolor3    = 5.
          watreedisplay-tpos3      = 60.

*         Select the message class text if we do not have it already
          if <wamessage>-stext is initial.
            select single stext from t100a
                                into <wamessage>-stext
                                where arbgb = <wamessage>-arbgb.
          endif.

          watreedisplay-text3 = <wamessage>-stext.
          concatenate `Message class:  `  watreedisplay-text3 into
watreedisplay-text3.
          append watreedisplay to iloctreedisplay.
        endat.
      endloop.
    endloop.
  endloop.
endform.                    "fillTreeNodeClasses
"fillTreeNodeClasses

*-----------------------------------------------------------------------
* displayTree...
*-----------------------------------------------------------------------
form displaytree using iloctreedisplay like itreedisplay[].

  data: watreedisplay type snodetext.

* build up the tree from the internal table node
  call function 'RS_TREE_CONSTRUCT'
    tables
      nodetab            = itreedisplay
    exceptions
      tree_failure       = 1
      id_not_found       = 2
      wrong_relationship = 3
      others             = 4.

* get the first index and expand the whole tree
  read table iloctreedisplay into watreedisplay index 1.
  call function 'RS_TREE_EXPAND'
    exporting
      node_id   = watreedisplay-id
      all       = 'X'
    exceptions
      not_found = 1
      others    = 2.

* now display the tree
  call function 'RS_TREE_LIST_DISPLAY'
    exporting
      callback_program      = sy-cprog
      callback_user_command = 'CB_USER_COMMAND'
      callback_text_display = 'CB_text_DISPLAY'
      callback_top_of_page  = 'TOP_OF_PAGE'
    exceptions
      others                = 1.
endform.                    "displayTree
"displayTree

*-----------------------------------------------------------------------
*  topOfPage... for tree display routines.
*-----------------------------------------------------------------------
form topofpage.

endform.                    "topOfPage
