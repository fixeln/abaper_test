*&---------------------------------------------------------------------*
*& Report  ZDYNAMIC_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zdynamic_program.

START-OF-SELECTION.
  DATA: lt_source_code TYPE TABLE OF string.

*Build the source code for soubroutine pool
  lt_source_code = VALUE #(
  ( `PROGRAM zsoub_poolprog.` )
  ( `FORM dynamic_soubpool.` )
  ( `WRITE: / 'Geraste código dinâmico...'.` )
  ( `ENDFORM.` ) ).

*Generate the soubroutine pool
  GENERATE SUBROUTINE POOL lt_source_code NAME DATA(lv_program).
  IF sy-subrc EQ 0.
    WRITE: / 'Programa gerado: ',lv_program.
  ENDIF.

*Call the dynamically generated soubroutine.
  WRITE: / 'outro código estático ...'.
  PERFORM dynamic_soubpool IN PROGRAM (lv_program) IF FOUND.
  WRITE: / 'outro código estático2 ...'.