*&---------------------------------------------------------------------*
*& Report  ZBC400_DYNAMIC_TABLE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc400_dynamic_table.


DATA: go_alv_table TYPE REF TO cl_salv_table,
      go_alv_msg   TYPE REF TO cx_salv_msg,
      gv_msg       TYPE string,
      got_data     TYPE REF TO data,
      gow_data     TYPE REF TO data.

FIELD-SYMBOLS: <fs_ta_data>     TYPE STANDARD TABLE,
               <fs_wa_data>     TYPE any,
               <fs_wa_dinamico> TYPE any,
               <fs_campo>       TYPE any.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_view  TYPE dd02l-tabname OBLIGATORY,
            p_mandt TYPE mandt.
SELECTION-SCREEN END OF BLOCK bl1.


START-OF-SELECTION.
  SELECT COUNT( * ) FROM dd02l UP TO 1 ROWS
    WHERE tabname EQ @p_view .

  CHECK ( sy-subrc EQ 0 ).

  CREATE DATA gow_data TYPE (p_view).
  ASSIGN gow_data->* TO <fs_wa_data>.

  CHECK ( sy-subrc EQ 0 ).

  CREATE DATA got_data TYPE STANDARD TABLE OF (p_view).
  ASSIGN got_data->* TO <fs_ta_data>.

  CHECK ( sy-subrc EQ 0 ).

  SELECT * FROM (p_view) INTO CORRESPONDING FIELDS OF TABLE <fs_ta_data>.

  CHECK ( sy-subrc EQ 0 ).

  LOOP AT <fs_ta_data> ASSIGNING  <fs_wa_dinamico>.
    ASSIGN COMPONENT 'MANDT' OF STRUCTURE <fs_wa_dinamico> TO <fs_campo>.
    CHECK ( sy-subrc EQ 0 ).
    <fs_campo> = sy-mandt.
  ENDLOOP.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_alv_table
                              CHANGING t_table = <fs_ta_data>
                                ).
      go_alv_table->display( ).

    CATCH cx_salv_msg INTO go_alv_msg .
      MOVE go_alv_msg->get_text( ) TO gv_msg.
      MESSAGE gv_msg TYPE 'E'.
  ENDTRY.