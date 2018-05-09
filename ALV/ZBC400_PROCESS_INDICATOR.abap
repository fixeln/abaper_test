*&---------------------------------------------------------------------*
*& Report  ZBC400_PROCESS_INDICATOR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc400_process_indicator.

DATA: go_progress TYPE REF TO cl_akb_progress_indicator.

CONSTANTS: co_max_times TYPE i VALUE 100000.

INITIALIZATION.

  IF go_progress IS NOT BOUND.
    go_progress = cl_akb_progress_indicator=>get_instance( ).
  ENDIF.

START-OF-SELECTION.

  WRITE: / 'TEST'.

  DO co_max_times TIMES.
    go_progress->display( EXPORTING total = co_max_times
                                    processed = sy-index
                                    message = 'Processing {0}'
                                    ).

  ENDDO.
