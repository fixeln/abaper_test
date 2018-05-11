REPORT zbc400_salv.



TYPES: BEGIN OF gty_line_structure,
         id      TYPE i,
         data    TYPE sy-datum,
         time    TYPE uzeit,
         message TYPE string,
         color   TYPE lvc_t_scol,
       END OF gty_line_structure.


DATA: gt_data        TYPE STANDARD TABLE OF gty_line_structure,
      go_salv_table  TYPE REF TO cl_salv_table,
      go_salv_cx_msg TYPE REF TO cx_salv_msg.


PERFORM get_alv_table.
INCLUDE zbc400_salv_c01.
INCLUDE zbc400_salv_f01.

*----------------------------------------------------------------------*
***INCLUDE ZBC400_SALV_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_ALV_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_alv_table .

  PERFORM create_data TABLES gt_data.

  TRY.
      PERFORM create_alv_table TABLES gt_data
                               CHANGING go_salv_table.
      PERFORM set_alv_functions CHANGING go_salv_table.
      PERFORM format_columns TABLES gt_data
                            CHANGING go_salv_table.
      PERFORM get_selections CHANGING go_salv_table.
      PERFORM on_user_event CHANGING go_salv_table.
      go_salv_table->display( ).
    CATCH cx_salv_msg INTO go_salv_cx_msg.
      MESSAGE go_salv_cx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.


FORM create_data TABLES lt_like_data.

  DATA: ls_data  TYPE gty_line_structure,
        lv_index TYPE i.

  DO 10  TIMES.
    ls_data-id = lv_index.
    ls_data-data = sy-datum + lv_index.
    ls_data-time = sy-uzeit.
    ls_data-message = 'Index number:' && space && lv_index.
    lv_index = lv_index + 1.
    APPEND ls_data TO lt_like_data[].
  ENDDO.

ENDFORM.


FORM create_alv_table TABLES gt_data
                      CHANGING go_salv_table TYPE REF TO cl_salv_table RAISING cx_salv_msg.

  cl_salv_table=>factory( IMPORTING r_salv_table = go_salv_table
                          CHANGING t_table = gt_data[]
                            ).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_go_salv_table  text
*----------------------------------------------------------------------*
FORM set_alv_functions  CHANGING p_go_salv_table TYPE REF TO cl_salv_table RAISING cx_salv_msg.

*  IF p_go_salv_table IS BOUND.
*    DATA: lo_salv_functions TYPE REF TO cl_salv_functions.
*    lo_salv_functions = p_go_salv_table->get_functions( ).
*    lo_salv_functions->set_all( abap_true ).
*  ELSE.
*    RETURN.
*  ENDIF.
  IF p_go_salv_table IS BOUND.
    p_go_salv_table->set_screen_status( pfstatus = 'SALV_STANDARD'
                                  report = sy-repid
                                  set_functions = p_go_salv_table->c_functions_all
                                   ).
  ELSE.
    RETURN.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMAT_COLUMNS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_go_salv_table  text
*----------------------------------------------------------------------*
FORM format_columns   TABLES p_gt_data
                      CHANGING p_go_salv_table TYPE REF TO cl_salv_table RAISING cx_salv_msg.

  IF ( p_go_salv_table IS BOUND ).
    INCLUDE <color>.

    DATA: lo_salv_columns_tab TYPE REF TO cl_salv_columns_table,
          lo_salv_column_tab  TYPE REF TO cl_salv_column_table,
          lo_salv_column      TYPE REF TO cl_salv_column,
          ls_color            TYPE lvc_s_colo,
          lt_scolor           TYPE lvc_t_scol,
          ls_scolor           TYPE lvc_s_scol,
          ls_data             TYPE gty_line_structure,
          lv_loop_count       TYPE i.


    lo_salv_columns_tab = p_go_salv_table->get_columns( ).
    lo_salv_columns_tab->set_optimize( abap_false ).

