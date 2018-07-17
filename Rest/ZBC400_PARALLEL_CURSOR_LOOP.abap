REPORT zbc400_parallel_cursor_loop.

DATA: gt_vbak TYPE STANDARD TABLE OF vbak,
      gt_vbap TYPE STANDARD TABLE OF vbap,
      gs_vbak LIKE LINE OF gt_vbak,
      gs_vbap LIKE LINE OF gt_vbap,
      gt_nums TYPE STANDARD TABLE OF i.

DO 10 TIMES.
  gs_vbak-vbeln = sy-tabix.
  APPEND gs_vbak TO gt_vbak.
ENDDO.

gs_vbap-vbeln = 3.
gs_vbap-posnr = '001'.
APPEND gs_vbap TO gt_vbap.
CLEAR gs_vbap.
gs_vbap-vbeln = 3.
gs_vbap-posnr = '002'.
APPEND gs_vbap TO gt_vbap.
DO 10 TIMES.
  APPEND sy-tabix TO gt_nums.
ENDDO.

FIELD-SYMBOLS: <gfs_vbak> LIKE LINE OF gt_vbak,
               <gfs_vbap> LIKE LINE OF gt_vbap.

SORT: gt_vbak BY vbeln,
      gt_vbap BY vbeln.
LOOP AT gt_vbak ASSIGNING <gfs_vbak>.
  READ TABLE gt_vbap TRANSPORTING NO FIELDS WITH KEY vbeln = <gfs_vbak>-vbeln BINARY SEARCH.
  IF sy-subrc EQ 0.
    LOOP AT gt_vbap FROM sy-tabix ASSIGNING <gfs_vbap>.
      IF <gfs_vbap>-vbeln NE <gfs_vbak>-vbeln.
        EXIT.
      ENDIF.
      READ TABLE gt_nums TRANSPORTING NO FIELDS WITH KEY table_line = '7'.
    ENDLOOP.
  ENDIF.
ENDLOOP.