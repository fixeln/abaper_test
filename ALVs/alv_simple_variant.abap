*&---------------------------------------------------------------------*
*& Report  ZBC400_ALV_SAVE_VARIANT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc400_alv_save_variant.

DATA: gs_layout_key TYPE salv_s_layout_key,
      go_alv_grid   TYPE REF TO cl_salv_table.


SELECT * FROM sflight INTO TABLE @DATA(gt_sflight).

TRY.
    cl_salv_table=>factory( IMPORTING r_salv_table = go_alv_grid
                            CHANGING  t_table = gt_sflight
                                      ).
  CATCH cx_salv_msg.
ENDTRY.


go_alv_grid->get_functions( )->set_all( abap_true ).
gs_layout_key-report = sy-repid.
go_alv_grid->get_layout( )->set_key( gs_layout_key ).
go_alv_grid->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).

go_alv_grid->display( ).
