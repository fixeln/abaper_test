*&---------------------------------------------------------------------*
*& Report  ZBC400_VALID_EMAIL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbc400_valid_email.

DATA: go_regex   TYPE REF TO cl_abap_regex,
      go_matcher TYPE REF TO cl_abap_matcher.


PARAMETERS: p_email TYPE c LENGTH 254.

START-OF-SELECTION.

  CREATE OBJECT go_regex
    EXPORTING
      pattern     = '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b'
      ignore_case = abap_true.

  go_matcher = go_regex->create_matcher( EXPORTING text = p_email ).

  IF go_matcher->match( ) EQ 'X'.
    WRITE: 'Email', p_email, 'é válido'.
  ELSE.
    WRITE: 'Email',p_email, 'não é válido'.
  ENDIF.