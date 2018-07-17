REPORT zbc400_email_report.

*---------------------------------------------------------------------*
* E-mail an Abap report                                               *
*---------------------------------------------------------------------*
* Updated 24 Dec 07                                                   *
*---------------------------------------------------------------------*

DATA w_name TYPE sos04-l_adr_name.

SELECT-OPTIONS:
* Recipient address
  s_name FOR w_name DEFAULT sy-uname NO INTERVALS.

*---------------------------------------------------------------------*
START-OF-SELECTION.

* E-mail Abap report
  PERFORM f_send_mail.

*---------------------------------------------------------------------*
* Form f_send_mail
*---------------------------------------------------------------------*
FORM f_send_mail.

* Data Declaration
  DATA:
    l_datum(10),
    ls_docdata    TYPE sodocchgi1,
    ls_objpack    TYPE sopcklsti1,
    lt_objpack    TYPE TABLE OF sopcklsti1,
    lt_objhead    TYPE TABLE OF solisti1,
    ls_objtxt     TYPE solisti1,
    lt_objtxt     TYPE TABLE OF solisti1,
    ls_objbin     TYPE solisti1,
    lt_objbin     TYPE TABLE OF solisti1,
    ls_reclist    TYPE somlreci1,
    lt_reclist    TYPE TABLE OF somlreci1,
    lt_listobject TYPE TABLE OF abaplist,

    l_tab_lines TYPE i,
    l_att_type  TYPE soodk-objtp.

  WRITE sy-datum TO l_datum.
  IF sy-saprl >= '700'.
    SUBMIT bcalv_fullscreen_demo_classic
           EXPORTING LIST TO MEMORY AND RETURN.
  ELSE.
* List of Users According to Logon Date and Password Change
* NOTE: Create ALI/OTF Document in Spool
    SUBMIT rsusr200 WITH valid = 'X'
                    WITH notvalid = space
                    WITH unlocked = 'X'
                    WITH locked = space
               EXPORTING LIST TO MEMORY AND RETURN.
  ENDIF.

* Read list from memory into table
  CALL FUNCTION 'LIST_FROM_MEMORY'
    TABLES
      listobject = lt_listobject
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
*   Error in function module &1
    MESSAGE ID '61' TYPE 'E' NUMBER '731'
       WITH 'LIST_FROM_MEMORY'.
  ENDIF.

* Because listobject is of size RAW(1000)
* and objbin is of size CHAR(255) we make this table copy
  CALL FUNCTION 'TABLE_COMPRESS'
    TABLES
      in             = lt_listobject
      out            = lt_objbin
    EXCEPTIONS
      compress_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*   Error in function module &1
    MESSAGE ID '61' TYPE 'E' NUMBER '731'
       WITH 'TABLE_COMPRESS'.
  ENDIF.

* NOTE: Creation of attachment is finished yet.
* For your report, the attachment should be placed into table
* objtxt for plain text or
* objbin for binary content.
* Now create the message and send the document.
* Create Message Body

* Title and Description
  ls_docdata-obj_name = 'USERS_LIST'.
  CONCATENATE 'List of Users' sy-sysid '-' l_datum          "#EC *
         INTO ls_docdata-obj_descr SEPARATED BY space.

* Main Text
  ls_objtxt = 'List of Users According to Logon Date' &
              ' and Password Change'.                       "#EC *

  APPEND ls_objtxt TO lt_objtxt.
* Write Packing List (Main)
  DESCRIBE TABLE lt_objtxt LINES l_tab_lines.
  READ TABLE lt_objtxt INDEX l_tab_lines INTO ls_objtxt.
  ls_docdata-doc_size = ( l_tab_lines - 1 ) * 255 + strlen( ls_objtxt ).
  CLEAR ls_objpack-transf_bin.
  ls_objpack-head_start = 1.
  ls_objpack-head_num = 0.
  ls_objpack-body_start = 1.
  ls_objpack-body_num = l_tab_lines.
  ls_objpack-doc_type = 'RAW'.
  APPEND ls_objpack TO lt_objpack.

* Create Message Attachment
* Write Packing List (Attachment)
  l_att_type = 'ALI'.
  DESCRIBE TABLE lt_objbin LINES l_tab_lines.
  READ TABLE lt_objbin INDEX l_tab_lines INTO ls_objbin.
  ls_objpack-doc_size = ( l_tab_lines - 1 ) * 255 + strlen( ls_objbin ).
  ls_objpack-transf_bin = 'X'.
  ls_objpack-head_start = 1.
  ls_objpack-head_num = 0.
  ls_objpack-body_start = 1.
  ls_objpack-body_num = l_tab_lines.
  ls_objpack-doc_type = l_att_type.
  ls_objpack-obj_name = 'ATTACHMENT'.
  ls_objpack-obj_descr = 'List_of_Users'.                   "#EC *
  APPEND ls_objpack TO lt_objpack.

* Create receiver list
  LOOP AT s_name.
    ls_reclist-receiver = s_name-low.
    ls_reclist-rec_type = 'B'.
    APPEND ls_reclist TO lt_reclist.
  ENDLOOP.

* Send Message
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = ls_docdata
      put_in_outbox              = 'X'
    TABLES
      packing_list               = lt_objpack
      object_header              = lt_objhead
      contents_bin               = lt_objbin
      contents_txt               = lt_objtxt
      receivers                  = lt_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc = 0.
*   Document sent
    MESSAGE ID 'SO' TYPE 'S' NUMBER '022'.
  ELSE.
*   Document <&> could not be sent
    MESSAGE ID 'SO' TYPE 'S' NUMBER '023'
       WITH ls_docdata-obj_name.
  ENDIF.

ENDFORM.                               " F_SEND_MAIL
***************** END OF PROGRAM Z_EMAIL_ABAP_REPORT ******************