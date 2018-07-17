CLASS zcl_bc400_trans_to_column DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: zif_bc400_transposer.
    METHODS constructor
      IMPORTING
        !it_data   TYPE zif_bc400_transposer=>tt_rows
        !it_fields TYPE zif_bc400_transposer=>tt_fields OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.

    ALIASES t_data
      FOR zif_bc400_transposer~t_data .
    ALIASES t_fields
      FOR zif_bc400_transposer~t_fields .
    ALIASES go_table_data FOR zif_bc400_transposer~go_table_data.
    ALIASES go_wa_data FOR zif_bc400_transposer~go_wa_data.
ENDCLASS.



CLASS ZCL_BC400_TRANS_TO_COLUMN IMPLEMENTATION.


  METHOD constructor.

    t_data = it_data.
    t_fields = it_fields.

  ENDMETHOD.


  METHOD zif_bc400_transposer~collect_fields.

    CHECK t_fields IS INITIAL.
    DATA: lv_first_field TYPE char30,
          ls_data        LIKE LINE OF me->t_data,
          ls_field       LIKE LINE OF me->t_fields.

    LOOP AT me->t_data INTO ls_data.

      IF lv_first_field = ls_data-field.
        EXIT.
      ENDIF.
      IF lv_first_field IS INITIAL.
        lv_first_field = ls_data-field.
      ENDIF.
      MOVE-CORRESPONDING ls_data TO ls_field.
      APPEND ls_field TO me->t_fields.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_bc400_transposer~create_dynamic_table.

    DATA: lo_struct   TYPE REF TO cl_abap_structdescr,
          lo_element  TYPE REF TO cl_abap_elemdescr,
          lo_new_type TYPE REF TO cl_abap_structdescr,
          lo_new_tab  TYPE REF TO cl_abap_tabledescr,
          lt_comp     TYPE cl_abap_structdescr=>component_table,
          lt_tot_comp TYPE cl_abap_structdescr=>component_table,
          lw_comp     LIKE LINE OF lt_comp.

    DATA: ls_field LIKE LINE OF me->t_fields,
          lv_name  TYPE string.

    LOOP AT me->t_fields INTO ls_field.

      IF ls_field-dename IS INITIAL.
        lv_name = ls_field-field.
      ELSE.
        lv_name = ls_field-dename.
      ENDIF.

      lo_element ?= cl_abap_elemdescr=>describe_by_name( lv_name ).

      lw_comp-name = ls_field-field.
      lw_comp-type = lo_element.
      APPEND lw_comp TO lt_tot_comp.
      CLEAR lw_comp.

    ENDLOOP.

    lo_new_type = cl_abap_structdescr=>create( lt_tot_comp ).
    lo_new_tab = cl_abap_tabledescr=>create( p_line_type = lo_new_type
                                             p_table_kind = cl_abap_tabledescr=>tablekind_std
                                             p_unique = abap_false ).
    CREATE DATA go_table_data TYPE HANDLE lo_new_tab.
    CREATE DATA go_wa_data TYPE HANDLE lo_new_type.

  ENDMETHOD.


  METHOD zif_bc400_transposer~transpose.

    FIELD-SYMBOLS: <fs_tab>   TYPE STANDARD TABLE,
                   <fs_wa>    TYPE any,
                   <fs_field> TYPE any.
    DATA: ls_data LIKE LINE OF me->t_data.


    me->zif_bc400_transposer~collect_fields( ).
    me->zif_bc400_transposer~create_dynamic_table( ).

    ASSIGN go_table_data->* TO <fs_tab>.
    ASSIGN go_wa_data->* TO <fs_wa>.

    LOOP AT me->t_data INTO ls_data.
      ASSIGN COMPONENT ls_data-field OF STRUCTURE <fs_wa> TO <fs_field>.
      IF sy-subrc EQ 0.
        <fs_field> = ls_data-value.
      ENDIF.
      AT END OF row.
        APPEND <fs_wa> TO <fs_tab>.
        CLEAR <fs_wa>.
      ENDAT.
    ENDLOOP.

    im_data = go_table_data.
  ENDMETHOD.
ENDCLASS.