*    PERFORM set_tecnical_optimize USING lo_salv_columns_tab.

    LOOP AT p_gt_data INTO ls_data.
      lv_loop_count = lv_loop_count + 1.
      CASE ls_data-id.
        WHEN 5.
          ls_scolor-color-col = col_negative.
          ls_scolor-color-int = 0.
          ls_scolor-color-inv = 0.
          APPEND ls_scolor TO lt_scolor.
          CLEAR ls_scolor.
          ls_scolor-fname = 'MESSAGE'.
          ls_scolor-color-col = col_group.
          ls_scolor-color-int = 0.
          ls_scolor-color-inv = 0.
          APPEND ls_scolor TO lt_scolor.
          CLEAR ls_scolor.
      ENDCASE.
      ls_data-color = lt_scolor.
      MODIFY p_gt_data FROM ls_data.
      CLEAR ls_data.
      REFRESH lt_scolor.
    ENDLOOP.

    TRY.
        lo_salv_column = lo_salv_columns_tab->get_column( EXPORTING columnname = 'ID' ).
        lo_salv_column_tab ?= lo_salv_columns_tab->get_column( EXPORTING columnname = 'ID' ).
        ls_color-col = col_positive.
        lo_salv_column_tab->set_color( ls_color ).
        lo_salv_column->set_short_text( 'ID' ).
        lo_salv_column->set_medium_text( 'ID num' ).
        lo_salv_column->set_long_text( 'Identification number' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lo_salv_column = lo_salv_columns_tab->get_column( EXPORTING columnname = 'DATA' ).
        lo_salv_column->set_short_text( 'Data' ).
        lo_salv_column->set_medium_text( 'Data ini').
        lo_salv_column->set_long_text( 'Data inicial' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        lo_salv_column = lo_salv_columns_tab->get_column( EXPORTING columnname =  'TIME' ).
        lo_salv_column->set_short_text( 'Tempo' ).
        lo_salv_column->set_medium_text( 'Tempo act' ).
        lo_salv_column->set_long_text( 'Tempo actual' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lo_salv_column = lo_salv_columns_tab->get_column( EXPORTING columnname = 'MESSAGE' ).
        lo_salv_column->set_short_text( 'Mes' ).
        lo_salv_column->set_medium_text( 'Mensagem' ).
        lo_salv_column->set_long_text( 'Mensagem de impressão' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lo_salv_columns_tab->set_color_column( 'COLOR' ).
      CATCH cx_salv_data_error.
    ENDTRY.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_TECNICAL_OPTIMIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LO_SALV_COLUMNS_TAB  text
*----------------------------------------------------------------------*
FORM set_tecnical_optimize  USING  p_lo_salv_columns_tab TYPE REF TO cl_salv_columns_table.

  DATA: lo_column TYPE REF TO cl_salv_column.

  TRY.
      lo_column = p_lo_salv_columns_tab->get_column( 'COLOR' ).
      lo_column->set_technical( abap_false ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_go_salv_table  text
*----------------------------------------------------------------------*
FORM get_selections  CHANGING p_go_salv_table TYPE REF TO cl_salv_table RAISING cx_salv_msg.

  DATA: lo_salv_selections TYPE REF TO cl_salv_selections.

  lo_salv_selections = p_go_salv_table->get_selections( ).
  lo_salv_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ON_USER_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_go_salv_table  text
*----------------------------------------------------------------------*
FORM on_user_event  CHANGING p_go_salv_table TYPE REF TO cl_salv_table.

  DATA: lo_event_handler TYPE REF TO cl_salv_events_table,
        lo_user_event    TYPE REF TO lcl_user_event.

  lo_event_handler = p_go_salv_table->get_event( ).

  CREATE OBJECT lo_user_event.

  SET HANDLER lo_user_event->on_ucomn_event FOR lo_event_handler.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTIONS_FUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selections_fun  USING p_go_salv_table TYPE REF TO cl_salv_table.

  DATA: lo_selections_fun TYPE REF TO cl_salv_selections,
        lt_row            TYPE salv_t_row,
        lt_col            TYPE salv_t_column,
        ls_cell           TYPE salv_s_cell,
        lv_row            TYPE i,
        lv_col            TYPE lvc_fname,
        lv_row_string     TYPE char128,
        lv_col_string     TYPE char128,
        lv_row_info       TYPE char128,
        lv_col_info       TYPE char128.


  lo_selections_fun = p_go_salv_table->get_selections( ).
  lt_row = lo_selections_fun->get_selected_rows( ).
  lt_col = lo_selections_fun->get_selected_columns( ).
  ls_cell = lo_selections_fun->get_current_cell( ).

  CLEAR lv_row_info.
  LOOP AT lt_row INTO lv_row.
    WRITE lv_row TO lv_row_string LEFT-JUSTIFIED.
    CONCATENATE lv_row_info lv_row_string INTO lv_row_info SEPARATED BY space.
  ENDLOOP.

  IF ( sy-subrc EQ 0 ).
    MESSAGE i000(0k) WITH text-i02 lv_row_info.
  ENDIF.

  CLEAR lv_col_info.
  LOOP AT lt_col INTO lv_col.
    WRITE lv_col TO lv_col_string LEFT-JUSTIFIED.
    CONCATENATE lv_col_info lv_col_string INTO lv_col_info SEPARATED BY space.
  ENDLOOP.

  IF ( sy-subrc EQ 0 ).
    MESSAGE i000(0k) WITH text-i03 lv_col_info.
  ENDIF.

  IF ( ls_cell IS NOT INITIAL ).
    MESSAGE i000(0k) WITH text-i02 ls_cell-row text-i03 ls_cell-columnname.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&  Include           ZBC400_SALV_C01
*&---------------------------------------------------------------------*

CLASS lcl_user_event DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS: on_ucomn_event FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.
*      on_double_click FOR EVENT double_click OF cl_salv_events_table
*        IMPORTING row column.
*    on_link_click FOR EVENT on_link_click OF cl_salv_event_table
*      IMPORTING row column.

ENDCLASS.

CLASS lcl_user_event IMPLEMENTATION.

  METHOD on_ucomn_event.
    CASE e_salv_function.
      WHEN 'GET_SEL'.
        PERFORM get_selections_fun USING go_salv_table.
      WHEN 'SET_ROWS'.
        PERFORM set_selected_rows USING go_salv_table.
      WHEN 'SET_COLS'.
        PERFORM set_selected_cols USING go_salv_table.
      WHEN 'SET_CELL'.
        PERFORM set_selected_cell USING go_salv_table.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
*
*  METHOD on_double_click.
*
*  ENDMETHOD.
