*&---------------------------------------------------------------------*
*& Report  ZBC400_09_TRANSPOSE_ALV
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc400_09_transpose_alv.

START-OF-SELECTION.
* test data
  DATA: lt_rows TYPE zif_bc400_transposer=>tt_rows.
  DATA: lt_fields TYPE zif_bc400_transposer=>tt_fields.
  DATA: ls_fields LIKE LINE OF lt_fields.
  DATA: ls_rows LIKE LINE OF lt_rows.
  ls_rows-row   = 1.
  ls_rows-field = 'MATNR'.
  ls_rows-value = '1-234-123'.
  APPEND ls_rows TO lt_rows.    CLEAR  ls_rows.
  ls_rows-row   = 1.
  ls_rows-field = 'MAKTX'.
  ls_rows-value = 'Test Material 1'.
  APPEND ls_rows TO lt_rows.    CLEAR  ls_rows.
  ls_rows-row   = 1.
  ls_rows-field = 'AMOUNT'.
  ls_rows-dename = 'DMBTR'.
  ls_rows-value = '123.45'.
  APPEND ls_rows TO lt_rows.    CLEAR  ls_rows.
  ls_rows-row   = 2.
  ls_rows-field = 'MATNR'.
  ls_rows-value = '9-123-123'.
  APPEND ls_rows TO lt_rows.    CLEAR  ls_rows.
  ls_rows-row   = 2.
  ls_rows-field = 'MAKTX'.
  ls_rows-value = 'Assembly 123'.
  APPEND ls_rows TO lt_rows.    CLEAR  ls_rows.


*  ls_fields-field = 'MATNR'.
*  ls_fields-dename = 'MATRN'.
*  APPEND ls_fields TO lt_fields.

* Transpose the data to columns
  DATA: lo_col_transposer TYPE REF TO zif_bc400_transposer.
  DATA: lo_col_data   TYPE REF TO data.
  FIELD-SYMBOLS:<f_output> TYPE STANDARD TABLE.
  CREATE OBJECT lo_col_transposer
    TYPE
    zcl_bc400_trans_to_column
    EXPORTING
      it_data = lt_rows.
  lo_col_data = lo_col_transposer->transpose( ).
  ASSIGN lo_col_data->* TO <f_output>.

  DATA: o_salv TYPE REF TO cl_salv_table.
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = o_salv
        CHANGING
          t_table      = <f_output>.
      o_salv->display( ).
    CATCH cx_salv_msg .
  ENDTRY.

*  Transpose to rows
  DATA: lo_row_transposer TYPE REF TO zif_bc400_transposer.
  DATA: lo_row_data TYPE REF TO data.
  FIELD-SYMBOLS: <lfs_row_tab> TYPE zif_bc400_transposer=>tt_rows.
  CREATE OBJECT lo_row_transposer
    TYPE
    zcl_bc400_trans_to_row
    EXPORTING
      it_data = <f_output>.
  lo_row_data = lo_row_transposer->transpose( ).
  ASSIGN lo_row_data->* TO <lfs_row_tab>.

  DATA: o_salv2 TYPE REF TO cl_salv_table.
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = o_salv2
        CHANGING
          t_table      = <lfs_row_tab>.
      o_salv2->display( ).
    CATCH cx_salv_msg .
  ENDTRY.