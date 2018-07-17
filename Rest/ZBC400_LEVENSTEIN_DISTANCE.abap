*&---------------------------------------------------------------------*
*& Report  ZBC400_LEVENSTEIN_DISTANCE
*&
*&---------------------------------------------------------------------*
*& Permite calcular número de caracteres que são diferentes nas duas palavras
*&
*&---------------------------------------------------------------------*
REPORT zbc400_levenstein_distance.

CLASS lcl_levenstein DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: distance IMPORTING im_s          TYPE csequence
                                      im_t          TYPE csequence
                            RETURNING VALUE(re_val) TYPE i.
ENDCLASS.

CLASS lcl_levenstein IMPLEMENTATION.

  METHOD distance.
    DEFINE lm_get.
      lv_index = ( ( lv_tvar * ( lv_i + ( &2 ) ) ) + lv_j + ( &1 ) ) + 1.
      READ TABLE lt_data INTO re_val INDEX lv_index.
      ADD &3 TO re_val.
      INSERT re_val INTO TABLE lt_var.
    END-OF-DEFINITION.

    DATA: lt_data  TYPE STANDARD TABLE OF i,
          lt_var   TYPE SORTED TABLE OF i WITH UNIQUE KEY table_line,
          lv_cost  TYPE i,
          lv_i     TYPE i,
          lv_j     TYPE i,
          lv_index TYPE i,
          lv_tvar  TYPE i,
          lv_svar  TYPE i.

    lv_svar = strlen( im_s ).
    lv_tvar = strlen( im_t ).

    DO lv_svar TIMES.
      lv_i = sy-index - 1.
      DO lv_tvar TIMES.
        lv_j = sy-index - 1.
        IF lv_j EQ 0.
          re_val = lv_i.
        ELSEIF lv_i EQ 0.
          re_val = lv_j.
        ELSE.
          IF im_s+lv_i(1) = im_t+lv_j(1).
            lv_cost = 0.
          ELSE.
            lv_cost = 1.
          ENDIF.
          CLEAR lt_var.
          lm_get: -1 0 1,0 -1 1, -1 -1 lv_cost.
          READ TABLE lt_var INTO re_val INDEX 1.
        ENDIF.
        APPEND re_val TO lt_data.
      ENDDO.
    ENDDO.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  DATA:  lv_i TYPE i.

  lv_i = lcl_levenstein=>distance( im_s = 'siteen'
                                   im_t = 'kitten'
                                   ).

  cl_demo_output=>display( lv_i ).