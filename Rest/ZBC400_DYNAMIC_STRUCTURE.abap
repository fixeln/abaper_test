*&---------------------------------------------------------------------*
*& Report  ZDYNAMIC_STRUCTURE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zdynamic_structure.

DATA: gt_data TYPE REF TO data.

PERFORM initialize_table USING 5 5
                         CHANGING gt_data.

*&---------------------------------------------------------------------*
*&      Form  INITIALIZE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5      text
*      -->P_5      text
*      <--P_GT_DATA  text
*----------------------------------------------------------------------*
FORM initialize_table  USING  width TYPE i
                              height TYPE i
                       CHANGING board TYPE REF TO data.
  DATA: lt_dynamic TYPE REF TO data,
        ls_dynamic TYPE REF TO data,
        lv_index   TYPE i,
        lt_columns TYPE lvc_t_fcat,
        ls_column  LIKE LINE OF lt_columns.

  FIELD-SYMBOLS: <fs_tabela> TYPE ANY TABLE,
                 <fs_vetor>  TYPE any.
  IF ( width < 1 OR height < 1 ).
    RETURN.
  ENDIF.

  DO width TIMES.
    ls_column-fieldname = '_' && lv_index.
    ls_column-datatype = cl_abap_structdescr=>typekind_char.
    ls_column-inttype = cl_abap_structdescr=>typekind_char.
    ls_column-intlen = 1.
    ls_column-decimals = 0.
    lv_index = lv_index + 1.
    APPEND ls_column TO lt_columns.
  ENDDO.

  cl_alv_table_create=>create_dynamic_table( EXPORTING it_fieldcatalog = lt_columns
    IMPORTING ep_table = lt_dynamic ).

  ASSIGN lt_dynamic->* TO <fs_tabela>.
  CREATE DATA ls_dynamic LIKE LINE OF <fs_tabela>.

  ASSIGN ls_dynamic->* TO <fs_vetor>.
  DO height TIMES.
    INSERT <fs_vetor> INTO TABLE <fs_tabela>.
  ENDDO.

cl_demo_output=>display( <fs_tabela> ).
ENDFORM.