*&---------------------------------------------------------------------*
*& Report  ZFILE_CREATE_VOL2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zfile_create_vol2.

CLASS lcl_file_create DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      create_file IMPORTING im_file_name TYPE filename-fileintern.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_structure,
             id_number  TYPE numc4,
             first_name TYPE ad_namefir,
             last_name  TYPE ad_namelas,
           END OF ty_structure.
ENDCLASS.

CLASS lcl_file_create IMPLEMENTATION.
  METHOD create_file.
    DATA: lv_dataset TYPE string,
          lv_message TYPE string,
          ls_record  TYPE ty_structure.

    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = im_file_name
      IMPORTING
        file_name        = lv_dataset
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    IF sy-subrc NE 0.
      MESSAGE 'Nome lógico do ficheiro invalido.' TYPE 'I'.
      RETURN.
    ENDIF.

    OPEN DATASET lv_dataset FOR OUTPUT IN TEXT MODE ENCODING UTF-8 WITH BYTE-ORDER
    MARK WITH SMART LINEFEED MESSAGE lv_message.
    IF sy-subrc NE 0.
      MESSAGE lv_message TYPE 'I'.
      RETURN.
    ENDIF.

    ls_record-id_number = '0001'.
    ls_record-first_name = 'Jojo'.
    ls_record-last_name = 'Smitha'.
    TRANSFER ls_record TO lv_dataset.

    ls_record-id_number = '0050'.
    ls_record-first_name = 'Alex'.
    ls_record-last_name = 'White'.
    TRANSFER ls_record TO lv_dataset.

    CLOSE DATASET lv_dataset.

  ENDMETHOD.
ENDCLASS.

PARAMETERS: p_file TYPE filename-fileintern DEFAULT 'ZTEST_FILE' OBLIGATORY.

START-OF-SELECTION.
  CALL METHOD lcl_file_create=>create_file( p_file ).