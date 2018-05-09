*&---------------------------------------------------------------------*
*& Report  ZBC400_FROM_EXCEL_TO_SAP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc400_from_excel_to_sap NO STANDARD PAGE HEADING.

DATA: gt_tab1 LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF gty_record,
         name1 LIKE gt_tab1-value,
         name2 LIKE gt_tab1-value,
         age   LIKE gt_tab1-value,
       END OF gty_record.

DATA: gt_record TYPE TABLE OF gty_record INITIAL SIZE 0,
      gs_record LIKE LINE OF gt_record,
      gv_row  TYPE i.

PARAMETERS: p_file LIKE rlgrap-filename.

START-OF-SELECTION.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '3'
      i_end_row               = '3'
    TABLES
      intern                  = gt_tab1
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE e001(zzz) WITH text-001.
  ENDIF.

  SORT gt_tab1 BY row col.
  READ TABLE gt_tab1 INDEX 1.
  gv_row = gt_tab1-row.

  LOOP AT gt_tab1.
    IF gt_tab1-row NE gv_row.
      APPEND gs_record TO gt_record.
      CLEAR gs_record.
      gv_row = gt_tab1-row.
    ENDIF.

    CASE gt_tab1-col.
      WHEN '0001'.
        gs_record-name1 = gt_tab1-value.
      WHEN '0002'.
        gs_record-name2 = gt_tab1-value.
      WHEN '0003'.
        gs_record-age = gt_tab1-value.
    ENDCASE.
  ENDLOOP.

  APPEND gs_record TO gt_record.

  LOOP AT gt_record INTO gs_record.
    WRITE: / sy-vline,
    (10) gs_record-name1, sy-vline,
    (10) gs_record-name2, sy-vline,
    (10) gs_record-age, sy-vline.
  ENDLOOP.
