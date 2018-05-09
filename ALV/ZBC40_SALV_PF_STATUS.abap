*&---------------------------------------------------------------------*
*& Report  ZBC40_SALV_PF_STATUS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc40_salv_pf_status.


DATA: go_salv_table TYPE REF TO cl_salv_table,
      go_function   TYPE REF TO cl_salv_functions,
      go_cx_msg     TYPE REF TO cx_salv_msg,
      gv_salv_msg   TYPE string.


PARAMETERS: p_dummy.

INITIALIZATION.

  SELECT * FROM spfli INTO TABLE @DATA(gt_spfli).

  TRY.
      cl_salv_table=>factory( EXPORTING r_container = cl_gui_container=>screen0
                              IMPORTING r_salv_table = go_salv_table
                              CHANGING  t_table = gt_spfli
                             ).
    CATCH cx_salv_msg INTO go_cx_msg.
      MOVE go_cx_msg->get_text( ) TO gv_salv_msg.
      MESSAGE gv_salv_msg TYPE 'E'.
  ENDTRY.

  go_function = go_salv_table->get_functions( ).

  CHECK go_function IS BOUND.
  go_function->set_all( abap_true ).
  go_function->add_function( EXPORTING name = 'FC_1'
                                       icon = '@01@'
                                       text = 'button'
                                       tooltip = 'pop_up'
                                       position = if_salv_c_function_position=>right_of_salv_functions
                                       ).

  go_salv_table->display( ).
